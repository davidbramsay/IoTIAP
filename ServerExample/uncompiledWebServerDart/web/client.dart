import 'dart:html';
import 'dart:convert' show JSON;

void main() {
	  TextInputElement input = querySelector('#input');
	    ParagraphElement output = querySelector('#output');

		 // String server = 'ws://meegs.mit.edu:8000';
		  String server = 'ws://104.236.98.132:10000/';
		  
		  WebSocket ws = new WebSocket(server);
			  ws.onOpen.listen((Event e) {
				      outputMessage(output, 'Connected to server');
					    });

			    ws.onMessage.listen((MessageEvent e){
					    outputMessage(output, e.data);
						  });

				  ws.onClose.listen((Event e) {
					      outputMessage(output, 'Connection to server lost...');
						    });

				  input.onChange.listen((Event e){
				        try{
				          var arg = input.value.split(" ");
				          ws.send(JSON.encode({"command": arg[0], "params": arg.sublist(1)}));
							    input.value = "";
				        } catch(e) {print(e);}
				        });
				        
}

void outputMessage(Element e, String message){
	  print(message);
	    e.appendText(message);
		  e.appendHtml('<br/>');

		    //Make sure we 'autoscroll' the new messages
		    e.scrollTop = e.scrollHeight;
}
