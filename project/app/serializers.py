from rest_framework import serializers
from .models import UserProfile, DiaryEntry, ToDoItem

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['user_id', 'mbti_result']

class DiaryEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = DiaryEntry
        fields = [
            'user_id',
            'date',
            'mood',
            'conflict_or_mistake',
            'parent_response_child_reaction',
            'praise_situation'
        ]

class ToDoItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = ToDoItem
        fields = ['id', 'task', 'is_completed', 'diary_entry']