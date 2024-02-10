package com.example.noteapp.presentation.viewModels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.noteapp.data.Note
import com.example.noteapp.data.NoteDao
import kotlinx.coroutines.launch

class NoteViewModel(
    private val dao: NoteDao
):ViewModel() {
    init {
        viewModelScope.launch {
            insertNote()
        }

    }

    private suspend fun insertNote() {
        dao.upsertNote(Note("hello","hello",12345))
    }
}