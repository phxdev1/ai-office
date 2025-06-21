#!/bin/bash

# 🎬 THE OFFICE LORA TRAINING - ONE SCRIPT TO RULE THEM ALL
# Complete deployment script for all 5 character LoRAs

set -e  # Exit on any error

echo "🎬 THE OFFICE LORA TRAINING DEPLOYMENT"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Load environment variables from .env file
if [[ -f .env ]]; then
    print_status "Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
fi

# Check if runpod CLI is installed
if ! command -v runpod &> /dev/null; then
    print_error "RunPod CLI not found. Install with: pip install runpod"
    exit 1
fi

# Check if API key is set
if [[ -z "$RUNPOD_API_KEY" ]]; then
    print_error "RUNPOD_API_KEY not found. Make sure it's in your .env file"
    exit 1
fi

print_success "RunPod CLI configured with API key"

print_status "Checking for required training data files..."
REQUIRED_FILES=(
    "autotrain_data/michael_autotrain.jsonl"
    "autotrain_data/dwight_autotrain.jsonl" 
    "autotrain_data/creed_autotrain.jsonl"
    "autotrain_data/erin_autotrain.jsonl"
    "autotrain_data/toby_autotrain.jsonl"
    "runpod_michael_training.sh"
    "runpod_dwight_training.sh"
    "runpod_creed_training.sh"
    "runpod_erin_training.sh"
    "runpod_toby_training.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        print_error "Required file missing: $file"
        exit 1
    fi
done
print_success "All required files found!"

# Create lora_models directory
mkdir -p lora_models

print_status "Step 1: Creating all RunPod instances..."

# Create pods and capture their IDs
declare -A POD_IDS

CHARACTERS=("michael" "dwight" "creed" "erin" "toby")
GPU_TYPES=("RTX A5000" "RTX A5000" "RTX A4000" "RTX A4000" "RTX A4000")

for i in "${!CHARACTERS[@]}"; do
    character="${CHARACTERS[$i]}"
    gpu_type="${GPU_TYPES[$i]}"
    
    print_status "Creating $character pod with $gpu_type..."
    
    # Create pod with timeout and better error handling (auto-confirm with yes)
    POD_OUTPUT=$(timeout 60 bash -c "echo 'y' | runpod pod create 'office-$character-lora' \
        --image 'runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04' \
        --gpu-type '$gpu_type' \
        --gpu-count 1 \
        --support-public-ip true" 2>&1)
    
    # Extract pod ID from JSON output
    if echo "$POD_OUTPUT" | jq -e . >/dev/null 2>&1; then
        POD_ID=$(echo "$POD_OUTPUT" | jq -r '.id // empty')
    else
        # Fallback: extract from text output
        POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | head -1)
    fi
    
    if [[ -n "$POD_ID" && "$POD_ID" != "null" ]]; then
        POD_IDS["$character"]="$POD_ID"
        print_success "$character pod created: $POD_ID"
    else
        print_error "Failed to create $character pod"
        print_error "Output: $POD_OUTPUT"
        
        # Continue with other pods instead of exiting
        print_warning "Continuing with remaining pods..."
        continue
    fi
    
    # Small delay between pod creations
    sleep 2
done

# Check if any pods were created successfully
if [[ ${#POD_IDS[@]} -eq 0 ]]; then
    print_error "No pods were created successfully. Exiting."
    exit 1
fi

print_success "Created ${#POD_IDS[@]} pods successfully"
print_status "Waiting 30 seconds for pods to initialize..."
sleep 30

print_status "Step 2: Uploading training data to ${#POD_IDS[@]} pods..."

for character in "${CHARACTERS[@]}"; do
    # Skip if pod wasn't created for this character
    if [[ -z "${POD_IDS[$character]}" ]]; then
        print_warning "Skipping $character - pod not created"
        continue
    fi
    
    pod_id="${POD_IDS[$character]}"
    
    print_status "Uploading data to $character pod ($pod_id)..."
    
    # Upload training data
    runpod send "autotrain_data/${character}_autotrain.jsonl" "$pod_id:/workspace/" || {
        print_error "Failed to upload training data for $character"
        continue
    }
    
    # Upload training script
    runpod send "runpod_${character}_training.sh" "$pod_id:/workspace/" || {
        print_error "Failed to upload training script for $character"
        continue
    }
    
    print_success "$character data uploaded"
done

print_status "Step 3: Starting all training jobs..."

# Start training on all pods in parallel
for character in "${CHARACTERS[@]}"; do
    # Skip if pod wasn't created for this character
    if [[ -z "${POD_IDS[$character]}" ]]; then
        print_warning "Skipping $character training - pod not created"
        continue
    fi
    
    pod_id="${POD_IDS[$character]}"
    
    print_status "Starting training for $character on pod $pod_id..."
    
    # Make script executable and start training in background
    runpod exec "$pod_id" "chmod +x /workspace/runpod_${character}_training.sh" || {
        print_error "Failed to make script executable for $character"
        continue
    }
    
    runpod exec "$pod_id" "cd /workspace && nohup bash runpod_${character}_training.sh > training.log 2>&1 &" || {
        print_error "Failed to start training for $character"
        continue
    }
    
    print_success "$character training started"
done

print_success "All training jobs started!"

echo ""
print_status "🎯 TRAINING STATUS MONITORING"
echo "=============================="
echo ""
echo "Monitor training progress with:"
for character in "${CHARACTERS[@]}"; do
    if [[ -n "${POD_IDS[$character]}" ]]; then
        pod_id="${POD_IDS[$character]}"
        echo "runpod exec $pod_id 'tail -f /workspace/training.log'"
    fi
done

echo ""
print_status "📥 DOWNLOAD COMMANDS (run when training completes)"
echo "=================================================="
echo ""
echo "# Download all trained models:"
for character in "${CHARACTERS[@]}"; do
    if [[ -n "${POD_IDS[$character]}" ]]; then
        pod_id="${POD_IDS[$character]}"
        echo "runpod receive $pod_id:/workspace/${character}_lora.tar.gz ./lora_models/"
    fi
done

echo ""
echo "# Extract and organize models:"
echo "cd lora_models"
for character in "${CHARACTERS[@]}"; do
    echo "tar -xzf ${character}_lora.tar.gz && mv final_model ${character}_lora"
done
echo "cd .."

echo ""
print_status "🎉 FINAL INTEGRATION"
echo "===================="
echo ""
echo "Once all models are downloaded and extracted:"
echo "python lora_balls_integration.py"

echo ""
print_status "💰 ESTIMATED COSTS"
echo "=================="
echo "Michael (RTX A5000): ~\$0.50/hr"
echo "Dwight (RTX A5000): ~\$0.50/hr" 
echo "Creed (RTX A4000): ~\$0.35/hr"
echo "Erin (RTX A4000): ~\$0.35/hr"
echo "Toby (RTX A4000): ~\$0.35/hr"
echo "Total: ~\$2.05 for ~1 hour"

echo ""
print_success "🚀 Office LoRA army deployment complete!"
print_status "Training will take approximately 1 hour. Check logs for progress."

# Save pod IDs for reference
echo "# Pod IDs for reference:" > pod_ids.txt
for character in "${CHARACTERS[@]}"; do
    if [[ -n "${POD_IDS[$character]}" ]]; then
        echo "$character: ${POD_IDS[$character]}" >> pod_ids.txt
    fi
done

print_success "Pod IDs saved to pod_ids.txt"