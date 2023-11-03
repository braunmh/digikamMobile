import 'package:flutter/material.dart';

class GotoPositionDialog extends StatefulWidget {
  final int start;
  final int max;

  const GotoPositionDialog({super.key, required this.start, required this.max});

  @override
  GotoPositionState createState() {
    return GotoPositionState();
  }
}

class GotoPositionState extends State<GotoPositionDialog> {
  late double max;
  late double selectedValue;

  @override
  void initState() {
    super.initState();
    max = 1.0 * widget.max;
    selectedValue = 1.0 * ((widget.start == 0) ? 1 : widget.start);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Center(
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slider(
              value: selectedValue,
              min: 1,
              max: max,
              divisions: widget.max,
              label: selectedValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, widget.start);
                      },
                      child: const Text('Abbrechen'),
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedValue.round() - 1);
                    },
                    child: const Text('Gehe zu'),
                  ),
                )

              ],
            ),
          ],
        ),
      ),
    ));
  }
}
