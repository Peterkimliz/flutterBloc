import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:realmapp/controllers/realm_controller.dart';
import 'package:realmapp/controllers/userController.dart';
import 'package:realmapp/models/note.dart';

class NoteController extends GetxController {
  RealmController realmController = Get.find<RealmController>();
  TextEditingController textEditingControllerTitle = TextEditingController();
  TextEditingController textEditingControllerMessage = TextEditingController();
  RxList<Note> allNotes = RxList([]);
  RxList<Categories> allCategories = RxList([]);
  Rxn<App> app = Rxn(null);
  Rxn<Categories> selectedCategory = Rxn(null);

  saveNote() {
    Note note = Note(ObjectId(), textEditingControllerTitle.text,
        textEditingControllerMessage.text, DateTime.now(),
        category: selectedCategory.value,
        user: Get.find<UserController>().currentUser.value);
    realmController.realm.write(() {
      realmController.realm.add(note);
    });
    clearText();
    Get.back();
    retriveAllNotes();
  }

  retriveAllCategories() {
    try {
      print("categories are");
      RealmResults<Categories> notes = realmController.realm.all<Categories>();
      print("categories are ${notes.map((e) => e.type).toList()}");
      if (notes.isNotEmpty) {
        allCategories.assignAll(notes);
      } else {
        allNotes = RxList([]);
      }
      print(notes);
    } catch (e) {
      print(e);
    }
  }

  saveSelectedCategory() {
    realmController.realm.write(() {
      realmController.realm.add<Categories>(selectedCategory.value!);
    });
  }

  retriveAllNotes({Categories? category}) {
    try {
      String filters = " AND TRUEPREDICATE SORT(date DESC)";
      RealmResults<Note> notes = realmController.realm.query<Note>(
          r'user== $0', [Get.find<UserController>().currentUser.value!]);

      if (category != null) {
        notes = realmController.realm.query<Note>(
            "category == '$category' AND user == \$0",
            [Get.find<UserController>().currentUser.value!]);
      }

      if (notes.isNotEmpty) {
        allNotes.assignAll(notes);
      } else {
        allNotes = RxList([]);
      }
      print(notes);
    } catch (e) {
      print(e);
    }
  }

  deleteNote({required Note note}) {
    allNotes.removeWhere((element) => element.id == note.id);
    allNotes.refresh();
    realmController.realm.write(() {
      realmController.realm.delete(note);
    });
    clearText();
    Get.back();
  }

  updateNote({required Note note}) {
    allNotes.removeWhere((element) => element.id == note.id);
    allNotes.refresh();
    realmController.realm.write(() {
      if (textEditingControllerMessage.text.isNotEmpty) {
        note.message = textEditingControllerMessage.text;
      }
      if (textEditingControllerTitle.text.isNotEmpty) {
        note.title = textEditingControllerTitle.text;
      }
    });
  }

  clearText() {
    textEditingControllerTitle.clear();
    textEditingControllerMessage.clear();
  }

  @override
  void onInit() {
    // retriveAllCategories();
    super.onInit();
  }

  createCategories() {
    var categories = [
      Categories(ObjectId(), "All Notes", "white"),
      Categories(ObjectId(), "Personal", "amber"),
      Categories(ObjectId(), "Family", "orange"),
      Categories(ObjectId(), "Work", "green"),
      Categories(ObjectId(), "Others", "blue")
    ];
    realmController.realm.write(() {
      realmController.realm.addAll(categories);
    });
  }
}
