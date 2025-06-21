#!/bin/bash

# 🎭 LAUNCH REMAINING 4 OFFICE CHARACTERS
# Michael is already running, deploy the rest

echo "🎭 LAUNCHING REMAINING 4 OFFICE CHARACTERS"
echo "=========================================="
echo ""
echo "✅ Michael already running: qif3gszlnqrmt4"
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
        echo "$character: $POD_ID" >> fresh_character_pods.txt
        
    else
        echo "❌ Failed to create $character pod"
        echo "Output: $POD_OUTPUT"
    fi
    
    echo "---"
    sleep 3  # Brief pause between deployments
done

echo ""
echo "🎯 FRESH DEPLOYMENT SUMMARY"
echo "=========================="
echo ""

echo "📋 All Character Pods:"
echo "michael: qif3gszlnqrmt4 (existing)"
if [[ -f "fresh_character_pods.txt" ]]; then
    cat fresh_character_pods.txt
else
    echo "   No new pods recorded"
fi

echo ""
echo "🔗 Next Step: Deploy auto-startup scripts to all 5 pods"
echo "💡 All pods will auto-start training once startup scripts are deployed"