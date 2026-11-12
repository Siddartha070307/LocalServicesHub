<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // Note: There are no user roles and the schema must not change, so any logged-in user can manage services and providers.
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + URLEncoder.encode("Please log in to manage providers.", "UTF-8"));
        return;
    }
%>
<%@ include file="conn.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Provider - Local Services Hub</title>
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
    <div class="form-container">
        <h2>Add New Service Provider</h2>

        <%
            String errorMsg = request.getParameter("error");
            if (errorMsg != null && !errorMsg.trim().isEmpty()) {
        %>
            <div class="alert-error"><%= escapeHtml(errorMsg) %></div>
        <%
            }
        %>

        <form action="provider_insert.jsp" method="post">
            <div class="form-group">
                <label for="name">Provider Name *</label>
                <input type="text" id="name" name="name" required placeholder="Full name of professional">
            </div>

            <div class="form-group">
                <label for="service_id">Service Category *</label>
                <select id="service_id" name="service_id" required>
                    <option value="">-- Select Associated Service --</option>
                    <%
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            stmt = con.createStatement();
                            rs = stmt.executeQuery("SELECT id, name FROM services ORDER BY name");
                            while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id") %>"><%= escapeHtml(rs.getString("name")) %></option>
                    <%
                            }
                        } catch (SQLException ignored) {
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                            if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
                            if (con != null) try { con.close(); } catch (SQLException ignored) {}
                        }
                    %>
                </select>
            </div>

            <div class="form-group">
                <label for="rating">Rating (1.0 to 5.0) *</label>
                <input type="number" id="rating" name="rating" min="1.0" max="5.0" step="0.1" value="4.5" required>
            </div>

            <div class="form-group">
                <label for="experience_years">Experience (Years) *</label>
                <input type="number" id="experience_years" name="experience_years" min="0" max="50" value="5" required>
            </div>

            <div class="form-group">
                <label for="description">Short Description *</label>
                <textarea id="description" name="description" rows="3" required placeholder="Specialties, skillsets, or service area"></textarea>
            </div>

            <div class="form-group">
                <label for="visit_fee">Standard Visit Fee (₹) *</label>
                <input type="number" id="visit_fee" name="visit_fee" min="0" value="299" required>
            </div>

            <div class="form-group">
                <button type="submit">Save Provider</button>
            </div>

            <a href="providers.jsp" class="btn-cancel-link">&larr; Back to Providers</a>
        </form>
    </div>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>
</body>
</html>
