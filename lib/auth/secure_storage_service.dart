import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _secureStorage = const FlutterSecureStorage();

  static const _jwtKey = 'jwt';
  static const _vpnKeysKey = 'vpn_keys';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _jwtKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _jwtKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _jwtKey);
  }

  Future<void> clearStorage() async {
    await _secureStorage.deleteAll();
  }

  Future<void> setVpnKeys(List<String> keys) async {
    if (keys.isEmpty) {
      await _secureStorage.delete(key: _vpnKeysKey);
    } else {
      final encoded = jsonEncode(keys);
      await _secureStorage.write(key: _vpnKeysKey, value: encoded);
    }
  }

  Future<List<String>> getVpnKeys() async {
    final raw = await _secureStorage.read(key: _vpnKeysKey);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVpnKey(String key) async {
    final keys = await getVpnKeys();
    if (!keys.contains(key)) {
      keys.insert(0, key);
      final encoded = jsonEncode(keys);
      await _secureStorage.write(key: _vpnKeysKey, value: encoded);
    }
  }

  Future<void> deleteVpnKey(String key) async {
    final keys = await getVpnKeys();
    if (keys.contains(key)) {
      keys.remove(key);
      if (keys.isEmpty) {
        await _secureStorage.delete(key: _vpnKeysKey);
      } else {
        final encoded = jsonEncode(keys);
        await _secureStorage.write(key: _vpnKeysKey, value: encoded);
      }
    }
  }
}