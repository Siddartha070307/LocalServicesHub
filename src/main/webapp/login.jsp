<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Local Services Hub</title>
    <style>
        :root {
            --bg: #0f1115;
            --card: #1a1d24;
            --amber: #ffb300;
            --amber-hover: #ffca28;
            --blue: #2196f3;
            --text: #eaeaea;
            --muted: #9aa0a6;
        }
        body { 
            background: var(--bg); 
            color: var(--text); 
            font-family: sans-serif; 
            line-height: 1.6;
        }
        header { 
            background: #14161c; 
            padding: 20px; 
            border-bottom: 1px solid #222; 
        }
        h1 { 
            color: var(--amber); 
        }
        nav a { 
            color: var(--text); 
            text-decoration: none; 
            margin-right: 20px; 
            transition: 0.3s;
        }
        nav a:hover {
            color: var(--blue);
        }
        main { 
            max-width: 500px; 
            margin: 60px auto; 
            padding: 20px; 
        }
        .login-page { 
            background: var(--card); 
            padding: 40px; 
            border-radius: 12px; 
            border: 1px solid #222; 
        }
        h2 { 
            color: var(--amber); 
            text-align: center; 
            margin-bottom: 30px; 
        }
        .form-group {
            margin-bottom: 20px; 
        }
        label { 
            display: block; 
            margin-bottom: 8px; 
        }
        input{ 
            width: 100%; 
            padding: 12px; 
            border-radius: 8px; 
            border: 1px solid #333; 
            background: #161922; 
            color: white; 
            box-sizing: border-box;
        }
        input:focus {
            border-color: var(--blue); 
            outline: none;
        }
        button { 
            width: 100%; 
            padding: 14px; 
            border-radius: 8px; 
            border: none; 
            background: var(--amber); 
            cursor: pointer; 
            font-weight: 600; 
            transition: 0.3s;
        }
        button:hover { 
            background: var(--amber-hover); 
        }
        .signup-link { 
            text-align: center; 
            margin-top: 20px; 
            color: var(--muted); 
        }
        .signup-link a { 
            color: var(--blue); 
            text-decoration: none; 
            font-weight: 600; 
        }
        .signup-link a:hover {
            text-decoration: underline; 
        }
        footer { 
            background: #14161c; 
            text-align: center; 
            padding: 30px; 
            color: var(--muted); 
            border-top: 2px solid var(--amber);
            margin-top: 80px; 
        }
        .alert-error {
            background: rgba(244, 67, 54, 0.15);
            border: 1px solid #f44336;
            color: #ff8a80;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }
        .alert-success {
            background: rgba(76, 175, 80, 0.15);
            border: 1px solid #4caf50;
            color: #81c784;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

<main>
    <section class="login-page">
        <h2>Login to Your Account</h2>

        <%
            String errorMsg = request.getParameter("error");
            if (errorMsg != null && !errorMsg.trim().isEmpty()) {
        %>
            <div class="alert-error"><%= escapeHtml(errorMsg) %></div>
        <%
            }
            String successMsg = request.getParameter("msg");
            if (successMsg != null && !successMsg.trim().isEmpty()) {
        %>
            <div class="alert-success"><%= escapeHtml(successMsg) %></div>
        <%
            }
        %>

        <form id="loginForm" action="login_process.jsp" method="post">
            <div class="form-group">
                <label for="email">Email Address *</label>
                <input type="email" id="email" name="email" required placeholder="Enter your email">
            </div>

            <div class="form-group">
                <label for="password">Password *</label>
                <input type="password" id="password" name="password" required placeholder="Enter your password">
            </div>

            <button type="submit">Login</button>

            <p class="signup-link">
                Don't have an account? <a href="signup.jsp">Sign Up</a>
            </p>
        </form>
    </section>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>

<script>
document.getElementById("loginForm").onsubmit = function() {
    let email = document.getElementById("email").value.trim();
    let password = document.getElementById("password").value;

    let emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

    if (!emailPattern.test(email)) {
        alert("Please enter a valid email address!");
        return false;
    } 
    
    if (password.length === 0) {
        alert("Please enter your password!");
        return false;
    }
    return true; 
};
</script>

</body>
</html>
