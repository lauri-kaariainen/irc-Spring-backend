
	            $(document).ready(function() {
					
					
					//list of when each channel has been checked
					var listOfWhenChannelsHaveBeenLastChecked = {};
					
					var statusElementId = '#status';
					var selectedNameElementId = '#channelName';
					var textElementId = '#textElement';
					var channelListId = '#channelMenu';
					var channelBarId = '#channelBar';
					var channelLinkClass = '.channelLink';
				
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
		            	
		            
		                var request = { url : document.location.toString() + "websocket/" + sessionStorage.channel.split('#').join('').split('.')[0].split("!").join(''),
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
		                       
		                        	
		                        		$(channelListId).children().remove();
		                        		$(channelBarId+' > '+channelLinkClass).remove();
		                        	   
		        		                var jsonArrayOfData = new Array();
		        		                jQuery.each($.parseJSON(data).activeChannels, function(i, val) {
		        		                	//console.log(i+":"+val);
		        		                	jsonArrayOfData.push({"channel":i, "timestamp":val}); 
		        		                });
		                        		//console.log(jsonArrayOfData);  
		                        		jsonArrayOfData.sort(sortJsonArrayByDescending("timestamp"));
										//hack because the newest item should be always displayed, even though the timestamp 
										//might be a little too early because back-end time differs from browser time
		                        		jsonArrayOfData[0].timestamp = new Date(); 
		                      
		                        		jQuery.each(jsonArrayOfData, function(i, val) {
		        	            			//console.log(i+":"+val.channel+":"+val.timestamp);
		        	            			var seconds =  Math.ceil((new Date() - new Date(val.timestamp))/1000); 
		        	            			
		        	            			//data-orig-time is for moving the clocks
		        	            			$(channelListId).append("<li role='presentation'>"+"<span role='menuitem' tabindex='-1' class='"+val.channel+"'style='font-weight:bold;color:#"+shadeColor("33FF33",40-Math.floor(0.5*seconds))+";'>"+val.channel+"</span>"+":"+ "<span class='minutes' style='color:white;' data-orig-time="+val.timestamp +">"+Math.round(seconds/60)+"</span>" +"<span style='color:#ccc;'>min</span>"+"</li>");
											//console.log(val.channel+": ("+listOfWhenChannelsHaveBeenLastChecked[val.channel]+" < "+ val.timestamp+")"+(listOfWhenChannelsHaveBeenLastChecked[val.channel] < val.timestamp));
											
											if(listOfWhenChannelsHaveBeenLastChecked[val.channel] < val.timestamp)
												$('.ircStatus').append("<li class='channelLink' ><span class='"+val.channel+"'>"+val.channel.substr(0,4)+"</span>, </li> ");
		        							//clear possible old bindings 	            			
		        	            			$('.'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).off();
		        	            			//onclick to change channel to whichever "active" one
		               		    			$('.'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).on('click',function(){
												$(selectedNameElementId)[0].value = val.channel;
												
		        	            				connect();
		        	            				
		        	            			}); 
		        	            		});
		                        		
		                        	}
	                        		if($.parseJSON(data).text !== undefined){
										sessionStorage.channel = $(selectedNameElementId)[0].value;
										console.log(channelBarId+' > '+channelLinkClass+' > .'+$(selectedNameElementId)[0].value.replace("!","\\!").replace("#","\\\#").replace(".","\\."));
										$(channelBarId+' > '+channelLinkClass+' > .'+$(selectedNameElementId)[0].value.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).parent().remove();
		                        		$(textElementId).html("");
		                        		$(textElementId).html("<pre>"+handleHighlights($.parseJSON(data).text)+ "</pre>").append("<hr>");
		                        		$(textElementId).prepend("<hr>");
										$('.pre-scrollable').animate({scrollTop:$('pre').height()},1000);
	                        		}	                      
		                        }
								listOfWhenChannelsHaveBeenLastChecked[$(selectedNameElementId)[0].value] = new Date().getTime();
								console.log( JSON.stringify(listOfWhenChannelsHaveBeenLastChecked));
								localStorage.listOfWhenChannelsHaveBeenLastChecked  = JSON.stringify(listOfWhenChannelsHaveBeenLastChecked);
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
						//$('body').css('visibility','hidden');
						//self._386 = self._386 || {};
						//self._386.speedFactor = 2;
						//loading();
	                   // getElementById('connect').value = "Switch transport";
	                }
	        
	                //check if we returned to the page, ie. there is channel in sessionstorage
	                if(sessionStorage.channel !== undefined){
						 $(selectedNameElementId)[0].value = sessionStorage.channel;
	                	subscribe();
	                }
	                
	                //populate activeChannels initially
            		$.getJSON("ajax/getActiveChannelsJson",function(data){
            			console.log(data);
						
		                //$(channelListId).html("");
		                $(channelListId).children().remove();
						
						
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
	            			
							//initialize
							if(!localStorage.listOfWhenChannelsHaveBeenLastChecked)
								listOfWhenChannelsHaveBeenLastChecked[val.channel] = 0;
							else{
								console.log(JSON.parse(localStorage.listOfWhenChannelsHaveBeenLastChecked));
								listOfWhenChannelsHaveBeenLastChecked[val.channel] = JSON.parse(localStorage.listOfWhenChannelsHaveBeenLastChecked)[val.channel] || 0;
	            			}
							//data-orig-time is for moving the clocks
							$(channelListId).append("<li role='presentation'>"+"<span role='menuitem' tabindex='-1' class='"+val.channel+"'style='font-weight:bold;color:#"+shadeColor("33FF33",40-Math.floor(0.5*seconds))+";'>"+val.channel+"</span>"+":"+ "<span class='minutes' style='color:white;' data-orig-time="+val.timestamp +">"+Math.round(seconds/60)+"</span>" +"<span style='color:#ccc;'>min</span>"+"</li>");
							if(listOfWhenChannelsHaveBeenLastChecked[val.channel] < val.timestamp)
								$('.ircStatus').append("<li class='channelLink' ><span class='"+val.channel+"'>"+val.channel.substr(0,4)+"</span>, </li> ");
							//clear possible old bindings 	            			
	            			$('.'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).off();
	            			//onclick to change channel to whichever "active" one
       		    			$('.'+val.channel.replace("!","\\!").replace("#","\\\#").replace(".","\\.")).on('click',function(){
	            				$(selectedNameElementId)[0].value = val.channel;
	            				connect();
	            			}); 
	            		});
						
						
						localStorage.listOfWhenChannelsHaveBeenLastChecked = JSON.stringify(listOfWhenChannelsHaveBeenLastChecked);
						
						console.log(JSON.stringify(listOfWhenChannelsHaveBeenLastChecked));
	            		
            		});
	                
	          
	                
            		
    				//moving the clocks
    				setInterval(function(){
    						$('.minutes').each(function() {
    							this.innerHTML = Math.round((new Date() - new Date(parseInt(this.getAttribute('data-orig-time'))))/1000/60);
    						});
    					},5000);
    				
            		
	                
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
				    return (0x1000000 + (R<255?R<1?90:R:255)*0x10000 + (G<255?G<1?90:G:255)*0x100 + (B<255?B<1?90:B:255)).toString(16).slice(1);
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
				
				
