import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';

class HomeController extends GetxController {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? p1;
  BluetoothDevice? p2;

  var p1Found = false.obs;
  var p2Found = false.obs;
  var isScanning = 0.obs;
  Future<int> startAction() async {
    p1Found.value = false;
    p2Found.value = false;
    isScanning.value = 1;
    flutterBlue.startScan();

    flutterBlue.scanResults.listen((event) {
      for (ScanResult r in event) {
        print('${r.device.name} found rssi: ${r.rssi}');
        if (r.device.name.startsWith('SR_01')) {
          isScanning.value++;
          p1 = r.device;
          p1Found.value = true;
        } else if (r.device.name.startsWith('SR_02')) {
          isScanning.value++;
          p2 = r.device;
          p2Found.value = true;
        }
      }
    });
    // await p1!.connect();
    // await p2!.connect();
    // List<BluetoothService> services = await p1!.discoverServices();
    // for (BluetoothService service in services) {
    //   // do something with service
    //   var characteristics = service.characteristics;
    //   for (BluetoothCharacteristic c in characteristics) {
    //     await c.write(utf8.encode("COM 090002550003000\r\n"));
    //     await c.write(utf8.encode("DEL 05000\r\n"));
    //     await c.write(utf8.encode("WRD pebble1_\r\n"));
    //     List<int> value = await c.read();
    //     print('\n\nRead Value is ----\t${value}\n');
    //   }
    // }
    // isScanning.value = 3;
    return isScanning.value;
  }

  void pebble1Found(found) async {
    if (found) {
      Get.snackbar('Hi', p1.toString());
      print('Device1 Connecting-------');
      await p1!.connect();
      print('Device1 Connected-------');
    }
  }

  void pebble2Found(found) async {
    if (found) {
      Get.snackbar('Hi', p2.toString());
      await p2!.connect();
    }
  }

  @override
  void onInit() async {
    super.onInit();
    ever(p1Found, pebble1Found);
    ever(p2Found, pebble2Found);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
