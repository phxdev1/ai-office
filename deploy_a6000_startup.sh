#!/bin/bash

# 🔥 DEPLOY A6000 AUTO-STARTUP TO ALL PODS
# Professional deployment for professional GPUs

echo "🔥 A6000 AUTO-STARTUP DEPLOYMENT"
echo "================================"
echo ""

# A6000 pod configuration  
declare -A PODS=(
    ["michael"]="rypn3g5urtufgz"
    ["dwight"]="r1afrobeuszebd"
    ["creed"]="pawxkrbrsr7thr"
    ["erin"]="mq3jh82e6u67qo"
    ["toby"]="n33ichrdq47d0k"
)

echo "📋 A6000 Target Pods:"
for character in "${!PODS[@]}"; do
    echo "   🎭 $character: ${PODS[$character]} (RTX A6000)"
done
echo ""

echo "🚀 DEPLOYMENT COMMAND FOR EACH POD:"
echo "==================================="
echo ""
echo "Copy and paste this into each pod after connecting:"
echo ""

cat << 'STARTUP_DEPLOYMENT'
cat > /workspace/a6000_auto_startup.sh << 'EOF'
#!/bin/bash

echo "🔥 A6000 OFFICE LORA AUTO-STARTUP"
echo "================================="
echo "Time: $(date)"
echo "Container: $(hostname)"
echo ""

# Detect character from hostname
if [[ $(hostname) == *"michael"* ]] || [[ "$HOSTNAME" == *"michael"* ]]; then
    CHARACTER="michael"
elif [[ $(hostname) == *"dwight"* ]] || [[ "$HOSTNAME" == *"dwight"* ]]; then
    CHARACTER="dwight"
elif [[ $(hostname) == *"creed"* ]] || [[ "$HOSTNAME" == *"creed"* ]]; then
    CHARACTER="creed"
elif [[ $(hostname) == *"erin"* ]] || [[ "$HOSTNAME" == *"erin"* ]]; then
    CHARACTER="erin"
elif [[ $(hostname) == *"toby"* ]] || [[ "$HOSTNAME" == *"toby"* ]]; then
    CHARACTER="toby"
else
    CHARACTER="michael"
fi

echo "🎭 Detected character: $CHARACTER"
echo "💪 GPU: RTX A6000 (48GB VRAM)"
echo ""

sleep 30
cd /workspace

exec > >(tee -a /workspace/a6000_startup_${CHARACTER}.log) 2>&1

echo "📁 Working directory: $(pwd)"
echo "💾 GPU info:"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
echo ""

if [[ ! -d "ai-office" ]]; then
    git clone https://github.com/phxdev1/ai-office.git
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to clone repository"
        exit 1
    fi
else
    echo "✅ Repository already exists"
    cd ai-office
    git pull
fi

cd ai-office

echo "📦 Installing dependencies (A6000 optimized)..."
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

DATA_FILE="autotrain_data/${CHARACTER}_autotrain.jsonl"
if [[ ! -f "$DATA_FILE" ]]; then
    echo "❌ Training data not found: $DATA_FILE"
    exit 1
fi

echo "✅ Training data found: $DATA_FILE"
echo "📊 Data size: $(wc -l < "$DATA_FILE") lines"
echo ""

echo "🔥 Pre-training GPU status:"
nvidia-smi
echo ""

echo "🚀 STARTING $CHARACTER A6000 LORA TRAINING..."
echo "============================================="
echo "💪 Hardware: RTX A6000 (48GB VRAM)"
echo "⚡ Mode: MAXIMUM THERMAL DESTRUCTION"
echo ""

python train_character_lora.py --character "$CHARACTER"

echo ""
echo "✅ $CHARACTER A6000 training completed at $(date)"
echo "🔥 GPU survived the thermal assault!"
echo ""

echo "🏁 Post-training GPU status:"
nvidia-smi
EOF

chmod +x /workspace/a6000_auto_startup.sh
nohup /workspace/a6000_auto_startup.sh &

echo "✅ A6000 auto-startup deployed and running!"
STARTUP_DEPLOYMENT

echo ""
echo "🔥 MANUAL DEPLOYMENT STEPS:"
echo "=========================="
for character in "${!PODS[@]}"; do
    pod_id="${PODS[$character]}"
    echo ""
    echo "🎭 $character A6000:"
    echo "   runpod pod connect $pod_id"
    echo "   [Paste the command above]"
    echo "   exit"
done

echo ""
echo "⚡ A6000 ARMY DEPLOYMENT RESULT:"
echo "==============================="
echo "   5 × RTX A6000 (48GB VRAM each)"
echo "   240GB total VRAM"
echo "   53,760 total CUDA cores"
echo "   Professional thermal destruction"
echo "   Datacenter temperature: Probably +10°F"
echo ""

echo "📊 MONITOR A6000 CARNAGE:"
echo "========================="
echo "   Connect to any pod:"
echo "   tail -f /workspace/a6000_startup_*.log"
echo "   nvidia-smi  # Watch the thermal destruction"
echo ""

echo "🔥 A6000 ARMY READY FOR MAXIMUM ASSAULT! 🔥"