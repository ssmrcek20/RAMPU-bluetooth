import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothUredaj extends ListTile {
  BluetoothUredaj({
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTap,
    bool enabled = true,
  }) : super(
          onTap: onTap,
          enabled: enabled,
          title: Text(device.name ?? "Nema naziva"),
          subtitle: Text(device.address.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              device.isConnected
                  ? Icon(Icons.import_export)
                  : Container(width: 0, height: 0),
              device.isBonded
                  ? Icon(Icons.link)
                  : Container(width: 0, height: 0),
            ],
          ),
        );
}
