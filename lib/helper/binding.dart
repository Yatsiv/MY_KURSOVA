import 'package:get/get.dart';
import 'package:my_app/helper/local_storage_data.dart';

import '../view_model/auth_view_model.dart';
import '../view_model/control_view_model.dart';

class Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthViewModel());
    Get.lazyPut(() => ControlViewModel());
    Get.lazyPut(() => LocalStorageData());
  }
}
