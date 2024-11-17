from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import UserProfile, DiaryEntry
from .serializers import UserProfileSerializer, DiaryEntrySerializer

# 육아일기 작성 및 피드백 제공 API
class DiaryEntryView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = DiaryEntrySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            feedback = get_feedback(serializer.data)
            return Response({"message": "Diary entry saved", "feedback": feedback})
        return Response(serializer.errors, status=400)
