const bool useLocal = true;

const String protocol = useLocal ? "https" : "http";
const String wsProtocol = useLocal ? "wss" : "ws";
const String host = useLocal ? "localhost:7707" : "sorcerers.filippo-orru.com";
