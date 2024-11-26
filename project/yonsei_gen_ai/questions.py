import os
from openai import OpenAI
import json
from dotenv import load_dotenv
import streamlit as st

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def load_questions():
    try:
        with open('questions.json', 'r') as file:
            data = json.load(file)
            return data['questions'], data['parenting_types']
    except FileNotFoundError:
        st.error("Questions file not found!")
        return [], {}

def calculate_parenting_type(responses):
    # Initialize counters for each type
    type_counts = {
        "A": 0,
        "B": 0,
        "C": 0
    }
    
    # Count responses for each type
    for response in responses.values():
        type_counts[response] += 1
    
    # Find the dominant type(s)
    max_count = max(type_counts.values())
    dominant_types = [t for t, count in type_counts.items() if count == max_count]
    
    return type_counts, dominant_types

def create_form():
    questions, parenting_types = load_questions()
    if not questions:
        return None

    st.title("부모 양육태도 유형 검사 🧑‍🧑‍🧒‍🧒")
    
    with st.form(key='parenting_form'):
        responses = {}
        
        # Create radio buttons for each question
        for i, q in enumerate(questions, 1):
            st.subheader(f"질문 {i}: {q['question']}")
            choice = st.radio(
                "하나를 선택하세요:",
                options=list(q['choices'].keys()),
                format_func=lambda x: q['choices'][x],
                key=f"q_{i}"
            )
            responses[f"question_{i}"] = choice
        
        submit_button = st.form_submit_button(label='제출')
        
        if submit_button:
            type_counts, dominant_types = calculate_parenting_type(responses)
            
            st.success("검사가 완료되었습니다!")
            
            # Show counts for each type
            st.write("### 유형별 응답 수")
            for type_key, count in type_counts.items():
                st.write(f"유형 {type_key}: {count}문항")
            
            st.write("### 당신의 주요 양육 유형")
            for type_key in dominant_types:
                style_info = parenting_types[type_key]
                st.write(f"**{style_info['style']}**")
                st.write(style_info['description'])
            
            return {
                "responses": responses,
                "type_counts": type_counts,
                "dominant_types": dominant_types
            }
    
    return None

def main():
    results = create_form()
    if results:
        # Optional: Add more detailed analysis or recommendations based on results
        st.write("---")
        st.write("끄읏 👩‍💻")

if __name__ == "__main__":
    main()
