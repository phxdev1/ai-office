#!/bin/bash

# 🐳 BUILD AND DEPLOY OFFICE LORA DOCKER IMAGE
# One image, five character deployments

echo "🐳 OFFICE LORA DOCKER BUILD & DEPLOY"
echo "===================================="
echo ""

# Build the Docker image
DOCKER_IMAGE="office-lora-trainer:latest"

echo "🔨 Building Docker image..."
echo "Image: $DOCKER_IMAGE"
echo ""

# Build command (when ready)
# docker build -t $DOCKER_IMAGE .

echo "🚀 DEPLOYMENT STRATEGY:"
echo "======================"
echo ""

# Character list
CHARACTERS=("michael" "dwight" "creed" "erin" "toby")

echo "📋 RunPod Deployment Commands:"
echo "============================="
echo ""

for character in "${CHARACTERS[@]}"; do
    echo "🎭 $character:"
    echo "   runpod pod create ${character}-lora-docker \\"
    echo "     --image $DOCKER_IMAGE \\"
    echo "     --gpu-type \"RTX A6000\" \\"
    echo "     --gpu-count 1 \\"
    echo "     --env CHARACTER_NAME=$character \\"
    echo "     --support-public-ip true"
    echo ""
done

echo "💡 DOCKER RUN EQUIVALENT:"
echo "========================="
echo ""

for character in "${CHARACTERS[@]}"; do
    echo "🎭 $character:"
    echo "   docker run --gpus all -e CHARACTER_NAME=$character $DOCKER_IMAGE"
    echo ""
done

echo "✅ BENEFITS:"
echo "============"
echo "   ✅ One image, five deployments"
echo "   ✅ No setup time - everything pre-installed"
echo "   ✅ Consistent environment"
echo "   ✅ Character specified at runtime"
echo "   ✅ Automatic training start"
echo "   ✅ No more broken dependencies"
echo ""

echo "🔥 DEPLOYMENT RESULT:"
echo "===================="
echo "   5 × RTX A6000 pods"
echo "   Each with CHARACTER_NAME env var"
echo "   Auto-start training on boot"
echo "   Professional Docker deployment"
echo ""

echo "🐳 Ready to containerize the Office! 🎭"