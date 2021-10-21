import 'package:get/get.dart';
import 'dart:async';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class HomeController extends GetxController {
  final RxInt isScanning = 0.obs;
  BleManager bleManager = BleManager();
  Future<int> startAction() async {
    isScanning.value = 1;
    await bleManager.createClient();

    bleManager.startPeripheralScan().listen((scanResult) {
      print(
          "Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
    });
    isScanning.value = 3;
    return isScanning.value;
  }

  @override
  void onInit() async {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
