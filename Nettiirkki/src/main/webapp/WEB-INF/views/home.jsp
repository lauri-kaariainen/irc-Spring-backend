<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
<form action="j_spring_security_check">
<input id="username" type="text" placeholder="username plz" name="j_username"/>
<input id="password" type="password" placeholder="password plz" name="j_password"/>
<button type="submit"></button>
</form>

</body>
</html>
