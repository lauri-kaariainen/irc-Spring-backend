
	            $(document).ready(function() {
				
					var statusElementId = '#status';
					var selectedNameElementId = '#topic';
					var textElementId = '#textElement';
					var channelListId = '#active';
				
				
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
		        
		                
		                function getElementByIdValue() {
		                    detectedTransport = null;
		                    return document.getElementById(arguments[0]).value;
		                }
		        
		            function subscribe() {
						console.log($(selectedNameElementId));
		            	//storing value so on reconnect we return to it
		            	sessionStorage.channel = $(selectedNameElementId)[0].value;
		            	
		            
		                var request = { url : document.location.toString() + "websocket/" + $(selectedNameElementId)[0].value,
		                    transport: 'websocket',
							fallbackTransport: 'long-polling',
		                    timeout: 300000};
		                console.log(document.location.toString() +"websocket/" + $(selectedNameElementId)[0].value);
		
		                request.onMessage = function (response) {
		                	$(statusElementId).html("Online");
		                	$(statusElementId).css("background-color","green");
		                	
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
		        	            				
		        	            			}); 
		        	            		});
		                        		
		                      
		                        	
		                        		
		                        	}
	                        		if($.parseJSON(data).text !== undefined){
		                        		$(textElementId).html("");
		                        		$(textElementId).html("<pre>"+handleHighlights($.parseJSON(data).text)+ "</pre>").append("<hr>");
		                        		$(textElementId).prepend("<hr>");
	                        		}	                      
		                        }
		                    }
		                    else
		                    	$(statusElementId).html("response.status was "+response.status);
		                };
		                
		                request.onClose = function (response){
		                	$(statusElementId).html("websocket closed, "+"response.status was "+response.status);
		                	$(statusElementId).css("background-color","red");
		                	
		                	  
		                };
		                
		                request.onReconnect = function(request, response){
		                	$(statusElementId).html("websocket reconnected, responsestate: "+response.state + ", response.status was "+response.status);
		                	$(statusElementId).css("background-color","yellow");
		                	
		                };
		                
		                request.onClientTimeout = function(request){
		                	$(statusElementId).html("client timeouted, trying to reconn");
		                	$(statusElementId).css("background-color","red");
		                	
		                	connect();           	
		                	
		                };
		
		                subSocket = socket.subscribe(request);
		            }
		
		            function unsubscribe(){
		                socket.unsubscribe();
		            }
		        
	                function connect() {
	                    unsubscribe();
	                   // getElementById('phrase').value = '';
	                   // getElementById('sendMessage').className = '';
	                   //getElementById('phrase').focus();
	                    subscribe();
	                   // getElementById('connect').value = "Switch transport";
	                }
	        
	                getElementById('connect').onclick = function(event) {
	                    if (getElementById('topic').value == '') {
	                        alert("Please type in a channel to subscribe");
	                        return;
	                    }
	                    connect();
	                }
	        
	      /*          getElementById('topic').onkeyup = function(event) {
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
	        */
			/*
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
			*/
	        /*
	                getElementById('topic').focus();
	            	
			*/      
	                //check if we returned to the page, ie. there is channel in sessionstorage
	                if(sessionStorage.channel !== undefined){
	                	$(selectedNameElementId)[0].value = sessionStorage.channel;
	                	subscribe();
	                }
	                
	                //populate activeChannels initially
            		$.getJSON("ajax/getActiveChannelsJson",function(data){
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
	            			$(channelListId).append("<span id='"+val.channel+"'style='font-weight:bold;color:#"+shadeColor("33FF33",40-Math.floor(0.5*seconds))+";'>"+val.channel+"</span>"+":"+ "<span class='seconds' data-orig-time="+val.timestamp +">"+seconds+"</span>" +"s").append("<br/>");
	            		
							//clear possible old bindings 	            			
	            			$('#'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).off();
	            			//onclick to change channel to whichever "active" one
       		    			$('#'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).on('click',function(){
	            				$(selectedNameElementId)[0].value = val.channel.split('#').join('').split('.')[0].split("!").join('');
	            				connect();
	            			}); 
	            		});
	            		
            		});
	                
	          
	                
            		
    				//moving the clocks
    				setInterval(function(){
    						$('.seconds').each(function() {
    							this.innerHTML = Math.ceil((new Date() - new Date(parseInt(this.getAttribute('data-orig-time'))))/1000);
    						});
    					},5000);
    				
            		/*
            		//set the activeChannels button to move activechannels-div to view and away
            		$('#showChannels').on('click',function(){
            			$('#active').toggle();
            			$('#showChannels').css('color','');
            			
            		});
	                */
	                
	            }); 
				
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
				
		