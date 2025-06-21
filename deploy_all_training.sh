#!/bin/bash

# 🚀 FULLY AUTOMATED OFFICE LORA DEPLOYMENT
# Zero manual intervention - just run and wait for completion

echo "🎭 FULLY AUTOMATED OFFICE LORA DEPLOYMENT"
echo "========================================="
echo ""

# Pod configurations
declare -A PODS=(
    ["michael"]="qif3gszlnqrmt4"
    ["dwight"]="qnk50v3f4necn8" 
    ["creed"]="d2r106j5n3btcc"
    ["erin"]="t61imb6b25bfk4"
    ["toby"]="og6vk9s808c1b6"
)

deploy_to_pod() {
    local character=$1
    local pod_id=$2
    
    echo "🚀 Deploying $character training to pod $pod_id..."
    
    # Execute remote commands on the pod
    runpod exec --pod-id "$pod_id" -- bash -c "
        echo '🎭 Starting automated $character LoRA training setup...'
        cd /workspace
        
        # Clone repo if needed
        if [[ ! -d 'ai-office' ]]; then
            echo '📥 Cloning repository...'
            git clone https://github.com/phxdev1/ai-office.git
        else
            echo '✅ Repository already exists'
        fi
        
        cd ai-office
        
        # Install dependencies
        echo '📦 Installing dependencies...'
        pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch
        
        # Start training in background with full logging
        echo '🚀 Starting $character training...'
        nohup python train_character_lora.py --character $character > /workspace/${character}_training.log 2>&1 &
        
        echo '✅ $character training started in background'
        echo 'Monitor with: tail -f /workspace/${character}_training.log'
    "
    
    if [[ $? -eq 0 ]]; then
        echo "✅ $character deployment successful!"
    else
        echo "❌ $character deployment failed!"
    fi
    echo ""
}

# Deploy to all pods in parallel
echo "🔥 DEPLOYING TO ALL PODS..."
echo "=========================="
echo ""

for character in "${!PODS[@]}"; do
    deploy_to_pod "$character" "${PODS[$character]}" &
done

# Wait for all deployments to complete
wait

echo ""
echo "🎯 DEPLOYMENT COMPLETE!"
echo "======================"
echo ""

echo "📊 MONITORING COMMANDS:"
echo "======================="
for character in "${!PODS[@]}"; do
    pod_id="${PODS[$character]}"
    echo "🎭 $character: runpod exec --pod-id $pod_id -- tail -f /workspace/${character}_training.log"
done

echo ""
echo "⏱️  EXPECTED TIMELINE:"
echo "====================="
echo "   Training: 30-45 minutes (all parallel)"
echo "   Cost: ~\$2.50 total"
echo "   Datacenter temp: +3°F"
echo ""

echo "🔍 CHECK TRAINING STATUS:"
echo "========================"
echo "   ./check_all_training.sh"
echo ""

echo "🎉 All Office characters are now training!"
echo "   The datacenter is getting toasty! 🔥"