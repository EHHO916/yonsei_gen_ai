import openai
import os
from dotenv import load_dotenv

# .env 파일에서 환경 변수 불러오기
load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")


def get_feedback_and_todos(diary_entry, user_message):
    """
    OpenAI ChatGPT를 사용해 부모 일기와 질문에 기반한 응답 및 To-Do 리스트 생성
    """
    context = [
        {"role": "system", "content": "You are a helpful assistant that provides parenting advice and generates actionable To-Do lists."},
        {"role": "user", "content": (
            f"Parent's diary entry:\n"
            f"Date: {diary_entry.date}\n"
            f"Mood: {', '.join(diary_entry.mood or [])}\n"
            f"Conflict or Mistake: {diary_entry.conflict_or_mistake}\n"
            f"Parent Response and Child Reaction: {diary_entry.parent_response_child_reaction}\n"
            f"Praise Situation: {diary_entry.praise_situation}\n\n"
            f"Based on this diary entry, suggest 3 actionable To-Do tasks and provide constructive feedback."
        )}
    ]

    # OpenAI API 호출
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=context,
        max_tokens=300
    )

    ai_response = response['choices'][0]['message']['content']

    # To-Do 리스트 추출
    todo_suggestions = ai_response.split("\n")
    todo_suggestions = [task.strip("- ") for task in todo_suggestions if task.strip()]

    return ai_response, todo_suggestions

