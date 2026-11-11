import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BLESetupScreen extends StatefulWidget {
  const BLESetupScreen({super.key});

  @override
  State<BLESetupScreen> createState() => _BLESetupScreenState();
}

class _BLESetupScreenState extends State<BLESetupScreen> {
  final List<ScanResult> _devices = [];
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool _showAll = true;
  bool _scanning = false;

  static const _watchKeywords = [
    'goboult',
    'boult',
    'watch',
    'gear',
    'band',
    'fit',
    'gtr',
    'gts',
    'amazfit',
    'pixel watch',
    'galaxy watch',
    'apple watch',
    'huawei',
    'xiaomi',
    'oppo',
  ];

  @override
  void initState() {
    super.initState();
    requestPermissions();

    // Subscribe ONCE
    _scanSub = FlutterBluePlus.onScanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        _devices
          ..clear()
          ..addAll(_showAll ? results : results.where(isSmartwatch));
      });
    }, onError: (e) => debugPrint('Scan error: $e'));

    FlutterBluePlus.isScanning.listen((s) {
      if (mounted) setState(() => _scanning = s);
    });
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    debugPrint('Permissions: $statuses');
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<void> startScan() async {
    if (!await requestPermissions()) {
      debugPrint('Permissions not granted');
      return;
    }

    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
      return;
    }

    setState(() => _devices.clear());

    // Already-connected devices won't advertise, so add them manually
    try {
      final system = await FlutterBluePlus.systemDevices([]);
      final bonded = await FlutterBluePlus.bondedDevices;
      debugPrint('System devices: ${system.map((d) => d.platformName)}');
      debugPrint('Bonded devices: ${bonded.map((d) => d.platformName)}');
    } catch (e) {
      debugPrint('Could not read system/bonded devices: $e');
    }

    // NO withNames filter here
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );
  }

  bool isSmartwatch(ScanResult r) {
    final adv = r.advertisementData;
    final name = (adv.advName.isNotEmpty ? adv.advName : r.device.platformName)
        .toLowerCase();

    if (name.isNotEmpty && _watchKeywords.any(name.contains)) return true;

    final a = adv.appearance;
    if (a != null && a >= 0x0080 && a <= 0x0082) return true;

    return false;
  }

  String _nameOf(ScanResult r) => r.advertisementData.advName.isNotEmpty
      ? r.advertisementData.advName
      : r.device.platformName;

  void connectDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();

    await device.connect(
      license: License.nonprofit,
      autoConnect: false,
    );

    await discoverServices(device);
  }

  // Future<void> discoverServices(BluetoothDevice device) async {
  //   try {
  //     List<BluetoothService> services = await device.discoverServices();
  //     for (BluetoothService service in services) {
  //       for (BluetoothCharacteristic c in service.characteristics) {
  //         if (c.properties.read) {
  //           // var data = await c.read();
  //           debugPrint(
  //             '${service.uuid} / ${c.uuid}  '
  //             'read:${c.properties.read} write:${c.properties.write} '
  //             'writeNoResp:${c.properties.writeWithoutResponse} '
  //             'notify:${c.properties.notify}',
  //           );
  //         }
  //         //write characteristics
  //         if (c.properties.write) {}

  //         if (c.properties.notify) {
  //           await c.setNotifyValue(true);
  //           // c.lastValueStream.listen((value) {
  //           //   print('Notification: $value');
  //           // });
  //           c.onValueReceived.listen((value) {
  //             final data = String.fromCharCodes(value);
  //             debugPrint("Recieved ints -> $value");
  //             print('Received: $data');
  //             print("Cahr -> $c");
  //             showDialog(context: context, builder: (context) {
  //               return AlertDialog(
  //                 title: Text("HeartRate - $value"),
  //               );
  //             },);
  //           });
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Failed to discover the services");
  //   }
  // }

  StreamSubscription? _hrsub;
  Future<void> discoverServices(BluetoothDevice device) async {
  try {
    final services = await device.discoverServices();

    for (final service in services) {
      for (final c in service.characteristics) {
        // Only subscribe to the HR Measurement characteristic
        if (c.uuid == Guid('2A37') && c.properties.notify) {
          await c.setNotifyValue(true);

          _hrsub = c.onValueReceived.listen((value) {
            final flags = value[0];
            final bpm = (flags & 0x01) == 1
                ? (value[2] << 8) | value[1]
                : value[1];

            debugPrint('Heart Rate: $bpm bpm');
          });
          device.cancelWhenDisconnected(_hrsub!);
          await c.setNotifyValue(true);
        }
      }
    }
  } catch (e) {
    debugPrint("Failed: $e");
  }
}   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Make sure that the device is not connected",
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: _scanning ? null : startScan,
              child: Text(_scanning ? 'Scanning...' : 'Start scan'),
            ),
            // SwitchListTile(
            //   title: const Text('Show all devices (debug)'),
            //   value: _showAll,
            //   onChanged: (v) => setState(() => _showAll = v),
            // ),
            Expanded(
              child: _devices.isEmpty
                  ? const Center(child: Text('No devices found'))
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, i) {
                        final d = _devices[i];
                        final name = _nameOf(d);
                        return ListTile(
                          leading: const Icon(Icons.watch),
                          title: Text(name.isEmpty ? 'Unknown' : name),
                          subtitle: Text(
                            '${d.device.remoteId.str}  •  ${d.rssi} dBm',
                          ),
                          onTap: () {
                            connectDevice(d.device);
                            debugPrint('Selected: $name');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
