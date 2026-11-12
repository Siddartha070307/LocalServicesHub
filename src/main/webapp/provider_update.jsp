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
<%
    request.setCharacterEncoding("UTF-8");

    String idStr = request.getParameter("id");
    String name = request.getParameter("name");
    String serviceIdStr = request.getParameter("service_id");
    String ratingStr = request.getParameter("rating");
    String experienceYearsStr = request.getParameter("experience_years");
    String description = request.getParameter("description");
    String visitFeeStr = request.getParameter("visit_fee");

    int providerId = 0;
    int serviceId = 0;
    double rating = 0.0;
    int experienceYears = 0;
    int visitFee = 0;

    name = (name != null) ? name.trim() : "";
    description = (description != null) ? description.trim() : "";

    try {
        if (idStr != null) providerId = Integer.parseInt(idStr.trim());
        if (serviceIdStr != null) serviceId = Integer.parseInt(serviceIdStr.trim());
        if (ratingStr != null) rating = Double.parseDouble(ratingStr.trim());
        if (experienceYearsStr != null) experienceYears = Integer.parseInt(experienceYearsStr.trim());
        if (visitFeeStr != null) visitFee = Integer.parseInt(visitFeeStr.trim());
    } catch (NumberFormatException ignored) {}

    if (providerId <= 0 || name.isEmpty() || serviceId <= 0 || rating <= 0 || experienceYears < 0 || visitFee < 0) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("provider_edit.jsp?id=" + providerId + "&error=" + URLEncoder.encode("Please fill in all fields with valid data.", "UTF-8"));
        return;
    }

    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement(
            "UPDATE providers SET name = ?, service_id = ?, rating = ?, experience_years = ?, description = ?, visit_fee = ? " +
            "WHERE id = ?"
        );
        ps.setString(1, name);
        ps.setInt(2, serviceId);
        ps.setDouble(3, rating);
        ps.setInt(4, experienceYears);
        ps.setString(5, description.isEmpty() ? null : description);
        ps.setInt(6, visitFee);
        ps.setInt(7, providerId);

        int updated = ps.executeUpdate();
        ps.close();
        con.close();

        if (updated > 0) {
            response.sendRedirect("providers.jsp?msg=" + URLEncoder.encode("Provider updated successfully.", "UTF-8"));
        } else {
            response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Provider not found.", "UTF-8"));
        }
    } catch (Exception e) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("provider_edit.jsp?id=" + providerId + "&error=" + URLEncoder.encode("Failed to update provider.", "UTF-8"));
    }
%>
