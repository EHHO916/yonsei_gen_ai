from django.urls import path
from .views import ChatWithAIView, SaveToDoListView, CalendarDataView

urlpatterns = [
    path('chat/', ChatWithAIView.as_view(), name='chat-ai'),
    path('todo/save/', SaveToDoListView.as_view(), name='save-todo-list'),
    path('calendar/<str:user_id>/<str:date>/', CalendarDataView.as_view(), name='calendar-data'),
]

