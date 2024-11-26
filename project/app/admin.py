from django.contrib import admin
from .models import UserProfile, DiaryEntry, ToDoItem

admin.site.register(UserProfile)
admin.site.register(DiaryEntry)
admin.site.register(ToDoItem)
