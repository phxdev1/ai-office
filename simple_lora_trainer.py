#!/usr/bin/env python3
"""
Simple LoRA training script for Office characters
Uses basic transformers + PEFT without heavy dependencies
"""

import json
import os
import torch
from transformers import (
    AutoTokenizer, 
    AutoModelForCausalLM, 
    TrainingArguments, 
    Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import Dataset
import argparse

def load_character_data(character_file: str):
    """Load JSONL training data for a character"""
    data = []
    with open(character_file, 'r', encoding='utf-8') as f:
        for line in f:
            data.append(json.loads(line.strip()))
    return data

def format_training_text(example):
    """Format the conversation for training"""
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
    """Tokenize the training data"""
    return tokenizer(
        examples["text"],
        truncation=True,
        padding=False,
        max_length=max_length,
        return_overflowing_tokens=False,
    )

def train_character_lora(character_name: str, data_file: str, output_dir: str):
    """Train a LoRA for a specific character using a small model"""
    print(f"🎭 Training {character_name} LoRA...")
    
    # Use a smaller model that works locally
    model_name = "microsoft/DialoGPT-medium"
    
    print(f"📥 Loading model: {model_name}")
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto" if torch.cuda.is_available() else None
    )
    
    # Add padding token if missing
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    # Configure LoRA
    lora_config = LoraConfig(
        task_type=TaskType.CAUSAL_LM,
        inference_mode=False,
        r=8,
        lora_alpha=32,
        lora_dropout=0.1,
        target_modules=["c_attn", "c_proj"]  # DialoGPT specific
    )
    
    # Apply LoRA to model
    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()
    
    # Load and prepare data
    print(f"📊 Loading training data from {data_file}...")
    raw_data = load_character_data(data_file)
    
    # Convert to dataset and format
    dataset = Dataset.from_list(raw_data)
    dataset = dataset.map(format_training_text)
    
    # Tokenize
    tokenized_dataset = dataset.map(
        lambda x: tokenize_function(x, tokenizer),
        batched=True,
        remove_columns=dataset.column_names
    )
    
    print(f"📈 Training dataset size: {len(tokenized_dataset)} examples")
    
    # Data collator
    data_collator = DataCollatorForLanguageModeling(
        tokenizer=tokenizer,
        mlm=False,
    )
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=f"{output_dir}/{character_name.lower()}_checkpoints",
        overwrite_output_dir=True,
        num_train_epochs=1,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=2,
        learning_rate=5e-5,
        warmup_steps=10,
        logging_steps=10,
        save_steps=100,
        evaluation_strategy="no",
        save_strategy="steps",
        remove_unused_columns=False,
        fp16=torch.cuda.is_available(),
    )
    
    # Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        data_collator=data_collator,
    )
    
    # Train
    print(f"🚀 Starting training for {character_name}...")
    trainer.train()
    
    # Save model
    model_output_dir = f"{output_dir}/{character_name.lower()}_lora"
    trainer.save_model(model_output_dir)
    tokenizer.save_pretrained(model_output_dir)
    
    print(f"✅ {character_name} LoRA saved to {model_output_dir}")
    
    return model_output_dir

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--character", required=True, choices=["michael", "dwight", "creed", "erin", "toby"])
    parser.add_argument("--data_dir", default="autotrain_data")
    parser.add_argument("--output_dir", default="lora_models")
    args = parser.parse_args()
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Map character to data file
    data_file = f"{args.data_dir}/{args.character}_autotrain.jsonl"
    
    if not os.path.exists(data_file):
        print(f"❌ Data file not found: {data_file}")
        return
    
    # Train the LoRA
    try:
        model_path = train_character_lora(
            character_name=args.character.capitalize(),
            data_file=data_file,
            output_dir=args.output_dir
        )
        
        print(f"🎉 Training complete! Model saved to: {model_path}")
        
    except Exception as e:
        print(f"❌ Training failed: {e}")
        print("Try running with CPU fallback...")

if __name__ == "__main__":
    main()