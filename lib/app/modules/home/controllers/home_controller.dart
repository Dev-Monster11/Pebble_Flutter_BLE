import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// import 'package:flutter_blue/flutter_blue.dart';

class HomeController extends GetxController {
  final Rx<BluetoothState> _bluetoothState = BluetoothState.UNKNOWN.obs;
  final Rx<String> _name = ''.obs;
  final Rx<String> _address = ''.obs;
  final RxBool discovering = true.obs;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[].obs;
  static BluetoothConnection? _connection1;
  static BluetoothConnection? _connection2;
  static BluetoothDevice? _pebble1;
  static BluetoothDevice? _pebble2;
  int index = 0;
  static BluetoothConnection? get connection1 => HomeController._connection1;
  static BluetoothConnection? get connection2 => HomeController._connection2;

  // FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void onInit() async {
    super.onInit();

    // flutterBlue.startScan(timeout: Duration(seconds: 4));

    // var subscription = flutterBlue.scanResults.listen((results) {
    //   for (ScanResult r in results) {
    //     if (r.device.name.contains('SR01')) {
    //       index = 1;
    //       _pebble1 = r.device;
    //       print('Pebble1 address:\t${_pebble1!.name}');
    //       flutterBlue.stopScan();
    //       break;
    //     }
    //   }
    // });
    // print('subscription----$subscription');
    // await _pebble1!.connect();
    // List<BluetoothService> services = await _pebble1!.discoverServices();

    // for (BluetoothService s in services) {
    //   print('---discovered service is ${s.uuid.toString()}');
    //   for (BluetoothCharacteristic c in s.characteristics) {
    //     print('---characteristics is ${c.descriptors}');
    //     c.write(utf8.encode('COM 090002550003000\r\n'));
    //     c.write(utf8.encode('DEL 05000\r\n'));
    //     c.write(utf8.encode('WRD pebble1_\r\n'));
    //   }
    // }
    // discovering.value = false;
    await FlutterBluetoothSerial.instance.requestEnable();
    final int timeout =
        (await FlutterBluetoothSerial.instance.requestDiscoverable(60))!;
    if (timeout < 0) {
      print('Discoverable mode denied');
    } else {
      print('Discoverable mode acquired for $timeout seconds');
    }

    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      if (event.device.name!.contains('SR01')) {
        _pebble1 = event.device;

        print('pebble1---${_pebble1!.address}');
        FlutterBluetoothSerial.instance.cancelDiscovery();
        index = 1;
      }
      // if (event.device.name!.contains('SR02')) {
      //   Get.snackbar('Pebble2', _pebble2!.address);
      //   _pebble2 = event.device;
      //   index = index | 2;
      // }
      // if (index == 3) {
      //   FlutterBluetoothSerial.instance.cancelDiscovery();
      //   Get.snackbar("Hi", 'All pebbles are found');
      //   return;
      // }
    });
    print('-----');
    _streamSubscription!.onDone(() {
      print('discovering done');
      discovering.value = false;
    });
    // FlutterBluetoothSerial.instance.setPairingRequestHandler((request) => )
    BluetoothConnection.toAddress(_pebble1!.address).then((value) {
      _connection1 = value;
      print('----connection1  ${_connection1!.isConnected}');
    });
    // BluetoothConnection.toAddress(_pebble2!.address)
    //     .then((value) => {_connection2 = value});
    connection1!.input!.listen(_onDataReceived1);
    // connection2!.input!.listen(_onDataReceived2);
  }

  void _onDataReceived1(Uint8List data) {
    Get.snackbar('SR1', data.toString());
  }

  void _onDataReceived2(Uint8List data) {
    Get.snackbar('SR2', data.toString());
  }

  void sendData() async {
    print('---senddata');
    Get.snackbar('Pebble1', 'Pebble1 Started');
    connection1!.output
        .add(Uint8List.fromList(utf8.encode("COM 090002550003000\r\n")));
    await connection1!.output.allSent;

    Get.snackbar('Pebble1', 'COM command sent');
    connection1!.output.add(Uint8List.fromList(utf8.encode("DEL 05000\r\n")));
    await connection1!.output.allSent;
    Get.snackbar('Pebble1', 'DEL command sent');
    connection1!.output
        .add(Uint8List.fromList(utf8.encode("WRD pebble1_\r\n")));
    await connection1!.output.allSent;
    Get.snackbar('Pebble1', 'WRD command sent');

    // if (index & 1 == 1) {
    //   Get.snackbar('Pebble1', 'Pebble1 Started');
    //   connection1!.output
    //       .add(Uint8List.fromList(utf8.encode("COM 090002550003000\r\n")));
    //   await connection1!.output.allSent;

    //   Get.snackbar('Pebble1', 'COM command sent');
    //   connection1!.output.add(Uint8List.fromList(utf8.encode("DEL 05000\r\n")));
    //   await connection1!.output.allSent;
    //   Get.snackbar('Pebble1', 'DEL command sent');
    //   connection1!.output
    //       .add(Uint8List.fromList(utf8.encode("WRD pebble1_\r\n")));
    //   await connection1!.output.allSent;
    //   Get.snackbar('Pebble1', 'WRD command sent');
    // }
    // if (index & 2 == 2) {
    //   Get.snackbar('Pebble2', 'Pebble2 Started');
    //   connection2!.output
    //       .add(Uint8List.fromList(utf8.encode("COM 090002550003000\r\n")));
    //   await connection2!.output.allSent;
    //   Get.snackbar('Pebble2', 'COM command sent');
    //   connection2!.output.add(Uint8List.fromList(utf8.encode("DEL 05000\r\n")));
    //   await connection2!.output.allSent;
    //   Get.snackbar('Pebble2', 'DEL command sent');
    //   connection2!.output
    //       .add(Uint8List.fromList(utf8.encode("WRD pebble2_\r\n")));
    //   await connection2!.output.allSent;
    //   Get.snackbar('Pebble2', 'WRD command sent');
    // }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // connection1?.dispose();
    // connection2?.dispose();
  }
}
