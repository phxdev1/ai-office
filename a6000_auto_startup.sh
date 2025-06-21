#!/bin/bash

# 🔥 A6000 AUTO-STARTUP SCRIPT
# Optimized for RTX A6000 48GB VRAM beasts

echo "🔥 A6000 OFFICE LORA AUTO-STARTUP"
echo "================================="
echo "Time: $(date)"
echo "Container: $(hostname)"
echo ""

# Detect character from hostname or container name
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
    CHARACTER="michael"  # Default fallback
fi

echo "🎭 Detected character: $CHARACTER"
echo "💪 GPU: RTX A6000 (48GB VRAM)"
echo ""

# Wait for system initialization
echo "⏳ Waiting for system initialization..."
sleep 30

cd /workspace

# Log everything to both console and file
exec > >(tee -a /workspace/a6000_startup_${CHARACTER}.log) 2>&1

echo "📁 Working directory: $(pwd)"
echo "🔍 Available space: $(df -h . | tail -1)"
echo "💾 GPU info:"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
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
    echo "✅ Repository already exists"
    cd ai-office
    git pull  # Update to latest
fi

cd ai-office

# Install dependencies optimized for A6000
echo "📦 Installing dependencies (A6000 optimized)..."
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Verify training data exists
DATA_FILE="autotrain_data/${CHARACTER}_autotrain.jsonl"
if [[ ! -f "$DATA_FILE" ]]; then
    echo "❌ Training data not found: $DATA_FILE"
    echo "📂 Available files:"
    ls -la autotrain_data/ 2>/dev/null || echo "No autotrain_data directory"
    exit 1
fi

echo "✅ Training data found: $DATA_FILE"
echo "📊 Data size: $(wc -l < "$DATA_FILE") lines"
echo ""

# Check GPU before training
echo "🔥 Pre-training GPU status:"
nvidia-smi
echo ""

# Start training with A6000 power
echo "🚀 STARTING $CHARACTER A6000 LORA TRAINING..."
echo "============================================="
echo "💪 Hardware: RTX A6000 (48GB VRAM)"
echo "⚡ Mode: MAXIMUM THERMAL DESTRUCTION"
echo ""

python train_character_lora.py --character "$CHARACTER"

echo ""
echo "✅ $CHARACTER A6000 training completed at $(date)"
echo "📁 Results in: /workspace/ai-office/lora_models/"
echo "🔥 GPU survived the thermal assault!"
echo ""

# Final GPU status
echo "🏁 Post-training GPU status:"
nvidia-smi