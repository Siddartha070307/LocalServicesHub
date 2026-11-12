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

    String category = request.getParameter("category");
    String name = request.getParameter("name");
    String description = request.getParameter("description");
    String priceRange = request.getParameter("price_range");

    category = (category != null) ? category.trim() : "";
    name = (name != null) ? name.trim() : "";
    description = (description != null) ? description.trim() : "";
    priceRange = (priceRange != null) ? priceRange.trim() : "";

    if (category.isEmpty() || name.isEmpty() || description.isEmpty() || priceRange.isEmpty()) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("service_add.jsp?error=" + URLEncoder.encode("All fields are required.", "UTF-8"));
        return;
    }

    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement(
            "INSERT INTO services (category, name, description, price_range) VALUES (?, ?, ?, ?)"
        );
        ps.setString(1, category);
        ps.setString(2, name);
        ps.setString(3, description);
        ps.setString(4, priceRange);
        ps.executeUpdate();

        ps.close();
        con.close();

        response.sendRedirect("services.jsp?msg=" + URLEncoder.encode("Service added successfully.", "UTF-8"));
    } catch (Exception e) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Failed to add service. Please try again.", "UTF-8"));
    }
%>