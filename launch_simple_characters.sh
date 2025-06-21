#!/bin/bash

# 🎭 LAUNCH REMAINING OFFICE CHARACTERS (SIMPLE VERSION)
# Create pods for Dwight, Creed, Erin, Toby

echo "🎭 LAUNCHING REMAINING OFFICE CHARACTERS"
echo "======================================="
echo ""

# Characters to launch (Michael already running)
CHARACTERS=("dwight" "creed" "erin" "toby")

for character in "${CHARACTERS[@]}"; do
    echo "🚀 Creating pod for $character..."
    
    POD_OUTPUT=$(echo 'y' | runpod pod create "${character}-lora-training" \
        --image "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04" \
        --gpu-type "RTX A5000" \
        --gpu-count 1 \
        --support-public-ip true 2>&1)
    
    echo "Pod creation output for $character:"
    echo "$POD_OUTPUT"
    echo ""
    
    # Extract pod ID
    POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)
    
    if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
        echo "✅ $character pod created successfully!"
        echo "   Pod ID: $POD_ID"
        echo ""
        
        # Save pod ID
        echo "$POD_ID" > "${character}_pod_id.txt"
        
        # Add to deployment log
        echo "$character: $POD_ID" >> character_pods.txt
        
    else
        echo "❌ Failed to create $character pod"
        echo "Output: $POD_OUTPUT"
    fi
    
    echo "---"
    sleep 5  # Brief pause between deployments
done

echo ""
echo "🎯 DEPLOYMENT SUMMARY"
echo "===================="
echo ""

echo "📋 Character Pods:"
if [[ -f "character_pods.txt" ]]; then
    cat character_pods.txt
else
    echo "   No pods recorded"
fi

echo ""
echo "💡 DISK SPACE NOTE:"
echo "   Default container disk should be sufficient"
echo "   If you need more space, you'll need to use the web console"
echo ""

echo "🔗 Next Steps:"
echo "1. Wait 1-2 minutes for pods to initialize"
echo "2. Connect to each pod: runpod pod connect [POD_ID]"
echo "3. Clone repo: git clone https://github.com/phxdev1/ai-office.git"
echo "4. Install deps: pip install unsloth[cu121-torch240] transformers datasets trl"
echo "5. Start training: python train_character_lora.py --character [name]"

echo ""
echo "📊 Expected Training Time: ~30-45 minutes per character"
echo "💰 Cost: ~$2.50 total for all 4 characters"