#!/bin/bash

echo "🎭 OFFICE LORA TRAINING STATUS CHECK"
echo "===================================="
echo ""

echo "📋 Raw pod list:"
runpod pod list

echo ""
echo "🎯 Office LoRA Pods Analysis:"
echo "============================"

# Extract Office pods
OFFICE_PODS=$(runpod pod list | grep "office-.*-lora" | grep "RUNNING")

if [[ -z "$OFFICE_PODS" ]]; then
    echo "❌ No running Office LoRA pods found"
    exit 0
fi

echo "$OFFICE_PODS" | while read -r line; do
    POD_ID=$(echo "$line" | awk '{print $1}')
    POD_NAME=$(echo "$line" | awk '{print $3}')
    POD_STATUS=$(echo "$line" | awk '{print $5}')
    
    CHARACTER=$(echo "$POD_NAME" | sed 's/office-//g' | sed 's/-lora//g')
    
    echo ""
    echo "🎭 Character: ${CHARACTER^}"
    echo "   Pod ID: $POD_ID"
    echo "   Status: $POD_STATUS"
    echo "   Connect: runpod pod connect $POD_ID"
done

echo ""
echo "💰 COST WARNING:"
OFFICE_COUNT=$(echo "$OFFICE_PODS" | wc -l)
echo "   Running Office pods: $OFFICE_COUNT"
echo "   Estimated cost: \$$(echo "scale=2; $OFFICE_COUNT * 0.4" | bc)/hour"

echo ""
echo "🔧 RECOMMENDED ACTIONS:"
echo "======================"
echo "1. Check if you have duplicate characters"
echo "2. Terminate duplicate pods to save costs"
echo "3. Connect to one pod per character to check training status"
echo ""
echo "Example: Connect to a Michael pod:"
MICHAEL_POD=$(echo "$OFFICE_PODS" | grep "michael" | head -1 | awk '{print $1}')
if [[ -n "$MICHAEL_POD" ]]; then
    echo "runpod pod connect $MICHAEL_POD"
fi