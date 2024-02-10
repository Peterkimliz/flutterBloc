package com.example.noteapp.presentation.events

import com.example.noteapp.data.Note

interface UserEvents {
    object SaveNote : UserEvents
    data class DeleteNote(val note: Note) : UserEvents
    data class SaveTitle(val title:String ):UserEvents


}