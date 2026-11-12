<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Note: There are no user roles and the schema must not change, so any logged-in user can manage services and providers.
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + java.net.URLEncoder.encode("Please log in to manage services.", "UTF-8"));
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Service - Local Services Hub</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .form-container {
            max-width: 550px;
            margin: 40px auto;
            background: var(--card);
            padding: 35px;
            border-radius: 12px;
            border: 1px solid #222;
        }
        .form-container h2 {
            margin-bottom: 25px;
        }
        .btn-cancel-link {
            display: inline-block;
            margin-top: 15px;
            color: var(--muted);
            text-decoration: none;
            text-align: center;
            width: 100%;
        }
        .btn-cancel-link:hover {
            color: var(--amber);
        }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>

<main>
    <div class="form-container">
        <h2>Add New Service</h2>

        <form action="services_insert.jsp" method="post">
            <div class="form-group">
                <label for="category">Category *</label>
                <input type="text" id="category" name="category" required placeholder="e.g. Maintenance, Construction, Cleaning">
            </div>

            <div class="form-group">
                <label for="name">Service Name *</label>
                <input type="text" id="name" name="name" required placeholder="e.g. Carpentry, Plumbing">
            </div>

            <div class="form-group">
                <label for="description">Description *</label>
                <textarea id="description" name="description" rows="3" required placeholder="Detailed description of the service"></textarea>
            </div>

            <div class="form-group">
                <label for="price_range">Price Range *</label>
                <input type="text" id="price_range" name="price_range" required placeholder="e.g. 50-120/hr">
            </div>

            <div class="form-group">
                <button type="submit">Save Service</button>
            </div>

            <a href="services.jsp" class="btn-cancel-link">&larr; Back to Services</a>
        </form>
    </div>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>
</body>
</html>
