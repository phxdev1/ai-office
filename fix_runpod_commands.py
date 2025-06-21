#!/usr/bin/env python3
"""
Fix RunPod commands - get actual pod IDs and create proper execution scripts
"""

def create_fixed_scripts():
    """Create scripts that work with actual RunPod pod IDs"""
    
    print("🔧 FIXING RUNPOD COMMANDS")
    print("=" * 50)
    
    # First, let's check what pods exist
    check_pods_script = """#!/bin/bash
echo "🔍 Checking existing RunPod instances..."
runpod list pods

echo ""
echo "📋 Pod Status Check:"
echo "Look for pods with names containing 'office' or 'michael', 'dwight', etc."
echo ""
echo "If no Office pods exist, run the create commands first:"
echo "./create_michael_pod.sh"
echo "./create_dwight_pod.sh" 
echo "./create_creed_pod.sh"
echo "./create_erin_pod.sh"
echo "./create_toby_pod.sh"
"""
    
    with open("check_pods.sh", 'w') as f:
        f.write(check_pods_script)
    
    # Create a script to get pod IDs and create proper exec commands
    get_pod_ids_script = """#!/bin/bash
echo "🎯 Getting RunPod IDs for Office training..."

# Get pod list and extract IDs
PODS=$(runpod list pods --output json)

echo "📋 Available pods:"
runpod list pods

echo ""
echo "🔧 To execute training on a specific pod:"
echo "1. Find your pod ID from the list above"
echo "2. Replace POD_ID with actual ID in commands below:"
echo ""

echo "# Upload training data to specific pod:"
echo "runpod send autotrain_data/michael_autotrain.jsonl POD_ID:/workspace/"
echo "runpod send runpod_michael_training.sh POD_ID:/workspace/"
echo ""

echo "# Execute training on specific pod:"
echo "runpod exec POD_ID 'chmod +x /workspace/runpod_michael_training.sh'"
echo "runpod exec POD_ID 'cd /workspace && bash runpod_michael_training.sh'"
echo ""

echo "# Download results from specific pod:"
echo "runpod receive POD_ID:/workspace/michael_lora.tar.gz ./lora_models/"
echo ""

echo "💡 TIP: Copy the pod ID from the list above and replace POD_ID in the commands"
"""
    
    with open("get_pod_ids.sh", 'w') as f:
        f.write(get_pod_ids_script)
    
    # Create a template for manual execution
    manual_template = """#!/bin/bash
# MANUAL RUNPOD EXECUTION TEMPLATE
# Replace POD_ID_X with actual pod IDs from 'runpod list pods'

echo "🎭 Manual Office LoRA Training Execution"
echo "========================================"

# Step 1: Check pods exist
echo "1. Checking pods..."
runpod list pods

echo ""
echo "2. Upload training data (replace POD_IDs):"

# Michael (replace POD_ID_MICHAEL with actual ID)
echo "# Michael LoRA:"
echo "runpod send autotrain_data/michael_autotrain.jsonl POD_ID_MICHAEL:/workspace/"
echo "runpod send runpod_michael_training.sh POD_ID_MICHAEL:/workspace/"
echo "runpod exec POD_ID_MICHAEL 'chmod +x /workspace/runpod_michael_training.sh'"
echo "runpod exec POD_ID_MICHAEL 'cd /workspace && nohup bash runpod_michael_training.sh > training.log 2>&1 &'"

echo ""
echo "# Dwight LoRA:"
echo "runpod send autotrain_data/dwight_autotrain.jsonl POD_ID_DWIGHT:/workspace/"
echo "runpod send runpod_dwight_training.sh POD_ID_DWIGHT:/workspace/"
echo "runpod exec POD_ID_DWIGHT 'chmod +x /workspace/runpod_dwight_training.sh'"
echo "runpod exec POD_ID_DWIGHT 'cd /workspace && nohup bash runpod_dwight_training.sh > training.log 2>&1 &'"

echo ""
echo "# Creed LoRA:"
echo "runpod send autotrain_data/creed_autotrain.jsonl POD_ID_CREED:/workspace/"
echo "runpod send runpod_creed_training.sh POD_ID_CREED:/workspace/"
echo "runpod exec POD_ID_CREED 'chmod +x /workspace/runpod_creed_training.sh'"
echo "runpod exec POD_ID_CREED 'cd /workspace && nohup bash runpod_creed_training.sh > training.log 2>&1 &'"

echo ""
echo "# Erin LoRA:"
echo "runpod send autotrain_data/erin_autotrain.jsonl POD_ID_ERIN:/workspace/"
echo "runpod send runpod_erin_training.sh POD_ID_ERIN:/workspace/"
echo "runpod exec POD_ID_ERIN 'chmod +x /workspace/runpod_erin_training.sh'"
echo "runpod exec POD_ID_ERIN 'cd /workspace && nohup bash runpod_erin_training.sh > training.log 2>&1 &'"

echo ""
echo "# Toby LoRA:"
echo "runpod send autotrain_data/toby_autotrain.jsonl POD_ID_TOBY:/workspace/"
echo "runpod send runpod_toby_training.sh POD_ID_TOBY:/workspace/"
echo "runpod exec POD_ID_TOBY 'chmod +x /workspace/runpod_toby_training.sh'"
echo "runpod exec POD_ID_TOBY 'cd /workspace && nohup bash runpod_toby_training.sh > training.log 2>&1 &'"

echo ""
echo "3. Monitor training:"
echo "runpod exec POD_ID 'tail -f /workspace/training.log'"

echo ""
echo "4. Download results when complete:"
echo "runpod receive POD_ID_MICHAEL:/workspace/michael_lora.tar.gz ./lora_models/"
echo "runpod receive POD_ID_DWIGHT:/workspace/dwight_lora.tar.gz ./lora_models/"
echo "runpod receive POD_ID_CREED:/workspace/creed_lora.tar.gz ./lora_models/"
echo "runpod receive POD_ID_ERIN:/workspace/erin_lora.tar.gz ./lora_models/"
echo "runpod receive POD_ID_TOBY:/workspace/toby_lora.tar.gz ./lora_models/"
"""
    
    with open("manual_training.sh", 'w') as f:
        f.write(manual_template)
    
    # Make scripts executable
    import os
    os.chmod("check_pods.sh", 0o755)
    os.chmod("get_pod_ids.sh", 0o755) 
    os.chmod("manual_training.sh", 0o755)
    
    print("✅ Fixed scripts created:")
    print("   check_pods.sh - Check existing pods")
    print("   get_pod_ids.sh - Get pod IDs and commands")
    print("   manual_training.sh - Manual execution template")
    print()
    print("🔧 NEXT STEPS:")
    print("1. Run: ./check_pods.sh")
    print("2. If no pods exist, create them with the create_*_pod.sh scripts")
    print("3. Run: ./get_pod_ids.sh to get actual pod IDs")
    print("4. Use manual_training.sh as template with real pod IDs")

if __name__ == "__main__":
    create_fixed_scripts()