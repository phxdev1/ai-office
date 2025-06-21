#!/usr/bin/env python3
"""
The Office Meeting Simulator
BALLS-powered group dynamics with actual character AI models

This is where the magic happens - mathematical personality modeling
meets trained character LoRAs for authentic Office chaos.
"""

import asyncio
import json
import random
from typing import Dict, List, Optional
from balls_engine import BALLSEngine, CHARACTER_SPHERES, TopicType
from dataclasses import dataclass

@dataclass 
class CharacterModel:
    """Placeholder for actual LoRA model integration"""
    name: str
    model_path: str = None
    used_responses: List[str] = None
    
    def __post_init__(self):
        if self.used_responses is None:
            self.used_responses = []
    
    def generate_response(self, prompt: str, context: List[str] = None) -> str:
        """
        Generate character response using trained LoRA
        Enhanced with topic-aware responses and massive variety
        """
        # Analyze topic for context-aware responses
        topic_lower = prompt.lower()
        context_str = " ".join(context) if context else ""
        combined_text = (topic_lower + " " + context_str).lower()
        
        # Check for specific character mentions or reactions
        has_michael_mention = 'michael' in combined_text
        has_dwight_mention = 'dwight' in combined_text  
        has_creed_mention = 'creed' in combined_text
        has_that_what_she_said = 'that\'s what she said' in context_str or 'thats what she said' in context_str
        
        if self.name == 'Michael':
            # React to other characters
            if has_dwight_mention:
                responses = [
                    "Dwight, you ignorant slut!",
                    "That's my right-hand man right there.",
                    "Dwight knows what he's talking about. Sometimes.",
                    "FALSE! ...wait, that's Dwight's thing."
                ]
            # Management/Business responses
            elif any(word in combined_text for word in ['sales', 'target', 'business', 'corporate', 'meeting']):
                responses = [
                    "I am a great boss. I'm like a friend first, boss second, and probably entertainer third.",
                    "Sometimes I'll start a sentence and I don't even know where it's going. I just hope I find it along the way.",
                    "I would say I kind of have an unfair advantage because I watch reality dating shows like a hawk.",
                    "The worst thing about prison was the... was the Dementors. They were flying all over the place and they were scary.",
                    "Would I rather be feared or loved? Easy. Both. I want people to be afraid of how much they love me.",
                    "I'm not a millionaire. I thought I would be by the time I was 30, but I wasn't even close.",
                    "I'm running away from my responsibilities. And it feels good."
                ]
            # HR/Policy responses (he avoids these)
            elif any(word in combined_text for word in ['hr', 'policy', 'complaint', 'harassment']):
                responses = [
                    "I'm not great at the advice. Can I interest you in a sarcastic comment?",
                    "I don't hate it. I just don't like it at all and it's terrible.",
                    "That's not what she said... or is it?",
                    "I think there's been a misunderstanding. I didn't do anything wrong... allegedly.",
                    "Toby is in HR which technically means he works for corporate, so he's not really a part of our family."
                ]
            # General Michael chaos
            else:
                responses = [
                    "That's what she said!",
                    "I'm not superstitious, but I am a little stitious.",
                    "You know what they say. Fool me once, strike one, but fool me twice... strike three.",
                    "I DECLARE BANKRUPTCY!",
                    "Guess what? I have flaws. What are they? Oh I donno, I sing in the shower? Sometimes I spend too much time volunteering.",
                    "I love inside jokes. I'd love to be a part of one someday.",
                    "I'm not usually the butt of the joke. I'm usually the face of the joke.",
                    "Abraham Lincoln once said that 'If you're a racist, I will attack you with the North.'",
                    "Wikipedia is the best thing ever. Anyone in the world can write anything they want about any subject.",
                    "I enjoy having breakfast in bed. I like waking up to the smell of bacon, sue me."
                ]
                
        elif self.name == 'Dwight':
            # React to Michael
            if has_michael_mention or 'boss' in combined_text:
                responses = [
                    "Michael is the best boss I've ever worked for!",
                    "MICHAEL! MICHAEL!",
                    "That's what I'm talking about!",
                    "As Assistant Regional Manager, I agree completely."
                ]
            # React to "FALSE" situations
            elif any(word in combined_text for word in ['wrong', 'incorrect', 'false', 'mistake']):
                responses = [
                    "FALSE!",
                    "That is factually incorrect!",
                    "WRONG! So wrong it hurts!",
                    "FALSE! Black bears are best!"
                ]
            # Survival/Beets/Farming
            elif any(word in combined_text for word in ['beet', 'farm', 'survive', 'attack', 'security', 'fight']):
                responses = [
                    "Bears. Beets. Battlestar Galactica.",
                    "I am faster than 80% of all snakes.",
                    "I can raise and lower my cholesterol at will.",
                    "Through concentration, I can raise and lower my blood pressure.",
                    "I have been growing beets for years. They are the superior root vegetable.",
                    "Before I do anything I ask myself 'Would an idiot do that?' And if the answer is yes, I do not do that thing.",
                    "I don't have a lot of experience with vampires, but I have hunted werewolves. I shot one once, but by the time I got to it, it had turned back into my neighbor's dog.",
                    "I am ready to face any challenges that might be foolish enough to face me.",
                    "In the wild, there is no healthcare. In the wild, healthcare is 'Ow, I hurt my leg. I can't run. A lion eats me and I'm dead.'",
                    "I have bear spray. And I've tested it on bears. It doesn't work."
                ]
            # Management/Authority (suck-up mode)
            elif any(word in combined_text for word in ['manage', 'boss', 'authority', 'corporate']):
                responses = [
                    "Michael is the best boss I've ever worked for. Also the only boss I've ever worked for.",
                    "I would follow Michael Scott to the ends of the earth. And I would do it willingly.",
                    "As Assistant Regional Manager, I can handle this situation.",
                    "Actually, it's Assistant TO the Regional Manager.",
                    "I have been given more responsibility and I intend to use it wisely.",
                    "I'm an early bird and I'm a night owl. So I'm wise and I have worms."
                ]
            # General Dwight intensity
            else:
                responses = [
                    "FALSE!",
                    "Fact: Bears eat beets. Bears. Beets. Battlestar Galactica.",
                    "Identity theft is not a joke, Jim! Millions of families suffer every year!",
                    "Michael! MICHAEL!",
                    "I am not a security threat. And my middle name is 'Kurt', not 'Fart'.",
                    "I don't believe in sun screen. I don't believe in doctors. I don't believe in vaccines.",
                    "I never smile if I can help it. Showing one's teeth is a submission signal in primates.",
                    "I signed up for Second Life about a year ago. Back then my life was so great that I literally wanted a second one.",
                    "Dwight Schrute does not do anything small.",
                    "I grew up on a farm. I have seen animals having sex in every position imaginable."
                ]
                
        elif self.name == 'Creed':
            # Conspiracy/Random chaos
            if any(word in combined_text for word in ['government', 'conspiracy', 'secret', 'steal', 'money']):
                responses = [
                    "I've been involved in a number of cults both as a leader and a follower.",
                    "Nobody steals from Creed Bratton and gets away with it. The last person to do this disappeared.",
                    "The Taliban is the worst. Great heroin though.",
                    "I run a small fake ID company from my car with a laminating machine.",
                    "Every week I'm supposed to take four hours and do a quality spot check at the paper mill.",
                    "Two eyes, two ears, a chin, a mouth, 10 fingers, two nipples, a butt, two kneecaps, a penis. I have just described to you the Loch Ness Monster.",
                    "I want to set you up with my daughter.",
                    "I know exactly what he's talking about. I sprout mung beans on a damp paper towel in my desk drawer.",
                    "You're paying way too much for worms, man. Who's your worm guy?"
                ]
            # General Creed randomness
            else:
                responses = [
                    "Cool beans, man. I live by the quarry. We should hang out by the quarry and throw things down there!",
                    "I'm not offended by homosexuality. In the '60s, I made love to many, many women.",
                    "When Pam gets Michael's old chair, I get Pam's old chair. Then I'll have two chairs. Only one to go.",
                    "I've done a lot more for a lot less.",
                    "If I can't scuba, then what's this all been about?",
                    "I already won the lottery. I was born in the US of A, baby!",
                    "I steal things all the time. It's just something I do. I stopped caring a long time ago.",
                    "Find out what language this is: *makes incomprehensible sounds*",
                    "I'm thirty. Well, in November I'll be thirty.",
                    "Strike, scream, and run."
                ]
                
        elif self.name == 'Erin':
            # Confusion/Questions
            if any(word in combined_text for word in ['understand', 'confused', 'complicated', 'explain']):
                responses = [
                    "I'm sorry, what?",
                    "That sounds really complicated.",
                    "I think I understand... no, wait, I don't.",
                    "Should I be writing this down?",
                    "Can you say that again, but slower?",
                    "I don't know what that means, but it sounds bad.",
                    "Is that a good thing or a bad thing?",
                    "I'm confused. Are we supposed to be doing something?",
                    "Wait, what are we talking about again?",
                    "I feel like I missed something important."
                ]
            # Innocent/Sweet responses  
            else:
                responses = [
                    "Oh, I don't know about that...",
                    "That's so nice!",
                    "I like your confidence.",
                    "Gosh, I hope everything works out.",
                    "I've never heard it put that way before.",
                    "You guys are so smart!",
                    "I wish I could help, but I don't really know how.",
                    "That sounds like a really good idea!",
                    "I love learning new things!",
                    "Oh my gosh, really?",
                    "I don't want to say the wrong thing.",
                    "Maybe we should ask someone who knows more about this?",
                    "I hope I'm not being too forward, but that sounds great!",
                    "Disposable cameras are fun, although it does seem wasteful."
                ]
                
        elif self.name == 'Toby':
            # HR/Policy (his domain)
            if any(word in combined_text for word in ['policy', 'hr', 'complaint', 'harassment', 'legal']):
                responses = [
                    "Actually, according to company policy...",
                    "We need to be careful about liability issues.",
                    "I should probably document this conversation.",
                    "That could potentially create a hostile work environment.",
                    "I think we need to review the employee handbook on this.",
                    "This is exactly the kind of thing that gets companies in trouble.",
                    "I'm going to have to report this to corporate.",
                    "We should probably have a formal meeting about this.",
                    "I need to make sure everyone understands the policy.",
                    "This is why we have training sessions."
                ]
            # Michael present (defeated)
            elif any(entry.get('speaker') == 'Michael' for entry in context if isinstance(entry, dict)):
                responses = [
                    "Michael, please...",
                    "That's not appropriate...",
                    "I don't think that's a good idea.",
                    "Can we please stay on topic?",
                    "I'm just trying to do my job here.",
                    "This is exactly what I'm talking about.",
                    "Michael, we've discussed this before.",
                    "I don't think corporate would approve of that.",
                    "Can we please be professional?",
                    "I'm going to have to ask you to stop."
                ]
            # General defeated Toby
            else:
                responses = [
                    "I'm just trying to do my job here.",
                    "I don't think that's appropriate...",
                    "Has anyone seen my desk?",
                    "I went to Costa Rica and I didn't come back for five months.",
                    "I'm not a part of this family. I'm the enemy.",
                    "Why are you the way that you are?",
                    "I hate so much about the things that you choose to be.",
                    "Smile if you love men's prostates!",
                    "I'm going to kill myself. I'm going to kill myself and it's your fault.",
                    "If I had a gun with two bullets and I was in a room with Hitler, Bin Laden, and Toby, I would shoot Toby twice."
                ]
        else:
            responses = ["I don't know what to say."]
        
        # Filter out responses we've already used in this meeting
        available_responses = [r for r in responses if r not in self.used_responses]
        
        # If we've used all responses from this category, still prevent global repeats
        if not available_responses:
            # Find any responses that haven't been used at all this meeting
            all_possible_responses = []
            
            # Collect all possible responses for this character (simplified)
            if self.name == 'Michael':
                all_possible_responses = [
                    "I am a great boss. I'm like a friend first, boss second, and probably entertainer third.",
                    "Sometimes I'll start a sentence and I don't even know where it's going. I just hope I find it along the way.",
                    "That's what she said!",
                    "I DECLARE BANKRUPTCY!",
                    "Would I rather be feared or loved? Easy. Both. I want people to be afraid of how much they love me.",
                    "I love inside jokes. I'd love to be a part of one someday.",
                    "I'm not superstitious, but I am a little stitious."
                ]
            elif self.name == 'Dwight':
                all_possible_responses = [
                    "FALSE!",
                    "Bears. Beets. Battlestar Galactica.",
                    "Michael! MICHAEL!",
                    "Identity theft is not a joke, Jim! Millions of families suffer every year!",
                    "I am faster than 80% of all snakes."
                ]
            elif self.name == 'Creed':
                all_possible_responses = [
                    "I've been involved in a number of cults both as a leader and a follower.",
                    "Nobody steals from Creed Bratton and gets away with it. The last person to do this disappeared.",
                    "Strike, scream, and run.",
                    "Cool beans, man. I live by the quarry. We should hang out by the quarry and throw things down there!"
                ]
            elif self.name == 'Erin':
                all_possible_responses = [
                    "I'm sorry, what?",
                    "That sounds really complicated.",
                    "Oh, I don't know about that...",
                    "That's so nice!"
                ]
            elif self.name == 'Toby':
                all_possible_responses = [
                    "Actually, according to company policy...",
                    "Michael, please...",
                    "I'm just trying to do my job here.",
                    "I don't think that's appropriate..."
                ]
            else:
                all_possible_responses = responses
            
            # Find unused responses
            available_responses = [r for r in all_possible_responses if r not in self.used_responses]
            
            # If still nothing, reset completely
            if not available_responses:
                self.used_responses = []
                available_responses = responses
        
        # Select response and track it
        selected_response = random.choice(available_responses)
        self.used_responses.append(selected_response)
        
        return selected_response

class OfficeMeetingSimulator:
    """
    Full Office meeting simulation with BALLS dynamics
    Orchestrates character interactions using sphere mathematics
    """
    
    def __init__(self, characters: List[str] = None):
        if characters is None:
            characters = ['Michael', 'Dwight', 'Creed', 'Erin', 'Toby']
            
        self.balls_engine = BALLSEngine(characters)
        self.character_models = {
            name: CharacterModel(name) for name in characters
        }
        self.meeting_log = []
        
    def start_meeting(self, topic: str, max_turns: int = 15) -> List[Dict]:
        """
        Start an Office meeting simulation
        Returns full conversation log with BALLS analytics
        """
        # Reset used responses for new meeting
        for character_model in self.character_models.values():
            character_model.used_responses = []
            
        print(f"\n🏢 === OFFICE MEETING STARTED ===")
        print(f"📋 Topic: {topic}")
        print(f"👥 Attendees: {', '.join(self.balls_engine.active_characters)}")
        
        # Analyze initial topic
        topic_type = self.balls_engine.analyze_topic(topic)
        print(f"📊 BALLS Topic Analysis: {topic_type.value}")
        
        # Show initial sphere sizes
        probabilities = self.balls_engine.calculate_speaking_probabilities(topic_type)
        print(f"\n⚡ Initial Speaking Probabilities:")
        for char, prob in sorted(probabilities.items(), key=lambda x: x[1], reverse=True):
            sphere = CHARACTER_SPHERES[char]
            radius = sphere.calculate_radius(topic_type)
            print(f"   {char}: {prob:.1%} (sphere: {radius:.2f})")
        
        # Initialize meeting log
        meeting_log = [{
            'turn': 0,
            'speaker': 'Moderator',
            'message': topic,
            'topic_type': topic_type.value,
            'sphere_analysis': {
                char: {
                    'radius': CHARACTER_SPHERES[char].calculate_radius(topic_type),
                    'probability': probabilities[char]
                } for char in self.balls_engine.active_characters
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
            
            # Generate character response
            context = [entry['message'] for entry in meeting_log[-3:]]  # Last 3 messages
            response = self.character_models[next_speaker].generate_response(topic, context)
            
            # Update topic based on response (conversations can drift)
            current_topic_type = self.balls_engine.analyze_topic(response)
            current_probabilities = self.balls_engine.calculate_speaking_probabilities(current_topic_type)
            
            # Log the turn
            turn_data = {
                'turn': turn,
                'speaker': next_speaker,
                'message': response,
                'topic_type': current_topic_type.value,
                'sphere_analysis': {
                    char: {
                        'radius': CHARACTER_SPHERES[char].calculate_radius(current_topic_type),
                        'probability': current_probabilities[char]
                    } for char in self.balls_engine.active_characters
                }
            }
            meeting_log.append(turn_data)
            
            # Print the exchange
            sphere_size = CHARACTER_SPHERES[next_speaker].calculate_radius(current_topic_type)
            prob = current_probabilities[next_speaker]
            print(f"[{next_speaker}] (⚡{prob:.1%}, 🔮{sphere_size:.2f}): {response}")
            
            last_speaker = next_speaker
            
            # Meeting can end early if Toby tries to enforce policy
            if next_speaker == 'Toby' and 'policy' in response.lower():
                print(f"[Michael]: NO! Meeting's over. Toby ruins everything.")
                break
        
        print(f"\n🏁 === MEETING ENDED ===")
        self.meeting_log = meeting_log
        return meeting_log
    
    def analyze_meeting_dynamics(self) -> Dict:
        """Analyze the BALLS dynamics from the completed meeting"""
        if not self.meeting_log:
            return {}
        
        analysis = {
            'total_turns': len(self.meeting_log) - 1,  # Exclude moderator
            'speaker_distribution': {},
            'topic_evolution': [],
            'sphere_dominance': {},
            'michael_toby_interactions': 0
        }
        
        # Speaker distribution and sphere analysis
        for char in self.balls_engine.active_characters:
            turns = [entry for entry in self.meeting_log if entry['speaker'] == char]
            analysis['speaker_distribution'][char] = {
                'turns': len(turns),
                'percentage': len(turns) / max(analysis['total_turns'], 1) * 100,
                'avg_sphere_size': sum(entry['sphere_analysis'][char]['radius'] for entry in self.meeting_log if 'sphere_analysis' in entry) / len(self.meeting_log),
                'avg_probability': sum(entry['sphere_analysis'][char]['probability'] for entry in self.meeting_log if 'sphere_analysis' in entry) / len(self.meeting_log)
            }
        
        # Topic evolution
        analysis['topic_evolution'] = [entry['topic_type'] for entry in self.meeting_log if 'topic_type' in entry]
        
        # Michael-Toby dynamics
        michael_turns = [i for i, entry in enumerate(self.meeting_log) if entry['speaker'] == 'Michael']
        toby_turns = [i for i, entry in enumerate(self.meeting_log) if entry['speaker'] == 'Toby']
        
        for m_turn in michael_turns:
            for t_turn in toby_turns:
                if abs(m_turn - t_turn) <= 2:  # Within 2 turns of each other
                    analysis['michael_toby_interactions'] += 1
        
        return analysis
    
    def print_analytics(self):
        """Print detailed BALLS analytics"""
        if not self.meeting_log:
            print("No meeting data to analyze")
            return
            
        analysis = self.analyze_meeting_dynamics()
        
        print(f"\n📊 === BALLS MEETING ANALYTICS ===")
        print(f"Total turns: {analysis['total_turns']}")
        
        print(f"\n🎭 Speaker Distribution:")
        for char, data in sorted(analysis['speaker_distribution'].items(), 
                               key=lambda x: x[1]['turns'], reverse=True):
            print(f"   {char}: {data['turns']} turns ({data['percentage']:.1f}%) | "
                  f"Avg sphere: {data['avg_sphere_size']:.2f} | "
                  f"Avg probability: {data['avg_probability']:.1%}")
        
        print(f"\n📈 Topic Evolution: {' → '.join(analysis['topic_evolution'])}")
        print(f"🔥 Michael-Toby Interactions: {analysis['michael_toby_interactions']}")

def demo_office_meeting():
    """Demonstrate the full Office meeting simulator"""
    simulator = OfficeMeetingSimulator()
    
    test_scenarios = [
        "We need to discuss the new sales targets for this quarter",
        "There's been a complaint about inappropriate workplace behavior",
        "I think someone has been stealing lunches from the refrigerator"
    ]
    
    for scenario in test_scenarios:
        print(f"\n" + "="*80)
        meeting_log = simulator.start_meeting(scenario, max_turns=8)
        simulator.print_analytics()
        print(f"="*80)

if __name__ == "__main__":
    demo_office_meeting()