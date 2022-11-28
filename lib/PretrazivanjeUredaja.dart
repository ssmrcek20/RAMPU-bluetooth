import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothUredaj.dart';

class PretrazivanjeUredaja extends StatefulWidget {

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<PretrazivanjeUredaja> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> rezultat =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    _pretrazi();
  }

  void _ponovnoPretrazi() {
    setState(() {
      rezultat.clear();
      isDiscovering = true;
    });

    _pretrazi();
  }

  void _pretrazi() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = rezultat.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          rezultat[existingIndex] = r;
        else
          rezultat.add(r);
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }


  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? Text('Pretraživanje bluetooth uređaja')
            : Text('Bluetooth uređaji'),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: _ponovnoPretrazi,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: rezultat.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = rezultat[index];
          final device = result.device;
          final address = device.address;
          return BluetoothUredaj(
            device: device,
            rssi: result.rssi,
            onTap: () async {
              try {
                bool bonded = false;
                if (device.isBonded) {
                  await FlutterBluetoothSerial.instance
                      .removeDeviceBondWithAddress(address);
                } else {
                  bonded = (await FlutterBluetoothSerial.instance
                      .bondDeviceAtAddress(address))!;
                }
                setState(() {
                  rezultat[rezultat.indexOf(result)] = BluetoothDiscoveryResult(
                      device: BluetoothDevice(
                        name: device.name ?? '',
                        address: address,
                        type: device.type,
                        bondState: bonded
                            ? BluetoothBondState.bonded
                            : BluetoothBondState.none,
                      ),
                      rssi: result.rssi);
                });
              } catch (ex) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text("${ex.toString()}"),
                      actions: <Widget>[
                        new TextButton(
                          child: new Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
