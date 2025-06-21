#!/bin/bash

# 🖥️ RUNPOD HARDWARE INVENTORY & MONITORING
# Complete overview of running pods, hardware specs, and costs

echo "🖥️ RUNPOD HARDWARE INVENTORY"
echo "============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_cost() {
    echo -e "${RED}$1${NC}"
}

print_hardware() {
    echo -e "${GREEN}$1${NC}"
}

print_status() {
    echo -e "${YELLOW}$1${NC}"
}

# Get current pod list
print_header "📋 CURRENT POD STATUS"
echo "======================"
runpod pod list

echo ""
print_header "🔍 DETAILED HARDWARE ANALYSIS"
echo "=============================="

# Parse pod list and analyze each running pod
RUNNING_PODS=$(runpod pod list | grep "RUNNING" | awk '{print $1 ":" $3 ":" $7}')

if [[ -z "$RUNNING_PODS" ]]; then
    print_status "No running pods found"
    exit 0
fi

TOTAL_COST_PER_HOUR=0
POD_COUNT=0

echo ""
print_hardware "🎯 RUNNING POD BREAKDOWN:"
echo "=========================="

while IFS=':' read -r pod_id name image; do
    POD_COUNT=$((POD_COUNT + 1))
    
    echo ""
    print_hardware "Pod #$POD_COUNT: $name"
    echo "  ID: $pod_id"
    echo "  Image: $image"
    
    # Determine GPU type and cost based on pod name/image
    if [[ "$name" == *"michael"* ]] || [[ "$name" == *"dwight"* ]]; then
        GPU_TYPE="RTX A5000"
        COST_PER_HOUR=0.50
        VRAM="24GB"
        CUDA_CORES="8192"
    elif [[ "$name" == *"creed"* ]] || [[ "$name" == *"erin"* ]] || [[ "$name" == *"toby"* ]]; then
        GPU_TYPE="RTX A4000"
        COST_PER_HOUR=0.35
        VRAM="16GB" 
        CUDA_CORES="6144"
    elif [[ "$image" == *"ollama"* ]] || [[ "$name" == *"CUDA"* ]]; then
        GPU_TYPE="Unknown (likely A4000/A5000)"
        COST_PER_HOUR=0.40
        VRAM="16-24GB"
        CUDA_CORES="6144-8192"
    else
        GPU_TYPE="Unknown"
        COST_PER_HOUR=0.40
        VRAM="Unknown"
        CUDA_CORES="Unknown"
    fi
    
    print_hardware "  🖥️  GPU: $GPU_TYPE"
    print_hardware "  💾 VRAM: $VRAM"
    print_hardware "  ⚡ CUDA Cores: $CUDA_CORES"
    print_cost "  💰 Cost: \$${COST_PER_HOUR}/hour"
    
    TOTAL_COST_PER_HOUR=$(echo "$TOTAL_COST_PER_HOUR + $COST_PER_HOUR" | bc -l)
    
    # Check if it's an Office LoRA pod
    if [[ "$name" == *"office"* ]]; then
        CHARACTER=$(echo "$name" | sed 's/office-//g' | sed 's/-lora//g')
        print_status "  🎭 Office Character: ${CHARACTER^}"
        
        # Get training data info
        case $CHARACTER in
            "michael")
                print_status "  📊 Training Examples: 24,351"
                print_status "  🎯 Priority: HIGH"
                ;;
            "dwight")
                print_status "  📊 Training Examples: 14,983"
                print_status "  🎯 Priority: HIGH"
                ;;
            "creed")
                print_status "  📊 Training Examples: 905"
                print_status "  🎯 Priority: MEDIUM"
                ;;
            "erin")
                print_status "  📊 Training Examples: 2,919"
                print_status "  🎯 Priority: MEDIUM"
                ;;
            "toby")
                print_status "  📊 Training Examples: 1,861"
                print_status "  🎯 Priority: MEDIUM"
                ;;
        esac
    fi
    
done <<< "$RUNNING_PODS"

echo ""
print_header "💰 COST ANALYSIS"
echo "================="
printf "Total pods running: %d\n" $POD_COUNT
printf "Cost per hour: \$%.2f\n" $TOTAL_COST_PER_HOUR
printf "Cost per day (24h): \$%.2f\n" $(echo "$TOTAL_COST_PER_HOUR * 24" | bc -l)
printf "Estimated training cost (1h): \$%.2f\n" $TOTAL_COST_PER_HOUR

echo ""
print_header "⚡ HARDWARE SUMMARY"
echo "==================="

# Count GPU types
A5000_COUNT=$(echo "$RUNNING_PODS" | grep -E "(michael|dwight)" | wc -l)
A4000_COUNT=$(echo "$RUNNING_PODS" | grep -E "(creed|erin|toby)" | wc -l)
OTHER_COUNT=$((POD_COUNT - A5000_COUNT - A4000_COUNT))

if [[ $A5000_COUNT -gt 0 ]]; then
    print_hardware "RTX A5000 pods: $A5000_COUNT"
    print_hardware "  └─ Total VRAM: $((A5000_COUNT * 24))GB"
    print_hardware "  └─ Total CUDA Cores: $((A5000_COUNT * 8192))"
fi

if [[ $A4000_COUNT -gt 0 ]]; then
    print_hardware "RTX A4000 pods: $A4000_COUNT"
    print_hardware "  └─ Total VRAM: $((A4000_COUNT * 16))GB"
    print_hardware "  └─ Total CUDA Cores: $((A4000_COUNT * 6144))"
fi

if [[ $OTHER_COUNT -gt 0 ]]; then
    print_hardware "Other/Unknown pods: $OTHER_COUNT"
fi

TOTAL_VRAM=$((A5000_COUNT * 24 + A4000_COUNT * 16))
TOTAL_CUDA_CORES=$((A5000_COUNT * 8192 + A4000_COUNT * 6144))

echo ""
print_hardware "🎯 TOTAL COMPUTE POWER:"
print_hardware "  💾 Combined VRAM: ${TOTAL_VRAM}GB"
print_hardware "  ⚡ Combined CUDA Cores: ${TOTAL_CUDA_CORES}"

echo ""
print_header "🎭 OFFICE LORA STATUS"
echo "====================="

OFFICE_PODS=$(echo "$RUNNING_PODS" | grep "office")
if [[ -n "$OFFICE_PODS" ]]; then
    OFFICE_COUNT=$(echo "$OFFICE_PODS" | wc -l)
    print_status "Office LoRA pods active: $OFFICE_COUNT/5"
    
    echo ""
    print_status "Characters ready for training:"
    echo "$OFFICE_PODS" | while IFS=':' read -r pod_id name image; do
        CHARACTER=$(echo "$name" | sed 's/office-//g' | sed 's/-lora//g')
        print_status "  ✅ ${CHARACTER^}: $pod_id"
    done
    
    echo ""
    print_status "🚀 Ready to start Office LoRA training!"
    print_status "💡 Use: runpod pod connect <pod_id> to begin"
else
    print_status "❌ No Office LoRA pods found"
fi

echo ""
print_header "🛠️ QUICK ACTIONS"
echo "================="
echo "Monitor pods: watch -n 30 'runpod pod list'"
echo "Connect to pod: runpod pod connect <pod_id>"
echo "Check this inventory: ./pod_inventory.sh"
echo ""
echo "🔗 Web console: https://runpod.io/console/pods"