#!/bin/bash

# 🚀 DEPLOY STARTUP SCRIPTS TO ALL PODS
# Creates startup scripts in each pod that auto-execute training

echo "🎭 DEPLOYING AUTO-STARTUP TO ALL PODS"
echo "====================================="
echo ""

# Current pod IDs
declare -A PODS=(
    ["michael"]="qif3gszlnqrmt4"
    ["dwight"]="magk54sqpzgh7n"
    ["creed"]="gekevp0rqulmw9" 
    ["erin"]="flxfij2i1n4wc6"
    ["toby"]="d7fdon0x55x2ao"
)

create_pod_startup() {
    local character=$1
    local pod_id=$2
    
    echo "🔧 Creating startup script for $character (Pod: $pod_id)..."
    
    # Create character-specific startup script
    cat > "deploy_${character}_startup.sh" << EOF
#!/bin/bash

echo "🎭 Deploying $character auto-startup script..."

# Connect to pod and create startup script
runpod pod connect $pod_id << 'REMOTE_COMMANDS'

# Create the startup script in the container
cat > /workspace/auto_startup.sh << 'STARTUP_SCRIPT'
#!/bin/bash

echo "🎭 $character LORA AUTO-STARTUP INITIATED"
echo "Time: \$(date)"
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
echo "🚀 Starting $character training..."
python train_character_lora.py --character $character > /workspace/${character}_training.log 2>&1

echo "✅ $character training completed at \$(date)"
STARTUP_SCRIPT

# Make it executable
chmod +x /workspace/auto_startup.sh

# Run it in background
nohup /workspace/auto_startup.sh &

echo "✅ $character auto-startup deployed and running!"

exit
REMOTE_COMMANDS

EOF

    chmod +x "deploy_${character}_startup.sh"
    echo "✅ Created deploy_${character}_startup.sh"
}

# Create deployment scripts for all characters
for character in "${!PODS[@]}"; do
    create_pod_startup "$character" "${PODS[$character]}"
done

echo ""
echo "📋 DEPLOYMENT SCRIPTS CREATED:"
echo "=============================="
for character in "${!PODS[@]}"; do
    echo "🎭 $character: ./deploy_${character}_startup.sh"
done

echo ""
echo "🚀 EXECUTE ALL DEPLOYMENTS:"
echo "==========================="
echo "Run these commands to deploy auto-startup to all pods:"
echo ""

for character in "${!PODS[@]}"; do
    echo "./deploy_${character}_startup.sh &"
done

echo ""
echo "wait  # Wait for all deployments to complete"
echo ""

echo "💡 ALTERNATIVE - MANUAL DEPLOYMENT:"
echo "==================================="
echo "For each pod, connect and run:"
echo ""
echo 'cat > /workspace/auto_startup.sh << "EOF"'
cat container_startup.sh
echo 'EOF'
echo ""
echo "chmod +x /workspace/auto_startup.sh"
echo "nohup /workspace/auto_startup.sh &"
echo ""

echo "🔥 Once deployed, all pods will auto-start training!"
echo "📊 Monitor with: tail -f /workspace/*_training.log"