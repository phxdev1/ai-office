#!/usr/bin/env python3
"""
🎭 MICHAEL SCOTT LORA TRAINING
Complete training script for RunPod
"""

import json
import torch
import os
import time
from transformers import (
    AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import Dataset

def load_character_data(file_path):
    """Load JSONL training data"""
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            data.append(json.loads(line.strip()))
    return data

def format_training_text(example):
    """Format messages for training"""
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
    """Tokenize examples for training"""
    return tokenizer(
        examples["text"],
        truncation=True,
        padding=False,
        max_length=max_length,
        return_overflowing_tokens=False,
    )

def main():
    start_time = time.time()
    
    print("🎭 MICHAEL SCOTT LORA TRAINING")
    print("=" * 40)
    print()
    
    # Environment check
    print("🔍 Environment Check:")
    print(f"   CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"   GPU: {torch.cuda.get_device_name(0)}")
        print(f"   VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f}GB")
    print()
    
    # Load training data
    print("📊 Loading training data...")
    data_file = "autotrain_data/michael_autotrain.jsonl"
    
    if not os.path.exists(data_file):
        print(f"❌ Training data not found: {data_file}")
        return
    
    raw_data = load_character_data(data_file)
    print(f"   Loaded {len(raw_data):,} training examples")
    
    # Sample validation
    print(f"   Sample: {raw_data[0]['messages'][1]['content'][:100]}...")
    print()
    
    # Load model
    print("📥 Loading model...")
    model_name = "microsoft/DialoGPT-medium"
    
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float16,
        device_map="auto",
        load_in_4bit=True
    )
    
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    print(f"   Model loaded: {model_name}")
    print()
    
    # LoRA setup
    print("🔧 Setting up LoRA...")
    lora_config = LoraConfig(
        task_type=TaskType.CAUSAL_LM,
        inference_mode=False,
        r=16,
        lora_alpha=32,
        lora_dropout=0.1,
        target_modules=["c_attn", "c_proj"]
    )
    
    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()
    print()
    
    # Prepare dataset
    print("📊 Preparing dataset...")
    dataset = Dataset.from_list(raw_data)
    dataset = dataset.map(format_training_text)
    
    tokenized_dataset = dataset.map(
        lambda x: tokenize_function(x, tokenizer),
        batched=True,
        remove_columns=dataset.column_names
    )
    
    print(f"   Tokenized {len(tokenized_dataset)} examples")
    print()
    
    # Data collator
    data_collator = DataCollatorForLanguageModeling(
        tokenizer=tokenizer,
        mlm=False,
    )
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir="/workspace/checkpoints",
        overwrite_output_dir=True,
        num_train_epochs=2,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        warmup_steps=100,
        logging_steps=50,
        save_steps=500,
        evaluation_strategy="no",
        save_strategy="steps",
        remove_unused_columns=False,
        fp16=True,
        dataloader_num_workers=2,
        optim="adamw_8bit",
        report_to=[],  # Disable wandb
    )
    
    # Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        data_collator=data_collator,
    )
    
    # Training
    print("🚀 Starting training...")
    print(f"   Epochs: {training_args.num_train_epochs}")
    print(f"   Batch size: {training_args.per_device_train_batch_size}")
    print(f"   Learning rate: {training_args.learning_rate}")
    print()
    
    trainer.train()
    
    # Save model
    print("💾 Saving model...")
    trainer.save_model("/workspace/final_model")
    tokenizer.save_pretrained("/workspace/final_model")
    
    end_time = time.time()
    duration = end_time - start_time
    
    print()
    print("✅ MICHAEL SCOTT LORA TRAINING COMPLETE!")
    print(f"   Duration: {duration/60:.1f} minutes")
    print(f"   Model saved to: /workspace/final_model")
    print()
    print("🎭 'That's what she said!' - Your LoRA is ready!")

if __name__ == "__main__":
    main()