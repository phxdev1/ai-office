# 🎭 OFFICE LORA TRAINING DOCKER IMAGE
# Professional containerized training environment

FROM nvidia/cuda:12.9.1-devel-ubuntu20.04

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Character name will be set at runtime via -e CHARACTER_NAME=xxx
# No default character - must be specified

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install PyTorch with CUDA 12.1 support
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install ML dependencies
RUN pip3 install \
    transformers \
    datasets \
    unsloth[cu121-torch240] \
    trl \
    accelerate \
    bitsandbytes

# Set working directory
WORKDIR /workspace

# Clone the Office LoRA repository
RUN git clone https://github.com/phxdev1/ai-office.git

# Copy training script to workspace root for easy access
COPY train_character_lora.py /workspace/
COPY autotrain_data/ /workspace/autotrain_data/

# Create startup script that auto-detects character from hostname
RUN echo '#!/bin/bash\n\
echo "🎭 OFFICE LORA TRAINING CONTAINER"\n\
echo "================================="\n\
echo "Hostname: $(hostname)"\n\
echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader)"\n\
echo "CUDA: $(nvcc --version | grep release)"\n\
echo "Time: $(date)"\n\
echo ""\n\
\n\
# Auto-detect character from hostname or environment\n\
if [[ -n "$CHARACTER_NAME" ]]; then\n\
    CHARACTER="$CHARACTER_NAME"\n\
elif [[ $(hostname) == *"michael"* ]]; then\n\
    CHARACTER="michael"\n\
elif [[ $(hostname) == *"dwight"* ]]; then\n\
    CHARACTER="dwight"\n\
elif [[ $(hostname) == *"creed"* ]]; then\n\
    CHARACTER="creed"\n\
elif [[ $(hostname) == *"erin"* ]]; then\n\
    CHARACTER="erin"\n\
elif [[ $(hostname) == *"toby"* ]]; then\n\
    CHARACTER="toby"\n\
else\n\
    echo "❌ Could not detect character from hostname: $(hostname)"\n\
    echo "Available characters: michael, dwight, creed, erin, toby"\n\
    echo "Set CHARACTER_NAME environment variable or ensure pod name contains character name"\n\
    exit 1\n\
fi\n\
\n\
echo "🎭 Detected character: $CHARACTER"\n\
\n\
# Verify training data exists\n\
DATA_FILE="/workspace/autotrain_data/${CHARACTER}_autotrain.jsonl"\n\
if [[ ! -f "$DATA_FILE" ]]; then\n\
    echo "❌ Training data not found: $DATA_FILE"\n\
    echo "Available data files:"\n\
    ls -la /workspace/autotrain_data/\n\
    exit 1\n\
fi\n\
\n\
echo "✅ Training data found: $DATA_FILE"\n\
echo "📊 Examples: $(wc -l < "$DATA_FILE")"\n\
echo ""\n\
\n\
# Move to ai-office directory for training\n\
cd /workspace/ai-office\n\
\n\
# Start training with logging\n\
echo "🚀 Starting $CHARACTER LoRA training..."\n\
echo "========================================="\n\
python3 train_character_lora.py --character "$CHARACTER" 2>&1 | tee "/workspace/${CHARACTER}_training.log"\n\
\n\
echo ""\n\
echo "✅ Training completed for $CHARACTER"\n\
echo "📁 Results in: /workspace/ai-office/lora_models/"\n\
' > /workspace/start_training.sh

# Make startup script executable
RUN chmod +x /workspace/start_training.sh

# Set default command
CMD ["/workspace/start_training.sh"]

# Expose common ports (if needed for monitoring)
EXPOSE 8888 6006

# Add labels
LABEL description="Office LoRA Training Environment"
LABEL version="1.0"
LABEL characters="michael,dwight,creed,erin,toby"