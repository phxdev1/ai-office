#!/bin/bash

# 🧹 CLEAN A6000 OFFICE LORA DEPLOYMENT
# Fresh deployment with professional hardware

echo "🧹 CLEAN A6000 OFFICE LORA DEPLOYMENT"
echo "====================================="
echo ""
echo "💪 Target Hardware:"
echo "   GPU: RTX A6000 (48GB VRAM)"
echo "   Storage: 100GB+ (default container)"
echo "   Performance: Professional grade"
echo "   Cost: $0.49/hour per GPU"
echo ""

# Clean deployment - all 5 characters
CHARACTERS=("michael" "dwight" "creed" "erin" "toby")

echo "🚀 Creating fresh A6000 pods..."
echo ""

for character in "${CHARACTERS[@]}"; do
    echo "🎭 Deploying $character on RTX A6000..."
    
    POD_OUTPUT=$(echo 'y' | runpod pod create "${character}-a6000-clean" \
        --image "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04" \
        --gpu-type "RTX A6000" \
        --gpu-count 1 \
        --support-public-ip true 2>&1)
    
    echo "Pod creation output:"
    echo "$POD_OUTPUT"
    echo ""
    
    # Extract pod ID
    POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)
    
    if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
        echo "✅ $character A6000 pod deployed!"
        echo "   Pod ID: $POD_ID"
        echo "   Hardware: RTX A6000 (48GB VRAM)"
        echo ""
        
        # Save to clean deployment log
        echo "$character: $POD_ID" >> clean_a6000_pods.txt
        echo "$POD_ID" > "clean_${character}_pod_id.txt"
        
    else
        echo "❌ Failed to deploy $character A6000 pod"
        echo "Output: $POD_OUTPUT"
    fi
    
    echo "---"
    sleep 5
done

echo ""
echo "🎯 CLEAN A6000 DEPLOYMENT COMPLETE"
echo "=================================="
echo ""

echo "📋 Fresh A6000 Army:"
if [[ -f "clean_a6000_pods.txt" ]]; then
    cat clean_a6000_pods.txt
else
    echo "   No pods recorded"
fi

echo ""
echo "💪 TOTAL HARDWARE POWER:"
echo "========================"
echo "   5 × RTX A6000 GPUs"
echo "   240GB total VRAM"
echo "   53,760 total CUDA cores"
echo "   Professional thermal output"
echo ""

echo "💰 COST ANALYSIS:"
echo "================="
echo "   Rate: $0.49/hour per A6000"
echo "   Total: $2.45/hour for army"
echo "   90min training: ~$3.68 total"
echo ""

echo "🚀 NEXT STEPS:"
echo "=============="
echo "1. Wait 60 seconds for pods to initialize"
echo "2. Deploy auto-startup scripts to all pods"
echo "3. Watch A6000s destroy Office character training"
echo "4. Monitor datacenter temperature increase"
echo ""

echo "🔥 A6000 ARMY READY FOR PROFESSIONAL ASSAULT! 🔥"