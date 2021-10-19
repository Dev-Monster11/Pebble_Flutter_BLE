import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  Widget mainContent() {
    if (controller.isScanning.value < 2) {
      return CircularProgressIndicator();
    } else {
      return ElevatedButton(onPressed: _sendData, child: Text("Send"));
    }
  }

  void _sendData() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: Obx(mainContent),
    );
  }
}
