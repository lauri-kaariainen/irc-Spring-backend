<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page session="false" %>
<html>
<head>
	<title>Irkki</title>
	
	<sec:authorize access="isAnonymous() == false">
		<script src="resources/jquery-1.10.2.min.js"></script>
		<script src="resources/jquery.atmosphere.min.js"></script>
		<script src="resources/home.js"></script>
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
			 
	       
	        
		<h5>Output:</h5>
	        <ul id="textElement"></ul>
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