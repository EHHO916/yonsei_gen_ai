from django.db import models
from bson import ObjectId

class UserProfile(models.Model):
    user_id = models.CharField(max_length=24, unique=True, default=lambda: str(ObjectId()))
    mbti_result = models.CharField(max_length=4)

    def __str__(self):
        return f"{self.user_id}'s Profile"

class DiaryEntry(models.Model):
    user = models.ForeignKey('UserProfile', on_delete=models.CASCADE)  # ForeignKey로 연결
    date = models.DateField()  # 일기 작성 날짜
    mood = models.JSONField(blank=True, null=True)  # 오늘의 기분 (복수 선택 가능)
    conflict_or_mistake = models.TextField(blank=True, null=True)  # 갈등 또는 실수 상황
    parent_response_child_reaction = models.TextField(blank=True, null=True)  # 부모 대처와 아이 반응
    praise_situation = models.TextField(blank=True, null=True)  # 칭찬한 상황

    def __str__(self):
        return f"Diary for {self.date} by user {self.user.user_id}"

class ChatHistory(models.Model):
    diary_entry = models.ForeignKey('DiaryEntry', on_delete=models.CASCADE)
    message = models.TextField()  # 사용자 메시지
    response = models.TextField()  # AI 응답
    timestamp = models.DateTimeField(auto_now_add=True)  # 대화 시간

    def __str__(self):
        return f"Chat for Diary {self.diary_entry.id} on {self.timestamp}"

class ToDoItem(models.Model):
    diary_entry = models.ForeignKey('DiaryEntry', on_delete=models.CASCADE, related_name='todos')  # DiaryEntry와 연결
    task = models.TextField()  # To-Do 리스트 항목
    is_completed = models.BooleanField(default=False)  # 완료 여부

    def __str__(self):
        return f"ToDo: {self.task} (Completed: {self.is_completed})"
