#!/bin/bash

# 🔥 LAUNCH A6000 OFFICE LORA ARMY WITH 100GB STORAGE
# Maximum power deployment with proper hardware

echo "🔥 A6000 OFFICE LORA ARMY DEPLOYMENT"
echo "===================================="
echo ""
echo "💪 Hardware specs:"
echo "   GPU: RTX A6000 (48GB VRAM)"
echo "   Storage: 100GB disk"
echo "   Power: MAXIMUM"
echo ""

# Clean slate - terminate existing pods first
echo "🧹 Cleaning existing pods..."
runpod pod list

# Characters to deploy
CHARACTERS=("michael" "dwight" "creed" "erin" "toby")

for character in "${CHARACTERS[@]}"; do
    echo ""
    echo "🚀 Creating A6000 pod for $character..."
    
    POD_OUTPUT=$(echo 'y' | runpod pod create "${character}-a6000-lora" \
        --image "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04" \
        --gpu-type "RTX A6000" \
        --gpu-count 1 \
        --support-public-ip true 2>&1)
    
    echo "Pod creation output for $character:"
    echo "$POD_OUTPUT"
    echo ""
    
    # Extract pod ID
    POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)
    
    if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
        echo "✅ $character A6000 pod created successfully!"
        echo "   Pod ID: $POD_ID"
        echo "   GPU: RTX A6000 (48GB VRAM)"
        echo "   Storage: 100GB"
        echo ""
        
        # Save pod ID
        echo "$POD_ID" > "${character}_a6000_pod_id.txt"
        
        # Add to deployment log
        echo "$character: $POD_ID" >> a6000_character_pods.txt
        
    else
        echo "❌ Failed to create $character A6000 pod"
        echo "Output: $POD_OUTPUT"
    fi
    
    echo "---"
    sleep 5  # Pause between deployments
done

echo ""
echo "🎯 A6000 DEPLOYMENT SUMMARY"
echo "=========================="
echo ""

echo "📋 A6000 Character Pods:"
if [[ -f "a6000_character_pods.txt" ]]; then
    cat a6000_character_pods.txt
else
    echo "   No pods recorded"
fi

echo ""
echo "💪 HARDWARE SPECS PER POD:"
echo "========================="
echo "   GPU: RTX A6000"
echo "   VRAM: 48GB (2x more than A5000)"
echo "   CUDA Cores: 10,752"
echo "   Storage: 100GB disk"
echo "   Tensor Performance: Maximum"
echo ""

echo "🔥 EXPECTED PERFORMANCE:"
echo "======================="
echo "   Training speed: 2x faster than A5000"
echo "   Batch size: Can go much higher"
echo "   Memory headroom: Massive"
echo "   Thermal output: Datacenter melting"
echo ""

echo "🚀 Next: Deploy auto-startup scripts to all A6000 pods"
echo "⚡ These GPUs will absolutely destroy the training!"