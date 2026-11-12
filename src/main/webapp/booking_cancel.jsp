<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // Ensure user is logged in
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + URLEncoder.encode("Please log in to manage your bookings.", "UTF-8"));
        return;
    }
    int userId = ((Integer) sessionUserId).intValue();
%>
<%@ include file="conn.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String bookingIdStr = request.getParameter("booking_id");
    int bookingId = 0;
    try {
        if (bookingIdStr != null) {
            bookingId = Integer.parseInt(bookingIdStr.trim());
        }
    } catch (NumberFormatException ignored) {}

    if (bookingId <= 0) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("my_bookings.jsp?error=" + URLEncoder.encode("Invalid booking ID.", "UTF-8"));
        return;
    }

    PreparedStatement ps = null;
    try {
        // Marks cancelled ONLY if the booking belongs to the logged-in user
        ps = con.prepareStatement(
            "UPDATE bookings SET status = 'CANCELLED' WHERE id = ? AND user_id = ? AND status <> 'CANCELLED'"
        );
        ps.setInt(1, bookingId);
        ps.setInt(2, userId);

        int updated = ps.executeUpdate();
        ps.close();
        con.close();

        if (updated > 0) {
            response.sendRedirect("my_bookings.jsp?msg=" + URLEncoder.encode("Booking has been successfully cancelled.", "UTF-8"));
        } else {
            response.sendRedirect("my_bookings.jsp?error=" + URLEncoder.encode("Booking could not be cancelled or does not belong to your account.", "UTF-8"));
        }
    } catch (Exception e) {
        try {
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("my_bookings.jsp?error=" + URLEncoder.encode("An error occurred while updating the booking.", "UTF-8"));
    }
%>
