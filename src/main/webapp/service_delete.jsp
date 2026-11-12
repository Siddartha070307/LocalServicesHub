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

    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement("DELETE FROM services WHERE id = ?");
        ps.setInt(1, serviceId);

        int rows = ps.executeUpdate();
        ps.close();
        con.close();

        if (rows > 0) {
            response.sendRedirect("services.jsp?msg=" + URLEncoder.encode("Service deleted successfully.", "UTF-8"));
        } else {
            response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Service not found.", "UTF-8"));
        }

    } catch (SQLException sqle) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        // Foreign key constraint violation check (ORA-02292)
        if (sqle.getErrorCode() == 2292 || (sqle.getMessage() != null && sqle.getMessage().contains("ORA-02292"))) {
            response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Cannot delete: it is still in use", "UTF-8"));
        } else {
            response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Cannot delete: it is still in use", "UTF-8"));
        }
    } catch (Exception e) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("services.jsp?error=" + URLEncoder.encode("Failed to delete service.", "UTF-8"));
    }
%>
