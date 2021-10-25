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
    flutterBlue.startScan(
        withServices: [Guid('00001800-0000-1000-8000-00805F9B34FB')],
        timeout: Duration(seconds: 2));
    // flutterBlue.startScan(timeout: Duration(seconds: 2));

    flutterBlue.scanResults.listen((event) {
      for (ScanResult r in event) {
        if (r.device.name.startsWith('SR_01')) {
          isScanning.value++;
          p1 = r.device;
          pebble1Found(true).then((v) {
            print('----pebble1 end   $v');
          });

          // services.forEach((service){

          // });
          p1Found.value = true;
          print('${r.device.name} found rssi: ${r.rssi}');
        }
        //  else if (r.device.name.startsWith('SR_02')) {
        //   isScanning.value++;
        //   p2 = r.device;
        //   p2Found.value = true;
        //   // await p2!.connect();
        //   print('${r.device.name} found rssi: ${r.rssi}');
        // }
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

  Future<int> pebble1Found(found) async {
    if (found) {
      await p1!.connect();
      print('p1 connected');
      List<BluetoothService> aa = await p1!.discoverServices();
      for (int i = 0; i < aa.length; i++) {
        BluetoothService service = aa[i];
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          print('characteristics descriptor ---${c.descriptors}');
          await c.write(utf8.encode('COM 090002550003000'));
          List<int> v = await c.read();
          print(v);
          await c.write(utf8.encode('DEL 05000'));
          v = await c.read();
          print(v);
          await c.write(utf8.encode('WRD pebble_1'));
          v = await c.read();
          print(v);
          return 1;
        }
      }
    } else {
      return 0;
    }
    return 0;
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
