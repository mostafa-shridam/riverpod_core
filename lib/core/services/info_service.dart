import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceInfoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> saveUserDeviceData() async {
    try {
      String? deviceName;
      String? deviceId;

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceName = androidInfo.model;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceId = iosInfo.identifierForVendor;
      }
      final String? token = await _fcm
          .getToken(); // ignore: deprecated_member_use -- TODO(C-20): migrate to register()
      final String? aPNSToken = await _fcm.getAPNSToken();

      final Map<String, dynamic> userData = {
        'deviceName': deviceName,
        'deviceId': deviceId,
        'fcmToken': token ?? aPNSToken ?? '',
        'lastUpdate': FieldValue.serverTimestamp(),
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
      };

      await _db
          .collection('deviceInfo')
          .doc(deviceId)
          .set(userData, SetOptions(merge: true));

      log('User data saved successfully!');
    } catch (e) {
      log('Error saving user data: $e');
    }
  }

  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      log('Error retrieving device ID: $e');
    }
    return '';
  }
}
