<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="conn.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Service Providers - Local Services Hub</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .filter-buttons {
            flex-wrap: wrap;
        }
        .filter-btn-active {
            background: var(--amber) !important;
            border-color: var(--amber) !important;
            color: black !important;
        }
        .filter-btn-inactive {
            background: transparent !important;
            border: 2px solid var(--blue) !important;
            color: var(--blue) !important;
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

<%!
    // Helper class to store service options for filter buttons
    public static class ServiceOption {
        public int id;
        public String name;
        public ServiceOption(int id, String name) {
            this.id = id;
            this.name = name;
        }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String serviceParam = request.getParameter("service");
    int filterServiceId = 0;
    if (serviceParam != null && !serviceParam.trim().isEmpty()) {
        try {
            filterServiceId = Integer.parseInt(serviceParam.trim());
        } catch (NumberFormatException e) {
            filterServiceId = 0;
        }
    }

    // Load services for filter buttons
    Statement stmtServices = null;
    ResultSet rsServices = null;
    PreparedStatement psProviders = null;
    ResultSet rsProviders = null;

    List<ServiceOption> serviceList = new ArrayList<ServiceOption>();

    try {
        stmtServices = con.createStatement();
        rsServices = stmtServices.executeQuery("SELECT id, name FROM services ORDER BY id");
        while (rsServices.next()) {
            serviceList.add(new ServiceOption(rsServices.getInt("id"), rsServices.getString("name")));
        }
        rsServices.close();
        stmtServices.close();

        // Query providers (with service name joined)
        if (filterServiceId > 0) {
            psProviders = con.prepareStatement(
                "SELECT p.id, p.name, p.service_id, s.name AS service_name, p.rating, " +
                "p.experience_years, p.description, p.visit_fee " +
                "FROM providers p " +
                "JOIN services s ON p.service_id = s.id " +
                "WHERE p.service_id = ? " +
                "ORDER BY p.id"
            );
            psProviders.setInt(1, filterServiceId);
        } else {
            psProviders = con.prepareStatement(
                "SELECT p.id, p.name, p.service_id, s.name AS service_name, p.rating, " +
                "p.experience_years, p.description, p.visit_fee " +
                "FROM providers p " +
                "JOIN services s ON p.service_id = s.id " +
                "ORDER BY p.id"
            );
        }
        rsProviders = psProviders.executeQuery();
%>

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
            <h3>Service Providers</h3>
            <p>Select Service Provider You Require</p>
            <% if (isUserLoggedIn) { %>
                <button onclick="window.location.href='provider_add.jsp'" style="margin-top: 15px;">+ Add New Provider</button>
            <% } %>
        </section>

        <section class="filter-bar">
            <h3>Filter by Service</h3>
            <div class="filter-buttons">
                <button class="<%= (filterServiceId == 0) ? "filter-btn-active" : "filter-btn-inactive" %>"
                        onclick="window.location.href='providers.jsp'">All</button>
                <%
                    for (ServiceOption s : serviceList) {
                        boolean isSelected = (filterServiceId == s.id);
                %>
                    <button class="<%= isSelected ? "filter-btn-active" : "filter-btn-inactive" %>"
                            onclick="window.location.href='providers.jsp?service=<%= s.id %>'">
                        <%= escapeHtml(s.name) %>
                    </button>
                <%
                    }
                %>
            </div>
        </section>

        <section class="providers-grid">
            <%
                boolean hasProviders = false;
                while (rsProviders.next()) {
                    hasProviders = true;
                    int pId = rsProviders.getInt("id");
                    String pName = rsProviders.getString("name");
                    String sName = rsProviders.getString("service_name");
                    double pRating = rsProviders.getDouble("rating");
                    int pExp = rsProviders.getInt("experience_years");
                    String pDesc = rsProviders.getString("description");
                    int pFee = rsProviders.getInt("visit_fee");
            %>
                <article class="provider-card">
                    <h4><%= escapeHtml(pName) %></h4>
                    <p><%= escapeHtml(sName) %></p>
                    <p>⭐ <%= String.format(Locale.US, "%.1f", pRating) %></p>
                    <p><%= pExp %> years experience</p>
                    <p><%= escapeHtml(pDesc != null ? pDesc : "") %></p>
                    <p>Visit Fee: ₹<%= pFee %></p>
                    <button onclick="window.location.href='bookings.jsp?providerId=<%= pId %>'">Book This Provider</button>

                    <% if (isUserLoggedIn) { %>
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <button style="flex: 1; padding: 8px 10px; background: transparent; border: 1px solid var(--blue); color: var(--blue); border-radius: 6px; cursor: pointer;"
                                    onclick="window.location.href='provider_edit.jsp?id=<%= pId %>'">Edit</button>
                            <form action="provider_delete.jsp" method="post" style="flex: 1; margin: 0; padding: 0; background: transparent; border: none;">
                                <input type="hidden" name="id" value="<%= pId %>">
                                <button type="submit" style="width: 100%; padding: 8px 10px; background: transparent; border: 1px solid #f44336; color: #ff8a80; border-radius: 6px; cursor: pointer;"
                                        onclick="return confirm('Are you sure you want to delete this provider?');">Delete</button>
                            </form>
                        </div>
                    <% } %>
                </article>
            <%
                }
                if (!hasProviders) {
            %>
                <p style="grid-column: 1 / -1; text-align: center; color: var(--muted); padding: 40px; font-size: 16px;">
                    No providers found for this service.
                </p>
            <%
                }
            %>
        </section>
    </main>

<%
    } catch (Exception e) {
%>
    <main>
        <p style="text-align: center; color: #ff8a80; padding: 40px;">
            Unable to load providers at this time. Please try again later.
        </p>
    </main>
<%
    } finally {
        if (rsProviders != null) try { rsProviders.close(); } catch (SQLException ignored) {}
        if (psProviders != null) try { psProviders.close(); } catch (SQLException ignored) {}
        if (rsServices != null) try { rsServices.close(); } catch (SQLException ignored) {}
        if (stmtServices != null) try { stmtServices.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }
%>

    <footer>
        <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
    </footer>
</body>
</html>
