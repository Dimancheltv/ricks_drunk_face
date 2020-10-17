import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'CircleProgress.dart';
import 'top_bar.dart';
import 'sticker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UsbPort _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  String _serialData = "0.0";
  int _max = 0;
  StreamSubscription<String> _subscription;
  Transaction<String> _transaction;
  int _deviceId;

  Future<bool> _connectTo(device) async {
    _serialData = '';
    _max = 0;

    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port.close();
      _port = null;
    }

    if (device == null) {
      _deviceId = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (!await _port.open()) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }

    _deviceId = device.deviceId;
    await _port.setDTR(true);
    await _port.setRTS(true);
    await _port.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port.inputStream, Uint8List.fromList([13, 10]));

    _subscription = _transaction.stream.listen((String line) {
      setState(() {
        _serialData = line;
        if (int.parse(_serialData) > _max) {
          _max = int.parse(_serialData);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName),
          subtitle: Text(device.manufacturerName),
          trailing: RaisedButton(
            child:
                Text(_deviceId == device.deviceId ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_deviceId == device.deviceId ? null : device)
                  .then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {
      print(_ports);
    });
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              TopBar(),
              Positioned(
                top: 78.0,
                left: 0.0,
                right: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Rick's alcohol level",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: Colors.white,
                                letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 200.0),
                child: Center(
                  child: Column(children: <Widget>[
                    Text(
                        _ports.length > 0
                            ? "Available Serial Ports"
                            : "No serial devices available"
                        ),
                    ..._ports,
                    Text('Status: $_status\n'),
                    Text("Rick's face"),
                    CustomPaint(
                      foregroundPainter: CircleProgress(double.parse(_serialData)),
                      child: Container(
                        width: 350,
                        height: 350,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Alcohol'),
                              Result(count: _max),
                              Text(
                                _serialData,
                                style: TextStyle(
                                    fontSize: 50, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'ppm',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Maximum level: ${_max.toString()}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: RaisedButton(
                          child: Text("Clean"),
                          onPressed: () {
                            _max = 0;
                          }),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ));
  }
}
