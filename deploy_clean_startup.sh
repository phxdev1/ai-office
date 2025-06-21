#!/bin/bash

# 🔥 DEPLOY AUTO-STARTUP TO CLEAN A6000 ARMY
# Professional deployment for professional GPUs

echo "🔥 CLEAN A6000 AUTO-STARTUP DEPLOYMENT"
echo "======================================"
echo ""

# Clean A6000 pod configuration
declare -A CLEAN_PODS=(
    ["michael"]="9m6oza3dwvssv8"
    ["dwight"]="wtrm7u6t9zvw9y" 
    ["creed"]="thq4e6mz8xau8y"
    ["erin"]="ay40q7hjctv0hn"
    ["toby"]="vmu4h8qmlwid23"
)

echo "📋 Clean A6000 Army:"
for character in "${!CLEAN_PODS[@]}"; do
    echo "   🎭 $character: ${CLEAN_PODS[$character]} (RTX A6000)"
done
echo ""

echo "🚀 AUTO-STARTUP DEPLOYMENT COMMAND:"
echo "==================================="
echo ""
echo "Copy and paste this into each pod after connecting:"
echo ""

cat << 'CLEAN_STARTUP_DEPLOYMENT'
cat > /workspace/clean_a6000_startup.sh << 'EOF'
#!/bin/bash

echo "🔥 CLEAN A6000 OFFICE LORA AUTO-STARTUP"
echo "======================================="
echo "Time: $(date)"
echo "Container: $(hostname)"
echo ""

# Detect character from container name
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
    echo "⚠️ Could not detect character from hostname: $(hostname)"
    echo "Please set CHARACTER manually:"
    echo "export CHARACTER=michael  # or dwight, creed, erin, toby"
    exit 1
fi

echo "🎭 Detected character: $CHARACTER"
echo "💪 GPU: RTX A6000 (48GB VRAM)"
echo "🧹 Clean deployment"
echo ""

# Wait for system initialization
echo "⏳ Initializing A6000 system..."
sleep 30

cd /workspace

# Log everything
exec > >(tee -a /workspace/clean_startup_${CHARACTER}.log) 2>&1

echo "📁 Working directory: $(pwd)"
echo "🔍 Available space: $(df -h . | tail -1)"
echo ""

# Display GPU info
echo "💾 A6000 GPU Status:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader
echo ""

# Clone repository
echo "📥 Cloning ai-office repository..."
if [[ ! -d "ai-office" ]]; then
    git clone https://github.com/phxdev1/ai-office.git
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to clone repository"
        exit 1
    fi
else
    echo "✅ Repository already exists, updating..."
    cd ai-office
    git pull
    cd ..
fi

cd ai-office

# Install dependencies optimized for A6000
echo "📦 Installing A6000-optimized dependencies..."
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Verify training data
DATA_FILE="autotrain_data/${CHARACTER}_autotrain.jsonl"
if [[ ! -f "$DATA_FILE" ]]; then
    echo "❌ Training data not found: $DATA_FILE"
    echo "📂 Available training data:"
    ls -la autotrain_data/ 2>/dev/null || echo "No autotrain_data directory found"
    exit 1
fi

echo "✅ Training data verified: $DATA_FILE"
LINES=$(wc -l < "$DATA_FILE")
echo "📊 Training examples: $LINES"
echo ""

# Pre-training GPU check
echo "🔥 Pre-training A6000 status:"
nvidia-smi
echo ""

# Start training with maximum A6000 power
echo "🚀 STARTING $CHARACTER A6000 LORA TRAINING"
echo "=========================================="
echo "💪 Hardware: RTX A6000 (48GB VRAM)"
echo "⚡ Mode: PROFESSIONAL THERMAL DESTRUCTION"
echo "🎭 Character: $CHARACTER ($LINES examples)"
echo "⏱️ Start time: $(date)"
echo ""

python train_character_lora.py --character "$CHARACTER"

TRAINING_EXIT_CODE=$?

echo ""
echo "🏁 TRAINING COMPLETED"
echo "===================="
echo "⏱️ End time: $(date)"
echo "🎭 Character: $CHARACTER"
echo "📊 Exit code: $TRAINING_EXIT_CODE"

if [[ $TRAINING_EXIT_CODE -eq 0 ]]; then
    echo "✅ Training successful!"
    echo "📁 Model saved to: lora_models/${CHARACTER,,}_lora/"
else
    echo "❌ Training failed with exit code: $TRAINING_EXIT_CODE"
fi

echo ""
echo "🔥 Post-training A6000 status:"
nvidia-smi
echo ""
echo "💪 A6000 survived the professional assault!"
EOF

chmod +x /workspace/clean_a6000_startup.sh
nohup /workspace/clean_a6000_startup.sh &

echo "✅ Clean A6000 auto-startup deployed and running!"
echo "📊 Monitor with: tail -f /workspace/clean_startup_*.log"
CLEAN_STARTUP_DEPLOYMENT

echo ""
echo "🎯 DEPLOYMENT INSTRUCTIONS:"
echo "=========================="
for character in "${!CLEAN_PODS[@]}"; do
    pod_id="${CLEAN_PODS[$character]}"
    echo ""
    echo "🎭 $character A6000 Pod:"
    echo "   runpod pod connect $pod_id"
    echo "   [Paste the startup command above]"
    echo "   exit"
done

echo ""
echo "⚡ EXPECTED A6000 CARNAGE:"
echo "========================="
echo "   5 × RTX A6000 at thermal limits"
echo "   240GB VRAM fully utilized"
echo "   Professional grade destruction"
echo "   Datacenter temperature: +15°F"
echo "   Training time: 45-60 minutes"
echo "   Cost: ~$3.68 total"
echo ""

echo "📊 MONITOR THE DESTRUCTION:"
echo "=========================="
echo "   Connect to any pod and run:"
echo "   tail -f /workspace/clean_startup_*.log"
echo "   nvidia-smi -l 5  # Live GPU monitoring"
echo ""

echo "🔥 CLEAN A6000 ARMY READY FOR PROFESSIONAL ASSAULT! 🔥"