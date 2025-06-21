#!/bin/bash

# 🎭 MANUAL OFFICE LORA TRAINING WITH ACTUAL POD IDS
# All 5 pods are RUNNING - let's train them manually!

# Actual pod IDs from runpod pod list
MICHAEL_POD="c8f4kltejbur9o"
DWIGHT_POD="ktje5dbtop7xv5"
CREED_POD="afzer9vb7qtv4o" 
ERIN_POD="15ifa0nxsbapv8"
TOBY_POD="iycmf9q0ubolfw"

echo "🎬 OFFICE LORA TRAINING - MANUAL EXECUTION"
echo "=========================================="
echo ""
echo "Pod IDs:"
echo "Michael: $MICHAEL_POD"
echo "Dwight:  $DWIGHT_POD"
echo "Creed:   $CREED_POD"
echo "Erin:    $ERIN_POD"
echo "Toby:    $TOBY_POD"
echo ""

# Check file transfer commands
echo "🔍 Checking file transfer options..."
runpod pod --help

echo ""
echo "📤 STEP 1: Upload training data and scripts"
echo "============================================"

# We need to use the correct file transfer method
# Let's try using pod connect or ssh

echo "# Connect to Michael pod and upload data:"
echo "runpod pod connect $MICHAEL_POD"
echo "# Then upload files manually or use scp"

echo ""
echo "📋 ALTERNATIVE: Connect to each pod individually"
echo "==============================================="

echo ""
echo "1. Michael LoRA (24,351 examples):"
echo "   runpod pod connect $MICHAEL_POD"
echo "   # Upload: autotrain_data/michael_autotrain.jsonl"
echo "   # Upload: runpod_michael_training.sh"
echo "   # Run: bash runpod_michael_training.sh"

echo ""
echo "2. Dwight LoRA (14,983 examples):"
echo "   runpod pod connect $DWIGHT_POD"
echo "   # Upload: autotrain_data/dwight_autotrain.jsonl"
echo "   # Upload: runpod_dwight_training.sh"
echo "   # Run: bash runpod_dwight_training.sh"

echo ""
echo "3. Creed LoRA (905 examples):"
echo "   runpod pod connect $CREED_POD"
echo "   # Upload: autotrain_data/creed_autotrain.jsonl"
echo "   # Upload: runpod_creed_training.sh"
echo "   # Run: bash runpod_creed_training.sh"

echo ""
echo "4. Erin LoRA (2,919 examples):"
echo "   runpod pod connect $ERIN_POD"
echo "   # Upload: autotrain_data/erin_autotrain.jsonl"
echo "   # Upload: runpod_erin_training.sh"
echo "   # Run: bash runpod_erin_training.sh"

echo ""
echo "5. Toby LoRA (1,861 examples):"
echo "   runpod pod connect $TOBY_POD"
echo "   # Upload: autotrain_data/toby_autotrain.jsonl"
echo "   # Upload: runpod_toby_training.sh"
echo "   # Run: bash runpod_toby_training.sh"

echo ""
echo "🎯 QUICK START FOR MICHAEL (Priority 1):"
echo "========================================"
echo "runpod pod connect $MICHAEL_POD"

echo ""
echo "💡 TRAINING COMMANDS ONCE CONNECTED:"
echo "==================================="
echo ""
echo "# Install dependencies:"
echo "pip install transformers datasets peft trl accelerate bitsandbytes torch"
echo ""
echo "# Create training script (copy runpod_michael_training.sh content)"
echo "# Upload training data (michael_autotrain.jsonl)"
echo "# Run training:"
echo "bash runpod_michael_training.sh"

echo ""
echo "🔥 ESTIMATED TRAINING TIME: 1 hour per character"
echo "🔥 START WITH MICHAEL AND DWIGHT (highest priority)"
echo "🔥 All pods are RUNNING and ready!"