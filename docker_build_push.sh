#!/bin/bash

# 🐳 BUILD AND PUSH OFFICE LORA DOCKER IMAGE
# Push to Docker Hub for RunPod deployment

echo "🐳 OFFICE LORA DOCKER BUILD & PUSH"
echo "=================================="
echo ""

# GitHub Container Registry configuration
GITHUB_USERNAME="phxdev1"
DOCKER_REPO="ai-office"
DOCKER_TAG="latest"
FULL_IMAGE_NAME="ghcr.io/$GITHUB_USERNAME/$DOCKER_REPO:$DOCKER_TAG"

echo "🎯 Target Image: $FULL_IMAGE_NAME"
echo ""

echo "🔨 Building Docker image..."
docker build -t $FULL_IMAGE_NAME .

if [[ $? -ne 0 ]]; then
    echo "❌ Docker build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

echo "🚀 Pushing to GitHub Container Registry..."
echo "GitHub PAT login required..."

# Login to GitHub Container Registry
echo "Use GitHub Personal Access Token with write:packages scope"
docker login ghcr.io -u $GITHUB_USERNAME

if [[ $? -ne 0 ]]; then
    echo "❌ Docker login failed!"
    exit 1
fi

# Push the image
docker push $FULL_IMAGE_NAME

if [[ $? -ne 0 ]]; then
    echo "❌ Docker push failed!"
    exit 1
fi

echo "✅ Push successful!"
echo ""

echo "🎯 IMAGE READY FOR DEPLOYMENT:"
echo "=============================="
echo "   Registry: GitHub Container Registry"
echo "   Image: $FULL_IMAGE_NAME"
echo "   Size: $(docker images $FULL_IMAGE_NAME --format "table {{.Size}}" | tail -1)"
echo "   Visibility: Public (accessible to RunPod)"
echo ""

echo "🚀 RUNPOD DEPLOYMENT COMMANDS:"
echo "=============================="
echo ""

CHARACTERS=("michael" "dwight" "creed" "erin" "toby")

for character in "${CHARACTERS[@]}"; do
    echo "🎭 $character:"
    echo "   runpod pod create ${character}-lora \\"
    echo "     --image $FULL_IMAGE_NAME \\"
    echo "     --gpu-type \"RTX A6000\" \\"
    echo "     --gpu-count 1 \\"
    echo "     --env CHARACTER_NAME=$character \\"
    echo "     --support-public-ip true"
    echo ""
done

echo "💡 ALTERNATIVE REGISTRIES:"
echo "========================="
echo "   GitHub Container Registry: ghcr.io/username/office-lora-trainer:latest"
echo "   AWS ECR: your-account.dkr.ecr.region.amazonaws.com/office-lora-trainer:latest"
echo "   Google GCR: gcr.io/project-id/office-lora-trainer:latest"
echo ""

echo "🔥 READY FOR CONTAINERIZED OFFICE ASSAULT! 🐳🎭"