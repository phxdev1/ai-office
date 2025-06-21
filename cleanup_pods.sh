#!/bin/bash

# 🧹 CLEANUP RUNPOD INSTANCES
# Terminate running pods to save costs

echo "🧹 RUNPOD CLEANUP UTILITY"
echo "========================"
echo ""

echo "📋 Current running pods:"
runpod pod list

echo ""
echo "💰 COST ANALYSIS:"
echo "================="
echo "Currently running pods are costing ~$2.05/hour"
echo "Office LoRA pods: 5 pods running"
echo "Other pods: 1 additional pod"
echo ""

echo "🛑 CLEANUP OPTIONS:"
echo "==================="
echo ""
echo "Since the RunPod CLI doesn't seem to have a terminate command,"
echo "you have two options:"
echo ""
echo "1. 🌐 WEB INTERFACE CLEANUP:"
echo "   - Go to https://runpod.io/console/pods"
echo "   - Click 'Terminate' on unwanted pods"
echo "   - Keep only the Office LoRA pods you want to train"
echo ""
echo "2. 🔄 FRESH START:"
echo "   - Terminate ALL pods via web interface"
echo "   - Run our deployment script again with fixes"
echo ""

echo "📊 PODS TO CONSIDER TERMINATING:"
echo "================================"
echo ""

# Office LoRA pods
echo "🎭 Office LoRA Training Pods (keep these if you want to train):"
echo "   c8f4kltejbur9o - office-michael-lora (RTX A5000)"
echo "   ktje5dbtop7xv5 - office-dwight-lora (RTX A5000)"
echo "   afzer9vb7qtv4o - office-creed-lora (RTX A4000)"
echo "   15ifa0nxsbapv8 - office-erin-lora (RTX A4000)"
echo "   iycmf9q0ubolfw - office-toby-lora (RTX A4000)"
echo ""

# Other pods
echo "🗑️ Other Pods (probably safe to terminate):"
echo "   44mq2d8p8ijv6h - BALLS CUDA (older pod)"
echo ""

echo "💡 RECOMMENDATION:"
echo "=================="
echo "1. Go to https://runpod.io/console/pods"
echo "2. Terminate the old 'BALLS CUDA' pod (44mq2d8p8ijv6h)"
echo "3. Keep the 5 Office LoRA pods if you want to continue training"
echo "4. OR terminate everything and restart with a cleaner deployment"
echo ""

echo "🔗 Quick link: https://runpod.io/console/pods"
echo ""
echo "⚡ Once cleaned up, you can:"
echo "   - Continue with existing Office pods"
echo "   - Or run ./deploy_office_loras.sh again for a fresh start"