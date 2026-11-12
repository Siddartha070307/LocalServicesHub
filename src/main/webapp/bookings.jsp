<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%
    // Rule 1: At the top of bookings.jsp, if there is no session user, redirect to login.jsp
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + java.net.URLEncoder.encode("Please log in to book a service.", "UTF-8"));
        return;
    }
%>
<%@ include file="conn.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book a Service - Local Services Hub</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .provider-display-box {
            padding: 14px;
            background: #161922;
            border: 1px solid var(--blue);
            border-radius: 8px;
            color: var(--amber);
            font-size: 16px;
            margin-bottom: 5px;
        }
        .provider-display-box strong {
            color: #fff;
            font-size: 18px;
        }
        .change-provider-link {
            display: inline-block;
            font-size: 13px;
            color: var(--blue);
            text-decoration: none;
            margin-top: 4px;
        }
        .change-provider-link:hover {
            text-decoration: underline;
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

<%
    request.setCharacterEncoding("UTF-8");
    int currentUserId = ((Integer) sessionUserId).intValue();

    // Preload user's existing details if available
    String defaultCustomerName = "";
    String defaultPhone = "";
    PreparedStatement psUser = null;
    ResultSet rsUser = null;
    try {
        psUser = con.prepareStatement("SELECT first_name, last_name, phone FROM app_users WHERE id = ?");
        psUser.setInt(1, currentUserId);
        rsUser = psUser.executeQuery();
        if (rsUser.next()) {
            String fn = rsUser.getString("first_name");
            String ln = rsUser.getString("last_name");
            defaultCustomerName = ((fn != null ? fn : "") + " " + (ln != null ? ln : "")).trim();
            defaultPhone = rsUser.getString("phone") != null ? rsUser.getString("phone") : "";
        }
    } catch (SQLException ignored) {
    } finally {
        if (rsUser != null) try { rsUser.close(); } catch (SQLException ignored) {}
        if (psUser != null) try { psUser.close(); } catch (SQLException ignored) {}
    }

    // Determine target provider
    String providerIdParam = request.getParameter("providerId");
    if (providerIdParam == null || providerIdParam.trim().isEmpty()) {
        providerIdParam = request.getParameter("provider_id");
    }

    int providerId = 0;
    if (providerIdParam != null && !providerIdParam.trim().isEmpty()) {
        try {
            providerId = Integer.parseInt(providerIdParam.trim());
        } catch (NumberFormatException e) {
            providerId = 0;
        }
    }

    String providerName = "";
    String serviceName = "";
    int visitFee = 0;

    PreparedStatement psProvider = null;
    ResultSet rsProvider = null;
    try {
        if (providerId > 0) {
            psProvider = con.prepareStatement(
                "SELECT p.id, p.name, s.name AS service_name, p.visit_fee " +
                "FROM providers p " +
                "JOIN services s ON p.service_id = s.id " +
                "WHERE p.id = ?"
            );
            psProvider.setInt(1, providerId);
            rsProvider = psProvider.executeQuery();
            if (rsProvider.next()) {
                providerName = rsProvider.getString("name");
                serviceName = rsProvider.getString("service_name");
                visitFee = rsProvider.getInt("visit_fee");
            } else {
                providerId = 0; // Invalid provider ID
            }
        }

        // If no provider selected yet or invalid, select the first available provider
        if (providerId == 0) {
            if (rsProvider != null) rsProvider.close();
            if (psProvider != null) psProvider.close();

            psProvider = con.prepareStatement(
                "SELECT p.id, p.name, s.name AS service_name, p.visit_fee " +
                "FROM providers p " +
                "JOIN services s ON p.service_id = s.id " +
                "WHERE ROWNUM = 1 ORDER BY p.id"
            );
            rsProvider = psProvider.executeQuery();
            if (rsProvider.next()) {
                providerId = rsProvider.getInt("id");
                providerName = rsProvider.getString("name");
                serviceName = rsProvider.getString("service_name");
                visitFee = rsProvider.getInt("visit_fee");
            }
        }
    } catch (SQLException ignored) {
    } finally {
        if (rsProvider != null) try { rsProvider.close(); } catch (SQLException ignored) {}
        if (psProvider != null) try { psProvider.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }

    String todayStr = LocalDate.now().toString();
%>

<main style="max-width:500px">
    <h2>Book a Service</h2>
    <p class="subtitle">Schedule a verified professional at your doorstep</p>

    <%
        String errorMsg = request.getParameter("error");
        if (errorMsg != null && !errorMsg.trim().isEmpty()) {
    %>
        <div class="alert-error"><%= escapeHtml(errorMsg) %></div>
    <%
        }
    %>

    <form action="booking_process.jsp" method="post" onsubmit="return validateBookingForm()">
        <!-- Provider ID in hidden field and Provider Name displayed -->
        <input type="hidden" id="provider_id" name="provider_id" value="<%= providerId %>">

        <div class="form-group">
            <label>Selected Service Provider</label>
            <div class="provider-display-box">
                <strong><%= escapeHtml(providerName) %></strong> &bull; <%= escapeHtml(serviceName) %>
                <br>
                <span style="font-size: 14px; color: var(--muted);">Standard Visit Fee: ₹<%= visitFee %></span>
            </div>
            <a href="providers.jsp" class="change-provider-link">&larr; Choose a different provider</a>
        </div>

        <div class="form-group">
            <label for="customer_name">Full Name *</label>
            <input type="text" id="customer_name" name="customer_name"
                   placeholder="Enter your full name" required
                   value="<%= escapeHtml(defaultCustomerName) %>">
        </div>

        <div class="form-group">
            <label for="phone">Phone Number *</label>
            <input type="tel" id="phone" name="phone"
                   placeholder="10-digit mobile number" required
                   value="<%= escapeHtml(defaultPhone) %>">
        </div>

        <div class="form-group">
            <label for="address">Service Address *</label>
            <textarea id="address" name="address" rows="3"
                      placeholder="Enter complete address with flat/house no, street, area" required></textarea>
        </div>

        <div class="datetime-group">
            <div class="form-group">
                <label for="booking_date">Booking Date *</label>
                <input type="date" id="booking_date" name="booking_date" min="<%= todayStr %>" required>
            </div>

            <div class="form-group">
                <label for="time">Preferred Time Slot</label>
                <input type="time" id="time" name="time">
            </div>
        </div>

        <div class="form-group">
            <label for="notes">Problem Description / Notes</label>
            <textarea id="notes" name="notes" rows="3" placeholder="Describe the issue or any specific requirements (optional)"></textarea>
        </div>

        <div class="form-group">
            <label class="checkbox-label">
                <input type="checkbox" name="terms" required checked>
                I agree to the Terms & Conditions and understand the visit fee is payable upon service
            </label>
        </div>

        <div class="form-group">
            <button type="submit">Confirm Booking</button>
        </div>
    </form>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>

<script>
function validateBookingForm() {
    let name = document.getElementById("customer_name").value.trim();
    let phone = document.getElementById("phone").value.trim();
    let address = document.getElementById("address").value.trim();
    let bookingDate = document.getElementById("booking_date").value;
    let providerId = document.getElementById("provider_id").value;

    let namePattern = /^[a-zA-Z\s]{3,50}$/; 
    let phonePattern = /^[0-9]{10}$/;       
    let addressPattern = /^.{5,200}$/;      

    if (!providerId || parseInt(providerId) <= 0) {
        alert("Please select a valid provider.");
        return false;
    }
    if (!namePattern.test(name)) {
        alert("Please enter a valid full name (letters only, 3-50 characters).");
        return false;
    }
    if (!phonePattern.test(phone)) {
        alert("Please enter a valid 10-digit phone number.");
        return false;
    }
    if (!addressPattern.test(address)) {
        alert("Please enter a valid address (5-200 characters).");
        return false;
    }
    if (bookingDate === "") {
        alert("Please select a preferred booking date.");
        return false;
    }

    let today = new Date().toISOString().split('T')[0];
    if (bookingDate < today) {
        alert("Booking date cannot be in the past.");
        return false;
    }

    return true;
}
</script>
</body>
</html>
