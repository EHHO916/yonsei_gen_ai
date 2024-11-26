from django.test import TestCase
from .models import DiaryEntry, UserProfile

class DiaryEntryTestCase(TestCase):
    def setUp(self):
        self.user = UserProfile.objects.create(user_id="12345", mbti_result="ENFP")

    def test_create_diary_entry(self):
        diary = DiaryEntry.objects.create(
            user=self.user,
            date="2024-11-20",
            mood=["happy", "calm"],
            conflict_or_mistake="청소를 두고 다툼.",
            parent_response_child_reaction="청소의 중요성을 설명.",
            praise_situation="숙제를 스스로 끝냄."
        )
        self.assertEqual(diary.mood, ["happy", "calm"])
