#!/bin/bash

# 🤖 AUTO TRAINING STARTUP SCRIPT
# This script will be added to pod startup to automatically begin training

CHARACTER_NAME="$1"

if [[ -z "$CHARACTER_NAME" ]]; then
    echo "❌ Character name required!"
    echo "Usage: $0 <character_name>"
    exit 1
fi

echo "🎭 OFFICE LORA AUTO-TRAINING STARTUP"
echo "===================================="
echo "Character: $CHARACTER_NAME"
echo "Time: $(date)"
echo ""

# Wait for system to fully boot
echo "⏳ Waiting for system initialization..."
sleep 30

# Change to workspace
cd /workspace || cd /root

# Log everything
exec > >(tee -a /workspace/startup_${CHARACTER_NAME}.log) 2>&1

echo "📁 Current directory: $(pwd)"
echo "🔍 Available space: $(df -h /workspace 2>/dev/null || df -h /)"
echo ""

# Clone repo if not exists
if [[ ! -d "ai-office" ]]; then
    echo "📥 Cloning ai-office repository..."
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

# Check for training data
DATA_FILE="autotrain_data/${CHARACTER_NAME}_autotrain.jsonl"
if [[ ! -f "$DATA_FILE" ]]; then
    echo "❌ Training data not found: $DATA_FILE"
    echo "Available files:"
    ls -la autotrain_data/ || echo "No autotrain_data directory"
    exit 1
fi

echo "✅ Training data found: $DATA_FILE"
echo "📊 Data size: $(wc -l < "$DATA_FILE") lines"

# Start training
echo ""
echo "🚀 STARTING $CHARACTER_NAME LORA TRAINING..."
echo "============================================"
echo ""

python train_character_lora.py --character "$CHARACTER_NAME"

echo ""
echo "✅ $CHARACTER_NAME training completed at $(date)"
echo "📁 Check /workspace/ai-office/lora_models/ for results"