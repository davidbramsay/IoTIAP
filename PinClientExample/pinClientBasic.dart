import 'dart:io';
import 'dart:async';
import 'pinLibrary.dart';


var interface = new pinInterface();

flipFlop(){
    //interface.togglePin(44);
    interface.ExecuteExternalCommand("togglePin",[44]);
 
    //interface.gpioGetPinValue(23).then((val)=>print(val));
    interface.ExecuteExternalCommand("gpioGetPinValue",[23]).then((val)=>print("Pin 23 State:" + val));
}


main(){

  const oneSec = const Duration(milliseconds: 1000); 
 
  print("starting"); 
  
//  interface.gpioExport(44); 
  interface.gpioSetPinDirection(44, "out"); 
  
  //GPIO 23 is pin P8-13 
  interface.gpioSetPinDirection(23, "in"); 
 
  //GPIO 49 is pin P9-23
 
  Timer testHardwareTimer = new Timer.periodic(oneSec, (Timer t) => flipFlop()); 
//  Timer testHardwareTimer = new Timer.periodic(oneSec, (Timer t) => testPollAndLed()); 


}
