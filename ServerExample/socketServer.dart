import 'dart:io';

//const int PORT = 8000;
const int PORT = 10000;

List<WebSocket> connections;

void main() {

  connections = new List<WebSocket>();

  HttpServer.bind(InternetAddress.ANY_IP_V4, PORT).then((HttpServer server) {
    print('Server listening on port ${PORT}.');
    server.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          connections.add(ws);
          print('Client connected, there are now ${connections.length} client(s) connected.');
          ws.listen((String message) {
            for (WebSocket connection in connections) {
              connection.add(message);
            }
          },
          onDone: () {
            connections.remove(ws);
            print('Client disconnected, there are now ${connections.length} client(s) connected.');
          });
        });
      } else {
        request.response.statusCode = HttpStatus.FORBIDDEN;
        request.response.reasonPhrase = 'Websocket connections only!';
        request.response.close();
      }
    });
  });
}

