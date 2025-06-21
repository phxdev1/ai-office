#!/bin/bash
echo 'Starting all LoRA training jobs in parallel...'

# Start michael training:
runpod exec office-michael-lora "chmod +x /workspace/runpod_michael_training.sh" &
runpod exec office-michael-lora "cd /workspace && bash runpod_michael_training.sh" &

# Start dwight training:
runpod exec office-dwight-lora "chmod +x /workspace/runpod_dwight_training.sh" &
runpod exec office-dwight-lora "cd /workspace && bash runpod_dwight_training.sh" &

# Start creed training:
runpod exec office-creed-lora "chmod +x /workspace/runpod_creed_training.sh" &
runpod exec office-creed-lora "cd /workspace && bash runpod_creed_training.sh" &

# Start erin training:
runpod exec office-erin-lora "chmod +x /workspace/runpod_erin_training.sh" &
runpod exec office-erin-lora "cd /workspace && bash runpod_erin_training.sh" &

# Start toby training:
runpod exec office-toby-lora "chmod +x /workspace/runpod_toby_training.sh" &
runpod exec office-toby-lora "cd /workspace && bash runpod_toby_training.sh" &

wait
echo '🎉 All training jobs completed!'
