#!/usr/bin/env python3
"""
Train individual character LoRAs using Unsloth
Fast local training for Office character models
"""

import json
import argparse
import os
from datasets import Dataset
import torch
from transformers import TrainingArguments
from unsloth import FastLanguageModel
from trl import SFTTrainer

def load_character_data(character_file: str):
    """Load JSONL training data for a character"""
    data = []
    with open(character_file, 'r', encoding='utf-8') as f:
        for line in f:
            data.append(json.loads(line.strip()))
    return data

def format_chat_template(example):
    """Format the conversation for training"""
    messages = example['messages']
    text = ""
    for message in messages:
        if message['role'] == 'user':
            text += f"<|im_start|>user\n{message['content']}<|im_end|>\n"
        elif message['role'] == 'assistant':
            text += f"<|im_start|>assistant\n{message['content']}<|im_end|>\n"
    return {"text": text}

def train_character_lora(character_name: str, data_file: str, output_dir: str):
    """Train a LoRA for a specific character"""
    print(f"🎭 Training {character_name} LoRA...")
    
    # Load model
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name="unsloth/llama-3.2-3b-instruct-bnb-4bit",
        max_seq_length=2048,
        dtype=None,
        load_in_4bit=True,
    )
    
    # Add LoRA adapters
    model = FastLanguageModel.get_peft_model(
        model,
        r=16,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                       "gate_proj", "up_proj", "down_proj"],
        lora_alpha=16,
        lora_dropout=0,
        bias="none",
        use_gradient_checkpointing="unsloth",
        random_state=3407,
        use_rslora=False,
        loftq_config=None,
    )
    
    # Load and prepare data
    print(f"📊 Loading training data from {data_file}...")
    raw_data = load_character_data(data_file)
    
    # Convert to dataset and format
    dataset = Dataset.from_list(raw_data)
    dataset = dataset.map(format_chat_template)
    
    print(f"📈 Training dataset size: {len(dataset)} examples")
    
    # Training arguments - MAXIMUM POWER MODE 🔥
    training_args = TrainingArguments(
        per_device_train_batch_size=8,  # Max batch size for RTX 3090
        gradient_accumulation_steps=1,  # No accumulation, pure speed
        warmup_steps=100,
        num_train_epochs=12,  # 12 epochs for proper training
        learning_rate=5e-4,  # Higher learning rate for faster convergence
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        logging_steps=10,
        optim="adamw_torch_fused",  # Fused optimizer for speed
        weight_decay=0.01,
        lr_scheduler_type="cosine",
        seed=3407,
        output_dir=f"{output_dir}/{character_name.lower()}_checkpoints",
        save_strategy="epoch",
        save_steps=500,
        remove_unused_columns=False,
        dataloader_num_workers=8,  # Max CPU workers for data loading
        tf32=True,  # Enable TF32 for Ampere GPUs
        gradient_checkpointing=False,  # Disable for max speed
    )
    
    # Trainer
    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=dataset,
        dataset_text_field="text",
        max_seq_length=2048,
        dataset_num_proc=2,
        args=training_args,
    )
    
    # Train
    print(f"🚀 Starting training for {character_name}...")
    trainer.train()
    
    # Save model
    model_output_dir = f"{output_dir}/{character_name.lower()}_lora"
    trainer.model.save_pretrained(model_output_dir)
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
    model_path = train_character_lora(
        character_name=args.character.capitalize(),
        data_file=data_file,
        output_dir=args.output_dir
    )
    
    print(f"🎉 Training complete! Model saved to: {model_path}")

if __name__ == "__main__":
    main()