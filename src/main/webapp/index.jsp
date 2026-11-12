<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="conn.jsp" %>
<%!
    // Small helper so text from the database cannot break the HTML.
    // It is named homeEsc so it cannot clash with a method in another file.
    private static String homeEsc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // The Sign Up band is hidden when the visitor is logged in.
    // "userId" must be the same session name that login_process.jsp sets.
    boolean homeLoggedIn = (session.getAttribute("userId") != null);

    int totalServices = 0;
    int totalProviders = 0;
    int totalBookings = 0;

    // Each row is stored as a small String array so the HTML below stays simple.
    List<String[]> popularServices = new ArrayList<String[]>();
    List<String[]> topProviders = new ArrayList<String[]>();
    String loadError = null;

    Statement homeStmt = null;
    ResultSet homeRs = null;
    try {
        homeStmt = con.createStatement();

        // Stats strip
        homeRs = homeStmt.executeQuery("SELECT COUNT(*) FROM services");
        if (homeRs.next()) totalServices = homeRs.getInt(1);
        homeRs.close();

        homeRs = homeStmt.executeQuery("SELECT COUNT(*) FROM providers");
        if (homeRs.next()) totalProviders = homeRs.getInt(1);
        homeRs.close();

        homeRs = homeStmt.executeQuery("SELECT COUNT(*) FROM bookings");
        if (homeRs.next()) totalBookings = homeRs.getInt(1);
        homeRs.close();

        // Popular services: first 6 rows (Oracle 10g uses ROWNUM, not LIMIT)
        homeRs = homeStmt.executeQuery(
            "SELECT * FROM (" +
            " SELECT id, category, name, description, price_range FROM services ORDER BY id" +
            ") WHERE ROWNUM <= 6");
        while (homeRs.next()) {
            popularServices.add(new String[] {
                String.valueOf(homeRs.getInt("id")),
                homeRs.getString("category"),
                homeRs.getString("name"),
                homeRs.getString("description"),
                homeRs.getString("price_range")
            });
        }
        homeRs.close();

        // Top-rated providers: best 3 by rating (NULLS LAST keeps unrated ones at the end)
        homeRs = homeStmt.executeQuery(
            "SELECT * FROM (" +
            " SELECT p.id, p.name, s.name AS service_name, p.rating, p.experience_years," +
            " p.description, p.visit_fee" +
            " FROM providers p JOIN services s ON p.service_id = s.id" +
            " ORDER BY p.rating DESC NULLS LAST, p.id" +
            ") WHERE ROWNUM <= 3");
        while (homeRs.next()) {
            double ratingValue = homeRs.getDouble("rating");
            String ratingText = homeRs.wasNull() ? "New" : String.format(Locale.US, "%.1f", ratingValue);
            topProviders.add(new String[] {
                String.valueOf(homeRs.getInt("id")),
                homeRs.getString("name"),
                homeRs.getString("service_name"),
                ratingText,
                homeRs.getString("experience_years"),
                homeRs.getString("description"),
                homeRs.getString("visit_fee")
            });
        }
        homeRs.close();

    } catch (Exception loadEx) {
        loadError = "Unable to load all home page details right now. Please refresh or try again later.";
    } finally {
        if (homeRs != null) try { homeRs.close(); } catch (SQLException ignored) {}
        if (homeStmt != null) try { homeStmt.close(); } catch (SQLException ignored) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Local Services Hub - Book Trusted Home Services</title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* Styles for the home page only. They use the colours already in style.css. */
        .home-container { max-width: 1200px; margin: 0 auto; padding: 0 20px 40px; }

        .hero-section {
            text-align: center;
            padding: 70px 20px;
            margin-top: 20px;
            border-radius: 16px;
            border: 1px solid #222;
            background: linear-gradient(135deg, #1a1d24 0%, #14161c 100%);
        }
        .hero-title { font-size: 2.6rem; color: var(--amber, #ffb300); margin: 0 0 10px; }
        .hero-subtitle { color: var(--muted, #9aa0a6); font-size: 1.1rem; margin: 0 0 25px; }
        .hero-search-form { display: flex; justify-content: center; flex-wrap: wrap; gap: 10px; }
        .hero-search-input {
            padding: 12px 15px; width: 480px; max-width: 100%;
            border-radius: 8px; border: 1px solid #333;
            background: #161922; color: var(--text, #eaeaea); outline: none;
        }
        .hero-search-input:focus { border-color: var(--blue, #2196f3); }
        .hero-search-btn {
            padding: 12px 22px; border: none; border-radius: 8px; cursor: pointer;
            font-weight: 600; background: var(--amber, #ffb300); color: black;
        }
        .hero-search-btn:hover { background: var(--amber-hover, #ffca28); }
        .hero-actions { margin-top: 22px; display: flex; justify-content: center; flex-wrap: wrap; gap: 12px; }
        .btn-hero-primary, .btn-hero-secondary, .btn-cta, .btn-card {
            display: inline-block; text-decoration: none; font-weight: 600;
            border-radius: 10px; transition: 0.3s ease;
        }
        .btn-hero-primary { padding: 12px 26px; background: var(--amber, #ffb300); color: black; }
        .btn-hero-primary:hover { background: var(--amber-hover, #ffca28); transform: translateY(-2px); }
        .btn-hero-secondary {
            padding: 10px 24px; border: 2px solid var(--blue, #2196f3); color: var(--blue, #2196f3);
        }
        .btn-hero-secondary:hover { background: var(--blue, #2196f3); color: white; transform: translateY(-2px); }

        .stats-strip { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-top: 30px; }
        .stat-card {
            background: var(--card, #1a1d24); border: 1px solid #222;
            border-radius: 12px; padding: 22px; text-align: center;
        }
        .stat-number { font-size: 2.2rem; font-weight: 700; color: var(--amber, #ffb300); }
        .stat-label { color: var(--muted, #9aa0a6); }

        .home-section { margin-top: 55px; text-align: center; }
        .home-section h2 { color: var(--amber, #ffb300); margin-bottom: 6px; }
        .section-subtitle { color: var(--muted, #9aa0a6); margin: 0 0 25px; }
        .empty-msg { grid-column: 1 / -1; color: var(--muted, #9aa0a6); padding: 30px; }
        .error-msg { text-align: center; color: #ff8a80; padding: 20px; }

        .home-services-grid, .home-provider-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 22px; text-align: left;
        }
        .home-service-card, .home-provider-card {
            background: var(--card, #1a1d24); border: 1px solid #222; border-radius: 12px;
            padding: 22px; transition: 0.3s ease;
            display: flex; flex-direction: column; justify-content: space-between;
        }
        .home-service-card:hover, .home-provider-card:hover {
            border-color: var(--blue, #2196f3); transform: translateY(-5px);
        }
        .home-service-card h3, .home-provider-card h3 { color: var(--amber, #ffb300); margin: 10px 0; }
        .home-service-card p, .home-provider-card p { margin: 6px 0; }
        .category-pill {
            display: inline-block; background: var(--blue, #2196f3); color: white;
            padding: 4px 10px; border-radius: 10px; font-size: 12px;
        }
        .price-row { display: flex; justify-content: space-between; align-items: center; margin-top: 15px; gap: 10px; flex-wrap: wrap; }
        .price-text { color: var(--amber, #ffb300); font-weight: 700; }
        .btn-card {
            padding: 8px 16px; border: 2px solid var(--blue, #2196f3);
            color: var(--blue, #2196f3); font-size: 14px;
        }
        .btn-card:hover { background: var(--blue, #2196f3); color: white; }
        .provider-service { color: var(--blue, #2196f3); font-weight: 600; }

        .steps-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .features-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        .step-card, .feature-card {
            background: var(--card, #1a1d24); border: 1px solid #222; border-radius: 12px;
            padding: 24px; transition: 0.3s ease;
        }
        .step-card:hover, .feature-card:hover { border-color: var(--blue, #2196f3); transform: translateY(-5px); }
        .step-card h3, .feature-card h3 { color: var(--amber, #ffb300); margin: 10px 0; }
        .step-card p, .feature-card p { color: var(--muted, #9aa0a6); margin: 0; }
        .step-number {
            width: 42px; height: 42px; line-height: 42px; margin: 0 auto;
            border-radius: 50%; background: var(--amber, #ffb300); color: black; font-weight: 700;
        }
        .feature-icon { font-size: 2rem; }

        .cta-band {
            margin-top: 55px; text-align: center; padding: 45px 20px; border-radius: 16px;
            border: 1px solid #222; background: linear-gradient(135deg, #1a1d24 0%, #232733 100%);
        }
        .cta-band h2 { color: var(--amber, #ffb300); margin-top: 0; }
        .cta-band p { color: var(--muted, #9aa0a6); }
        .btn-cta { padding: 12px 28px; background: var(--amber, #ffb300); color: black; }
        .btn-cta:hover { background: var(--amber-hover, #ffca28); transform: translateY(-2px); }

        /* Tablets */
        @media (max-width: 900px) {
            .home-services-grid, .home-provider-grid, .features-grid { grid-template-columns: repeat(2, 1fr); }
            .steps-grid { grid-template-columns: repeat(2, 1fr); }
        }
        /* Phones */
        @media (max-width: 600px) {
            .hero-title { font-size: 1.8rem; }
            .home-services-grid, .home-provider-grid, .features-grid,
            .steps-grid, .stats-strip { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

<main class="home-container">

    <% if (loadError != null) { %>
        <p class="error-msg"><%= homeEsc(loadError) %></p>
    <% } %>

    <!-- 1. HERO -->
    <section class="hero-section">
        <h1 class="hero-title">Book Trusted Home Services Near You</h1>
        <p class="hero-subtitle">Plumbers, Electricians, Carpenters, Mechanics and more &mdash; at your doorstep.</p>

        <form action="services.jsp" method="get" class="hero-search-form">
            <input type="text" name="search" class="hero-search-input"
                   placeholder="Search for a service (e.g. Plumbing, Electrical, AC Repair)" required>
            <button type="submit" class="hero-search-btn">Search</button>
        </form>

        <div class="hero-actions">
            <a href="bookings.jsp" class="btn-hero-primary">Book a Service</a>
            <a href="providers.jsp" class="btn-hero-secondary">Find Providers</a>
        </div>
    </section>

    <!-- 2. STATS -->
    <section class="stats-strip">
        <div class="stat-card">
            <div class="stat-number"><%= totalServices %></div>
            <div class="stat-label">Services</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= totalProviders %></div>
            <div class="stat-label">Providers</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= totalBookings %></div>
            <div class="stat-label">Bookings Made</div>
        </div>
    </section>

    <!-- 3. POPULAR SERVICES -->
    <section class="home-section">
        <h2>Popular Services</h2>
        <p class="section-subtitle">Explore our most requested home services</p>

        <div class="home-services-grid">
            <% if (popularServices.isEmpty()) { %>
                <p class="empty-msg">No services available yet.</p>
            <% } else {
                   for (String[] sv : popularServices) { %>
                <article class="home-service-card">
                    <div>
                        <span class="category-pill"><%= homeEsc(sv[1] != null ? sv[1] : "General") %></span>
                        <h3><%= homeEsc(sv[2]) %></h3>
                        <p><%= homeEsc(sv[3]) %></p>
                    </div>
                    <div class="price-row">
                        <span class="price-text"><%= sv[4] != null ? "&#8377;" + homeEsc(sv[4]) : "Contact for quote" %></span>
                        <a href="providers.jsp?service=<%= sv[0] %>" class="btn-card">Find Providers &rarr;</a>
                    </div>
                </article>
            <%     }
               } %>
        </div>
    </section>

    <!-- 4. TOP-RATED PROVIDERS -->
    <section class="home-section">
        <h2>Top-Rated Providers</h2>
        <p class="section-subtitle">Our highest-rated local professionals</p>

        <div class="home-provider-grid">
            <% if (topProviders.isEmpty()) { %>
                <p class="empty-msg">No providers available yet.</p>
            <% } else {
                   for (String[] pv : topProviders) { %>
                <article class="home-provider-card">
                    <div>
                        <h3><%= homeEsc(pv[1]) %></h3>
                        <p class="provider-service"><%= homeEsc(pv[2]) %></p>
                        <p>&#11088; <%= homeEsc(pv[3]) %></p>
                        <p><%= homeEsc(pv[4]) %> years experience</p>
                        <p><%= homeEsc(pv[5]) %></p>
                        <p>Visit Fee: &#8377;<%= homeEsc(pv[6]) %></p>
                    </div>
                    <div class="price-row">
                        <a href="bookings.jsp?providerId=<%= pv[0] %>" class="btn-card">Book This Provider</a>
                    </div>
                </article>
            <%     }
               } %>
        </div>
    </section>

    <!-- 5. HOW IT WORKS -->
    <section class="home-section">
        <h2>How It Works</h2>
        <p class="section-subtitle">Get your problem solved in four simple steps</p>

        <div class="steps-grid">
            <div class="step-card">
                <div class="step-number">1</div>
                <h3>Choose a service</h3>
                <p>Browse our categories and find the service you need.</p>
            </div>
            <div class="step-card">
                <div class="step-number">2</div>
                <h3>Pick a provider</h3>
                <p>Compare ratings, experience and visit fees.</p>
            </div>
            <div class="step-card">
                <div class="step-number">3</div>
                <h3>Book a time slot</h3>
                <p>Choose the date that suits you.</p>
            </div>
            <div class="step-card">
                <div class="step-number">4</div>
                <h3>Get service at home</h3>
                <p>Your professional arrives at your doorstep.</p>
            </div>
        </div>
    </section>

    <!-- 6. WHY CHOOSE US -->
    <section class="home-section">
        <h2>Why Choose Us</h2>
        <p class="section-subtitle">Reliable service you can count on</p>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">&#9989;</div>
                <h3>Verified Professionals</h3>
                <p>Every provider is checked before joining the platform.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">&#128178;</div>
                <h3>Transparent Pricing</h3>
                <p>Clear visit fees and price ranges, with no surprises.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">&#9889;</div>
                <h3>Quick Booking</h3>
                <p>Book in a few clicks and track your bookings online.</p>
            </div>
        </div>
    </section>

    <!-- 7. CALL TO ACTION (only for visitors who are not logged in) -->
    <% if (!homeLoggedIn) { %>
        <section class="cta-band">
            <h2>Ready to get started?</h2>
            <p>Create a free account and book a trusted professional today.</p>
            <a href="signup.jsp" class="btn-cta">Sign Up Now</a>
        </section>
    <% } %>

</main>

<!-- 8. FOOTER -->
<footer>
    <p>&copy; 2026 Local Services Hub. All rights reserved.</p>
</footer>

<%
    // Close the connection last, in case header.jsp needed it.
    try { con.close(); } catch (SQLException ignored) {}
%>
</body>
</html>
