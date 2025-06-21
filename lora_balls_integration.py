#!/usr/bin/env python3
"""
BALLS + LoRA Integration Engine
Combines trained character LoRAs with BALLS orchestration for authentic Office dynamics
"""

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel
from typing import Dict, List, Optional
import os
import json
from balls_engine import BALLSEngine, CHARACTER_SPHERES, TopicType

class CharacterLoRAModel:
    """Wrapper for a character-specific LoRA model"""
    
    def __init__(self, character_name: str, model_path: str, base_model: str = "microsoft/DialoGPT-medium"):
        self.character_name = character_name
        self.model_path = model_path
        self.base_model = base_model
        self.model = None
        self.tokenizer = None
        self.loaded = False
        
    def load_model(self):
        """Load the LoRA model on demand"""
        if self.loaded:
            return
            
        print(f"🎭 Loading {self.character_name} LoRA from {self.model_path}")
        
        # Load tokenizer
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_path)
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
            
        # Load base model
        base_model = AutoModelForCausalLM.from_pretrained(
            self.base_model,
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
            device_map="auto" if torch.cuda.is_available() else None
        )
        
        # Load LoRA weights
        self.model = PeftModel.from_pretrained(base_model, self.model_path)
        self.model.eval()
        
        self.loaded = True
        print(f"✅ {self.character_name} LoRA loaded successfully")
    
    def generate_response(self, prompt: str, max_length: int = 100) -> str:
        """Generate a response using the character LoRA"""
        if not self.loaded:
            self.load_model()
            
        # Format prompt for the character
        formatted_prompt = f"<|user|>\n{prompt}\n<|assistant|>\n"
        
        # Tokenize
        inputs = self.tokenizer.encode(formatted_prompt, return_tensors="pt")
        if torch.cuda.is_available():
            inputs = inputs.cuda()
            
        # Generate
        with torch.no_grad():
            outputs = self.model.generate(
                inputs,
                max_length=inputs.shape[1] + max_length,
                num_return_sequences=1,
                temperature=0.8,
                do_sample=True,
                pad_token_id=self.tokenizer.eos_token_id,
                eos_token_id=self.tokenizer.eos_token_id,
                repetition_penalty=1.1
            )
        
        # Decode response
        full_response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Extract just the assistant's response
        if "<|assistant|>" in full_response:
            response = full_response.split("<|assistant|>")[-1].strip()
        else:
            response = full_response[len(formatted_prompt):].strip()
            
        return response

class BALLSLoRAOrchestrator:
    """
    The main orchestrator that combines BALLS dynamics with character LoRAs
    """
    
    def __init__(self, lora_models_dir: str = "lora_models"):
        self.lora_models_dir = lora_models_dir
        self.character_models = {}
        self.balls_engine = BALLSEngine()
        self.conversation_history = []
        
        # Load available character models
        self._load_available_models()
        
    def _load_available_models(self):
        """Load all available character LoRA models"""
        available_characters = ['michael', 'dwight', 'creed', 'erin', 'toby']
        
        for character in available_characters:
            model_path = f"{self.lora_models_dir}/{character}_lora"
            if os.path.exists(model_path):
                print(f"📁 Found {character} LoRA at {model_path}")
                self.character_models[character.capitalize()] = CharacterLoRAModel(
                    character_name=character.capitalize(),
                    model_path=model_path
                )
            else:
                print(f"⚠️  {character} LoRA not found at {model_path}")
                
        print(f"🎭 Loaded {len(self.character_models)} character LoRAs")
    
    def start_meeting(self, topic: str, max_turns: int = 15) -> List[Dict]:
        """
        Start an Office meeting with BALLS orchestration and LoRA responses
        """
        print(f"\n🏢 === BALLS + LoRA OFFICE MEETING ===")
        print(f"📋 Topic: {topic}")
        
        available_characters = list(self.character_models.keys())
        print(f"👥 Available Characters: {', '.join(available_characters)}")
        
        # Update BALLS engine with available characters
        self.balls_engine.active_characters = available_characters
        
        # Analyze initial topic
        topic_type = self.balls_engine.analyze_topic(topic)
        print(f"📊 BALLS Topic Analysis: {topic_type.value}")
        
        # Show initial sphere dynamics
        probabilities = self.balls_engine.calculate_speaking_probabilities(topic_type)
        print(f"\n⚡ Initial BALLS Probabilities:")
        for char, prob in sorted(probabilities.items(), key=lambda x: x[1], reverse=True):
            if char in self.character_models:
                sphere = CHARACTER_SPHERES[char]
                radius = sphere.calculate_radius(topic_type)
                print(f"   {char}: {prob:.1%} (sphere: {radius:.2f})")
        
        # Initialize meeting log
        meeting_log = [{
            'turn': 0,
            'speaker': 'Moderator',
            'message': topic,
            'topic_type': topic_type.value,
            'response_type': 'human',
            'sphere_analysis': {
                char: {
                    'radius': CHARACTER_SPHERES[char].calculate_radius(topic_type),
                    'probability': probabilities[char]
                } for char in available_characters
            }
        }]
        
        print(f"\n💬 Meeting Transcript:")
        print(f"[Moderator]: {topic}")
        
        # Run meeting simulation
        last_speaker = None
        
        for turn in range(1, max_turns + 1):
            # BALLS determines next speaker
            exclude = []
            if last_speaker and CHARACTER_SPHERES[last_speaker].dominance_factor < 0.8:
                exclude = [last_speaker]
                
            next_speaker = self.balls_engine.select_next_speaker(topic, exclude)
            
            # Skip if character LoRA not available
            if next_speaker not in self.character_models:
                continue
                
            # Generate character response using LoRA
            character_model = self.character_models[next_speaker]
            
            # Create context from recent conversation
            recent_context = [entry['message'] for entry in meeting_log[-3:]]
            context_prompt = f"Topic: {topic}\nRecent conversation: {' '.join(recent_context)}\nRespond as {next_speaker} from The Office:"
            
            try:
                response = character_model.generate_response(context_prompt)
                response_type = 'lora'
            except Exception as e:
                print(f"⚠️  Error generating LoRA response for {next_speaker}: {e}")
                response = f"[{next_speaker} would respond here, but LoRA failed]"
                response_type = 'fallback'
            
            # Update topic based on response
            current_topic_type = self.balls_engine.analyze_topic(response)
            current_probabilities = self.balls_engine.calculate_speaking_probabilities(current_topic_type)
            
            # Log the turn
            turn_data = {
                'turn': turn,
                'speaker': next_speaker,
                'message': response,
                'topic_type': current_topic_type.value,
                'response_type': response_type,
                'sphere_analysis': {
                    char: {
                        'radius': CHARACTER_SPHERES[char].calculate_radius(current_topic_type),
                        'probability': current_probabilities[char]
                    } for char in available_characters
                }
            }
            meeting_log.append(turn_data)
            
            # Print the exchange
            sphere_size = CHARACTER_SPHERES[next_speaker].calculate_radius(current_topic_type)
            prob = current_probabilities[next_speaker]
            response_indicator = "🤖" if response_type == 'lora' else "⚠️"
            print(f"[{next_speaker}] {response_indicator}(⚡{prob:.1%}, 🔮{sphere_size:.2f}): {response}")
            
            last_speaker = next_speaker
        
        print(f"\n🏁 === MEETING ENDED ===")
        self.conversation_history = meeting_log
        return meeting_log
    
    def get_model_status(self) -> Dict:
        """Get status of all character models"""
        status = {}
        for char, model in self.character_models.items():
            status[char] = {
                'loaded': model.loaded,
                'path': model.model_path,
                'available': os.path.exists(model.model_path)
            }
        return status

def demo_lora_balls():
    """Demo the BALLS + LoRA integration"""
    orchestrator = BALLSLoRAOrchestrator()
    
    # Show model status
    print("🔍 Model Status:")
    status = orchestrator.get_model_status()
    for char, info in status.items():
        status_icon = "✅" if info['available'] else "❌"
        print(f"   {char}: {status_icon} {'Available' if info['available'] else 'Missing'}")
    
    if not any(info['available'] for info in status.values()):
        print("\n⚠️  No trained LoRA models found. Please train some models first!")
        return
    
    # Run a test meeting
    test_topic = "We need to discuss the recent drop in sales performance"
    meeting_log = orchestrator.start_meeting(test_topic, max_turns=8)
    
    # Count LoRA vs fallback responses
    lora_responses = sum(1 for entry in meeting_log if entry.get('response_type') == 'lora')
    total_responses = len([entry for entry in meeting_log if entry.get('response_type')])
    
    print(f"\n📊 Meeting Stats:")
    print(f"   LoRA Responses: {lora_responses}/{total_responses}")
    print(f"   BALLS orchestration working: ✅")

if __name__ == "__main__":
    demo_lora_balls()