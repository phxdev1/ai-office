#!/bin/bash
echo 'Downloading all trained LoRA models...'
mkdir -p lora_models

# Download michael trained model:
runpod receive office-michael-lora:/workspace/michael_lora.tar.gz ./lora_models/
cd lora_models && tar -xzf michael_lora.tar.gz && mv final_model michael_lora

# Download dwight trained model:
runpod receive office-dwight-lora:/workspace/dwight_lora.tar.gz ./lora_models/
cd lora_models && tar -xzf dwight_lora.tar.gz && mv final_model dwight_lora

# Download creed trained model:
runpod receive office-creed-lora:/workspace/creed_lora.tar.gz ./lora_models/
cd lora_models && tar -xzf creed_lora.tar.gz && mv final_model creed_lora

# Download erin trained model:
runpod receive office-erin-lora:/workspace/erin_lora.tar.gz ./lora_models/
cd lora_models && tar -xzf erin_lora.tar.gz && mv final_model erin_lora

# Download toby trained model:
runpod receive office-toby-lora:/workspace/toby_lora.tar.gz ./lora_models/
cd lora_models && tar -xzf toby_lora.tar.gz && mv final_model toby_lora

echo '🎉 All models downloaded and ready!'
