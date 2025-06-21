#!/bin/bash
echo 'Creating toby LoRA training pod...'
runpod create pod
  --name "office-toby-lora"
  --image-name "runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04"
  --gpu-type "RTX A4000"
  --container-disk-in-gb 50
  --env CHARACTER_NAME=toby
  --env DATA_FILE=toby_autotrain.jsonl
  --env WANDB_DISABLED=true
echo '✅ toby pod created!'
