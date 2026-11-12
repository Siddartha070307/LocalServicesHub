<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // Note: There are no user roles and the schema must not change, so any logged-in user can manage services and providers.
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + URLEncoder.encode("Please log in to manage services.", "UTF-8"));
        return;
    }
%>
<%@ include file="conn.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String idStr = request.getParameter("id");
    int serviceId = 0;
    try {
        if (idStr != null) {
            serviceId = Integer.parseInt(idStr.trim());
        }
    } catch (NumberFormatException ignored) {}

    if (serviceId <= 0) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Invalid service ID.", "UTF-8"));
        return;
    }

    String category = "";
    String name = "";
    String description = "";
    String priceRange = "";

    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ps = con.prepareStatement("SELECT id, category, name, description, price_range FROM services WHERE id = ?");
        ps.setInt(1, serviceId);
        rs = ps.executeQuery();

        if (rs.next()) {
            category = rs.getString("category");
            name = rs.getString("name");
            description = rs.getString("description");
            priceRange = rs.getString("price_range");
        } else {
            rs.close();
            ps.close();
            con.close();
            response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Service not found.", "UTF-8"));
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Unable to retrieve service.", "UTF-8"));
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Service - Local Services Hub</title>
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
        <h2>Edit Service</h2>

        <form action="service_update.jsp" method="post">
            <input type="hidden" name="id" value="<%= serviceId %>">

            <div class="form-group">
                <label for="category">Category *</label>
                <input type="text" id="category" name="category" required value="<%= escapeHtml(category) %>">
            </div>

            <div class="form-group">
                <label for="name">Service Name *</label>
                <input type="text" id="name" name="name" required value="<%= escapeHtml(name) %>">
            </div>

            <div class="form-group">
                <label for="description">Description *</label>
                <textarea id="description" name="description" rows="3" required><%= escapeHtml(description) %></textarea>
            </div>

            <div class="form-group">
                <label for="price_range">Price Range *</label>
                <input type="text" id="price_range" name="price_range" required value="<%= escapeHtml(priceRange) %>">
            </div>

            <div class="form-group">
                <button type="submit">Update Service</button>
            </div>

            <a href="services.jsp" class="btn-cancel-link">&larr; Cancel and Back to Services</a>
        </form>
    </div>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>
</body>
</html>
