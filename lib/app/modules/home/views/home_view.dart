import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  void _sendData() async{
    int a = await controller.startAction();
    print('\n\n-------return value   $a\n\n');
  }

  Widget loadingIndicator(){

    if (controller.isScanning.value < 2){
      return CircularProgressIndicator();
    }else{
      return Text('Finished');
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: Column(
        children: [
      Center(
          child: ElevatedButton(onPressed: _sendData, child: Text("Send"))
          
        ),
        Center(
          child: Obx(loadingIndicator)
        )
        ])
    );
  }
}
