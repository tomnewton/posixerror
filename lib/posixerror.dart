import 'dart:async';

import 'package:flutter/services.dart';

class Posixerror {
  static const MethodChannel _channel = const MethodChannel('posixerror');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
