import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'pinLibrary.dart';
import 'dart:convert' show JSON;


var interface = new pinInterface();

Websocket ws;


void onMessage(String message){
  print(message);
  
  try{
    
    var decodedMsg = JSON.decode(message);
      
    var reply = interface.ExecuteExternalCommand(decodedMsg["command"],decodedMsg["params"]);
 
    if(reply is String){
      ws.add(reply.trim());
    } else {
      try{//it's a future
        reply.then((val){
          if(val is String){
            ws.add(val);
          }else{
            ws.add(val.toString()); 
          }
        });  
      } catch(e){//it's not
        ws.add(reply.toString());  
      }
    }  
  }catch(e){}
}


void connectionClosed() {
  print('Connection to server closed');
}


main(){

  print("starting"); 
 

  WebSocket.connect('ws://104.236.98.132:10000').then((WebSocket socket) { //ws://meegs.mit.edu:8000
      ws = socket; 
      ws.listen(onMessage, onDone: connectionClosed);
  });

  //GPIO 44 is pin P8-12
  interface.gpioSetPinDirection(44, "out"); 
  
  //GPIO 23 is pin P8-13 
  interface.gpioSetPinDirection(23, "in"); 
 
  //GPIO 49 is pin P9-23

}
