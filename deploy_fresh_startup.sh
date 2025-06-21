#!/bin/bash

# 🎭 DEPLOY AUTO-STARTUP TO FRESH OFFICE PODS
# All 5 characters ready for maximum thermal deployment

echo "🎭 FRESH OFFICE LORA AUTO-STARTUP DEPLOYMENT"
echo "==========================================="
echo ""

# Fresh pod configuration
declare -A PODS=(
    ["michael"]="qif3gszlnqrmt4"
    ["dwight"]="e3otxs565ncs9m"
    ["creed"]="kfaxrwaevdurdc"
    ["erin"]="gtkhg9obtl13r9"
    ["toby"]="a86hjzz7rlt78e"
)

echo "📋 Target Pods:"
for character in "${!PODS[@]}"; do
    echo "   🎭 $character: ${PODS[$character]}"
done
echo ""

echo "🚀 MANUAL DEPLOYMENT COMMANDS:"
echo "=============================="
echo ""

echo "For each pod, connect and run this command:"
echo ""

cat << 'DEPLOYMENT_COMMAND'
cat > /workspace/auto_startup.sh << 'EOF'
#!/bin/bash

echo "🎭 OFFICE LORA AUTO-STARTUP INITIATED"
echo "Time: $(date)"
echo "Container: $(hostname)"
echo ""

# Detect character from hostname
if [[ $(hostname) == *"michael"* ]]; then
    CHARACTER="michael"
elif [[ $(hostname) == *"dwight"* ]]; then
    CHARACTER="dwight"
elif [[ $(hostname) == *"creed"* ]]; then
    CHARACTER="creed"
elif [[ $(hostname) == *"erin"* ]]; then
    CHARACTER="erin"
elif [[ $(hostname) == *"toby"* ]]; then
    CHARACTER="toby"
else
    CHARACTER="michael"  # Default fallback
fi

echo "🎭 Detected character: $CHARACTER"
echo ""

# Wait for system initialization
echo "⏳ Waiting for system initialization..."
sleep 30

cd /workspace

# Log everything
exec > >(tee -a /workspace/startup_${CHARACTER}.log) 2>&1

echo "📁 Working directory: $(pwd)"
echo ""

# Clone repo
echo "📥 Cloning ai-office repository..."
if [[ ! -d "ai-office" ]]; then
    git clone https://github.com/phxdev1/ai-office.git
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to clone repository"
        exit 1
    fi
else
    echo "✅ Repository already exists"
fi

cd ai-office

# Install dependencies
echo "📦 Installing dependencies..."
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Verify training data
DATA_FILE="autotrain_data/${CHARACTER}_autotrain.jsonl"
if [[ ! -f "$DATA_FILE" ]]; then
    echo "❌ Training data not found: $DATA_FILE"
    exit 1
fi

echo "✅ Training data found: $DATA_FILE"
echo "📊 Data size: $(wc -l < "$DATA_FILE") lines"

# Start training
echo ""
echo "🚀 STARTING $CHARACTER LORA TRAINING..."
echo "======================================="
echo ""

python train_character_lora.py --character "$CHARACTER"

echo ""
echo "✅ $CHARACTER training completed at $(date)"
EOF

chmod +x /workspace/auto_startup.sh
nohup /workspace/auto_startup.sh &

echo "✅ Auto-startup deployed and running!"
DEPLOYMENT_COMMAND

echo ""
echo "🔥 DEPLOYMENT STEPS:"
echo "==================="
for character in "${!PODS[@]}"; do
    pod_id="${PODS[$character]}"
    echo "🎭 $character:"
    echo "   runpod pod connect $pod_id"
    echo "   [Paste the command above]"
    echo "   exit"
    echo ""
done

echo "⚡ EXPECTED RESULT:"
echo "=================="
echo "   5 RTX A5000 GPUs at 100% utilization"
echo "   12 epochs × 24k examples each"
echo "   60-90 minutes training time"
echo "   Maximum thermal carnage"
echo ""

echo "📊 MONITOR PROGRESS:"
echo "==================="
echo "   Connect to any pod:"
echo "   tail -f /workspace/startup_*.log"
echo "   tail -f /workspace/*_training.log"
echo ""

echo "🎭 Ready for Blues Brothers deployment!"
echo "Hit it! 🔥⚡"