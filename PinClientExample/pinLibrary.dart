library pinLibrary;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

class pinInterface{


	var interfaceIntrospected;
    var analogPinAddress;

	pinInterface(){
		this.interfaceIntrospected = reflect(this);
		this.analogPinAddress = gpioAnalogEnable();
	}

	ExecuteExternalCommand(funcName, funcParams){
		var returnVars = this.interfaceIntrospected.invoke(new Symbol(funcName),funcParams).reflectee;
		return returnVars;
	}
	
	void gpioExport(pinNumber) {

		Process.runSync('bash', ['-c', 'echo $pinNumber > /sys/class/gpio/export']);

		print("gpioExport($pinNumber)");
	}

	void gpioUnexport(pinNumber) {

		Process.runSync('bash', ['-c', 'echo $pinNumber > /sys/class/gpio/unexport']);

		print("gpioUnexport($pinNumber)");

	}

	String gpioAnalogEnable() {

		Process.runSync('bash', ['-c', 'echo cape-bone-iio > /sys/devices/bone_capemgr.*/slots']);
	    var temp =	Process.runSync('bash', ['-c', 'find /sys -name *AIN0']);
		return temp.stdout.substring(0,temp.stdout.length-2);
	}

	void gpioSetPinDirection(pinNumber, pinDirection) {
        
        gpioUnexport(pinNumber);
		gpioExport(pinNumber);

		String commandString = "echo " + "$pinDirection" + " > /sys/class/gpio/gpio" + pinNumber.toString() + "/direction";

		Process.runSync('bash', ['-c', '$commandString']);

		print("commandString for gpioSetPinDirection is: $commandString");

		print("gpioSetPinDirection($pinNumber, $pinDirection)");

	}

	Future<String> gpioGetAnalogPinValue(pinNumber) {

		Process.runSync('bash', ['-c', '"echo ${this.analogPinAddress}$pinNumber"']);

		var file = new File("${this.analogPinAddress}$pinNumber");

		Future<String> finishedReading = file.readAsString(encoding: ASCII); 

		return finishedReading; 

	}
	
	void gpioSetPinValue(pinNumber, pinValue) {

		String commandString = "echo " + pinValue.toString() + " > /sys/class/gpio/gpio" + pinNumber.toString() + "/value";

		Process.runSync('bash', ['-c', '$commandString']);

		print(commandString);

		var pNtoString = pinNumber.toString();
		var pVtoString = pinValue.toString();

		print("gpioSetPinValue($pNtoString, $pVtoString)");

	}

	Future<String> gpioGetPinValue(pinNumber) {

		Process.runSync('bash', ['-c', '"echo /sys/class/gpio/gpio$pinNumber/value"']);

		var file = new File("/sys/class/gpio/gpio$pinNumber/value");

		Future<String> finishedReading = file.readAsString(encoding: ASCII); 

	    //	print("gpioGetPinValue(pinNumber)");

		return finishedReading; 

	}

	void takeANap(howManyMilliseconds) {

		Duration sleepDuration = new Duration(milliseconds: howManyMilliseconds);
		sleep(sleepDuration);

	}

	void togglePin(pinNumber) {

		var pinValue;

		gpioGetPinValue(pinNumber).then((val) {

				if (int.parse(val) == 1) pinValue = 0; else pinValue = 1; 	
				gpioSetPinValue(pinNumber, pinValue);

				});  

	}


	void testPollAndLed() {

		togglePin(44);
		gpioGetPinValue(23).then((val) => print(val));

	}

	String findPWMFilePathOnDisk(pathToCheck, pinHeaderName) {

		String pwm_path_string = "ERROR: NO PATH FOUND";

		String pathToMatch = pathToCheck + "pwm_test_" + pinHeaderName;

		print("We need to locate: $pathToMatch");

		List fileDirectoryList = new List();
		List fileList = new List();

		var systemCheckDir = new Directory(pathToCheck);
		List syncDirectoryList = new List();

		systemCheckDir = systemCheckDir.listSync(recursive: true, followLinks: false);

		systemCheckDir.forEach((e) {

				if (e is Directory) {
				// msg(entity.path);
				fileDirectoryList.add(e);
				}


				if (e is File) { // TBD - don't need to use files now - maybe later
				// msg(entity.path);
				fileList.add(e);
				}


				});

		bool matchFound = false;
		fileDirectoryList.sort((a, b) => a.toString().compareTo(b.toString()));

		print("**************** Search for target PWM directory ******************* " + pathToMatch);

		fileDirectoryList.forEach((e) {

				if (!matchFound && (e.path.toString().startsWith(pathToMatch, 0))) { // /sys/devices/ocp.3/
				// print(e.path.toString());
				pwm_path_string = e.path.toString();
				print("*********** MATCH on THE PWM DIRECTORIES *********>>> " + pwm_path_string);

				// return(pwm_path_string); // this is where the PWM path is ...
				matchFound = true;
				}

				});

		return pwm_path_string;

	}

	void runPWM(pwmPin) {
		// cd /sys/devices/bone_capemgr.9
		// echo am33xx_pwm > slots
		// echo bone_pwm_P8_19 > slots
		// cd /sys/devices/ocp.3/pwm_test_P8_19.16
		// echo 20000000 > period
		// echo 0 > polarity
		// echo 1500000 > duty
		// echo 1000000 > duty
		// echo 1500000 > duty

		print("starting to run setupPWM()");

		String commandString;

		// echo am33xx_pwm > /sys/devices/bone_capemgr.9/slots
		commandString = "echo " + "am33xx_pwm > " + "/sys/devices/bone_capemgr.9/slots"; 
		Process.runSync('bash', ['-c', '$commandString']);
		print("Just ran " + commandString);

		// echo bone_pwm_P8_19 > /sys/devices/bone_capemgr.9/slots
		commandString = "echo " + "bone_pwm_" + pwmPin + " > " + "/sys/devices/bone_capemgr.9/slots";
		Process.runSync('bash', ['-c', '$commandString']);
		print("Just ran " + commandString);

		// this is a hack to find the path where the PWM directory is created
		// this changes from run to run and boot to boot, so it takes a bit of a search
		// TBD - maybe these can be specified prior to application run-time as part of overlay?

		String P8_19_path = findPWMFilePathOnDisk("/sys/devices/ocp.3/", pwmPin);
		print("The Matching Path is: >>>>>>>>>>>  " + P8_19_path);

		commandString = "echo " + "20000000 > " + P8_19_path + "/period"; // "/sys/devices/ocp.3/pwm_test_P8_19.15/period"; // /sys/devices/ocp.3/
		Process.runSync('bash', ['-c', '$commandString']);
		print("Just ran " + commandString);

		commandString = "echo " + "0 > " + P8_19_path + "/polarity"; // "/sys/devices/ocp.3/pwm_test_P8_19.15/polarity";
		Process.runSync('bash', ['-c', '$commandString']);
		print("Just ran " + commandString);

		for (int i = 0; i < 2; i ++) {

			commandString = "echo " + "1500000 > " + P8_19_path + "/duty"; // "/sys/devices/ocp.3/pwm_test_P8_19.15/duty";
			Process.runSync('bash', ['-c', '$commandString']);
			print("Just ran " + commandString);

			takeANap(200);

			commandString = "echo " + "1000000 > " + P8_19_path + "/duty"; // + "/sys/devices/ocp.3/pwm_test_P8_19.15/duty";
			Process.runSync('bash', ['-c', '$commandString']);
			print("Just ran " + commandString);

			takeANap(200);

			commandString = "echo " + "1500000 > " + P8_19_path + "/duty"; // + "/sys/devices/ocp.3/pwm_test_P8_19.15/duty";
			Process.runSync('bash', ['-c', '$commandString']);
			print("Just ran " + commandString);

			takeANap(200);


		}
		print("FINISH run setupPWM()");

	}

}
