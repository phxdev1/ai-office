#!/bin/bash

# 🎭 LAUNCH REMAINING OFFICE CHARACTERS
# Create pods for Dwight, Creed, Erin, Toby with proper disk space

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
        --support-public-ip true \
        --container-disk-in-gb 50 \
        --volume-in-gb 100 2>&1)
    
    echo "Pod creation output for $character:"
    echo "$POD_OUTPUT"
    echo ""
    
    # Extract pod ID
    POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)
    
    if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
        echo "✅ $character pod created successfully!"
        echo "   Pod ID: $POD_ID"
        echo "   Disk: 50GB container + 100GB volume"
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
echo "💾 Disk Configuration:"
echo "   Container: 50GB (up from 10GB)"
echo "   Volume: 100GB for models/checkpoints"
echo ""

echo "🔗 Next Steps:"
echo "1. Wait 1-2 minutes for pods to initialize"
echo "2. Connect to each pod and clone the repo"
echo "3. Start parallel training with GPU Claude's optimized script"

echo ""
echo "📊 Expected Training Time: ~30-45 minutes per character"
echo "💰 Cost: ~$2.50 total for all 4 characters"