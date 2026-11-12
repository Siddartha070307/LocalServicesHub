# Local Services Hub

A web app for finding local service providers and booking them. Built with JSP, JDBC and Oracle as part of the FSD-II course project.

## Features
- User signup and login (passwords hashed with BCrypt)
- Browse services and providers
- Book a provider, view and cancel your bookings
- Add, edit and delete services and providers (CRUD)

## Tech Stack
- Frontend: JSP, HTML, CSS
- Backend: Java (JSP + JDBC)
- Database: Oracle 10g Express (SID `XE`)
- Server: Apache Tomcat 9
- Build: Maven, JDK 17

## Database Tables
`app_users`, `services`, `providers`, `bookings` (ids use sequences + triggers).

## Setup
1. Clone the repo and import it into Eclipse as an existing Maven project.
2. Create the tables in Oracle and insert the seed data.
3. Open `src/main/webapp/conn.jsp` and set your own Oracle username and password:
   ```java
   DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "YOUR_USER", "YOUR_PASSWORD");
   ```
4. Run the project on Tomcat 9.
5. Open `http://localhost:8089/LocalServicesHub/` (use your own Tomcat port if different).

## Project Structure
```
LocalServicesHub/
├── pom.xml
└── src/main/
    ├── java/DBUtil.java        # standalone DB connection test
    └── webapp/
        ├── *.jsp               # pages (login, signup, services, providers, bookings)
        ├── conn.jsp            # DB connection
        ├── style.css
        └── WEB-INF/lib/        # jbcrypt jar
```

