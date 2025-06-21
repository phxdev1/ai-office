#!/bin/bash
echo "🎭 Starting erin LoRA training at $(date)"
cd /workspace

# Clone repo if needed
if [[ ! -d "ai-office" ]]; then
    git clone https://github.com/phxdev1/ai-office.git
fi

cd ai-office

# Install dependencies
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

# Start training with logging
python train_character_lora.py --character erin > /workspace/erin_training.log 2>&1

echo "✅ erin training completed at $(date)" >> /workspace/erin_training.log
