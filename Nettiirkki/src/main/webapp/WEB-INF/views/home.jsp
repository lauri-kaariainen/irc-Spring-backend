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
		<script src="resources/home.js"></script>
	</sec:authorize>
	<style>
		html {
			height:100%
		}
	
      body {
  
		background-color:black;

	  }
	 
	  .irc-scrollarea {
		height:82vh;
	  }
	  
	  pre {
		word-break:normal;
	  }
	  
	  .ircStatus {
		background-color:darkblue;
	
		//height:20px;
		margin:3px;
	  }
	  
	  .ircInput {
		height:20px;
		margin:3px;
	  }
	  
	  .pre-scrollable {
		max-height:100%;
	  }
	

	</style>
	
</head>
<body>



	<input type="text" hidden="hidden" style="display:none;" id="channelName"/>
	<sec:authorize access="hasRole('superman')">
		<div class="navbar navbar-inverse navbar-fixed-top" id="status" style="background-color:white; height:20px;">irkki</div>
		<!--div class="navbar navbar-inverse navbar-fixed-top">
		  <div class="navbar-inner">
			<div class="container">
			  <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			  </button>
			  <a class="brand" href="http://kristopolous.github.io/BOOTSTRA.386/examples/starter-template.html#">Project name</a>
			  <div class="nav-collapse collapse">
				<ul class="nav">
				  <li class="active"><a href="http://kristopolous.github.io/BOOTSTRA.386/examples/starter-template.html#">Home</a></li>
				  <li><a href="http://kristopolous.github.io/BOOTSTRA.386/examples/starter-template.html#about">About</a></li>
				  <li><a href="http://kristopolous.github.io/BOOTSTRA.386/examples/starter-template.html#contact">Contact</a></li>
				</ul>
			  </div><!--/.nav-collapse -->
			<!--/div>
		  </div>
		</div-->

		<div class="container-fluid">

			<!--h1>Bootstrap starter template</h1>
			<p>Use this document as a way to quick start any new project.<br> All you get is this message and a barebones HTML document.</p-->
			<div class="row-fluid irc-scrollarea" ><div class="pre-scrollable"><pre id="textElement"></pre></div></div>

			<div class="row-fluid" >
				<p class="ircStatus" id="active">this text is the status bar</p>
			</div>
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
