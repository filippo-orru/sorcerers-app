const bool useLocal = true;

const String protocol = useLocal ? "https" : "http";
const String wsProtocol = useLocal ? "ws" : "wss";
const String host = useLocal ? "192.168.114.31:7707" : "sorcerers.filippo-orru.com";
