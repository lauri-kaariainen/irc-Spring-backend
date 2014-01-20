<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page session="false" %>
<html>
<head>
	<title>Irkki</title>
	<sec:authorize access="isAnonymous() == false">
		<script src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
		<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery.atmosphere/2.1.2/jquery.atmosphere.min.js"></script>
	</sec:authorize>
	<style>
	
	ul {
		font-family: 'Consolas';
		background-color: black;
		color: rgb(187,187,187);
	}
	</style>
</head>
<body>


<P>  The time on the server is ${serverTime}. </P>

	<sec:authorize access="hasRole('superman')">
			<!--h1>AtmosphereHandler PubSub Sample using Atmosphere's JQuery Plug In</h1-->
	        
	        <p>Select Channel to follow<p>
	        
	        <div id='pubsub'>
	            <input id='topic' type='text'/>
	        </div>
	        <p>Select transport to use for subscribing</p>
	        
	        <p>You can change the transport any time.</p>
	        
	        <div id='select_transport'>
	            <select id="transport">
	                <option id="autodetect" value="websocket">autodetect</option>
	                <option id="long-polling" value="long-polling">long-polling</option>
	                <option id="streaming" value="streaming">http streaming</option>
	                <option id="websocket" value="websocket">websocket</option>
	            </select>
	            <input id='connect' class='button' type='submit' name='connect' value='Connect'/>
	        </div>
	        <br/>
	        <br/>
	        
	        <p id="s_h" class='hidden'>Publish Topic</p>
	        
	        <div id='sendMessage' class='hidden'>
	            <input id='phrase' type='text'/>
	            <input id='send_message' class='button' type='submit' name='Publish' value='Publish Message'/>
	        </div>
	        <br/>
			 
	        <script type="text/javascript">
	            $(document).ready(function() {
	            var detectedTransport = null;
	            var socket = $.atmosphere;
	            var subSocket;
	        
	                function getKeyCode(ev) {
	                    if (window.event) return window.event.keyCode;
	                    return ev.keyCode;
	                }
	        
	                function getElementById() {
	                    return document.getElementById(arguments[0]);
	                }
	        
	                function getTransport(t) {
	                    transport = t.options[t.selectedIndex].value;
	                    if (transport == 'autodetect') {
	                        transport = 'websocket';
	                    }
	        
	                    return false;
	                }
	        
	                function getElementByIdValue() {
	                    detectedTransport = null;
	                    return document.getElementById(arguments[0]).value;
	                }
	        
	            function subscribe() {
	            	//storing value so on reconnect we return to it
	            	sessionStorage.channel = getElementByIdValue('topic');
	                var request = { url : document.location.toString() +"websocket/" + getElementByIdValue('topic'),
	                    transport: getElementByIdValue('transport'),
	                    timeout: 2000000};
	                console.log(document.location.toString() +"websocket/" + getElementByIdValue('topic'));
	
	                request.onMessage = function (response) {
	                    detectedTransport = response.transport;
	                    if (response.status == 200) {
	                        var data = response.responseBody;
	                        
	                        if (data.length > 0) {
	                        	if($.parseJSON(data).activeChannels !== undefined){
	                        		$('#active').html("Active channels: ["+$.parseJSON(data).activeChannels+"]");
	                        	}
                        		if($.parseJSON(data).text !== undefined){
	                        		$('ul').html("");
	                        		$('ul').html("<pre>"+handleHighlights($.parseJSON(data).text)+ "</pre>").append("<hr>");
	                        		$('ul').prepend("<hr>");
                        		}	                      
	                        }
	                    }
	                    else
	                    	alert("response.status was "+response.status)
	                };
	                
	                request.onClose = function (response){
	                	alert("websocket closed, "+"response.status was "+response.status);
	                	$('#active').html("websocket closed");
	                };
	                
	                request.onReconnect = function(request, response){
	                	alert("websocket reconnected, responsestate: "+response.state + ", response.status was "+response.status);
	                	$('#active').html("websocket reconnected, responsestate: "+response.state);
	                };
	                
	                request.onClientTimeout = function(request){
	                	alert("client timeouted, trying to reconn");
	                	$('#active').html("client timeouted");
	                	subSocket = socket.subscribe(request);           	
	                	
	                };
	
	                subSocket = socket.subscribe(request);
	            }
	
	            function unsubscribe(){
	                socket.unsubscribe();
	            }
	        
	                function connect() {
	                    unsubscribe();
	                    getElementById('phrase').value = '';
	                    getElementById('sendMessage').className = '';
	                    getElementById('phrase').focus();
	                    subscribe();
	                    getElementById('connect').value = "Switch transport";
	                }
	        
	                getElementById('connect').onclick = function(event) {
	                    if (getElementById('topic').value == '') {
	                        alert("Please type in a channel to subscribe");
	                        return;
	                    }
	                    connect();
	                }
	        
	                getElementById('topic').onkeyup = function(event) {
	                    getElementById('sendMessage').className = 'hidden';
	                    var keyc = getKeyCode(event);
	                    if (keyc == 13 || keyc == 10) {
	                        connect();
	                        return false;
	                    }
	                }
	        
	                getElementById('phrase').setAttribute('autocomplete', 'OFF');
	                getElementById('phrase').onkeyup = function(event) {
	                    var keyc = getKeyCode(event);
	                    if (keyc == 13 || keyc == 10) {
	        
	                        var m = " sent using " + detectedTransport;
	                        if (detectedTransport == null) {
	                            detectedTransport = getElementByIdValue('transport');
	                            m = " sent trying to use " + detectedTransport;
	                        }
	        
	                    subSocket.push({data: 'message=' + getElementByIdValue('phrase') + m});
	        
	                        getElementById('phrase').value = '';
	                        return false;
	                    }
	                    return true;
	                };
	        
	                getElementById('send_message').onclick = function(event) {
	                    if (getElementById('topic').value == '') {
	                        alert("Please enter a message to publish");
	                        return;
	                    }
	        
	                    var m = " sent using " + detectedTransport;
	                    if (detectedTransport == null) {
	                        detectedTransport = getElementByIdValue('transport');
	                        m = " sent trying to use " + detectedTransport;
	                    }
	        
	                subSocket.push({data: 'message=' + getElementByIdValue('phrase') + m});
	        
	                    getElementById('phrase').value = '';
	                    return false;
	                };
	        
	                getElementById('topic').focus();
	            	
	                
	                //check if we returned to the page, ie. there is channel in sessionstorage
	                if(sessionStorage.channel !== undefined){
	                	document.getElementById('topic').value = sessionStorage.channel;
	                	subscribe();
	                }
	            });
	        </script>
	        <script>
		        //@author lauri
		        function handleHighlights(text){
		        	//var newtext = text.replace(/<(?!(br|\s+|\+|@))/gi,"^"); //parsing less-than '<'-char, turning it into '^', not <br/>-s, <@ or <" " or <+though
		        	var newtext= text.replace(/([^\s]*laurik[^\s]*)/gi,"<span style='font-weight: bold;color: white;'>$1</span>"); //hilight
		        	//newtext=newtext.replace(/(.*-!-.*)/gi,"<span style='color: grey;'><i>$1</i></span>"); //join||quit||namechange?
		        	
		        	newtext = newtext.replace(/http([^\s]*)/gi,"<a href='http$1' target='_blank'>http$1</a>");	//making links out of words starting with http(/s)
		        	//newtext = newtext.replace(/< /gi,"<  "); //making < nick> the same lenght onscreen as <@nick>
		        	
		        	return newtext;
		        }

			</script>
		<h5>Output:</h5>
	        <ul></ul>
	        <p id="active"></p>
	</sec:authorize>

 <sec:authorize access="isAnonymous()"> 
	<form action="j_spring_security_check" method="post">
		<input id="username" type="text" placeholder="username plz" name="j_username"/>
		<input id="password" type="password" placeholder="password plz" name="j_password"/>
		<button type="submit"></button>
	</form>
</sec:authorize>
 <sec:authorize access="isAnonymous() == false">
	<a href="j_spring_security_logout" >Sing me out!</a>
</sec:authorize>
</body>
</html>
