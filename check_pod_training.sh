#!/bin/bash

# 🔍 CHECK OFFICE LORA TRAINING STATUS
# Multiple approaches to check if training is running

echo "🔍 OFFICE LORA TRAINING STATUS CHECKER"
echo "======================================"
echo ""

# Pod IDs from the list
MICHAEL_PODS=("4qrla29jdv0zth" "f3l9vompawxywn")
DWIGHT_PODS=("tazpyzbt4f7bme" "znace2em26ngaw")
CREED_PODS=("lf7xhryqfqe7tu" "wjf5txmhan5fzg")
ERIN_PODS=("asp2rtepl9js1q" "q5p0kove646pn1")
TOBY_PODS=("mhprru6h0gtba6" "yv40e12aksyc0x")

check_pod_training() {
    local pod_id=$1
    local character=$2
    
    echo "🎭 Checking $character pod: $pod_id"
    
    # Try different methods to check status
    echo "   Method 1: Try Python exec to check processes..."
    
    # Try to run a simple Python command to check if the pod is responsive
    PYTHON_CHECK=$(runpod exec python --help 2>&1 | grep -q "Usage" && echo "responsive" || echo "not_responsive")
    echo "   Python exec status: $PYTHON_CHECK"
    
    # Check if we can see any running processes through alternative methods
    echo "   Pod ID: $pod_id"
    echo "   Character: $character"
    echo ""
}

echo "📊 CHECKING ALL OFFICE PODS:"
echo "============================"

echo ""
echo "🎭 MICHAEL PODS:"
for pod in "${MICHAEL_PODS[@]}"; do
    check_pod_training "$pod" "Michael"
done

echo "🎭 DWIGHT PODS:"
for pod in "${DWIGHT_PODS[@]}"; do
    check_pod_training "$pod" "Dwight"
done

echo "🎭 CREED PODS:"
for pod in "${CREED_PODS[@]}"; do
    check_pod_training "$pod" "Creed"
done

echo "🎭 ERIN PODS:"
for pod in "${ERIN_PODS[@]}"; do
    check_pod_training "$pod" "Erin"
done

echo "🎭 TOBY PODS:"
for pod in "${TOBY_PODS[@]}"; do
    check_pod_training "$pod" "Toby"
done

echo ""
echo "💡 MANUAL CHECK OPTIONS:"
echo "========================"
echo ""
echo "Since automated checks are limited, try these manual approaches:"
echo ""

echo "1. 🌐 WEB CONSOLE CHECK:"
echo "   - Go to https://runpod.io/console/pods"
echo "   - Click on a pod to see detailed info"
echo "   - Check logs or terminal access"
echo ""

echo "2. 📊 RESOURCE USAGE CHECK:"
echo "   - In web console, look for GPU/CPU usage"
echo "   - Training pods should show high GPU utilization"
echo "   - Idle pods will show low resource usage"
echo ""

echo "3. 🔌 DIRECT CONNECTION (if SSH works):"
echo "   Example commands to try:"
for pod in "${MICHAEL_PODS[@]}"; do
    echo "   runpod pod connect $pod"
    break
done
echo "   Then once connected: ps aux | grep python"
echo "   Look for training processes"
echo ""

echo "4. 📁 CHECK FOR TRAINING FILES:"
echo "   Look for these files in /workspace/:"
echo "   - training_data.jsonl (uploaded data)"
echo "   - training.log (training output)"
echo "   - checkpoints/ (training progress)"
echo "   - final_model/ (completed training)"
echo ""

echo "🎯 RECOMMENDATION:"
echo "=================="
echo "1. Check web console for resource usage"
echo "2. If you see high GPU usage = training is running"
echo "3. If you see low usage = pods are idle"
echo "4. Keep active training pods, terminate idle duplicates"

echo ""
echo "🔗 Quick link: https://runpod.io/console/pods"