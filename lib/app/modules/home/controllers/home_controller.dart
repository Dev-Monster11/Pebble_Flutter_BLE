import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';

class HomeController extends GetxController {
  final RxInt isScanning = 0.obs;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? p1;
  BluetoothDevice? p2;
  Future<int> startAction() async {
    isScanning.value = 1;
    flutterBlue.startScan();
    flutterBlue.scanResults.listen((event) {
      for (ScanResult r in event) {
        print('${r.device.name} found rssi: ${r.rssi}');
        if (r.device.name.startsWith('SR_01')) {
          isScanning.value |= 2;
          p1 = r.device;
          Get.snackbar('Device1 Found', 'Pebble1 Found');
        } else if (r.device.name.startsWith('SR_02')) {
          isScanning.value |= 4;
          p2 = r.device;
          Get.snackbar('Device@ Found', 'Pebble2 Found');
        }
        if (isScanning.value == 7) {
          flutterBlue.stopScan();
          break;
        }
      }
    });
    await p1!.connect();
    await p2!.connect();
    List<BluetoothService> services = await p1!.discoverServices();
    for (BluetoothService service in services) {
      // do something with service
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        await c.write(utf8.encode("COM 090002550003000\r\n"));
        await c.write(utf8.encode("DEL 05000\r\n"));
        await c.write(utf8.encode("WRD pebble1_\r\n"));
        List<int> value = await c.read();
        print('\n\nRead Value is ----\t${value}\n');
      }
    }
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
