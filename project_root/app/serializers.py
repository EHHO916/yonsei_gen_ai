from rest_framework import serializers
from .models import UserProfile, DiaryEntry

# UserProfile Serializer
class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['mbti_result']

# DiaryEntry Serializer
class DiaryEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = DiaryEntry
        fields = ['date', 'conflict_situation', 'praise_situation', 'mistake_situation', 'parent_response', 'child_reaction']
