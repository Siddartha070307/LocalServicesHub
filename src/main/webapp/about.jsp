<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>About Us - Local Services Hub</title>
    <style>
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
            font-weight: 700;
        }

        nav {
            margin-top: 10px;
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
            max-width: 1000px;
            margin: 60px auto;
            padding: 20px;
        }

        h2 {
            color: var(--amber);
            text-align: center;
            margin-bottom: 20px;
        }

        p {
            color: var(--text);
            line-height: 1.8;
            text-align: center;
            margin-bottom: 40px;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin: 40px 0;
        }

        .card {
            background: var(--card);
            padding: 40px;
            border-radius: 12px;
            border: 1px solid #222;
            text-align: center;
            transition: 0.3s;
        }

        .card:hover {
            border-color: var(--blue);
            transform: translateY(-5px);
        }

        .card h3 {
            color: var(--amber);
            font-size: 48px;
            margin-bottom: 10px;
        }

        .card p {
            color: var(--muted);
            font-size: 18px;
            margin: 0;
        }

        footer {
            background: rgb(58, 50, 91);
            text-align: center;
            padding: 20px;
            color: var(--muted);
            border-top: 2px solid var(--amber);
            margin-top: 60px;
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <main>
        <h2>About Local Services Hub</h2>
        
        <p>
            We connect homeowners with trusted local professionals for all your home service needs. 
            From plumbers to electricians, carpenters to cleaners - we've got you covered.
        </p>
        <h2>Our Story</h2>
        <p>
            Local Services Hub was born from a simple idea - connecting people with reliable home
            service professionals shouldn't be difficult. We started in 2024 with a vision to make quality
            home services accessible to everyone. Today, we're proud to serve hundreds of satisfied
            customers across the city.
        </p>

        <div class="stats">
            <div class="card">
                <h3>500+</h3>
                <p>Happy Customers</p>
            </div>

            <div class="card">
                <h3>50+</h3>
                <p>Verified Professionals</p>
            </div>

            <div class="card">
                <h3>1000+</h3>
                <p>Services Completed</p>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
    </footer>
</body>
</html>
