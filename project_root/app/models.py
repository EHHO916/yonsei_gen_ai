from django.db import models
from django.contrib.auth.models import User

# 사용자 프로필 (MBTI 결과 저장)
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    mbti_result = models.CharField(max_length=4)

    def __str__(self):
        return f"{self.user.username}'s Profile"

# 육아일기 모델
class DiaryEntry(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField()
    conflict_situation = models.TextField(blank=True)
    praise_situation = models.TextField(blank=True)
    mistake_situation = models.TextField(blank=True)
    parent_response = models.TextField(blank=True)
    child_reaction = models.TextField(blank=True)

    def __str__(self):
        return f"Diary for {self.date} by {self.user.username}"

