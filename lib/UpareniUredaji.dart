import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothUredaj.dart';

class UpareniUredaji extends StatefulWidget {
  final bool checkAvailability;

  const UpareniUredaji({this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<UpareniUredaji> {
  List<_DeviceWithAvailability> uredaji =
      List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        uredaji = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }



  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothUredaj> list = uredaji
        .map((_device) => BluetoothUredaj(
              device: _device.device,
              rssi: _device.rssi,
              enabled: _device.availability == _DeviceAvailability.yes,
              onTap: () {
                Navigator.of(context).pop(_device.device);
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Upareni uređaji'),
      ),
      body: ListView(children: list),
    );
  }
}
