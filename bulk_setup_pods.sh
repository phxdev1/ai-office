#!/bin/bash

# 🚀 BULK POD SETUP SCRIPT
# Automatically set up training on all character pods

echo "🎭 BULK OFFICE LORA TRAINING SETUP"
echo "=================================="
echo ""

# Pod configurations
declare -A PODS=(
    ["michael"]="qif3gszlnqrmt4"
    ["dwight"]="qnk50v3f4necn8" 
    ["creed"]="d2r106j5n3btcc"
    ["erin"]="t61imb6b25bfk4"
    ["toby"]="og6vk9s808c1b6"
)

# Create startup script for each character
create_startup_script() {
    local character=$1
    local pod_id=$2
    
    echo "🔧 Setting up $character training on pod $pod_id..."
    
    # Create the startup script content
    cat > "startup_${character}.sh" << EOF
#!/bin/bash
echo "🎭 Starting $character LoRA training at \$(date)"
cd /workspace

# Clone repo if needed
if [[ ! -d "ai-office" ]]; then
    git clone https://github.com/phxdev1/ai-office.git
fi

cd ai-office

# Install dependencies
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

# Start training with logging
python train_character_lora.py --character $character > /workspace/${character}_training.log 2>&1

echo "✅ $character training completed at \$(date)" >> /workspace/${character}_training.log
EOF

    chmod +x "startup_${character}.sh"
    echo "✅ Created startup_${character}.sh"
}

# Create all startup scripts
for character in "${!PODS[@]}"; do
    create_startup_script "$character" "${PODS[$character]}"
done

echo ""
echo "📋 MANUAL DEPLOYMENT INSTRUCTIONS:"
echo "=================================="
echo ""

for character in "${!PODS[@]}"; do
    pod_id="${PODS[$character]}"
    echo "🎭 $character (Pod: $pod_id):"
    echo "   1. runpod pod connect $pod_id"
    echo "   2. Upload startup_${character}.sh to /workspace/"
    echo "   3. chmod +x /workspace/startup_${character}.sh"
    echo "   4. nohup /workspace/startup_${character}.sh &"
    echo "   5. exit"
    echo ""
done

echo "💡 MONITORING:"
echo "=============="
echo "Connect to any pod and run:"
echo "   tail -f /workspace/*_training.log"
echo ""

echo "⏱️  EXPECTED TIMELINE:"
echo "====================="
echo "   Setup: 5 minutes per pod"
echo "   Training: 30-45 minutes (parallel)"
echo "   Total: ~50 minutes"
echo ""

echo "💰 COST ESTIMATE: ~\$2.50 total"
echo ""
echo "🔥 Warning: Datacenter temperature will increase by 3°F"