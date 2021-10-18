import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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

  static BluetoothConnection? get connection1 => HomeController._connection1;
  static BluetoothConnection? get connection2 => HomeController._connection2;

  @override
  void onInit() async {
    super.onInit();
    FlutterBluetoothSerial.instance.requestEnable();
    final int timeout =
        (await FlutterBluetoothSerial.instance.requestDiscoverable(60))!;
    if (timeout < 0) {
      print('Discoverable mode denied');
    } else {
      print('Discoverable mode acquired for $timeout seconds');
    }
    FlutterBluetoothSerial.instance.state
        .then((value) => {_bluetoothState.value = value});

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        _address.value = address!;
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      _name.value = name!;
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      _bluetoothState.value = state;
    });

    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      if (event.device.name!.contains('SR1')) {
        Get.snackbar('Hi', 'Pebble 1 Found');
        _pebble1 = event.device;
      }
      if (event.device.name!.contains('SR2')) {
        Get.snackbar('Hi', 'Pebble 2 Found');
        _pebble2 = event.device;
      }
    });

    _streamSubscription!.onDone(() {
      discovering.value = false;
    });

    BluetoothConnection.toAddress(_pebble1!.address)
        .then((value) => {_connection1 = value});
    BluetoothConnection.toAddress(_pebble2!.address)
        .then((value) => {_connection2 = value});
    connection1!.input!.listen(_onDataReceived1);
    connection2!.input!.listen(_onDataReceived2);
  }

  void _onDataReceived1(Uint8List data) {
    Get.snackbar('SR1', data.toString());
  }

  void _onDataReceived2(Uint8List data) {
    Get.snackbar('SR2', data.toString());
  }

  void sendData() async {
    connection1!.output.add(Uint8List.fromList(
        utf8.encode("COM 090002550003000DEL 05000WRD pebble1_")));
    await connection1!.output.allSent;
    connection2!.output.add(Uint8List.fromList(
        utf8.encode("COM 090002550003000DEL 05000WRD pebble2_")));
    await connection2!.output.allSent;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    connection1?.dispose();
    connection2?.dispose();
  }
}
