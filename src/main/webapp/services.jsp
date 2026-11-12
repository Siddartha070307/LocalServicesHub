<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="conn.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Services - Local Services Hub</title>
    <style>
        :root{
            --bg:#0f1115;
             --card: #1a1d24;
             --amber:#ffb300;
             --amber-hover:#ffca28;
             --blue:#2196f3;
             --text:#eaeaea;
            --muted:#9aa0a6;
        }
        body {
           background: var(--bg);
           color: var(--text);
           line-height: 1.6;
        }
        header {
           background: rgb(20,22,28);
           padding: 20px;
           border-bottom: 1px solid black;
        }
        h1{
            color:var(--amber);
        }
        nav{
             margin-top: 10px;
        }
        nav a{
            color:var(--text);
            text-decoration: none;
            transition: 0.3s;
            margin-right: 8px;
        }
        nav a:hover{
            color:var(--blue);
        }
        section{
            padding: 10px;
            text-align: center;
        }
        h2{
            color: var(--amber);
            margin-bottom: 20px;
            font-weight: 600;
        }
        button{
            padding:10px 20px;
            border-radius: 10px;
            border:none;
            cursor: pointer;
            font-weight: 600;
            transition: 0.3s ease;
            background: var(--amber);
            color: black;
        }
        button:hover{
            background:var(--amber-hover);
            transform: translateY(-2px);
        }
        input[type="text"] {
          padding: 12px 15px;
          width: 280px;
          border-radius: 8px;
          border: 1px solid #333;
         background: #161922;
         color: var(--amber);
         outline: none;
         margin-right: 10px;
}

       input[type="text"]:focus {
           border-color: var(--blue);
       }
        section:nth-of-type(2) {
             display: flex;
             justify-content: center;
             flex-wrap: wrap;
             gap: 25px;
        }
        section:nth-of-type(2) > div{
            background: var(--card);
            padding: 25px;
            width: 200px;
            border-radius: 10px;
            border: 1px solid black;
            transition: 0.3s ease;
        }
        section:nth-of-type(2) > div:hover {
             border-color: var(--blue);
             transform: translateY(-5px);
        }
        section:nth-of-type(2) button:hover {
              background: var(--blue);
               color: white;
            }
         section:nth-of-type(2) h3{
            color:var(--blue);
            margin-bottom: 10px;
        }
        section:nth-of-type(2) button{
            border: 2px solid var(--blue);
            background: transparent;
            color: var(--blue);
           border-radius: 20px;
        }

        section:nth-of-type(3) {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
        }

        section:nth-of-type(3) div {
             background: var(--card);
             padding: 25px;
             border-radius: 12px;
             border: 1px solid #222;
             transition: 0.3s;
        }

        section:nth-of-type(3) button {
                margin-top: 15px;
                width: 100%;
            }

        section:nth-of-type(3) div:hover {
           border-color: var(--blue);
           transform: translateY(-5px);
        }
        span{
            background:var(--blue);
            color:white;
            padding:5px 10px;
            border-radius: 10px;
            font-size:12px
        }
        h3 {
          color: var(--amber);
          margin: 10px 0;
        }
        footer{
            background: rgb(58, 50, 91);
            text-align: center;
            padding: 20px;
            color: var(--muted);
            border-top: 2px solid var(--amber);
        }
        .price{
            background:transparent;
            color: var(--amber);
            font-weight: 700;
            font-size: 18px;
            padding: 0;
        }

    </style>
</head>
<body>

<%@ include file="header.jsp" %>

    <main>

        <%
            // Note: There are no user roles and the schema must not change, so any logged-in user can manage services and providers.
            boolean isUserLoggedIn = (session.getAttribute("userId") != null);
            String successMsg = request.getParameter("msg");
            if (successMsg != null && !successMsg.trim().isEmpty()) {
        %>
            <div style="background: rgba(76, 175, 80, 0.15); border: 1px solid #4caf50; color: #81c784; padding: 12px; border-radius: 8px; margin: 20px auto; max-width: 800px; text-align: center;">
                <%= escapeHtml(successMsg) %>
            </div>
        <%
            }
            String errorMsg = request.getParameter("error");
            if (errorMsg != null && !errorMsg.trim().isEmpty()) {
        %>
            <div style="background: rgba(244, 67, 54, 0.15); border: 1px solid #f44336; color: #ff8a80; padding: 12px; border-radius: 8px; margin: 20px auto; max-width: 800px; text-align: center;">
                <%= escapeHtml(errorMsg) %>
            </div>
        <%
            }
        %>

        <section>
            <h2>Our Services</h2>
            <p>Browse all available home services delivered by verified professionals.</p>
            <% if (isUserLoggedIn) { %>
                <button onclick="window.location.href='service_add.jsp'">+ Add New Service</button>
            <% } %>
        </section>

        <section>
            <button onclick="window.location.href='services.jsp'">All</button>
            <button onclick="window.location.href='services.jsp'">Construction</button>
            <button onclick="window.location.href='services.jsp'">Maintenance</button>
            <button onclick="window.location.href='services.jsp'">Automotive</button>
            <button onclick="window.location.href='services.jsp'">Cleaning</button>
        </section>

        <section>
<%
    String searchParam = request.getParameter("search");
    boolean isSearching = (searchParam != null && !searchParam.trim().isEmpty());
    PreparedStatement psServices = null;
    ResultSet rs = null;

    if (isSearching) {
%>
        <div style="grid-column: 1 / -1; text-align: center; margin-bottom: 20px;">
            <p style="color: var(--muted); display: inline-block;">
                Showing search results for "<strong style="color: var(--amber);"><%= escapeHtml(searchParam.trim()) %></strong>"
            </p>
            <a href="services.jsp" style="color: var(--blue); margin-left: 10px; text-decoration: none; font-weight: 600;">&times; Clear Search</a>
        </div>
<%
        psServices = con.prepareStatement(
            "SELECT id, category, name, description, price_range FROM services WHERE LOWER(name) LIKE ? ORDER BY id"
        );
        psServices.setString(1, "%" + searchParam.trim().toLowerCase() + "%");
        rs = psServices.executeQuery();
    } else {
        psServices = con.prepareStatement(
            "SELECT id, category, name, description, price_range FROM services ORDER BY id"
        );
        rs = psServices.executeQuery();
    }

    boolean hasServices = false;
    while (rs.next()) {
        hasServices = true;
        int sId = rs.getInt("id");
%>
            <div>
                <span><%= escapeHtml(rs.getString("category")) %></span>
                <h3><%= escapeHtml(rs.getString("name")) %></h3>
                <p><%= escapeHtml(rs.getString("description")) %></p>
                <span class="price">₹<%= escapeHtml(rs.getString("price_range")) %></span>
                <button onclick="window.location.href='providers.jsp?service=<%= sId %>'">Book Now</button>

                <% if (isUserLoggedIn) { %>
                    <div style="display: flex; gap: 8px; margin-top: 10px;">
                        <button style="flex: 1; padding: 8px 10px; background: transparent; border: 1px solid var(--blue); color: var(--blue); border-radius: 6px; cursor: pointer;"
                                onclick="window.location.href='service_edit.jsp?id=<%= sId %>'">Edit</button>
                        <form action="service_delete.jsp" method="post" style="flex: 1; margin: 0; padding: 0; background: transparent; border: none;">
                            <input type="hidden" name="id" value="<%= sId %>">
                            <button type="submit" style="width: 100%; padding: 8px 10px; background: transparent; border: 1px solid #f44336; color: #ff8a80; border-radius: 6px; cursor: pointer;"
                                    onclick="return confirm('Are you sure you want to delete this service?');">Delete</button>
                        </form>
                    </div>
                <% } %>
            </div>
<%
    }
    if (!hasServices) {
%>
            <p style="grid-column: 1 / -1; text-align: center; color: var(--muted); padding: 40px; font-size: 16px;">
                No services found matching "<%= escapeHtml(searchParam != null ? searchParam : "") %>".
                <br><br>
                <a href="services.jsp" style="color: var(--amber); text-decoration: underline;">View all services</a>
            </p>
<%
    }
    if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
    if (psServices != null) try { psServices.close(); } catch (SQLException ignored) {}
    if (con != null) try { con.close(); } catch (SQLException ignored) {}
%>
        </section>
    </main>

    <footer>
        <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
    </footer>
</body>
</html>
