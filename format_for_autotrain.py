#!/usr/bin/env python3
"""
Format Office character data for AutoTrain
Creates conversation-style training data for each character
"""

import os
import json
from typing import List, Dict

def create_autotrain_format(character_lines: List[str], character_name: str) -> List[Dict]:
    """
    Convert character lines to AutoTrain conversation format
    Each line becomes a user prompt with character response
    """
    training_examples = []
    
    for i, line in enumerate(character_lines):
        # Extract the actual dialogue after "Character: "
        if ': ' in line:
            dialogue = line.split(': ', 1)[1]
        else:
            continue
            
        # Create conversational training example
        example = {
            "messages": [
                {
                    "role": "user",
                    "content": f"Respond as {character_name} from The Office:"
                },
                {
                    "role": "assistant",
                    "content": dialogue
                }
            ]
        }
        
        training_examples.append(example)
        
        # Also create contextual variations
        if i > 0:
            # Previous line context
            prev_line = character_lines[i-1]
            if ': ' in prev_line:
                prev_dialogue = prev_line.split(': ', 1)[1]
                context_example = {
                    "messages": [
                        {
                            "role": "user", 
                            "content": f"In The Office, someone just said: '{prev_dialogue}'. How would {character_name} respond?"
                        },
                        {
                            "role": "assistant",
                            "content": dialogue
                        }
                    ]
                }
                training_examples.append(context_example)
    
    return training_examples

def load_character_data(data_dir: str) -> Dict[str, List[str]]:
    """Load all character training data"""
    character_data = {}
    
    for filename in os.listdir(data_dir):
        if filename.endswith('_training_data.txt'):
            character = filename.replace('_training_data.txt', '').capitalize()
            filepath = os.path.join(data_dir, filename)
            
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f.readlines() if line.strip()]
            
            character_data[character] = lines
    
    return character_data

def save_autotrain_data(character_data: Dict[str, List[str]], output_dir: str):
    """Save data in AutoTrain format"""
    os.makedirs(output_dir, exist_ok=True)
    
    for character, lines in character_data.items():
        print(f"Processing {character}...")
        
        # Create training examples
        training_examples = create_autotrain_format(lines, character)
        
        # Save as JSONL for AutoTrain
        output_file = f"{output_dir}/{character.lower()}_autotrain.jsonl"
        with open(output_file, 'w', encoding='utf-8') as f:
            for example in training_examples:
                f.write(json.dumps(example) + '\n')
        
        print(f"Saved {len(training_examples)} examples for {character} to {output_file}")

def main():
    print("Loading character training data...")
    character_data = load_character_data('training_data')
    
    print(f"Found characters: {list(character_data.keys())}")
    
    print("\nFormatting for AutoTrain...")
    save_autotrain_data(character_data, 'autotrain_data')
    
    print("\n=== AUTOTRAIN FORMATTING COMPLETE ===")
    print("Ready for LoRA training!")

if __name__ == "__main__":
    main()