#!/bin/bash

echo "🎭 Deploying creed auto-startup script..."

# Connect to pod and create startup script
runpod pod connect gekevp0rqulmw9 << 'REMOTE_COMMANDS'

# Create the startup script in the container
cat > /workspace/auto_startup.sh << 'STARTUP_SCRIPT'
#!/bin/bash

echo "🎭 creed LORA AUTO-STARTUP INITIATED"
echo "Time: $(date)"
echo ""

# Wait for system initialization
sleep 30

cd /workspace

# Clone repo
if [[ ! -d "ai-office" ]]; then
    git clone https://github.com/phxdev1/ai-office.git
fi

cd ai-office

# Install dependencies
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch

# Start training with logging
echo "🚀 Starting creed training..."
python train_character_lora.py --character creed > /workspace/creed_training.log 2>&1

echo "✅ creed training completed at $(date)"
STARTUP_SCRIPT

# Make it executable
chmod +x /workspace/auto_startup.sh

# Run it in background
nohup /workspace/auto_startup.sh &

echo "✅ creed auto-startup deployed and running!"

exit
REMOTE_COMMANDS

