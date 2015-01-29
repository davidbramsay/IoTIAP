import 'dart:io';
import 'dart:async';
import 'pinLibrary.dart';


var interface = new pinInterface();

flipFlop(){
//	interface.gpioGetAnalogPinValue(0).then((val0)=>print("AIN0:" + val0));	
//	interface.gpioGetAnalogPinValue(1).then((val1)=>print("AIN1:" + val1));

	interface.gpioGetAnalogPinValue(0).then((val0){	
		interface.gpioGetAnalogPinValue(1).then((val1)=>print("AIN0:" + val0 + " AIN1:" + val1));
	});
}


main(){

  const oneSec = const Duration(milliseconds: 1000); 
 
  print("starting"); 
  Timer testHardwareTimer = new Timer.periodic(oneSec, (Timer t) => flipFlop()); 


}
