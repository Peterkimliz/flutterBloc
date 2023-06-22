import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:realmapp/controllers/note_controller.dart';

import '../models/note.dart';

class RealmController extends GetxController {
  Rxn<App> app = Rxn(null);
  late Realm realm;
  Rxn<User> currentUser = Rxn(null);

  initializeApp(String appId)async {
    final appConfig = AppConfiguration(appId);
    app.value = App(appConfig);
    await initializeAppConfiguration();

    Get.put<NoteController>(NoteController()).createCategories();
    Get.put<NoteController>(NoteController()).retriveAllCategories();
  }

  initializeAppConfiguration() async {
    try {
      List<SchemaObject> schemas = [Note.schema, UserModel.schema,Categories.schema];
      if (app.value?.currentUser != null || currentUser.value != app.value?.currentUser) {
        currentUser.value = app.value?.currentUser;
        final config = Configuration.flexibleSync(currentUser.value!, schemas);
        realm = Realm(config);

        realm.subscriptions.update((mutableSubscriptions) {
          mutableSubscriptions.add(realm.all<Note>());
          mutableSubscriptions.add(realm.all<UserModel>());
          mutableSubscriptions.add(realm.all<Categories>());
        });
        await realm.subscriptions.waitForSynchronization();
      }

    } catch (e) {
      print("error is ttt ${e}");
    }


  }

 @override
  void dispose() {
    realm.close();
    super.dispose();
  }
}
