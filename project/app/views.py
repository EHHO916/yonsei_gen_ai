from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .serializers import DiaryEntrySerializer
from .models import DiaryEntry, ChatHistory, ToDoItem
from .openai_utils import get_feedback_and_todos



class DiaryEntryView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data.copy()
        data['user_id'] = str(request.user.id)  # 현재 로그인된 사용자 ID
        serializer = DiaryEntrySerializer(data=data)

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Diary entry saved successfully"}, status=201)
        return Response(serializer.errors, status=400)

class ChatWithAIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user_id = request.data.get('user_id')
        message = request.data.get('message')  # 사용자가 입력한 질문
        diary_id = request.data.get('diary_id')  # 해당 일기의 ID

        try:
            # 해당 일기 가져오기
            diary_entry = DiaryEntry.objects.get(id=diary_id, user_id=request.user)

            # AI와의 대화 및 To-Do 리스트 생성
            ai_response, todo_suggestions = get_feedback_and_todos(diary_entry, message)

            # 대화 이력 저장
            ChatHistory.objects.create(
                user_id=user_id,
                diary_entry=diary_entry,
                message=message,
                response=ai_response
            )

            return Response({
                "message": message,
                "response": ai_response,
                "todo_suggestions": todo_suggestions
            }, status=200)

        except DiaryEntry.DoesNotExist:
            return Response({"error": "Diary entry not found"}, status=404)

class SaveToDoListView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        diary_id = request.data.get('diary_id')  # 해당 일기의 ID
        selected_todos = request.data.get('selected_todos', [])  # 사용자가 선택한 To-Do 리스트

        try:
            # 해당 일기 가져오기
            diary_entry = DiaryEntry.objects.get(id=diary_id)

            # 선택된 To-Do 리스트 저장
            for task in selected_todos:
                ToDoItem.objects.create(diary_entry=diary_entry, task=task)

            return Response({"message": "To-Do list saved successfully"}, status=201)

        except DiaryEntry.DoesNotExist:
            return Response({"error": "Diary entry not found"}, status=404)

class CalendarDataView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, user_id, date):
        try:
            diary_entry = DiaryEntry.objects.get(user__user_id=user_id, date=date)
            todos = ToDoItem.objects.filter(diary_entry=diary_entry)

            todo_list = [{"task": todo.task, "is_completed": todo.is_completed} for todo in todos]

            return Response({
                "date": diary_entry.date,
                "mood": diary_entry.mood,
                "conflict_or_mistake": diary_entry.conflict_or_mistake,
                "parent_response_child_reaction": diary_entry.parent_response_child_reaction,
                "praise_situation": diary_entry.praise_situation,
                "todos": todo_list
            }, status=200)

        except DiaryEntry.DoesNotExist:
            return Response({"error": "No diary entry found for this date."}, status=404)
