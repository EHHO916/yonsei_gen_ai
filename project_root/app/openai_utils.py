import openai
import os
from dotenv import load_dotenv

# .env 파일에서 환경 변수 불러오기
load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

# OpenAI API를 통해 피드백 받기
def get_feedback(diary_data):
    prompt = (
        f"Provide feedback based on this parenting diary entry:\n"
        f"Conflict Situation: {diary_data.get('conflict_situation')}\n"
        f"Praise Situation: {diary_data.get('praise_situation')}\n"
        f"Mistake Situation: {diary_data.get('mistake_situation')}\n"
        f"Parent Response: {diary_data.get('parent_response')}\n"
        f"Child Reaction: {diary_data.get('child_reaction')}\n"
    )
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=prompt,
        max_tokens=100
    )
    return response.choices[0].text.strip()
