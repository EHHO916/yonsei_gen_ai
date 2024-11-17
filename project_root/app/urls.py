from django.urls import path
from .views import DiaryEntryView

urlpatterns = [
    path('diary/', DiaryEntryView.as_view(), name='diary-entry')
]
