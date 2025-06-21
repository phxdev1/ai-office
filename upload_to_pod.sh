#!/bin/bash

# 📤 UPLOAD TRAINING DATA TO TEST POD
# Quick script to prepare files for upload

echo "📤 PREPARING FILES FOR POD UPLOAD"
echo "=================================="
echo ""

POD_ID="qif3gszlnqrmt4"

echo "🎭 Target Pod: $POD_ID (Michael test pod)"
echo ""

echo "📋 FILES TO UPLOAD:"
echo "==================="

# Check if training data exists
if [[ -f "autotrain_data/michael_autotrain.jsonl" ]]; then
    SIZE=$(du -h "autotrain_data/michael_autotrain.jsonl" | cut -f1)
    echo "✅ michael_autotrain.jsonl ($SIZE)"
else
    echo "❌ michael_autotrain.jsonl (missing)"
fi

# Check if training script exists
if [[ -f "runpod_michael_training.sh" ]]; then
    echo "✅ runpod_michael_training.sh"
else
    echo "❌ runpod_michael_training.sh (missing)"
fi

echo ""
echo "🚀 MANUAL UPLOAD INSTRUCTIONS:"
echo "=============================="
echo ""
echo "Since you're connected to the pod, upload these files manually:"
echo ""

echo "1. 📊 UPLOAD TRAINING DATA:"
echo "   - Copy contents of: autotrain_data/michael_autotrain.jsonl"
echo "   - Create file on pod: /workspace/michael_autotrain.jsonl"
echo ""

echo "2. 🔧 OR CREATE TRAINING SCRIPT DIRECTLY:"
echo "   Copy and paste this training script on the pod:"
echo ""

cat << 'EOF'
# Create the training script directly on the pod:
cat > /workspace/train_michael.py << 'SCRIPT_EOF'
import json
import torch
from transformers import (
    AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import Dataset
import os

print("🎭 Starting Michael Scott LoRA Training...")

# Sample training data (replace with actual data)
sample_data = [
    {
        "messages": [
            {"role": "user", "content": "Respond as Michael from The Office:"},
            {"role": "assistant", "content": "That's what she said!"}
        ]
    },
    {
        "messages": [
            {"role": "user", "content": "What's your management philosophy?"},
            {"role": "assistant", "content": "I'm not a regular boss, I'm a cool boss. Sometimes I'll start a sentence and I don't even know where it's going."}
        ]
    }
]

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

# Load model
print("📥 Loading model...")
model_name = "microsoft/DialoGPT-medium"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.float16,
    device_map="auto"
)

if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

# LoRA config
print("🔧 Setting up LoRA...")
lora_config = LoraConfig(
    task_type=TaskType.CAUSAL_LM,
    inference_mode=False,
    r=8,
    lora_alpha=32,
    lora_dropout=0.1,
    target_modules=["c_attn", "c_proj"]
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

# Prepare training data
print("📊 Preparing training data...")
dataset = Dataset.from_list(sample_data)
dataset = dataset.map(format_training_text)

tokenized_dataset = dataset.map(
    lambda x: tokenize_function(x, tokenizer),
    batched=True,
    remove_columns=dataset.column_names
)

# Data collator
data_collator = DataCollatorForLanguageModeling(
    tokenizer=tokenizer,
    mlm=False,
)

# Training arguments (minimal for testing)
training_args = TrainingArguments(
    output_dir="/workspace/checkpoints",
    overwrite_output_dir=True,
    num_train_epochs=1,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=2,
    learning_rate=5e-5,
    warmup_steps=10,
    logging_steps=1,
    save_steps=10,
    evaluation_strategy="no",
    save_strategy="steps",
    remove_unused_columns=False,
    fp16=torch.cuda.is_available(),
    max_steps=10,  # Just 10 steps for testing
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset,
    data_collator=data_collator,
)

# Train
print("🚀 Starting training...")
trainer.train()

# Save final model
print("💾 Saving model...")
trainer.save_model("/workspace/final_model")
tokenizer.save_pretrained("/workspace/final_model")

print("✅ Michael Scott LoRA training complete!")
SCRIPT_EOF
EOF

echo ""
echo "3. 🚀 RUN INITIAL TEST:"
echo "   cd /workspace"
echo "   python train_michael.py"
echo ""

echo "4. 📊 MONITOR TRAINING:"
echo "   watch -n 5 nvidia-smi"
echo "   (Should show GPU usage)"
echo ""

echo "💡 This creates a minimal test with sample data."
echo "If this works, we can upload the full 24k examples!"