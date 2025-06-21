#!/usr/bin/env python3
"""
🎭 MICHAEL SCOTT LORA TRAINING SETUP
Direct training script for RunPod environment
"""

import json
import torch
import os
from transformers import (
    AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import Dataset

def main():
    print("🎭 MICHAEL SCOTT LORA TRAINING SETUP")
    print("=" * 40)
    print()
    
    # Check environment
    print("🔍 Environment Check:")
    print(f"   Working directory: {os.getcwd()}")
    print(f"   CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"   GPU: {torch.cuda.get_device_name(0)}")
        print(f"   VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f}GB")
    print()
    
    # Check for training data
    data_file = "autotrain_data/michael_autotrain.jsonl"
    if os.path.exists(data_file):
        with open(data_file, 'r') as f:
            sample_count = sum(1 for _ in f)
        print(f"✅ Training data found: {sample_count:,} examples")
        
        # Show sample
        with open(data_file, 'r') as f:
            sample = json.loads(f.readline())
        print(f"📄 Sample format: {json.dumps(sample, indent=2)}")
    else:
        print(f"❌ Training data not found: {data_file}")
        print("   Make sure autotrain_data/michael_autotrain.jsonl exists")
        return
    
    print()
    print("🚀 READY FOR TRAINING!")
    print("Next steps:")
    print("1. pip install transformers datasets peft trl accelerate bitsandbytes")
    print("2. python train_michael_lora.py")

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

if __name__ == "__main__":
    main()