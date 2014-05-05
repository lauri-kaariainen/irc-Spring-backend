<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page session="false" %>
<html>
<head>
	<title>Irkki</title>
	<script src="../resources/jquery-1.10.2.min.js"></script>
	<script src="../resources/jquery.atmosphere.min.js"></script>
	<sec:authorize access="isAnonymous() == false">
		<script src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
		<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery.atmosphere/2.1.2/jquery.atmosphere.min.js"></script>
	</sec:authorize>
	<style>
	
	ul {
		font-family: 'Consolas';
		background-color: black;
		color: rgb(187,187,187);
		font-size: 14px;
	}
	
	pre {
		white-space: pre-wrap;
		word-wrap: break-word;
		
	}
	pre a {
		color: cyan;
	}
	
	#active {
		position:fixed;
		top: 20%;
		left: 60%;
		height: 100%;
		background-color: white;
		width: 100%;
		font-size: 2.2em;
		overflow: auto;
	
	}
	
	#showChannels{
		position:fixed;
		top: 50px;
		left: 95%;
		height: 50px;
		width: 50px;
		font-size: 60px;
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
		            	
		            	//TODO: notice that this is hardcoded, it doesn't need to be
		            	//original was document.location.toString() + "websocket" + getElemen...
		                var request = { url : "http://jeuride.sytes.net:8080/nettiirkki/websocket/" + getElementByIdValue('topic'),
		                    transport: getElementByIdValue('transport'),
		                    timeout: 8000000};
		                console.log(document.location.toString() +"websocket/" + getElementByIdValue('topic'));
		
		                request.onMessage = function (response) {
		                	$('#status').html("Online");
		                	$('#status').css("background-color","green");
		                	
		                    detectedTransport = response.transport;
		                    if (response.status == 200) {
		                        var data = response.responseBody;
		                        
		                        if (data.length > 0) {
		                        	
		                        	
		                        	
		                        	
		                        	if($.parseJSON(data).activeChannels !== undefined){
		                        		
		                        		//console.log("($.parseJSON(data)).activeChannels:"+($.parseJSON(data)).activeChannels);
		                       
		                        	
		                        		$('#active').html("");
		                        		
		                        	      
		        		                var jsonArrayOfData = new Array();
		        		                jQuery.each($.parseJSON(data).activeChannels, function(i, val) {
		        		                	//console.log(i+":"+val);
		        		                	jsonArrayOfData.push({"channel":i, "timestamp":val});
		        		                });
		                        		//console.log(jsonArrayOfData); 
		                        		jsonArrayOfData.sort(sortJsonArrayByDescending("timestamp"));
		                      
		                        		jQuery.each(jsonArrayOfData, function(i, val) {
		        	            			//console.log(i+":"+val.channel+":"+val.timestamp);
		        	            			var seconds =  Math.ceil((new Date() - new Date(val.timestamp))/1000);
		        	            			
		        	            			//data-orig-time is for moving the clocks
		        	            			$('#active').append("<span id='"+val.channel+"'style='font-weight:bold;color:#"+shadeColor("33FF33",40-Math.floor(0.5*seconds))+";'>"+val.channel+"</span>"+":"+ "<span class='seconds' data-orig-time="+val.timestamp +">"+seconds+"</span>" +"s").append("<br/>");
		        	            		
		        							//clear possible old bindings 	            			
		        	            			$('#'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).off();
		        	            			//onclick to change channel to whichever "active" one
		               		    			$('#'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).on('click',function(){
		        	            				document.getElementById('topic').value = val.channel.split('#').join('').split('.')[0].split("!").join('');
		        	            				connect();
		        	            				$('#showChannels').css('color','');
		        	            			}); 
		        	            		});
		                        		
		                        		
		                        		
		                        		/* 		jQuery.each(($.parseJSON(data)).activeChannels, function(i, val) {
		                        			
		                        		//	console.log(val,($.parseJSON(data)).activeChannels.val,i);
		                        			var seconds =  Math.ceil((new Date() - new Date(val))/1000);
		                        			
		                        			//data-orig-time is for moving the clocks
		                        			//TODO: make this so that it won't remove all the clocks from view, maybe select the correct id and change adjacent span's value and attribute 
		                        			$('#active').append("<span id='"+i+"'style='font-weight:bold;color:#"+shadeColor("33FF33",40-Math.floor(0.5*seconds))+";'>"+i+"</span>"+":"+ "<span class='seconds' data-orig-time="+val +">"+seconds+"</span>" +"s").append("<br/>");
		                        		
											//clear previous bindings		                        			
		                        			$('#'+i.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).off();
		                        			//onclick to change channel to whichever "active" one
		                        			 $('#'+i.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).on('click',function(){
		                        				document.getElementById('topic').value = i.split('#').join('').split('.')[0].split("!").join('');
		                        				connect();
		                        			}); 
		                        		});
		                      */
		                      
		                      
		                      
		                        		$('#showChannels').css('color','lightgreen');
		                        		//$('#active').html("Active channels: ["+$.parseJSON($.parseJSON(data).activeChannels).activeChannelName+"]");
		                        	}
	                        		if($.parseJSON(data).text !== undefined){
		                        		$('ul').html("");
		                        		$('ul').html("<pre>"+handleHighlights($.parseJSON(data).text)+ "</pre>").append("<hr>");
		                        		$('ul').prepend("<hr>");
	                        		}	                      
		                        }
		                    }
		                    else
		                    	$('#status').html("response.status was "+response.status);
		                };
		                
		                request.onClose = function (response){
		                	$('#status').html("websocket closed, "+"response.status was "+response.status);
		                	$('#status').css("background-color","red");
		                	//$('#active').html("websocket closed");
		                	  
		                };
		                
		                request.onReconnect = function(request, response){
		                	$('#status').html("websocket reconnected, responsestate: "+response.state + ", response.status was "+response.status);
		                	$('#status').css("background-color","yellow");
		                	//$('#active').html("websocket reconnected, responsestate: "+response.state);
		                };
		                
		                request.onClientTimeout = function(request){
		                	$('#status').html("client timeouted, trying to reconn");
		                	$('#status').css("background-color","red");
		                	//$('#active').html("client timeouted");
		                	connect();           	
		                	
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
	                   //getElementById('phrase').focus();
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
	                
	                //populate activeChannels initially
            		$.getJSON("websocket/getActiveChannelsJson",function(data){
            			console.log(data);
		                $('#active').html("");
		                
		                var jsonArrayOfData = new Array();
		                jQuery.each(data.activeChannels, function(i, val) {
		                	//console.log(i+":"+val);
		                	jsonArrayOfData.push({"channel":i, "timestamp":val});
		                });
                		//console.log(jsonArrayOfData); 
                		jsonArrayOfData.sort(sortJsonArrayByDescending("timestamp"));
		                
	            		jQuery.each(jsonArrayOfData, function(i, val) {
	            			//console.log(i+":"+val.channel+":"+val.timestamp);
	            			var seconds =  Math.ceil((new Date() - new Date(val.timestamp))/1000);
	            			
	            			//data-orig-time is for moving the clocks
	            			$('#active').append("<span id='"+val.channel+"'style='font-weight:bold;color:#"+shadeColor("33FF33",40-Math.floor(0.5*seconds))+";'>"+val.channel+"</span>"+":"+ "<span class='seconds' data-orig-time="+val.timestamp +">"+seconds+"</span>" +"s").append("<br/>");
	            		
							//clear possible old bindings 	            			
	            			$('#'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).off();
	            			//onclick to change channel to whichever "active" one
       		    			$('#'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).on('click',function(){
	            				document.getElementById('topic').value = val.channel.split('#').join('').split('.')[0].split("!").join('');
	            				connect();
	            				$('#showChannels').css('color','');
	            			}); 
	            		});
	            		
            		});
	                
	          
	                
            		
    				//moving the clocks
    				setInterval(function(){
    						$('.seconds').each(function() {
    							this.innerHTML = Math.ceil((new Date() - new Date(parseInt(this.getAttribute('data-orig-time'))))/1000);
    						});
    					},5000);
    				
            		//set the activeChannels button to move activechannels-div to view and away
            		
            		$('#showChannels').on('click',function(){
            			$('#active').toggle();
            			$('#showChannels').css('color','');
            			
            		});
	                
	                
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
				//@author Pimp Trizkit @ stackoverflow
				//use with 33FF33,(-)20 for example
		       function shadeColor(color, percent) {   
				    var num = parseInt(color,16),
				    amt = Math.round(2.55 * percent),
				    R = (num >> 16) + amt,
				    G = (num >> 8 & 0x00FF) + amt,
				    B = (num & 0x0000FF) + amt;
				    return (0x1000000 + (R<255?R<1?0:R:255)*0x10000 + (G<255?G<1?0:G:255)*0x100 + (B<255?B<1?0:B:255)).toString(16).slice(1);
				}
				
				//@author Engineer @ stackoverflow
		       function sortJsonArrayByDescending(prop){
		    	   return function(a,b){
		    	      if( a[prop] > b[prop]){
		    	          return -1;
		    	      }else if( a[prop] < b[prop] ){
		    	          return 1;
		    	      }
		    	      return 0;
		    	   }
		    	}
				
			</script>
		<h5>Output:</h5>
	        <ul></ul>
	        <button type="button" id="showChannels">*</button>
	        <div id="active"></div>
	        <p id="status" style="background-color:green;float:right;margin-right:200px;">Initial STATUS</p>
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
