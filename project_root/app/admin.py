from django.contrib import admin
from .models import UserProfile, DiaryEntry  # app의 models.py에서 모델 임포트

# 모델 등록
admin.site.register(UserProfile)
admin.site.register(DiaryEntry)
