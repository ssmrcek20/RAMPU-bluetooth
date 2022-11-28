import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './Poruke.dart';
import './PretrazivanjeUredaja.dart';
import './UpareniUredaji.dart';

void main() => runApp(new Pocetna());

class Pocetna extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  Timer? _discoverableTimeoutTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: ElevatedButton(
                  child: const Text('Pretraži bluetooth uređaje'),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return PretrazivanjeUredaja();
                        },
                      ),
                    );
                  }),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('Upareni uređaji'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return UpareniUredaji(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    _zapocniRazgovor(context, selectedDevice);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zapocniRazgovor(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Poruke(server: server);
        },
      ),
    );
  }
}
