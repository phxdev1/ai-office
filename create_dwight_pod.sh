#!/bin/bash
echo 'Creating dwight LoRA training pod...'
runpod create pod
  --name "office-dwight-lora"
  --image-name "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04"
  --gpu-type "RTX A5000"
  --container-disk-in-gb 50
  --env CHARACTER_NAME=dwight
  --env DATA_FILE=dwight_autotrain.jsonl
  --env WANDB_DISABLED=true
echo '✅ dwight pod created!'
