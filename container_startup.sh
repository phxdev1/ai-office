#!/bin/bash

# 🎭 CONTAINER STARTUP SCRIPT
# Auto-executes Office LoRA training on container boot

echo "🎭 OFFICE LORA AUTO-STARTUP INITIATED"
echo "====================================="
echo "Time: $(date)"
echo "Container: $(hostname)"
echo ""

# Detect character from environment variable or hostname
if [[ -n "$CHARACTER_NAME" ]]; then
    CHARACTER="$CHARACTER_NAME"
elif [[ $(hostname) == *"michael"* ]]; then
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

# Wait for system to fully initialize
echo "⏳ Waiting for system initialization..."
sleep 30

# Change to workspace
cd /workspace || cd /root

# Log everything
exec > >(tee -a /workspace/startup_${CHARACTER}.log) 2>&1

echo "📁 Working directory: $(pwd)"
echo "🔍 Available space: $(df -h . | tail -1)"
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

# Start training
echo ""
echo "🚀 STARTING $CHARACTER LORA TRAINING..."
echo "======================================="
echo ""

python train_character_lora.py --character "$CHARACTER"

echo ""
echo "✅ $CHARACTER training completed at $(date)"
echo "📁 Check /workspace/ai-office/lora_models/ for results"