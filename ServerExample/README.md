This represents a dart server structure for communicating with the beaglebone via the pinClient examples.


In this example, there are 2 servers- first, there is a webserver that will serve a 'controller' website, that anyone can use to control the beaglebone.  Dart compiles to javascript.  Here we have the uncompiled web server written in dart, as well as the final, compiled version, which uses Node.js to serve the html/javascript.  

For clarity- the code in 'uncompiledWebServerDart' gets compiled to javascript/css/jade (jade is rendered to html through Node when a user requests the site), and this compiled code is then found in 'webServer/public' and 'webServer/views'.  The webServer is a working Node webserver that will serve the dart code. (To run it, go into the webServer folder from the terminal and type 'node bin/www'.)

The served website communicates through a websocket server with the beaglebones that are connected.  The websocket server can be run using the VM dart to run 'socketServer.dart'. (To run, type 'dart socketServer.dart').  This server simply opens a websocket connection to the pinClient examples running on the beaglebone, as well as the browser code served by the web server example.  

This has a couple of benefits - NAT traversal and communication speed.  Websockets create fast, open connections between the beaglebones and the website controller software.  The beaglebone, even on private networks, can also contact the public IP of to the websocket server without knowing anything about the local network.  The webserver, similarly can exist on a public server.


