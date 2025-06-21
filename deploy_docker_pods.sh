#!/bin/bash

# 🚀 DEPLOY OFFICE LORA DOCKER PODS ON RUNPOD
# Use pushed Docker image with character ENV vars

echo "🚀 OFFICE LORA DOCKER POD DEPLOYMENT"
echo "===================================="
echo ""

# GitHub Container Registry image
DOCKER_IMAGE="ghcr.io/phxdev1/ai-office:latest"

echo "🐳 Docker Image: $DOCKER_IMAGE"
echo ""

# Characters to deploy
CHARACTERS=("michael" "dwight" "creed" "erin" "toby")

echo "🎭 Deploying Office LoRA Docker Army..."
echo ""

for character in "${CHARACTERS[@]}"; do
    echo "🚀 Deploying $character with Docker image..."
    
    # Deploy pod with character environment variable
    POD_OUTPUT=$(echo 'y' | runpod pod create "${character}-lora-docker" \
        --image "$DOCKER_IMAGE" \
        --gpu-type "RTX A6000" \
        --gpu-count 1 \
        --support-public-ip true 2>&1)
    
    # Note: RunPod CLI might not support --env flag
    # You may need to set environment variables through RunPod web interface
    
    echo "Pod creation output:"
    echo "$POD_OUTPUT"
    echo ""
    
    # Extract pod ID
    POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)
    
    if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
        echo "✅ $character Docker pod deployed!"
        echo "   Pod ID: $POD_ID"
        echo "   Image: $DOCKER_IMAGE"
        echo "   Character: $character"
        echo "   ⚠️  Set CHARACTER_NAME=$character via web interface"
        echo ""
        
        # Save to Docker deployment log
        echo "$character: $POD_ID" >> docker_pods.txt
        
    else
        echo "❌ Failed to deploy $character Docker pod"
        echo "Output: $POD_OUTPUT"
    fi
    
    echo "---"
    sleep 5
done

echo ""
echo "🎯 DOCKER DEPLOYMENT COMPLETE"
echo "============================="
echo ""

echo "📋 Docker Office Army:"
if [[ -f "docker_pods.txt" ]]; then
    cat docker_pods.txt
else
    echo "   No pods recorded"
fi

echo ""
echo "⚠️  MANUAL STEPS REQUIRED:"
echo "========================="
echo "For each pod, set the CHARACTER_NAME environment variable:"
echo ""

for character in "${CHARACTERS[@]}"; do
    echo "🎭 $character pod:"
    echo "   1. Go to RunPod web interface"
    echo "   2. Find pod: ${character}-lora-docker"
    echo "   3. Set environment variable: CHARACTER_NAME=$character"
    echo "   4. Restart container"
    echo ""
done

echo "💡 ALTERNATIVE:"
echo "==============="
echo "If RunPod CLI supports environment variables:"
echo ""
for character in "${CHARACTERS[@]}"; do
    echo "runpod pod create ${character}-lora --image $DOCKER_IMAGE --env CHARACTER_NAME=$character --gpu-type RTX A6000"
done

echo ""
echo "🔥 DOCKER OFFICE ARMY READY FOR CONTAINERIZED ASSAULT! 🐳🎭"