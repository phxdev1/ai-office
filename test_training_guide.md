# 🧪 MICHAEL LORA TRAINING TEST GUIDE

## Pod Info
- **Pod ID**: `qif3gszlnqrmt4`
- **Connect**: `runpod pod connect qif3gszlnqrmt4`

## Once Connected, Run These Commands:

### 1. Check Environment
```bash
pwd
ls -la
nvidia-smi
python --version
```

### 2. Install Dependencies
```bash
pip install transformers datasets peft trl accelerate bitsandbytes torch
```

### 3. Upload Training Files
You'll need to upload these files to `/workspace/`:
- `autotrain_data/michael_autotrain.jsonl` (5.6 MB)
- `runpod_michael_training.sh`

### 4. Manual Training Script (if upload fails)
Create the training script directly:

```bash
cat > /workspace/train_michael.py << 'EOF'
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

# LoRA config
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

# Load training data
print("📊 Loading training data...")
if os.path.exists('/workspace/michael_autotrain.jsonl'):
    raw_data = load_character_data('/workspace/michael_autotrain.jsonl')
    print(f"Loaded {len(raw_data)} training examples")
else:
    print("❌ Training data not found! Upload michael_autotrain.jsonl first")
    exit(1)

dataset = Dataset.from_list(raw_data)
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

# Training arguments
training_args = TrainingArguments(
    output_dir="/workspace/checkpoints",
    overwrite_output_dir=True,
    num_train_epochs=2,  # Start with 2 epochs for testing
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
EOF
```

### 5. Start Training
```bash
cd /workspace
python train_michael.py > training.log 2>&1 &
```

### 6. Monitor Training
```bash
tail -f training.log
```

## Expected Training Time
- **2 epochs**: ~30-45 minutes
- **GPU usage**: Should be 80-100%
- **Memory**: Should be near capacity

## Success Indicators
- ✅ High GPU utilization in `nvidia-smi`
- ✅ Training logs showing progress
- ✅ No error messages
- ✅ Checkpoints being created

## If Successful
Once this test works, we can scale up to all 5 characters!