<%!
    // Small shared helper function to escape user-entered text before printing in HTML
    public static String escapeHtml(Object input) {
        if (input == null) {
            return "";
        }
        String text = String.valueOf(input);
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;");
    }
%>
<header>
    <h1>Local Services Hub</h1>
    <nav>
        <a href="index.jsp">Home</a>
        <a href="services.jsp">Services</a>
        <a href="providers.jsp">Providers</a>
        <a href="bookings.jsp">Book Now</a>
        <a href="about.jsp">About</a>
        <%
            Object navUserIdObj = session.getAttribute("userId");
            String navUserFirstName = (String) session.getAttribute("userFirstName");
            if (navUserIdObj != null && navUserFirstName != null) {
        %>
            <span style="color: var(--amber); margin-right: 15px; font-weight: 600;">Hello <%= escapeHtml(navUserFirstName) %></span>
            <a href="my_bookings.jsp">My Bookings</a>
            <a href="logout.jsp">Logout</a>
        <%
            } else {
        %>
            <a href="login.jsp">Login</a>
            <a href="signup.jsp">Signup</a>
        <%
            }
        %>
    </nav>
</header>
