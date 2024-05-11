import 'package:flutter/material.dart';

class DatePicket extends StatelessWidget {
  final TimeOfDay selectedTime;
  final String text;
  final Function() onPressed;

  const DatePicket({
    Key? key,
    required this.selectedTime,
    required this.onPressed, 
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text),
        Text(
          '${selectedTime.hour < 10 ? '0${selectedTime.hour}' : selectedTime.hour}:${selectedTime.minute < 10 ? '0${selectedTime.minute}' : selectedTime.minute}',
          style: const TextStyle(fontSize: 20),
        ),
        ElevatedButton(
          onPressed: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'PickTime',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
