#!/usr/bin/env python3
"""
Launch All Office LoRA Training Jobs in Parallel
Mass deployment script for RunPod training army
"""

import subprocess
import time
import os
from concurrent.futures import ThreadPoolExecutor
from typing import List

# All character configs
CHARACTERS = {
    'michael': {
        'examples': 24351,
        'data_size': '5.6 MB',
        'priority': 'HIGH',
        'gpu_type': 'RTX A5000'
    },
    'dwight': {
        'examples': 14983,
        'data_size': '3.2 MB', 
        'priority': 'HIGH',
        'gpu_type': 'RTX A5000'
    },
    'creed': {
        'examples': 905,
        'data_size': '0.2 MB',
        'priority': 'MEDIUM',
        'gpu_type': 'RTX A4000'  # Smaller model
    },
    'erin': {
        'examples': 2919,
        'data_size': '0.6 MB',
        'priority': 'MEDIUM', 
        'gpu_type': 'RTX A4000'
    },
    'toby': {
        'examples': 1861,
        'data_size': '0.4 MB',
        'priority': 'MEDIUM',
        'gpu_type': 'RTX A4000'
    }
}

def create_runpod_command(character: str, config: dict) -> str:
    """Generate RunPod CLI command for character"""
    return f"""runpod create pod \\
  --name "office-{character}-lora" \\
  --image-name "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04" \\
  --gpu-type "{config['gpu_type']}" \\
  --container-disk-in-gb 50 \\
  --env CHARACTER_NAME={character} \\
  --env DATA_FILE={character}_autotrain.jsonl \\
  --env WANDB_DISABLED=true"""

def create_upload_commands(character: str) -> List[str]:
    """Create commands to upload training data to pod"""
    return [
        f"# Upload {character} training data:",
        f"runpod send {character}_autotrain.jsonl office-{character}-lora:/workspace/",
        f"runpod send runpod_{character}_training.sh office-{character}-lora:/workspace/"
    ]

def create_training_commands(character: str) -> List[str]:
    """Create commands to start training on pod"""
    return [
        f"# Start {character} training:",
        f'runpod exec office-{character}-lora "chmod +x /workspace/runpod_{character}_training.sh"',
        f'runpod exec office-{character}-lora "cd /workspace && bash runpod_{character}_training.sh"'
    ]

def main():
    print("🚀" * 20)
    print("THE OFFICE LORA TRAINING ARMY DEPLOYMENT")
    print("🚀" * 20)
    print()
    
    print("📊 TRAINING OVERVIEW:")
    total_examples = sum(config['examples'] for config in CHARACTERS.values())
    print(f"   Total Examples: {total_examples:,}")
    print(f"   Total Characters: {len(CHARACTERS)}")
    print(f"   Estimated Time: 1 hour (parallel)")
    print(f"   Estimated Cost: ~$3.00")
    print()
    
    # Show character breakdown
    print("🎭 CHARACTER BREAKDOWN:")
    for char, config in CHARACTERS.items():
        print(f"   {char.upper():>7}: {config['examples']:>6,} examples ({config['data_size']:>6}) - {config['priority']} priority - {config['gpu_type']}")
    print()
    
    print("=" * 80)
    print("STEP 1: CREATE ALL RUNPOD INSTANCES")
    print("=" * 80)
    
    # Generate all pod creation commands
    for i, (character, config) in enumerate(CHARACTERS.items(), 1):
        print(f"\n{i}. CREATE {character.upper()} POD:")
        print("-" * 40)
        command = create_runpod_command(character, config)
        print(command)
        print()
        
        # Save command to file for easy execution
        with open(f"create_{character}_pod.sh", 'w') as f:
            f.write("#!/bin/bash\n")
            f.write(f"echo 'Creating {character} LoRA training pod...'\n")
            f.write(command.replace(" \\", "") + "\n")
            f.write(f"echo '✅ {character} pod created!'\n")
        
        os.chmod(f"create_{character}_pod.sh", 0o755)
        print(f"💾 Saved: create_{character}_pod.sh")
    
    print("\n" + "=" * 80)
    print("STEP 2: UPLOAD TRAINING DATA TO ALL PODS")
    print("=" * 80)
    
    upload_commands = []
    for character in CHARACTERS.keys():
        commands = create_upload_commands(character)
        upload_commands.extend(commands)
        upload_commands.append("")
    
    # Save upload script
    with open("upload_all_data.sh", 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("echo 'Uploading training data to all pods...'\n\n")
        for cmd in upload_commands:
            if cmd.startswith("#"):
                f.write(f"{cmd}\n")
            elif cmd.strip():
                f.write(f"{cmd}\n")
            else:
                f.write("\n")
        f.write("echo '✅ All training data uploaded!'\n")
    
    os.chmod("upload_all_data.sh", 0o755)
    
    for cmd in upload_commands:
        print(cmd)
    
    print("\n" + "=" * 80)
    print("STEP 3: START ALL TRAINING JOBS")
    print("=" * 80)
    
    training_commands = []
    for character in CHARACTERS.keys():
        commands = create_training_commands(character)
        training_commands.extend(commands)
        training_commands.append("")
    
    # Save training script
    with open("start_all_training.sh", 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("echo 'Starting all LoRA training jobs in parallel...'\n\n")
        for cmd in training_commands:
            if cmd.startswith("#"):
                f.write(f"{cmd}\n")
            elif cmd.strip():
                f.write(f"{cmd} &\n")  # Run in background
            else:
                f.write("\n")
        f.write("wait\n")  # Wait for all jobs to complete
        f.write("echo '🎉 All training jobs completed!'\n")
    
    os.chmod("start_all_training.sh", 0o755)
    
    for cmd in training_commands:
        print(cmd)
    
    print("\n" + "=" * 80)
    print("STEP 4: DOWNLOAD ALL TRAINED MODELS")
    print("=" * 80)
    
    download_commands = []
    for character in CHARACTERS.keys():
        download_commands.extend([
            f"# Download {character} trained model:",
            f"runpod receive office-{character}-lora:/workspace/{character}_lora.tar.gz ./lora_models/",
            f"cd lora_models && tar -xzf {character}_lora.tar.gz && mv final_model {character}_lora",
            ""
        ])
    
    # Save download script
    with open("download_all_models.sh", 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("echo 'Downloading all trained LoRA models...'\n")
        f.write("mkdir -p lora_models\n\n")
        for cmd in download_commands:
            if cmd.startswith("#"):
                f.write(f"{cmd}\n")
            elif cmd.strip():
                f.write(f"{cmd}\n")
            else:
                f.write("\n")
        f.write("echo '🎉 All models downloaded and ready!'\n")
    
    os.chmod("download_all_models.sh", 0o755)
    
    for cmd in download_commands:
        print(cmd)
    
    print("\n" + "🔥" * 80)
    print("EXECUTION PLAN - FIRE ALL PODS AT ONCE!")
    print("🔥" * 80)
    
    execution_plan = """
🎯 PARALLEL DEPLOYMENT STRATEGY:

1. CREATE ALL PODS (2 minutes):
   ./create_michael_pod.sh &
   ./create_dwight_pod.sh &
   ./create_creed_pod.sh &
   ./create_erin_pod.sh &
   ./create_toby_pod.sh &
   wait

2. UPLOAD ALL DATA (5 minutes):
   ./upload_all_data.sh

3. START ALL TRAINING (1 hour):
   ./start_all_training.sh

4. DOWNLOAD ALL MODELS (5 minutes):
   ./download_all_models.sh

5. INTEGRATE WITH BALLS:
   python lora_balls_integration.py

💰 TOTAL COST ESTIMATE:
   - 2x RTX A5000 (Michael, Dwight): $0.50/hr × 2 × 1hr = $1.00
   - 3x RTX A4000 (Creed, Erin, Toby): $0.35/hr × 3 × 1hr = $1.05
   - TOTAL: ~$2.05 for complete Office LoRA army

⏱️  TOTAL TIME: ~1.2 hours from start to finish

🎭 RESULT: 5 trained character LoRAs ready for BALLS orchestration!
"""
    
    print(execution_plan)
    
    print("\n📋 FILES CREATED:")
    files = [
        "create_michael_pod.sh", "create_dwight_pod.sh", "create_creed_pod.sh", 
        "create_erin_pod.sh", "create_toby_pod.sh",
        "upload_all_data.sh", "start_all_training.sh", "download_all_models.sh"
    ]
    for file in files:
        print(f"   ✅ {file}")
    
    print(f"\n🚀 READY TO LAUNCH THE OFFICE LORA ARMY!")
    print(f"Run: ./create_michael_pod.sh && ./create_dwight_pod.sh && ./create_creed_pod.sh && ./create_erin_pod.sh && ./create_toby_pod.sh")

if __name__ == "__main__":
    main()