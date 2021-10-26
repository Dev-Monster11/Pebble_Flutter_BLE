import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';

class HomeController extends GetxController {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? p1;
  BluetoothDevice? p2;
  // Guid guid1 = Guid('00001800-0000-1000-8000-00805F9B34FB');
  Guid guid2 = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  var p1Found = false.obs;
  var p2Found = false.obs;
  var isScanning = 0.obs;
  Future<int> startAction() async {
    p1Found.value = false;
    p2Found.value = false;
    isScanning.value = 1;
    flutterBlue.startScan(timeout: Duration(seconds: 2), withServices: [guid2]);
    // flutterBlue.startScan(timeout: Duration(seconds: 2));

    flutterBlue.scanResults.listen((event) {
      for (ScanResult r in event) {
        if (r.device.name.startsWith('SR01')) {
          p1 = r.device;
          // pebble1Found(r.device).then((v) {
          //   isScanning.value = v;
          // });
        } else if (r.device.name.startsWith('SR02')) {
          // pebble2Found(r.device).then((v) {
          //   isScanning.value = v;
          // });
          p2 = r.device;
          flutterBlue.stopScan();
        }
      }
    });
    return isScanning.value;
  }

  Future<int> pebble1Found(BluetoothDevice pebble1) async {
    await pebble1.connect();
    List<BluetoothService> aa = await pebble1.discoverServices();
    for (int i = 0; i < aa.length; i++) {
      BluetoothService service = aa[i];
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        await c.write(utf8.encode('COM 090002550003000'));
        List<int> v = await c.read();
        print(v);
        await c.write(utf8.encode('DEL 05000'));
        v = await c.read();
        print(v);
        await c.write(utf8.encode('WRD pebble1_'));
        v = await c.read();
        print(v);
        return 1;
      }
    }
    return 0;
  }

  Future<int> sendAction() async {
    await p2!.connect();

    List<BluetoothService> aa = await p2!.discoverServices();
    print('length-----------${aa.length}');
    for (int i = 0; i < aa.length; i++) {
      BluetoothService service = aa[i];
      print('service uuid----${service.uuid}');
      var characteristics = service.characteristics;

      for (BluetoothCharacteristic c in characteristics) {
        // if (c.uuid == 0x03) {
        print('chaaracter uuid ----${c.uuid}');
        print('character id------${c.serviceUuid}');
        await c.write(utf8.encode('COM 090002550003000'));
        List<int> v = await c.read();
        print('read--------$v');
        await c.write(utf8.encode('DEL 05000'));
        v = await c.read();
        print('del read-------$v');
        await c.write(utf8.encode('WRD pebble2_'));
        v = await c.read();
        print('wrd read--------$v');
        return 10;
        // }
      }
    }
    return 0;
  }

  Future<int> pebble2Found(BluetoothDevice pebble2) async {
    await pebble2.connect();
    List<BluetoothService> aa = await pebble2.discoverServices();

    for (int i = 0; i < aa.length; i++) {
      BluetoothService service = aa[i];
      var characteristics = service.characteristics;
      print('discovered characteris-------$characteristics');
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid == guid2) {
          print('found characteristics');
          await c.write(utf8.encode('COM 090002550003000'));
          List<int> v = await c.read();
          print('read--------$v');
          await c.write(utf8.encode('DEL 05000'));
          v = await c.read();
          print('del read-------$v');
          await c.write(utf8.encode('WRD pebble2_'));
          v = await c.read();
          print('wrd read--------$v');
          return 10;
        }
      }
    }
    return 0;
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
