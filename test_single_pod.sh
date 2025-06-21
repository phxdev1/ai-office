#!/bin/bash

# 🧪 TEST SINGLE OFFICE LORA POD
# Create one Michael pod to test training process

echo "🧪 SINGLE POD TRAINING TEST"
echo "============================"
echo ""

echo "🎭 Creating test pod for Michael Scott..."
echo "  Character: Michael (24,351 examples)"
echo "  GPU: RTX A5000"
echo "  Cost: ~$0.50/hour"
echo ""

# Create single Michael pod
POD_OUTPUT=$(echo 'y' | runpod pod create "test-michael-lora" \
    --image "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04" \
    --gpu-type "RTX A5000" \
    --gpu-count 1 \
    --support-public-ip true 2>&1)

echo "Pod creation output:"
echo "$POD_OUTPUT"

# Extract pod ID
POD_ID=$(echo "$POD_OUTPUT" | grep -oE '[a-zA-Z0-9]{8,}' | tail -1)

if [[ -n "$POD_ID" && "$POD_ID" != "Launching" ]]; then
    echo ""
    echo "✅ Test pod created successfully!"
    echo "   Pod ID: $POD_ID"
    echo "   Name: test-michael-lora"
    echo ""
    
    echo "📋 NEXT STEPS:"
    echo "=============="
    echo "1. Wait 30 seconds for pod to initialize"
    echo "2. Connect to pod: runpod pod connect $POD_ID"
    echo "3. Upload training data and script"
    echo "4. Test training process"
    echo ""
    
    echo "💾 Save pod ID for reference:"
    echo "$POD_ID" > test_pod_id.txt
    echo "   Saved to: test_pod_id.txt"
    
    echo ""
    echo "🔗 Manual connection command:"
    echo "runpod pod connect $POD_ID"
    
else
    echo "❌ Failed to create test pod"
    echo "Output: $POD_OUTPUT"
fi