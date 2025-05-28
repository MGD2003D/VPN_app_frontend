import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {

  static const double _trackWidth = 130;
  static const double _trackHeight = 205;
  late final double _thumbHeight;

  late double _thumbPosition;

  late final FlutterV2ray _flutterV2ray;
  bool _isConnected = false;
  String _statusText = 'Disconnected';
  String? _remark;
  int? _serverDelay;
  final String _v2rayLink = 'vless://183b8685-5033-4a32-9764-07f296be45d4@185.184.121.48:443?type=tcp&security=reality&pbk=OTaHp-w6pfI6LSU30DKJp00o2L0VVDpiDkYVa_EVcDs&fp=chrome&sni=nowmeow.pw&sid=7c1a8b90ee&spx=%2F&flow=xtls-rprx-vision#omdbmo';
  @override
  void initState() {
    super.initState();
    _thumbHeight = _trackHeight / 2;
    _thumbPosition = _trackHeight - _thumbHeight;

    _flutterV2ray = FlutterV2ray(onStatusChanged: _onStatusChanged);
    _initializeV2Ray();
  }

  Future<void> _initializeV2Ray() async {
    await _flutterV2ray.initializeV2Ray();
  }

  void _onStatusChanged(V2RayStatus status) {
    setState(() {
      _statusText = status.toString();
    });
  }

  Future<void> _toggleConnection(bool connect) async {
    setState(() {
      _isConnected = connect;
    });

    if (connect) {
      V2RayURL parser = FlutterV2ray.parseFromURL(_v2rayLink);
      _remark = parser.remark;
      final config = parser.getFullConfiguration();
      bool granted = await _flutterV2ray.requestPermission();
      if (granted) {
        await _flutterV2ray.startV2Ray(
          remark: _remark!,
          config: config,
          blockedApps: null,
          bypassSubnets: null,
          proxyOnly: false,
        );
        final delay = await _flutterV2ray.getServerDelay(config: config);
        setState(() {
          _serverDelay = delay;
        });
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } else {
      await _flutterV2ray.stopV2Ray();
      setState(() {
        _serverDelay = null;
        _remark = null;
      });
    }
  }

  void _snapThumb() {
    final midpoint = (_trackHeight - _thumbHeight) / 2;
    final connect = _thumbPosition <= midpoint;
    setState(() {
      _thumbPosition = connect ? 0 : (_trackHeight - _thumbHeight);
    });
    _toggleConnection(connect);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topOffset = screenHeight * 458 / 957;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: topOffset - 80,
            left: (screenWidth - 200) / 2,
            width: 200,
            child: Column(
              children: [
                Text(
                  _isConnected ? 'Connected: $_remark' : 'Disconnected',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_serverDelay != null)
                  Text('Delay: ${_serverDelay}ms'),
              ],
            ),
          ),
          Positioned(
            top: topOffset,
            left: (screenWidth - _trackWidth) / 2,
            width: _trackWidth,
            height: _trackHeight,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _thumbPosition = (_thumbPosition + details.delta.dy)
                      .clamp(0.0, _trackHeight - _thumbHeight);
                });
              },
              onVerticalDragEnd: (_) => _snapThumb(),
              child: Stack(
                children: [
                  Container(
                    width: _trackWidth,
                    height: _trackHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    top: _thumbPosition,
                    width: _trackWidth,
                    height: _thumbHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isConnected ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
