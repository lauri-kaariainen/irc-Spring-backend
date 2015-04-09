<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page session="false" %>
<html>
<head>
	<title>Irkki</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<sec:authorize access="isAnonymous() == false">
		<link href="resources/bootstrap/bootstrap.css" rel="stylesheet">
		<link href="resources/bootstrap/bootstrap-responsive.css" rel="stylesheet">
		<script src="resources/jquery-1.10.2.min.js"></script>
		<script src="resources/jquery.atmosphere.min.js"></script>
		
	</sec:authorize>
	<style>
		html {
			height:100%
		}
	
      body {
  
		background-color:black;

	  }
	 
	  .irc-scrollarea {
		height:77vh;
	  }
	  
	  pre {
		word-break:normal;
		color: grey;
		font-size:0.7em;
		line-height:1.2em;
		}
	  
	  .ircStatus {
		background-color:darkblue;
		height: 20px;
		color:white;
		margin:3px;
	  }
	  .ircStatus li a {
	  color:white;
	  }
	  
	  .ircInput {
		height:20px;
		margin:3px;
	  }
	  
	  .pre-scrollable {
		max-height:100%;
		
	  }
	  
	  .caret {
		transform: rotate(180deg);
		}
	

	</style>
	
</head>
<body>



	<input type="text" hidden="hidden" style="display:none;" id="channelName"/>
	<sec:authorize access="hasRole('superman')">
		<div class="navbar navbar-inverse navbar-fixed-top" id="status" style="background-color:white; height:20px;">irkki</div>
		

		<div class="container-fluid">

			<!--h1>Bootstrap starter template</h1>
			<p>Use this document as a way to quick start any new project.<br> All you get is this message and a barebones HTML document.</p-->
			<div class="row-fluid irc-scrollarea" ><div class="pre-scrollable"><pre id="textElement"></pre></div></div>

			<!--div class="row-fluid" >
				<p class="ircStatus" id="active">this text is the status bar</p>
			</div-->
			
			
			
			<ul class="nav nav-pills ircStatus" id="channelBar">
			  <li class="dropup pull-right">
				<a class="dropdown-toggle"
				   data-toggle="dropdown"
				   href="#">
					Channels
					<b class="caret caret-reversed"></b>
				  </a>
				<ul class="dropdown-menu" id="channelMenu">
					<li role="presentation"><a role="menuitem" tabindex="-1" href="#">No channels</a></li>
					
				</ul>
			  </li>
			</ul>
			
			
			
			
			<div class="row-fluid" >
				<div class="span4">
					<p class="ircInput">this is the input area</p>
				</div>
				<div class="span2 offset6">
					<a href="j_spring_security_logout" >Sing me out!</a>
				<div>
			</div>
				
		  
	  
		</div> <!-- /container -->
		<script src="resources/bootstrap/bootstrap-transition.js"></script>
		<script>
			//this enables cool coming up effect in the bootstrap-386.js file
			$('body').css('visibility','hidden');
			self._386 = self._386 || {};
			self._386.speedFactor = 4;
		</script>
		<script src="resources/bootstrap/bootstrap.min.js"></script>
		<script src="resources/bootstrap/bootstrap-dropdown.js"></script>
		<script src="resources/bootstrap/bootstrap-scrollspy.js"></script>
		<script src="resources/home.js"></script>
	
	</sec:authorize>

 <sec:authorize access="isAnonymous()"> 
	<form action="j_spring_security_check" method="post">
		<input id="username" type="text" placeholder="username plz" name="j_username"/>
		<input id="password" type="password" placeholder="password plz" name="j_password"/>
		<button type="submit"></button>
	</form>
</sec:authorize>
 <%--sec:authorize access="isAnonymous() == false">
	<a href="j_spring_security_logout" >Sing me out!</a>
</sec:authorize--%>

</body>
</html>
