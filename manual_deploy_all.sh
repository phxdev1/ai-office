#!/bin/bash

# 🎭 MANUAL DEPLOYMENT GUIDE FOR ALL OFFICE CHARACTERS
# Step-by-step commands to run on each pod

echo "🎭 OFFICE LORA TRAINING DEPLOYMENT GUIDE"
echo "========================================"
echo ""

# Pod configurations
declare -A PODS=(
    ["michael"]="qif3gszlnqrmt4"
    ["dwight"]="qnk50v3f4necn8" 
    ["creed"]="d2r106j5n3btcc"
    ["erin"]="t61imb6b25bfk4"
    ["toby"]="og6vk9s808c1b6"
)

echo "🚀 QUICK DEPLOYMENT COMMANDS:"
echo "============================="
echo ""

for character in "${!PODS[@]}"; do
    pod_id="${PODS[$character]}"
    echo "🎭 $character (Pod: $pod_id):"
    echo "runpod pod connect $pod_id"
    echo "cd /workspace && git clone https://github.com/phxdev1/ai-office.git && cd ai-office && pip install unsloth[cu121-torch240] transformers datasets trl torch && nohup python train_character_lora.py --character $character > /workspace/${character}_training.log 2>&1 & && exit"
    echo ""
done

echo "💡 ONE-LINER FOR EACH POD:"
echo "=========================="
echo ""

echo "🎭 MICHAEL:"
echo "runpod pod connect qif3gszlnqrmt4 && cd /workspace && git clone https://github.com/phxdev1/ai-office.git && cd ai-office && pip install unsloth[cu121-torch240] transformers datasets trl torch && nohup python train_character_lora.py --character michael > /workspace/michael_training.log 2>&1 & && exit"
echo ""

echo "🎭 DWIGHT:" 
echo "runpod pod connect qnk50v3f4necn8 && cd /workspace && git clone https://github.com/phxdev1/ai-office.git && cd ai-office && pip install unsloth[cu121-torch240] transformers datasets trl torch && nohup python train_character_lora.py --character dwight > /workspace/dwight_training.log 2>&1 & && exit"
echo ""

echo "🎭 CREED:"
echo "runpod pod connect d2r106j5n3btcc && cd /workspace && git clone https://github.com/phxdev1/ai-office.git && cd ai-office && pip install unsloth[cu121-torch240] transformers datasets trl torch && nohup python train_character_lora.py --character creed > /workspace/creed_training.log 2>&1 & && exit"
echo ""

echo "🎭 ERIN:"
echo "runpod pod connect t61imb6b25bfk4 && cd /workspace && git clone https://github.com/phxdev1/ai-office.git && cd ai-office && pip install unsloth[cu121-torch240] transformers datasets trl torch && nohup python train_character_lora.py --character erin > /workspace/erin_training.log 2>&1 & && exit"
echo ""

echo "🎭 TOBY:"
echo "runpod pod connect og6vk9s808c1b6 && cd /workspace && git clone https://github.com/phxdev1/ai-office.git && cd ai-office && pip install unsloth[cu121-torch240] transformers datasets trl torch && nohup python train_character_lora.py --character toby > /workspace/toby_training.log 2>&1 & && exit"
echo ""

echo "🔥 EXPECTED RESULT:"
echo "=================="
echo "   5 RTX A5000 GPUs at 100% utilization"
echo "   Datacenter temperature: +3°F"
echo "   Training time: 30-45 minutes"
echo "   Cost: ~\$2.50"
echo ""

echo "📊 MONITOR PROGRESS:"
echo "==================="
echo "Connect to any pod and run:"
echo "   tail -f /workspace/*_training.log"