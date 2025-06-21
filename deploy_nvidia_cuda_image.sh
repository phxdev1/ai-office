#!/bin/bash

# 🔥 DEPLOY A6000 ARMY WITH NVIDIA CUDA IMAGE
# Use proper NVIDIA base image and install our own stack

echo "🔥 A6000 ARMY - NVIDIA CUDA 12.9.1 DEPLOYMENT"
echo "=============================================="
echo ""

# Proper NVIDIA CUDA image
NVIDIA_IMAGE="nvidia/cuda:12.9.1-devel-ubuntu20.04"

echo "🎯 Target Image: $NVIDIA_IMAGE"
echo "✅ Features:"
echo "   - CUDA 12.9.1 (latest)"
echo "   - Development tools"
echo "   - Clean Ubuntu 20.04"
echo "   - No broken PyTorch bullshit"
echo ""

CHARACTERS=("michael" "dwight" "creed" "erin" "toby")

for character in "${CHARACTERS[@]}"; do
    echo ""
    echo "🎭 Deploying $character with NVIDIA CUDA image..."
    
    POD_OUTPUT=$(echo 'y' | runpod pod create "${character}-a6000-nvidia" \
        --image "$NVIDIA_IMAGE" \
        --gpu-type "RTX A6000" \
        --gpu-count 1 \
        --support-public-ip true 2>&1)
    
    echo "Pod creation output:"
    echo "$POD_OUTPUT"
    echo ""
    
    # Extract pod ID
    POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)
    
    if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
        echo "✅ $character NVIDIA pod deployed!"
        echo "   Pod ID: $POD_ID"
        echo "   Image: $NVIDIA_IMAGE"
        echo "   GPU: RTX A6000 (48GB VRAM)"
        echo ""
        
        # Save to NVIDIA deployment log
        echo "$character: $POD_ID" >> nvidia_cuda_pods.txt
        
    else
        echo "❌ Failed to deploy $character pod"
        echo "Output: $POD_OUTPUT"
    fi
    
    echo "---"
    sleep 5
done

echo ""
echo "🎯 NVIDIA CUDA DEPLOYMENT COMPLETE"
echo "=================================="
echo ""

echo "📋 NVIDIA CUDA A6000 Army:"
if [[ -f "nvidia_cuda_pods.txt" ]]; then
    cat nvidia_cuda_pods.txt
else
    echo "   No pods recorded"
fi

echo ""
echo "🔧 SETUP COMMANDS FOR EACH POD:"
echo "==============================="
echo ""
echo "1. Install Python and pip:"
echo "   apt update && apt install -y python3 python3-pip git"
echo ""
echo "2. Install PyTorch (proper CUDA 12.x):"
echo "   pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121"
echo ""
echo "3. Install ML dependencies:"
echo "   pip3 install transformers datasets unsloth[cu121-torch240] trl"
echo ""
echo "4. Clone repo and train:"
echo "   git clone https://github.com/phxdev1/ai-office.git"
echo "   cd ai-office"
echo "   python3 train_character_lora.py --character [character_name]"
echo ""

echo "🔥 NVIDIA CUDA ARMY READY FOR PROPER DEPLOYMENT! 🔥"
echo "No more broken PyTorch installations!"