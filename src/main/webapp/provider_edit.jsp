<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
<%
    request.setCharacterEncoding("UTF-8");

    String idStr = request.getParameter("id");
    int providerId = 0;
    try {
        if (idStr != null) {
            providerId = Integer.parseInt(idStr.trim());
        }
    } catch (NumberFormatException ignored) {}

    if (providerId <= 0) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Invalid provider ID.", "UTF-8"));
        return;
    }

    String name = "";
    int currentServiceId = 0;
    double rating = 0.0;
    int experienceYears = 0;
    String description = "";
    int visitFee = 0;

    class ServiceChoice {
        int id;
        String name;
        ServiceChoice(int id, String name) {
            this.id = id;
            this.name = name;
        }
    }
    List<ServiceChoice> serviceChoices = new ArrayList<ServiceChoice>();

    PreparedStatement ps = null;
    ResultSet rs = null;
    Statement stmtServices = null;
    ResultSet rsServices = null;

    try {
        ps = con.prepareStatement("SELECT id, name, service_id, rating, experience_years, description, visit_fee FROM providers WHERE id = ?");
        ps.setInt(1, providerId);
        rs = ps.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            currentServiceId = rs.getInt("service_id");
            rating = rs.getDouble("rating");
            experienceYears = rs.getInt("experience_years");
            description = rs.getString("description");
            visitFee = rs.getInt("visit_fee");
        } else {
            rs.close();
            ps.close();
            con.close();
            response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Provider not found.", "UTF-8"));
            return;
        }

        stmtServices = con.createStatement();
        rsServices = stmtServices.executeQuery("SELECT id, name FROM services ORDER BY name");
        while (rsServices.next()) {
            serviceChoices.add(new ServiceChoice(rsServices.getInt("id"), rsServices.getString("name")));
        }

    } catch (Exception e) {
        response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Unable to load provider details.", "UTF-8"));
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        if (rsServices != null) try { rsServices.close(); } catch (SQLException ignored) {}
        if (stmtServices != null) try { stmtServices.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Provider - Local Services Hub</title>
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
        <h2>Edit Service Provider</h2>

        <form action="provider_update.jsp" method="post">
            <input type="hidden" name="id" value="<%= providerId %>">

            <div class="form-group">
                <label for="name">Provider Name *</label>
                <input type="text" id="name" name="name" required value="<%= escapeHtml(name) %>">
            </div>

            <div class="form-group">
                <label for="service_id">Service Category *</label>
                <select id="service_id" name="service_id" required>
                    <% for (ServiceChoice sc : serviceChoices) { %>
                        <option value="<%= sc.id %>" <%= (sc.id == currentServiceId) ? "selected" : "" %>>
                            <%= escapeHtml(sc.name) %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label for="rating">Rating (1.0 to 5.0) *</label>
                <input type="number" id="rating" name="rating" min="1.0" max="5.0" step="0.1"
                       value="<%= String.format(Locale.US, "%.1f", rating) %>" required>
            </div>

            <div class="form-group">
                <label for="experience_years">Experience (Years) *</label>
                <input type="number" id="experience_years" name="experience_years" min="0" max="50"
                       value="<%= experienceYears %>" required>
            </div>

            <div class="form-group">
                <label for="description">Short Description *</label>
                <textarea id="description" name="description" rows="3" required><%= escapeHtml(description != null ? description : "") %></textarea>
            </div>

            <div class="form-group">
                <label for="visit_fee">Standard Visit Fee (₹) *</label>
                <input type="number" id="visit_fee" name="visit_fee" min="0" value="<%= visitFee %>" required>
            </div>

            <div class="form-group">
                <button type="submit">Update Provider</button>
            </div>

            <a href="providers.jsp" class="btn-cancel-link">&larr; Cancel and Back to Providers</a>
        </form>
    </div>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>
</body>
</html>
