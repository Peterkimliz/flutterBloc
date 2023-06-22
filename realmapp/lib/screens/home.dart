import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:realmapp/controllers/note_controller.dart';
import 'package:realmapp/models/note.dart';
import 'package:realmapp/screens/add_note.dart';

class Home extends StatelessWidget {
  NoteController noteController = Get.find<NoteController>();

  Home({Key? key}) : super(key: key) {
    noteController.retriveAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        title: Text("Notes"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
                onPressed: () {
                  showfilterBottomShhet(context: context);
                },
                icon: Icon(Icons.filter_list_outlined, color: Colors.black)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddNote());
        },
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        return noteController.allNotes.isEmpty
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Keep your life organized",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: noteController.allNotes.length,
                itemBuilder: (context, index) {
                  Note note = noteController.allNotes.elementAt(index);
                  return InkWell(
                    onTap: () {
                      Get.to(() => AddNote(note: note));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(1, 1),
                                // blurRadius: 1,
                                // spreadRadius: 1,
                                color: Colors.grey)
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            note.title,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${DateFormat("dd-MM-yyyy").format(note.date)}",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            note.message,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  );
                });
      }),
    );
  }

  showfilterBottomShhet({required BuildContext context}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        context: context,
        builder: (context) {
          return Builder(builder: (BuildContext context) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: noteController.allCategories.length,
                    itemBuilder: (context, index) {
                      Categories categories =
                          noteController.allCategories.elementAt(index);
                      return InkWell(
                        onTap: (){
                          Get.back();
                          noteController.selectedCategory.value=categories;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          child: Text(categories.type),
                        ),
                      );
                    }));
          });
        });
  }
}
