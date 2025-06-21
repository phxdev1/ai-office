
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
            text += f"<|user|>\n{message['content']}\n"
        elif message['role'] == 'assistant':
            text += f"<|assistant|>\n{message['content']}\n"
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
