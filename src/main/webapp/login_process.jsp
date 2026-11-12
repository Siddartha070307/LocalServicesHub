<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ include file="conn.jsp" %>
<%
    // Set character encoding
    request.setCharacterEncoding("UTF-8");

    String email = request.getParameter("email");
    String password = request.getParameter("password");

    email = (email != null) ? email.trim() : "";
    password = (password != null) ? password : "";

    // If empty input, reject immediately
    if (email.isEmpty() || password.isEmpty()) {
        if (con != null) con.close();
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("Invalid email or password.", "UTF-8"));
        return;
    }

    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // Query user by email (case-insensitive)
        ps = con.prepareStatement("SELECT id, first_name, password_hash FROM app_users WHERE LOWER(email) = LOWER(?)");
        ps.setString(1, email);
        rs = ps.executeQuery();

        if (rs.next()) {
            int userId = rs.getInt("id");
            String firstName = rs.getString("first_name");
            String storedHash = rs.getString("password_hash");

            // Verify password using BCrypt
            if (storedHash != null && BCrypt.checkpw(password, storedHash)) {
                // Invalidate any existing session to prevent session fixation attacks
                session.invalidate();

                // Create fresh new session
                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("userId", userId);
                newSession.setAttribute("userFirstName", firstName);

                rs.close();
                ps.close();
                con.close();

                // Redirect to services.jsp
                response.sendRedirect("services.jsp");
                return;
            }
        }

        // Close resources before failure redirect
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();

        // Generic failure message
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("Invalid email or password.", "UTF-8"));

    } catch (Exception e) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (SQLException ignored) {}

        // Friendly error message, never show stack trace
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("Invalid email or password.", "UTF-8"));
    }
%>
