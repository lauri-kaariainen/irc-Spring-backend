<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page session="false" %>
<html>
<head>
	<title>Home</title>
</head>
<body>
<h1>
	Hello world!  
</h1>

<P>  The time on the server is ${serverTime}. </P>
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
