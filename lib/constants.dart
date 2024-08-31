import 'package:flutter/foundation.dart';

const bool useLocal = true && kDebugMode;

const String protocol = useLocal ? "https" : "http";
const String wsProtocol = useLocal ? "ws" : "wss";
const String host = useLocal ? "192.168.0.230:7707" : "sorcerers.filippo-orru.com";
