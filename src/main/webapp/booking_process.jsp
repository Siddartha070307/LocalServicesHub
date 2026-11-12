<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeParseException" %>
<%
    // Ensure user is logged in: user_id comes strictly from the SESSION, never from the form
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + URLEncoder.encode("Please log in to book a service.", "UTF-8"));
        return;
    }
    int userId = ((Integer) sessionUserId).intValue();
%>
<%@ include file="conn.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String providerIdStr = request.getParameter("provider_id");
    String customerName = request.getParameter("customer_name");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String bookingDateStr = request.getParameter("booking_date");
    String timeStr = request.getParameter("time");
    String notes = request.getParameter("notes");

    customerName = (customerName != null) ? customerName.trim() : "";
    phone = (phone != null) ? phone.trim() : "";
    address = (address != null) ? address.trim() : "";
    bookingDateStr = (bookingDateStr != null) ? bookingDateStr.trim() : "";
    timeStr = (timeStr != null) ? timeStr.trim() : "";
    notes = (notes != null) ? notes.trim() : "";

    int providerId = 0;
    try {
        if (providerIdStr != null) {
            providerId = Integer.parseInt(providerIdStr.trim());
        }
    } catch (NumberFormatException ignored) {}

    String validationError = null;

    if (providerId <= 0) {
        validationError = "Invalid service provider selected.";
    } else if (customerName.length() < 3 || customerName.length() > 50) {
        validationError = "Please enter a valid full name between 3 and 50 characters.";
    } else if (!phone.matches("^[0-9]{10}$")) {
        validationError = "Phone number must be exactly 10 digits.";
    } else if (address.length() < 5 || address.length() > 200) {
        validationError = "Please enter a valid address between 5 and 200 characters.";
    } else if (bookingDateStr.isEmpty()) {
        validationError = "Please select a booking date.";
    } else {
        try {
            LocalDate bookingDate = LocalDate.parse(bookingDateStr);
            LocalDate today = LocalDate.now();
            if (bookingDate.isBefore(today)) {
                validationError = "Booking date cannot be in the past.";
            }
        } catch (DateTimeParseException e) {
            validationError = "Invalid booking date format.";
        }
    }

    if (validationError != null) {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
        response.sendRedirect("bookings.jsp?providerId=" + providerId + "&error=" + URLEncoder.encode(validationError, "UTF-8"));
        return;
    }

    PreparedStatement psCheck = null;
    ResultSet rsCheck = null;
    PreparedStatement psInsert = null;

    try {
        // Validate that provider exists in database
        psCheck = con.prepareStatement("SELECT id FROM providers WHERE id = ?");
        psCheck.setInt(1, providerId);
        rsCheck = psCheck.executeQuery();

        if (!rsCheck.next()) {
            rsCheck.close();
            psCheck.close();
            con.close();
            response.sendRedirect("bookings.jsp?error=" + URLEncoder.encode("Selected provider no longer exists.", "UTF-8"));
            return;
        }

        // Combine notes with time slot if provided
        String fullNotes = notes;
        if (!timeStr.isEmpty()) {
            fullNotes = "Preferred Time: " + timeStr + (notes.isEmpty() ? "" : " | " + notes);
        }
        if (fullNotes.length() > 500) {
            fullNotes = fullNotes.substring(0, 500);
        }

        // Insert booking (trigger generates id and created_at)
        psInsert = con.prepareStatement(
            "INSERT INTO bookings (user_id, provider_id, customer_name, phone, address, booking_date, notes, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')"
        );
        psInsert.setInt(1, userId);
        psInsert.setInt(2, providerId);
        psInsert.setString(3, customerName);
        psInsert.setString(4, phone);
        psInsert.setString(5, address);
        psInsert.setDate(6, java.sql.Date.valueOf(bookingDateStr));
        psInsert.setString(7, fullNotes.isEmpty() ? null : fullNotes);

        psInsert.executeUpdate();

        // Close resources
        if (rsCheck != null) rsCheck.close();
        if (psCheck != null) psCheck.close();
        if (psInsert != null) psInsert.close();
        if (con != null) con.close();

        // Redirect to my_bookings.jsp with friendly success message
        response.sendRedirect("my_bookings.jsp?msg=" + URLEncoder.encode("Booking requested successfully! Your booking is currently PENDING.", "UTF-8"));

    } catch (Exception e) {
        try {
            if (rsCheck != null) rsCheck.close();
            if (psCheck != null) psCheck.close();
            if (psInsert != null) psInsert.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        response.sendRedirect("bookings.jsp?providerId=" + providerId + "&error=" + URLEncoder.encode("An error occurred while saving your booking. Please try again.", "UTF-8"));
    }
%>
