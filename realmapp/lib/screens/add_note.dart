import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realmapp/controllers/note_controller.dart';
import 'package:realmapp/models/note.dart';

class AddNote extends StatelessWidget {
  final Note? note;

  AddNote({Key? key, this.note}) : super(key: key) {
    if (note != null) {
      noteController.textEditingControllerTitle.text = note!.title;
      noteController.textEditingControllerMessage.text = note!.message;
    }
  }

  NoteController noteController = Get.find<NoteController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""
            "Add Note"),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        actions: [
          if (note == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () {
                    noteController.saveNote();

                  },
                  icon: Icon(
                    Icons.check,
                    size: 30,
                    color: Colors.green,
                  )),
            ),
          if (note != null)
            IconButton(
                onPressed: () {
                  noteController.deleteNote(note:note!);
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: noteController.textEditingControllerTitle,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                decoration: InputDecoration(
                  hintText: "Heading",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: noteController.textEditingControllerMessage,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  fillColor: Colors.grey.withOpacity(0.2),
                  hintText: "Your message ...",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 0.2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 0.2)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 0.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
