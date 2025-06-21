#!/bin/bash

# 📊 CHECK ALL OFFICE TRAINING STATUS
# Monitor all 5 character training processes

echo "📊 OFFICE LORA TRAINING STATUS"
echo "=============================="
echo ""

# Pod configurations
declare -A PODS=(
    ["michael"]="qif3gszlnqrmt4"
    ["dwight"]="qnk50v3f4necn8" 
    ["creed"]="d2r106j5n3btcc"
    ["erin"]="t61imb6b25bfk4"
    ["toby"]="og6vk9s808c1b6"
)

check_training_status() {
    local character=$1
    local pod_id=$2
    
    echo "🎭 $character (Pod: $pod_id)"
    echo "   Checking training status..."
    
    # Check if training is running
    TRAINING_STATUS=$(runpod exec --pod-id "$pod_id" -- bash -c "
        if pgrep -f 'train_character_lora.py.*$character' > /dev/null; then
            echo 'RUNNING'
        elif [[ -f '/workspace/${character}_training.log' ]]; then
            if grep -q 'training completed' /workspace/${character}_training.log; then
                echo 'COMPLETED'
            elif grep -q 'Error\|Failed' /workspace/${character}_training.log; then
                echo 'FAILED'
            else
                echo 'IN_PROGRESS'
            fi
        else
            echo 'NOT_STARTED'
        fi
    " 2>/dev/null)
    
    # Get latest log lines
    LATEST_LOG=$(runpod exec --pod-id "$pod_id" -- bash -c "
        if [[ -f '/workspace/${character}_training.log' ]]; then
            tail -3 /workspace/${character}_training.log
        else
            echo 'No log file found'
        fi
    " 2>/dev/null)
    
    case "$TRAINING_STATUS" in
        "RUNNING"|"IN_PROGRESS")
            echo "   ✅ Status: TRAINING"
            ;;
        "COMPLETED")
            echo "   🎉 Status: COMPLETED"
            ;;
        "FAILED")
            echo "   ❌ Status: FAILED"
            ;;
        "NOT_STARTED")
            echo "   ⏳ Status: NOT STARTED"
            ;;
        *)
            echo "   ❓ Status: UNKNOWN"
            ;;
    esac
    
    echo "   📝 Latest log:"
    echo "$LATEST_LOG" | sed 's/^/      /'
    echo ""
}

# Check all training processes
for character in "${!PODS[@]}"; do
    check_training_status "$character" "${PODS[$character]}"
done

echo "🔗 DETAILED MONITORING:"
echo "======================"
echo "For real-time logs, run:"
for character in "${!PODS[@]}"; do
    pod_id="${PODS[$character]}"
    echo "   runpod exec --pod-id $pod_id -- tail -f /workspace/${character}_training.log"
done

echo ""
echo "🌡️  Datacenter temperature: Probably still +3°F"