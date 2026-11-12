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
    String category = request.getParameter("category");
    String name = request.getParameter("name");
    String description = request.getParameter("description");
    String priceRange = request.getParameter("price_range");

    int serviceId = 0;
    try {
        if (idStr != null) {
            serviceId = Integer.parseInt(idStr.trim());
        }
    } catch (NumberFormatException ignored) {}

    category = (category != null) ? category.trim() : "";
    name = (name != null) ? name.trim() : "";
    description = (description != null) ? description.trim() : "";
    priceRange = (priceRange != null) ? priceRange.trim() : "";

    if (serviceId <= 0 || category.isEmpty() || name.isEmpty() || description.isEmpty() || priceRange.isEmpty()) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("service_edit.jsp?id=" + serviceId + "&error=" + URLEncoder.encode("All fields are required.", "UTF-8"));
        return;
    }

    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement(
            "UPDATE services SET category = ?, name = ?, description = ?, price_range = ? WHERE id = ?"
        );
        ps.setString(1, category);
        ps.setString(2, name);
        ps.setString(3, description);
        ps.setString(4, priceRange);
        ps.setInt(5, serviceId);

        int updated = ps.executeUpdate();
        ps.close();
        con.close();

        if (updated > 0) {
            response.sendRedirect("services.jsp?msg=" + URLEncoder.encode("Service updated successfully.", "UTF-8"));
        } else {
            response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Service not found.", "UTF-8"));
        }
    } catch (Exception e) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("service_edit.jsp?id=" + serviceId + "&error=" + URLEncoder.encode("Failed to update service.", "UTF-8"));
    }
%>
