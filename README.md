This code was written for the MIT IoT IAP class in January 2015, for the beaglebone.

Code is written in Dart.

The PinClientExample folder has a Dart library that will initialize and poll both analog and digital pins on the beaglebone.  It has a basic example to show how to use the pinLibrary for digital and analog pins.

There is also an example for networked beaglebones.  Any number of beaglebones will connect with any number of controller websites, which can then link any number of beaglebones, on any network, to a website pulled up from any device. 

If you attempt to run this at MIT, be aware of port issues on the MIT Guest network. 
http://kb.mit.edu/confluence/pages/viewpage.action?pageId=43941912

The pinClientExample folder has a 'networked' example which will automatically connect to the websocket server demonstrated in the ServerExample folder.  On the other end, the websocket server connects with a browser-based 'controller' website, which is also in the ServerExample folder.  This website is written in Dart, and served with a Node server.