#!/usr/bin/env python3
"""
The Office Character Data Preprocessor
Extracts character-specific dialogues for BALLS-powered LoRA training
"""

import json
import os
from collections import defaultdict, Counter
from typing import Dict, List, Tuple

# Our BALLS character roster
TARGET_CHARACTERS = {
    'Michael': ['Michael', 'Michael Scott'],
    'Dwight': ['Dwight', 'Dwight Schrute'],
    'Creed': ['Creed', 'Creed Bratton'],
    'Erin': ['Erin', 'Erin Hannon'],
    'Toby': ['Toby', 'Toby Flenderson']
}

def load_office_data(filepath: str) -> List[Dict]:
    """Load The Office episode data"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def normalize_character_name(character: str) -> str:
    """Normalize character names to match our BALLS roster"""
    character = character.strip()
    
    for target, variations in TARGET_CHARACTERS.items():
        if character in variations:
            return target
    
    return None  # Ignore characters not in our roster

def extract_character_lines(episodes: List[Dict]) -> Dict[str, List[str]]:
    """Extract all lines for each target character"""
    character_lines = defaultdict(list)
    
    for episode in episodes:
        season = episode['season']
        episode_num = episode['episode']
        title = episode['title']
        
        # Process regular scenes
        for scene in episode.get('scenes', []):
            for line_data in scene:
                character = normalize_character_name(line_data['character'])
                if character:
                    line = line_data['line']
                    # Add context metadata
                    character_lines[character].append({
                        'line': line,
                        'season': season,
                        'episode': episode_num,
                        'title': title,
                        'scene_type': 'regular'
                    })
        
        # Process deleted scenes
        for scene in episode.get('deleted_scenes', []):
            for line_data in scene:
                character = normalize_character_name(line_data['character'])
                if character:
                    line = line_data['line']
                    character_lines[character].append({
                        'line': line,
                        'season': season,
                        'episode': episode_num,
                        'title': title,
                        'scene_type': 'deleted'
                    })
    
    return dict(character_lines)

def format_for_training(character_lines: Dict[str, List[Dict]]) -> Dict[str, List[str]]:
    """Format character lines for LoRA training"""
    training_data = {}
    
    for character, lines in character_lines.items():
        formatted_lines = []
        
        for line_data in lines:
            line = line_data['line']
            
            # Clean up the line
            line = line.strip()
            if not line:
                continue
                
            # Remove stage directions in brackets
            import re
            line = re.sub(r'\[.*?\]', '', line).strip()
            
            if line:
                # Format as training example
                formatted_lines.append(f"{character}: {line}")
        
        training_data[character] = formatted_lines
    
    return training_data

def analyze_character_data(character_lines: Dict[str, List[Dict]]) -> None:
    """Analyze character dialogue statistics"""
    print("\n=== CHARACTER DIALOGUE ANALYSIS ===")
    
    for character in TARGET_CHARACTERS.keys():
        lines = character_lines.get(character, [])
        total_lines = len(lines)
        
        if total_lines == 0:
            print(f"{character}: NO LINES FOUND")
            continue
        
        # Season distribution
        season_counts = Counter(line['season'] for line in lines)
        
        # Average line length
        line_lengths = [len(line['line']) for line in lines]
        avg_length = sum(line_lengths) / len(line_lengths) if line_lengths else 0
        
        print(f"\n{character}:")
        print(f"  Total lines: {total_lines}")
        print(f"  Avg line length: {avg_length:.1f} chars")
        print(f"  Season distribution: {dict(season_counts)}")

def save_training_data(training_data: Dict[str, List[str]], output_dir: str) -> None:
    """Save character-specific training data"""
    os.makedirs(output_dir, exist_ok=True)
    
    for character, lines in training_data.items():
        filename = f"{output_dir}/{character.lower()}_training_data.txt"
        
        with open(filename, 'w', encoding='utf-8') as f:
            for line in lines:
                f.write(line + '\n')
        
        print(f"Saved {len(lines)} lines for {character} to {filename}")

def main():
    # Load the data
    print("Loading The Office dataset...")
    episodes = load_office_data('the-office/the-office.json')
    print(f"Loaded {len(episodes)} episodes")
    
    # Extract character lines
    print("\nExtracting character dialogues...")
    character_lines = extract_character_lines(episodes)
    
    # Analyze the data
    analyze_character_data(character_lines)
    
    # Format for training
    print("\nFormatting for training...")
    training_data = format_for_training(character_lines)
    
    # Save training data
    print("\nSaving training data...")
    save_training_data(training_data, 'training_data')
    
    print("\n=== PREPROCESSING COMPLETE ===")
    print("Ready for LoRA training!")

if __name__ == "__main__":
    main()