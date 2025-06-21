#!/bin/bash
echo 'Uploading training data to all pods...'

# Upload michael training data:
runpod send michael_autotrain.jsonl office-michael-lora:/workspace/
runpod send runpod_michael_training.sh office-michael-lora:/workspace/

# Upload dwight training data:
runpod send dwight_autotrain.jsonl office-dwight-lora:/workspace/
runpod send runpod_dwight_training.sh office-dwight-lora:/workspace/

# Upload creed training data:
runpod send creed_autotrain.jsonl office-creed-lora:/workspace/
runpod send runpod_creed_training.sh office-creed-lora:/workspace/

# Upload erin training data:
runpod send erin_autotrain.jsonl office-erin-lora:/workspace/
runpod send runpod_erin_training.sh office-erin-lora:/workspace/

# Upload toby training data:
runpod send toby_autotrain.jsonl office-toby-lora:/workspace/
runpod send runpod_toby_training.sh office-toby-lora:/workspace/

echo '✅ All training data uploaded!'
