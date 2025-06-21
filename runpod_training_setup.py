#!/usr/bin/env python3
"""
RunPod Training Setup for Office Character LoRAs
Sets up parallel training jobs for all 5 characters
"""

import os
import json
import requests
from typing import Dict, List

# RunPod training script for each character
RUNPOD_TRAINING_SCRIPT = """
#!/bin/bash
set -e

echo "🚀 Starting Office Character LoRA Training on RunPod"
echo "Character: $CHARACTER_NAME"
echo "Data file: $DATA_FILE"

# Install dependencies
pip install transformers datasets peft trl accelerate bitsandbytes

# Download training data
wget -O /workspace/training_data.jsonl "$DATA_URL"

# Training script
cat > /workspace/train_lora.py << 'EOF'
import json
import torch
from transformers import (
    AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import Dataset
import os

def load_character_data(file_path):
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            data.append(json.loads(line.strip()))
    return data

def format_training_text(example):
    messages = example['messages']
    text = ""
    for message in messages:
        if message['role'] == 'user':
            text += f"<|user|>\\n{message['content']}\\n"
        elif message['role'] == 'assistant':
            text += f"<|assistant|>\\n{message['content']}\\n"
    text += "<|endoftext|>"
    return {"text": text}

def tokenize_function(examples, tokenizer, max_length=512):
    return tokenizer(
        examples["text"],
        truncation=True,
        padding=False,
        max_length=max_length,
        return_overflowing_tokens=False,
    )

# Load model - use Llama for better results
model_name = "meta-llama/Llama-3.2-3B-Instruct"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.float16,
    device_map="auto",
    load_in_4bit=True
)

if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

# LoRA config
lora_config = LoraConfig(
    task_type=TaskType.CAUSAL_LM,
    inference_mode=False,
    r=16,
    lora_alpha=32,
    lora_dropout=0.1,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

# Load and prepare data
print(f"Loading training data...")
raw_data = load_character_data('/workspace/training_data.jsonl')
dataset = Dataset.from_list(raw_data)
dataset = dataset.map(format_training_text)

tokenized_dataset = dataset.map(
    lambda x: tokenize_function(x, tokenizer),
    batched=True,
    remove_columns=dataset.column_names
)

print(f"Training dataset size: {len(tokenized_dataset)} examples")

# Data collator
data_collator = DataCollatorForLanguageModeling(
    tokenizer=tokenizer,
    mlm=False,
)

# Training arguments - optimized for RunPod
training_args = TrainingArguments(
    output_dir="/workspace/checkpoints",
    overwrite_output_dir=True,
    num_train_epochs=3,
    per_device_train_batch_size=8,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    warmup_steps=100,
    logging_steps=50,
    save_steps=500,
    evaluation_strategy="no",
    save_strategy="steps",
    remove_unused_columns=False,
    fp16=True,
    dataloader_num_workers=4,
    optim="adamw_8bit",
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset,
    data_collator=data_collator,
)

# Train
print(f"Starting training...")
trainer.train()

# Save final model
trainer.save_model("/workspace/final_model")
tokenizer.save_pretrained("/workspace/final_model")

print("Training complete!")
EOF

# Run training
python /workspace/train_lora.py

# Compress results
cd /workspace
tar -czf ${CHARACTER_NAME}_lora.tar.gz final_model/

echo "✅ Training complete for $CHARACTER_NAME"
echo "Model saved as ${CHARACTER_NAME}_lora.tar.gz"
"""

def create_runpod_jobs():
    """Create RunPod training jobs for all characters"""
    
    characters = {
        'michael': {'examples': 24351, 'priority': 'high'},
        'dwight': {'examples': 14983, 'priority': 'high'}, 
        'creed': {'examples': 905, 'priority': 'medium'},
        'erin': {'examples': 2919, 'priority': 'medium'},
        'toby': {'examples': 1861, 'priority': 'medium'}
    }
    
    # Upload training data to a public host (GitHub, S3, etc.)
    # For now, create job configs that can be manually executed
    
    job_configs = []
    
    for character, info in characters.items():
        job_config = {
            'character': character,
            'examples': info['examples'],
            'priority': info['priority'],
            'runpod_config': {
                'image': 'runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04',
                'gpu_type': 'RTX A5000',  # Good price/performance for LoRA
                'container_disk_in_gb': 50,
                'volume_in_gb': 0,
                'env': {
                    'CHARACTER_NAME': character,
                    'DATA_FILE': f'{character}_autotrain.jsonl',
                    'DATA_URL': f'https://your-server.com/data/{character}_autotrain.jsonl'  # Replace with actual URL
                }
            },
            'training_script': RUNPOD_TRAINING_SCRIPT
        }
        job_configs.append(job_config)
    
    return job_configs

def generate_runpod_commands():
    """Generate RunPod CLI commands to start training"""
    
    job_configs = create_runpod_jobs()
    
    print("🔥 RUNPOD TRAINING COMMANDS FOR OFFICE LORAS")
    print("=" * 60)
    
    for i, config in enumerate(job_configs, 1):
        character = config['character']
        examples = config['examples']
        priority = config['priority']
        
        print(f"\n{i}. {character.upper()} LoRA ({examples:,} examples - {priority} priority)")
        print("-" * 40)
        
        # Save training script
        script_file = f"runpod_{character}_training.sh"
        with open(script_file, 'w') as f:
            f.write(config['training_script'])
        
        print(f"📄 Training script saved: {script_file}")
        
        # RunPod command
        print(f"🚀 RunPod Command:")
        print(f"runpod create pod \\")
        print(f"  --name \"office-{character}-lora\" \\")
        print(f"  --image-name \"runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04\" \\")
        print(f"  --gpu-type \"RTX A5000\" \\")
        print(f"  --container-disk-in-gb 50 \\")
        print(f"  --env CHARACTER_NAME={character} \\")
        print(f"  --env DATA_FILE={character}_autotrain.jsonl")
        
        print(f"\n📋 Manual Setup:")
        print(f"1. Upload {character}_autotrain.jsonl to RunPod pod")
        print(f"2. Run: bash runpod_{character}_training.sh")
        print(f"3. Download: {character}_lora.tar.gz")

def upload_training_data():
    """Instructions for uploading training data"""
    
    print("\n📤 TRAINING DATA UPLOAD INSTRUCTIONS")
    print("=" * 50)
    
    characters = ['michael', 'dwight', 'creed', 'erin', 'toby']
    
    print("Upload these files to your RunPod instances:")
    for character in characters:
        file_path = f"autotrain_data/{character}_autotrain.jsonl"
        if os.path.exists(file_path):
            size_mb = os.path.getsize(file_path) / (1024 * 1024)
            print(f"  ✅ {file_path} ({size_mb:.1f} MB)")
        else:
            print(f"  ❌ {file_path} (missing)")
    
    print(f"\n💡 Quick upload commands for RunPod:")
    print(f"# In RunPod terminal:")
    for character in characters:
        print(f"wget https://your-server.com/{character}_autotrain.jsonl")

def main():
    print("🎬 THE OFFICE LORA TRAINING - RUNPOD EDITION")
    print("=" * 60)
    
    # Generate commands and scripts
    generate_runpod_commands()
    
    # Upload instructions
    upload_training_data()
    
    print(f"\n🎯 EXECUTION PLAN:")
    print(f"1. Start with Michael & Dwight (high priority, most data)")
    print(f"2. Train Creed, Erin, Toby in parallel")
    print(f"3. Each training should take 30-60 minutes on RTX A5000")
    print(f"4. Download trained models and integrate with BALLS")
    
    print(f"\n💰 Estimated Cost:")
    print(f"- RTX A5000: ~$0.50/hour")
    print(f"- 5 characters × 1 hour each = ~$2.50 total")
    print(f"- Parallel training: ~$2.50 in 1 hour")
    
    print(f"\n🚀 Ready to launch Office LoRA training army!")

if __name__ == "__main__":
    main()