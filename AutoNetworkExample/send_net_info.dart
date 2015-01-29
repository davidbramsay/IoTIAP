import 'dart:io';
import 'dart:async';
import 'dart:convert';

String ip = "";

void main() {
  var duration = new Duration(seconds: 30);
  var timer = new Timer.periodic(duration, onTimer);
}

void onIfconfig(ProcessResult results) {
  print(results.stdout);
  var start = results.stdout.indexOf('addr:')+5;
  var end = results.stdout.indexOf(' Bcast');
  if(start > 0 && end > start) {
    ip = results.stdout.substring(results.stdout.indexOf('addr:')+5, results.stdout.indexOf(' Bcast'));
    print('IP = ' + ip);
  }
}

void onTimer(timer) {
  var file = new File('/sys/devices/bone_capemgr.9/baseboard/serial-number');
  Future<String> finishedReading = file.readAsString(encoding: ASCII);
  finishedReading.then((serialno) => send(serialno));
  Process.run('ifconfig', ['ra0']).then(onIfconfig);
}

void send(String serialno) {
  var connection = Socket.connect("dweet.io", 80);
  connection.then((socket) => onConnect(socket, serialno))
            .catchError((error) => handleError(error));
}

void handleError(error) {
  print('Send to dweet.io failed.');
}

void onConnect(Socket socket, String serialno) {
  String sn = serialno.trim();
  String indexRequest = 'GET /dweet/for/beagle-at-mit?sn=${sn}&ip=${ip} HTTP/1.1\nConnection: close\n\n';
  print(indexRequest);

  print('Connected to: '
    '${socket.remoteAddress.address}:${socket.remotePort}'
    ' from ${socket.address.address}');
   
  //Establish the onData, and onDone callbacks
  socket.listen((data) {
    print(new String.fromCharCodes(data).trim());
  },
  onDone: () {
    print("Done");
    socket.destroy();
  });
  
  //Send the request
  socket.write(indexRequest);
}
