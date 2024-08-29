import 'package:flutter/foundation.dart';

const bool useLocal = true && kDebugMode;

const String protocol = useLocal ? "https" : "http";
const String wsProtocol = useLocal ? "ws" : "wss";
const String host = useLocal ? "localhost:7707" : "sorcerers.filippo-orru.com";
