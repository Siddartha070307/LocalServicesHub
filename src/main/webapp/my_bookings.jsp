<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Ensure user is logged in
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp?msg=" + java.net.URLEncoder.encode("Please log in to view your bookings.", "UTF-8"));
        return;
    }
    int userId = ((Integer) sessionUserId).intValue();
%>
<%@ include file="conn.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Bookings - Local Services Hub</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .bookings-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
        }
        .booking-card {
            background: var(--card);
            border: 1px solid #222;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            transition: 0.3s ease;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        .booking-card:hover {
            border-color: var(--blue);
        }
        .booking-info h4 {
            color: var(--amber);
            font-size: 20px;
            margin: 0 0 8px 0;
        }
        .booking-info p {
            margin: 4px 0;
            color: var(--muted);
            font-size: 14px;
            text-align: left;
        }
        .booking-info strong {
            color: var(--text);
        }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-pending {
            background: rgba(255, 179, 0, 0.15);
            color: var(--amber);
            border: 1px solid var(--amber);
        }
        .status-confirmed {
            background: rgba(76, 175, 80, 0.15);
            color: #81c784;
            border: 1px solid #4caf50;
        }
        .status-cancelled {
            background: rgba(244, 67, 54, 0.15);
            color: #ff8a80;
            border: 1px solid #f44336;
        }
        .btn-cancel {
            background: transparent;
            color: #ff8a80;
            border: 1px solid #f44336;
            padding: 8px 18px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.3s;
            width: auto;
        }
        .btn-cancel:hover {
            background: #f44336;
            color: white;
            transform: translateY(-2px);
        }
        .alert-success {
            background: rgba(76, 175, 80, 0.15);
            border: 1px solid #4caf50;
            color: #81c784;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 25px;
            text-align: center;
        }
        .alert-error {
            background: rgba(244, 67, 54, 0.15);
            border: 1px solid #f44336;
            color: #ff8a80;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 25px;
            text-align: center;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: var(--card);
            border-radius: 12px;
            border: 1px solid #222;
        }
        .empty-state p {
            color: var(--muted);
            margin-bottom: 20px;
        }
        .btn-book-now {
            display: inline-block;
            background: var(--amber);
            color: black;
            padding: 12px 28px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: 0.3s;
        }
        .btn-book-now:hover {
            background: var(--amber-hover);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>

<main class="bookings-container">
    <section>
        <h2>My Bookings</h2>
        <p>Review and manage all your requested and confirmed service bookings</p>
    </section>

    <%
        String msg = request.getParameter("msg");
        if (msg != null && !msg.trim().isEmpty()) {
    %>
        <div class="alert-success"><%= escapeHtml(msg) %></div>
    <%
        }
        String error = request.getParameter("error");
        if (error != null && !error.trim().isEmpty()) {
    %>
        <div class="alert-error"><%= escapeHtml(error) %></div>
    <%
        }
    %>

    <%
        PreparedStatement ps = null;
        ResultSet rs = null;
        SimpleDateFormat sdf = new SimpleDateFormat("EEEE, dd MMM yyyy");
        boolean hasBookings = false;

        try {
            // Query only the logged-in user's bookings joined with provider and service
            ps = con.prepareStatement(
                "SELECT b.id, b.customer_name, b.phone, b.address, b.booking_date, " +
                "b.notes, b.status, p.name AS provider_name, s.name AS service_name, p.visit_fee " +
                "FROM bookings b " +
                "JOIN providers p ON b.provider_id = p.id " +
                "JOIN services s ON p.service_id = s.id " +
                "WHERE b.user_id = ? " +
                "ORDER BY b.id DESC"
            );
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                hasBookings = true;
                int bookingId = rs.getInt("id");
                String providerName = rs.getString("provider_name");
                String serviceName = rs.getString("service_name");
                Date bookingDate = rs.getDate("booking_date");
                String formattedDate = (bookingDate != null) ? sdf.format(bookingDate) : "N/A";
                String address = rs.getString("address");
                String status = rs.getString("status");
                if (status == null) status = "PENDING";
                String notes = rs.getString("notes");
                int visitFee = rs.getInt("visit_fee");

                String statusClass = "status-pending";
                if ("CONFIRMED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status)) {
                    statusClass = "status-confirmed";
                } else if ("CANCELLED".equalsIgnoreCase(status)) {
                    statusClass = "status-cancelled";
                }
    %>
        <article class="booking-card">
            <div class="booking-info">
                <h4><%= escapeHtml(providerName) %> &bull; <span style="font-size: 16px; color: var(--blue);"><%= escapeHtml(serviceName) %></span></h4>
                <p><strong>Date:</strong> <%= formattedDate %></p>
                <p><strong>Address:</strong> <%= escapeHtml(address) %></p>
                <p><strong>Visit Fee:</strong> ₹<%= visitFee %></p>
                <% if (notes != null && !notes.trim().isEmpty()) { %>
                    <p><strong>Notes:</strong> <%= escapeHtml(notes) %></p>
                <% } %>
            </div>

            <div style="text-align: right; display: flex; flex-direction: column; align-items: flex-end; gap: 15px;">
                <span class="status-badge <%= statusClass %>"><%= escapeHtml(status) %></span>

                <% if (!"CANCELLED".equalsIgnoreCase(status)) { %>
                    <form action="booking_cancel.jsp" method="post" style="margin: 0; padding: 0; background: transparent; border: none;">
                        <input type="hidden" name="booking_id" value="<%= bookingId %>">
                        <button type="submit" class="btn-cancel" onclick="return confirm('Are you sure you want to cancel this booking?');">
                            Cancel Booking
                        </button>
                    </form>
                <% } %>
            </div>
        </article>
    <%
            }

            if (!hasBookings) {
    %>
        <div class="empty-state">
            <h3>No Bookings Found</h3>
            <p>You have not booked any local services yet.</p>
            <a href="providers.jsp" class="btn-book-now">Explore Providers & Book Now</a>
        </div>
    <%
            }

        } catch (Exception e) {
    %>
        <div class="alert-error">Unable to retrieve your bookings at this time. Please try again later.</div>
    <%
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
            if (con != null) try { con.close(); } catch (SQLException ignored) {}
        }
    %>
</main>

<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>
</body>
</html>
