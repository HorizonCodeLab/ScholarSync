import 'package:get/get.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() async {
    super.onReady();

    await Future.delayed(const Duration(seconds: 2));

    Get.offAllNamed(AppRoutes.main);
  }
}
