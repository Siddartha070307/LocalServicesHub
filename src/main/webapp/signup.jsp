<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sign Up - Local Services Hub</title>
    <style>
        section {
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
            padding: 40px 20px;
            color: #ffb300;
        }

        .form-group {
            margin-bottom: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            background-color: #0f1115;
        }

        label {
            width: 150px;
            text-align: right;
            font-weight: 600;
        }

        input {
            width: 300px;
            padding: 12px;
            background-color: #000;   
            color: #fff;              
            border: 1px solid #333;
            border-radius: 6px;
        }

        input:focus {
            outline: none;
            border: 1px solid #2196f3;
            box-shadow: 0 0 5px #2196f3;
        }

        button {
            padding: 12px 40px;
            margin-top: 20px;
            border-radius: 30px;
            border: none;
            background-color: #ffb300;
            color: black;
            font-weight: 600;
            cursor: pointer;
            transition: 0.3s ease;
        }

        button:hover {
            background-color: #ffca28;
            transform: translateY(-2px);
        }

        :root {
            --bg: #0f1115;
            --card: #1a1d24;
            --amber: #ffb300;
            --blue: #2196f3;
            --text: #eaeaea;
            --muted: #9aa0a6;
        }

        body {
            background: var(--bg);
            color: var(--text);
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

        form {
            max-width: 500px;
            margin: 0 auto;
            background: black;
            padding: 30px;
            border-radius: 12px;
            border: 1px solid #ffb300;
        }

        footer {
            background: #14161c;
            text-align: center;
            padding: 30px;
            color: var(--muted);
            border-top: 2px solid var(--amber);
            margin-top: 60px;
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
    </style>
</head>

<body>

<%@ include file="header.jsp" %>

<main>
<section>
    <h2>Create Account</h2>

    <%
        String errorMsg = request.getParameter("error");
        if (errorMsg != null && !errorMsg.trim().isEmpty()) {
    %>
        <div class="alert-error"><%= escapeHtml(errorMsg) %></div>
    <%
        }
    %>

    <form action="signup_process.jsp" method="post" onsubmit="return validateForm()">

        <div class="form-group">
            <label>First Name *</label>
            <input type="text" id="first_name" name="first_name" required>
        </div>

        <div class="form-group">
            <label>Last Name *</label>
            <input type="text" id="last_name" name="last_name" required>
        </div>

        <div class="form-group">
            <label>Email *</label>
            <input type="email" id="email" name="email" required>
        </div>

        <div class="form-group">
            <label>Password *</label>
            <input type="password" id="password" name="password" required>
        </div>

        <div class="form-group">
            <label>Confirm Password *</label>
            <input type="password" id="confirmPassword" name="confirm_password" required>
        </div>

        <div class="form-group">
            <label>Phone Number</label>
            <input type="tel" id="phone" name="phone">
        </div>

        <button type="submit" id="sbtn">Sign Up</button>
    </form>
</section>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>

<script>
function validateForm() {
    let email = document.getElementById("email").value.trim();
    let password = document.getElementById("password").value;
    let confirmPassword = document.getElementById("confirmPassword").value;
    let phone = document.getElementById("phone").value.trim();

    let emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    let phonePattern = /^[0-9]{10}$/;
    // Password must be at least 8 characters, include uppercase, lowercase, and a number
    let passPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

    if (!emailPattern.test(email)) {
        alert("Please enter a valid email!");
        return false;
    }
    if (!passPattern.test(password)) {
        alert("Password must be at least 8 characters, include uppercase, lowercase, and a number.");
        return false;
    }
    if (password !== confirmPassword) {
        alert("Passwords do not match!");
        return false;
    }
    if (phone !== "" && !phonePattern.test(phone)) {
        alert("Phone must be exactly 10 digits!");
        return false;
    }
    return true;
}
</script>

</body>
</html>
