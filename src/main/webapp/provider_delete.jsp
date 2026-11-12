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

    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement("DELETE FROM providers WHERE id = ?");
        ps.setInt(1, providerId);

        int rows = ps.executeUpdate();
        ps.close();
        con.close();

        if (rows > 0) {
            response.sendRedirect("providers.jsp?msg=" + URLEncoder.encode("Provider deleted successfully.", "UTF-8"));
        } else {
            response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Provider not found.", "UTF-8"));
        }

    } catch (SQLException sqle) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        // Foreign key constraint violation check (ORA-02292)
        if (sqle.getErrorCode() == 2292 || (sqle.getMessage() != null && sqle.getMessage().contains("ORA-02292"))) {
            response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Cannot delete: it is still in use", "UTF-8"));
        } else {
            response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Cannot delete: it is still in use", "UTF-8"));
        }
    } catch (Exception e) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("providers.jsp?error=" + URLEncoder.encode("Failed to delete provider.", "UTF-8"));
    }
%>
