import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:http/http.dart' as http;
import 'package:vpn/auth/secure_storage_service.dart';
import 'package:vpn/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final FlutterV2ray _flutterV2ray;
  bool _isConnected = false;
  String _statusText = 'DISCONNECTED';
  String? _remark;
  int? _serverDelay;
  String? _v2rayLink;

  List<String> _allVpnKeys = [];

  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _flutterV2ray = FlutterV2ray(onStatusChanged: _onStatusChanged);

    _initV2Ray();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _loadVpnKeysFromStorage();
  }

  Future<void> _initV2Ray() async {
    try {
      await _flutterV2ray.initializeV2Ray();
    } catch (e) {
      _showSnack("Init V2Ray failed: $e");
    }
  }

  void _onStatusChanged(V2RayStatus status) {
    debugPrint("V2Ray status changed: ${status.state}");
    final connected = status.state == 'CONNECTED';
    setState(() {
      _statusText = status.state;
      _isConnected = connected;
      if (!connected) {
        _serverDelay = null;
        _remark = null;
      }
    });
  }


  Future<void> _loadVpnKeysFromStorage() async {
    final keys = await SecureStorageService().getVpnKeys();
    setState(() {
      _allVpnKeys = keys;
      _v2rayLink = keys.isNotEmpty ? keys.first : null;
    });
  }

  Future<void> _fetchCloudKeys() async {
    final token = await SecureStorageService().getToken();
    if (token == null) {
      _showSnack("No JWT stored. Please log in first.");
      return;
    }
    final uri = Uri.parse('http://${Config.apiHost}${Config.getByJWT}');
    try {
      final resp = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        final fetched = data.map((e) => e['key_data'] as String).toList();
        if (fetched.isEmpty) {
          _showSnack("No keys returned from server");
        } else {
          await SecureStorageService().setVpnKeys(fetched);
          await _loadVpnKeysFromStorage();
        }
      } else {
        _showSnack("Failed to fetch keys: ${resp.statusCode}");
      }
    } catch (e) {
      _showSnack("Error fetching keys: $e");
    }
  }

  void _promptManualKeyEntry() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter VPN key URL"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "vless://...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final link = ctrl.text.trim();
              try {
                FlutterV2ray.parseFromURL(link);
                await SecureStorageService().saveVpnKey(link);
                await _loadVpnKeysFromStorage();
                Navigator.pop(context);
                _showSnack("VPN key saved");
              } catch (_) {
                _showSnack("Invalid key format");
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteVpnKey(String key) async {
    await SecureStorageService().deleteVpnKey(key);
    await _loadVpnKeysFromStorage();
    if (_v2rayLink == key) {
      setState(() => _v2rayLink = _allVpnKeys.isNotEmpty ? _allVpnKeys.first : null);
    }
    _showSnack("VPN key deleted");
  }

  Future<void> _toggleConnection() async {
    final wantConnect = !_isConnected;
    await _animController.forward();
    await _animController.reverse();

    if (wantConnect) {
      if (_v2rayLink == null) {
        _showSnack("No VPN key selected");
        return;
      }

      late V2RayURL parser;
      try {
        parser = FlutterV2ray.parseFromURL(_v2rayLink!);
      } catch (_) {
        _showSnack("Invalid V2Ray link format");
        return;
      }

      _remark = parser.remark;
      final config = parser.getFullConfiguration();

      if (!await _flutterV2ray.requestPermission()) return;

      try {
        await _flutterV2ray.startV2Ray(
          remark: _remark!,
          config: config,
          blockedApps: <String>[],
          bypassSubnets: <String>[],
          proxyOnly: false,
        );
        final delay = await _flutterV2ray.getServerDelay(config: config);
        setState(() => _serverDelay = delay);
      } catch (e) {
        _showSnack("Failed to start V2Ray: $e");
      }
    } else {
      await _flutterV2ray.stopV2Ray();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_download),
                      title: const Text("Fetch from cloud"),
                      onTap: () {
                        Navigator.pop(context);
                        _fetchCloudKeys();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text("Enter manually"),
                      onTap: () {
                        Navigator.pop(context);
                        _promptManualKeyEntry();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: () async {
              final token = await SecureStorageService().getToken();
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Stored JWT"),
                  content: Text(token ?? "No token"),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available VPN Keys:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _allVpnKeys.isEmpty
                ? const Center(
              child: Text("No VPN keys stored", style: TextStyle(color: Colors.grey)),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _allVpnKeys.length,
              itemBuilder: (ctx, i) {
                final key = _allVpnKeys[i];
                final selected = key == _v2rayLink;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Card(
                    elevation: selected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: selected
                          ? const BorderSide(color: Colors.blue, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: selected ? Colors.blue : Colors.grey.shade400,
                        radius: 16,
                        child: Icon(
                          selected ? Icons.lock_open : Icons.vpn_key,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        key.length > 32 ? "${key.substring(0, 32)}..." : key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteVpnKey(key),
                      ),
                      onTap: () => setState(() => _v2rayLink = key),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: _toggleConnection,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isConnected ? Colors.green : Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                        ],
                      ),
                      child: Icon(_isConnected ? Icons.power_off : Icons.power, color: Colors.white, size: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isConnected ? Colors.green : Colors.redAccent, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isConnected ? "Connected" : "Disconnected",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        if (_isConnected && _remark != null) ...[
                          const SizedBox(height: 4),
                          Text(_remark!, style: const TextStyle(color: Colors.white70)),
                        ],
                        if (_serverDelay != null) ...[
                          const SizedBox(height: 4),
                          Text("Delay: $_serverDelay ms", style: const TextStyle(color: Colors.white70)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}