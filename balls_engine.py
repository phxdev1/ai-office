#!/usr/bin/env python3
"""
BALLS (Bounded Analytics with Limited Locality Spheres) Engine
Mathematical modeling of Office character dynamics

The core innovation: Each character has a bounded attention sphere that
dynamically resizes based on topic relevance and social dominance patterns.
"""

import numpy as np
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import re

class TopicType(Enum):
    MANAGEMENT = "management"
    HR = "hr" 
    SURVIVAL = "survival"
    CONSPIRACY = "conspiracy"
    CONFUSION = "confusion"
    BEETS = "beets"
    SALES = "sales"
    GENERAL = "general"

@dataclass
class CharacterSphere:
    """Represents a character's attention sphere in BALLS framework"""
    name: str
    base_size: float  # Base attention sphere radius (0.0 to 1.0)
    topic_modifiers: Dict[TopicType, float]  # Topic-specific multipliers
    dominance_factor: float  # How much this character dominates conversations
    repulsion_targets: List[str]  # Characters this sphere repels
    
    def calculate_radius(self, topic: TopicType, context: Dict = None) -> float:
        """Calculate dynamic sphere radius based on topic and context"""
        modifier = self.topic_modifiers.get(topic, 1.0)
        
        # Apply Michael's repulsion field for Toby - BUT NOT on HR topics (his domain)
        if context and 'michael_present' in context and self.name == 'Toby':
            if topic != TopicType.HR:  # Toby gets to shine on HR topics despite Michael
                modifier *= 0.1
            
        return min(self.base_size * modifier, 1.0)  # Cap at 1.0

# Character sphere definitions based on Office dynamics
CHARACTER_SPHERES = {
    'Michael': CharacterSphere(
        name='Michael',
        base_size=0.8,
        topic_modifiers={
            TopicType.MANAGEMENT: 2.0,  # Delusion amplification
            TopicType.HR: 0.1,          # Active avoidance
            TopicType.SALES: 1.5,       # Claims expertise
            TopicType.CONSPIRACY: 0.6,  # Dismissive
            TopicType.SURVIVAL: 0.4,    # Completely lost
            TopicType.GENERAL: 1.2      # Always makes it about himself
        },
        dominance_factor=0.9,
        repulsion_targets=['Toby']
    ),
    
    'Dwight': CharacterSphere(
        name='Dwight',
        base_size=0.6,
        topic_modifiers={
            TopicType.SURVIVAL: 2.5,    # Actual expertise domain
            TopicType.BEETS: 2.5,       # Peak performance
            TopicType.MANAGEMENT: 1.5,  # Suck-up mode activated
            TopicType.SALES: 1.8,       # Top salesman
            TopicType.HR: 0.7,          # Bureaucratic frustration
            TopicType.CONSPIRACY: 1.2,  # Takes it seriously
            TopicType.GENERAL: 1.0
        },
        dominance_factor=0.7,
        repulsion_targets=[]
    ),
    
    'Creed': CharacterSphere(
        name='Creed',
        base_size=0.4,
        topic_modifiers={
            TopicType.CONSPIRACY: 2.0,  # His domain
            TopicType.SURVIVAL: 1.3,    # Random expertise
            TopicType.MANAGEMENT: 0.8,  # Zones out
            TopicType.HR: 0.9,          # Mild paranoia
            TopicType.GENERAL: 1.1      # Random interjections
        },
        dominance_factor=0.5,
        repulsion_targets=[]
    ),
    
    'Erin': CharacterSphere(
        name='Erin',
        base_size=0.2,
        topic_modifiers={
            TopicType.CONFUSION: 1.3,   # Innocent questions
            TopicType.MANAGEMENT: 0.7,  # Doesn't understand
            TopicType.HR: 0.8,          # Basic compliance
            TopicType.CONSPIRACY: 0.5,  # Too innocent
            TopicType.GENERAL: 0.9      # Mousy presence
        },
        dominance_factor=0.2,
        repulsion_targets=[]
    ),
    
    'Toby': CharacterSphere(
        name='Toby',
        base_size=0.15,
        topic_modifiers={
            TopicType.HR: 3.0,          # His one moment to shine - BOOSTED!
            TopicType.MANAGEMENT: 0.3,  # Gets ignored
            TopicType.CONSPIRACY: 0.6,  # Voice of reason
            TopicType.GENERAL: 0.8      # Generally defeated
        },
        dominance_factor=0.3,           # Boosted for HR situations
        repulsion_targets=[]
    )
}

class BALLSEngine:
    """
    The BALLS conversation orchestration engine
    Manages character sphere interactions and turn-taking
    """
    
    def __init__(self, characters: List[str] = None):
        if characters is None:
            characters = list(CHARACTER_SPHERES.keys())
        
        self.active_characters = characters
        self.conversation_history = []
        
    def analyze_topic(self, message: str) -> TopicType:
        """Analyze message content to determine topic type"""
        message_lower = message.lower()
        
        # Topic detection patterns
        if any(word in message_lower for word in ['manage', 'boss', 'meeting', 'corporate', 'business']):
            return TopicType.MANAGEMENT
        elif any(word in message_lower for word in ['hr', 'human resources', 'policy', 'complaint']):
            return TopicType.HR
        elif any(word in message_lower for word in ['beet', 'farm', 'schrute']):
            return TopicType.BEETS
        elif any(word in message_lower for word in ['survive', 'bear', 'fight', 'weapons', 'attack']):
            return TopicType.SURVIVAL
        elif any(word in message_lower for word in ['conspiracy', 'government', 'secret', 'truth']):
            return TopicType.CONSPIRACY
        elif any(word in message_lower for word in ['confused', 'don\'t understand', 'what', 'how']):
            return TopicType.CONFUSION
        else:
            return TopicType.GENERAL
    
    def calculate_speaking_probabilities(self, topic: TopicType, context: Dict = None) -> Dict[str, float]:
        """
        Calculate each character's probability of speaking next
        Based on sphere radius overlap and dominance factors
        """
        if context is None:
            context = {}
            
        # Add Michael presence context for Toby repulsion
        if 'Michael' in self.active_characters:
            context['michael_present'] = True
            
        probabilities = {}
        total_influence = 0
        
        for character in self.active_characters:
            sphere = CHARACTER_SPHERES[character]
            
            # Calculate effective sphere radius for this topic
            radius = sphere.calculate_radius(topic, context)
            
            # Factor in dominance
            influence = radius * sphere.dominance_factor
            
            probabilities[character] = influence
            total_influence += influence
        
        # Normalize to probabilities
        if total_influence > 0:
            for character in probabilities:
                probabilities[character] /= total_influence
        
        return probabilities
    
    def select_next_speaker(self, message: str, exclude: List[str] = None) -> str:
        """Select the next character to speak based on BALLS dynamics"""
        topic = self.analyze_topic(message)
        
        if exclude is None:
            exclude = []
            
        available_characters = [c for c in self.active_characters if c not in exclude]
        
        if not available_characters:
            return np.random.choice(self.active_characters)
        
        probabilities = self.calculate_speaking_probabilities(topic)
        
        # Filter to available characters and renormalize
        filtered_probs = {c: probabilities[c] for c in available_characters}
        total = sum(filtered_probs.values())
        
        if total > 0:
            for c in filtered_probs:
                filtered_probs[c] /= total
        else:
            # Equal probability fallback
            uniform_prob = 1.0 / len(available_characters)
            filtered_probs = {c: uniform_prob for c in available_characters}
        
        # Select based on probabilities
        characters = list(filtered_probs.keys())
        probs = list(filtered_probs.values())
        
        return np.random.choice(characters, p=probs)
    
    def simulate_meeting_dynamics(self, initial_topic: str, turns: int = 10) -> List[Dict]:
        """Simulate a full Office meeting with BALLS dynamics"""
        conversation = []
        topic = self.analyze_topic(initial_topic)
        
        conversation.append({
            'speaker': 'User',
            'message': initial_topic,
            'topic': topic.value,
            'sphere_sizes': {}
        })
        
        last_speaker = None
        
        for turn in range(turns):
            # Select next speaker (avoid back-to-back unless dominant)
            exclude = [last_speaker] if last_speaker and CHARACTER_SPHERES[last_speaker].dominance_factor < 0.8 else []
            speaker = self.select_next_speaker(initial_topic, exclude)
            
            # Calculate current sphere sizes for visualization
            probabilities = self.calculate_speaking_probabilities(topic)
            sphere_sizes = {}
            for char in self.active_characters:
                sphere = CHARACTER_SPHERES[char]
                sphere_sizes[char] = sphere.calculate_radius(topic)
            
            conversation.append({
                'speaker': speaker,
                'message': f"[{speaker} responds with sphere size {sphere_sizes[speaker]:.2f}]",
                'topic': topic.value,
                'sphere_sizes': sphere_sizes,
                'speaking_probability': probabilities[speaker]
            })
            
            last_speaker = speaker
        
        return conversation

def demo_balls_dynamics():
    """Demonstrate BALLS framework with different topics"""
    engine = BALLSEngine()
    
    test_topics = [
        "We need to discuss the new management policies",
        "There's been an HR complaint filed",
        "I've been growing beets on my desk",
        "I think the government is watching us",
        "I don't understand what's happening"
    ]
    
    print("=== BALLS DYNAMICS DEMONSTRATION ===\n")
    
    for topic in test_topics:
        print(f"TOPIC: {topic}")
        topic_type = engine.analyze_topic(topic)
        probabilities = engine.calculate_speaking_probabilities(topic_type)
        
        print(f"Topic Type: {topic_type.value}")
        print("Speaking Probabilities:")
        
        for character, prob in sorted(probabilities.items(), key=lambda x: x[1], reverse=True):
            sphere = CHARACTER_SPHERES[character]
            radius = sphere.calculate_radius(topic_type)
            print(f"  {character}: {prob:.3f} (radius: {radius:.2f})")
        
        print("-" * 50)

if __name__ == "__main__":
    demo_balls_dynamics()