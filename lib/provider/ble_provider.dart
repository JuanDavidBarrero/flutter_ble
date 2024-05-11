import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Bleprovider with ChangeNotifier {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  Bleprovider();

  void startScanning() async {
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          devices.add(result.device);
          notifyListeners();
        }
      }
    });
  }

  void stopScanning() {
    FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    selectedDevice = device;
    await selectedDevice!.connect();
    notifyListeners();
  }

  Future<void> disconnectToDevice(BluetoothDevice device) async {
    await selectedDevice!.disconnect();
    selectedDevice = null;
    notifyListeners();
  }

  void readCharacteristic(Guid characteristicId) async {
    List<BluetoothService> services = await selectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          List<int> value = await characteristic.read();
          String text = utf8.decode(value);
          print('Read value: $text');
        }
      }
    }
  }

  void writeCharacteristic(Guid characteristicId, List<int> data) async {
    List<BluetoothService> services = await selectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          await characteristic.write(data);
          print('Data written successfully.');
        }
      }
    }
  }
}
