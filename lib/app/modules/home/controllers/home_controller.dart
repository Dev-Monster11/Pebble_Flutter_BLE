import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue/flutter_blue.dart';

class HomeController extends GetxController {
  final RxInt isScanning = 0.obs;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? pebble1;
  BluetoothDevice? pebble2;
  @override
  void onInit() async {
    super.onInit();
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.contains('SR01')) {
          pebble1 = r.device;

          Get.snackbar('Pebble1 found', r.device.name);
        } else if (r.device.name.contains('SR02')) {
          pebble2 = r.device;
          pebble2!.connect();
          Get.snackbar('Pebble2 found', r.device.name);
        }
      }
    });
    flutterBlue.stopScan();
    bool flag = await connectDevice();
    isScanning.value = 1;
    print('Flag -----$flag');
    flag = await discoverService();
    print('Flag -----$flag');
    isScanning.value = 2;
  }

  Future<bool> connectDevice() async {
    if (pebble1!.name.isEmpty == false) {
      await pebble1!.connect();
    }
    if (pebble2!.name.isEmpty == false) {
      await pebble2!.connect();
    }
    return true;
  }

  Future<bool> discoverService() async {
    List<BluetoothService> services = await pebble1!.discoverServices();
    services.forEach((service) {
      writeCharacteristics(service);
    });
    return true;
  }

  void writeCharacteristics(BluetoothService service) async {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      await c.write(utf8.encode('COM 090002550003000\r\n'));
      List<int> value = await c.read();
      print(String.fromCharCodes(value));
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    pebble1!.disconnect();
    pebble2!.disconnect();
  }
}
