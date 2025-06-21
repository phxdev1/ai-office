# 🎭 POD TRAINING COMMANDS

## Pod Info
- **Pod ID**: `qif3gszlnqrmt4`
- **Status**: Connected with cloned repo

## Commands to Run on Pod

### 1. Install Dependencies
```bash
pip install transformers datasets peft trl accelerate bitsandbytes torch
```

### 2. Check Setup
```bash
python pod_training_setup.py
```

### 3. Start Training
```bash
python train_michael_lora.py > training.log 2>&1 &
```

### 4. Monitor Training
```bash
# Check logs
tail -f training.log

# Check GPU usage
watch -n 5 nvidia-smi

# Check processes
ps aux | grep python
```

### 5. Check Progress
```bash
# Check checkpoints
ls -la /workspace/checkpoints/

# Check final model
ls -la /workspace/final_model/
```

## Expected Results
- Training should take ~30-45 minutes
- GPU utilization: 80-100%
- Memory usage: Near capacity
- Final model: `/workspace/final_model/`

## Success Indicators
- ✅ High GPU usage in nvidia-smi
- ✅ Training logs showing step progress
- ✅ Checkpoint files being created
- ✅ No CUDA out of memory errors

## If Successful
Scale to all 5 characters with parallel training!