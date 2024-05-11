import 'package:ble_test_provider/widget/date_piker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'package:ble_test_provider/provider/ble_provider.dart';

import 'package:time_picker_spinner/time_picker_spinner.dart';
import 'package:ble_test_provider/widget/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "Selecione un dipositivo";
  late BluetoothDevice myDevice;
  bool isConnected = false;
  Guid UUIDread = Guid("229a8d41-fde4-44ff-8dad-feecdc379e92");
  Guid UUIDwrite = Guid("d8520577-81ed-478c-a3ad-a810d65c064a");
  DateTime dateTime = DateTime.now();
  TimeOfDay _timefrom = TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _timeto = TimeOfDay(hour: 8, minute: 30);

  @override
  Widget build(BuildContext context) {
    final bleprovider = Provider.of<Bleprovider>(context);

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          const SizedBox(height: 20),
          devicemneu(bleprovider),
          buttonsRow(bleprovider),
          CustomButton(
            text: "Desconectar",
            icon: Icons.close,
            onPressed: () async {
              if (isConnected) {
                print("Momento de desconectar");
                await bleprovider.disconnectToDevice(myDevice);
                text =
                    "${myDevice.platformName} -> ${myDevice.isConnected ? "Connected" : "Disconnected"}";
                isConnected = myDevice.isConnected;
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 20),
          readbutton(bleprovider),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DatePicket(
                selectedTime: _timefrom,
                text: 'from',
                onPressed: () async {
                  await _showTimePicker((newTime) {
                    setState(() {
                      _timefrom = newTime;
                      if ((_timefrom.hour > _timeto.hour ||
                              (_timefrom.hour == _timeto.hour &&
                                  _timefrom.minute > _timeto.minute))) {
                        _timeto = TimeOfDay(
                            hour: _timefrom.hour, minute: _timefrom.minute + 1);
                      }
                    });
                  });
                },
              ),
              DatePicket(
                selectedTime: _timeto,
                text: 'to',
                onPressed: () async {
                  await _showTimePicker((newTime) {
                    setState(() {
                      _timeto = newTime;
                    });
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          writebutton(bleprovider),
          const SizedBox(height: 20),
          // timepicker(context),
        ],
      )),
    );
  }

  Future<void> _showTimePicker(void Function(TimeOfDay) onTimePicked) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onTimePicked(pickedTime);
    }
  }

  Column timepicker(BuildContext context) {
    return Column(
      children: [
        Text('${dateTime.hour} : ${dateTime.minute} : ${dateTime.second}',
            style: Theme.of(context).textTheme.headlineMedium),
        TimePickerSpinner(
          locale: const Locale('en', ''),
          time: dateTime,
          is24HourMode: false,
          isShowSeconds: true,
          itemHeight: 80,
          normalTextStyle: const TextStyle(
            fontSize: 12,
          ),
          highlightedTextStyle:
              const TextStyle(fontSize: 24, color: Colors.blue),
          isForce2Digits: true,
          onTimeChange: (time) {
            setState(() {
              dateTime = time;
            });
          },
        ),
      ],
    );
  }

  DropdownButton<BluetoothDevice> devicemneu(Bleprovider bleprovider) {
    return DropdownButton(
      hint: const Text("Seleciones un dispostivo"),
      value: bleprovider.selectedDevice,
      onChanged: (BluetoothDevice? newDevice) {
        text =
            "${newDevice!.platformName} -> ${newDevice.isConnected ? "Connectes" : "Disconnected"}";
        myDevice = newDevice;
        bleprovider.stopScanning();
        setState(() {});
      },
      items: bleprovider.devices
          .map<DropdownMenuItem<BluetoothDevice>>((BluetoothDevice device) {
        return DropdownMenuItem<BluetoothDevice>(
          value: device,
          child: Text(device.platformName.trim()),
        );
      }).toList(),
    );
  }

  ElevatedButton writebutton(Bleprovider bleprovider) {
    return ElevatedButton.icon(
      onPressed: () {
        if (isConnected) {
          if (_timefrom.hour < _timeto.hour ||
              (_timefrom.hour == _timeto.hour &&
                  _timefrom.minute < _timeto.minute)) {
            print(
                'from ${_timefrom.hour}:${_timefrom.minute} to ${_timeto.hour}:${_timeto.minute}');
            List<int> exampleList = [
              _timefrom.hour,
              _timefrom.minute,
              _timeto.hour,
              _timeto.minute
            ];
            bleprovider.writeCharacteristic(UUIDwrite, exampleList);
          } else {
            print(
                "La hora de inicio debe ser menor que la hora de finalización");
          }
        }else{
          print("is not connected");
        }
      },

      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50), // Tamaño del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
        ),
      ),
      icon: const Icon(Icons.touch_app), // Ícono
      label: const Text('Write data'), // Texto del botón
    );
  }

  ElevatedButton readbutton(Bleprovider bleprovider) {
    return ElevatedButton.icon(
      onPressed: () {
        if (isConnected) {
          print("Reading data");
          bleprovider.readCharacteristic(UUIDread);
        } else {
          print("No esta conectado");
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50), // Tamaño del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
        ),
      ),
      icon: const Icon(Icons.touch_app), // Ícono
      label: const Text('Click Me'), // Texto del botón
    );
  }

  Row buttonsRow(Bleprovider bleprovider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          text: "Scan",
          icon: Icons.scanner,
          onPressed: () {
            text = "Scanning select one device";
            print("scan");
            bleprovider.startScanning();
            setState(() {});
          },
        ),
        CustomButton(
          text: "Connect",
          icon: Icons.connect_without_contact_outlined,
          onPressed: () async {
            print("Momento de contar");
            await bleprovider.connectToDevice(myDevice);
            text =
                "${myDevice.platformName} -> ${myDevice.isConnected ? "Connected" : "Disconnected"}";
            isConnected = myDevice.isConnected;
            setState(() {});
          },
        ),
      ],
    );
  }
}
