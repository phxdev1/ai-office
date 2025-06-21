# 🤖 POD AUTO-STARTUP COMMANDS

## For Each Character Pod

Connect to each pod and run these commands to set up auto-training:

### Dwight Pod (qnk50v3f4necn8)
```bash
runpod pod connect qnk50v3f4necn8

# Copy startup script
cat > /workspace/startup.sh << 'EOF'
#!/bin/bash
cd /workspace
git clone https://github.com/phxdev1/ai-office.git
cd ai-office
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch
python train_character_lora.py --character dwight > /workspace/dwight_training.log 2>&1
EOF

chmod +x /workspace/startup.sh
nohup /workspace/startup.sh &
exit
```

### Creed Pod (d2r106j5n3btcc)
```bash
runpod pod connect d2r106j5n3btcc

cat > /workspace/startup.sh << 'EOF'
#!/bin/bash
cd /workspace
git clone https://github.com/phxdev1/ai-office.git
cd ai-office
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch
python train_character_lora.py --character creed > /workspace/creed_training.log 2>&1
EOF

chmod +x /workspace/startup.sh
nohup /workspace/startup.sh &
exit
```

### Erin Pod (t61imb6b25bfk4)
```bash
runpod pod connect t61imb6b25bfk4

cat > /workspace/startup.sh << 'EOF'
#!/bin/bash
cd /workspace
git clone https://github.com/phxdev1/ai-office.git
cd ai-office
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch
python train_character_lora.py --character erin > /workspace/erin_training.log 2>&1
EOF

chmod +x /workspace/startup.sh
nohup /workspace/startup.sh &
exit
```

### Toby Pod (og6vk9s808c1b6)
```bash
runpod pod connect og6vk9s808c1b6

cat > /workspace/startup.sh << 'EOF'
#!/bin/bash
cd /workspace
git clone https://github.com/phxdev1/ai-office.git
cd ai-office
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch
python train_character_lora.py --character toby > /workspace/toby_training.log 2>&1
EOF

chmod +x /workspace/startup.sh
nohup /workspace/startup.sh &
exit
```

### Michael Pod (qif3gszlnqrmt4) - Already has repo
```bash
runpod pod connect qif3gszlnqrmt4

cd ai-office
pip install --no-cache-dir unsloth[cu121-torch240] transformers datasets trl torch
nohup python train_character_lora.py --character michael > /workspace/michael_training.log 2>&1 &
exit
```

## Monitor All Training
After setting up all pods, check progress:

```bash
# Check pod status
runpod pod list

# Check logs (connect to each pod):
tail -f /workspace/*_training.log
```

## Expected Timeline
- **Setup**: 5 minutes per pod
- **Training**: 30-45 minutes parallel
- **Total**: ~50 minutes for all 5 characters

## Cost Estimate
- **5 RTX A5000 pods**: ~$0.50/hour each
- **Total runtime**: ~1 hour
- **Total cost**: ~$2.50

🔥 **Datacenter temperature increase: +3°F**