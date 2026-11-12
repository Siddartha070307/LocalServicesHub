import java.sql.*;

public class DBUtil {

    public static void main(String[] args) {

        try {
            // Register Oracle Driver
            Class.forName("oracle.jdbc.OracleDriver");
            System.out.println("Oracle Driver Registered Successfully");

            String user = args.length > 0 ? args[0] : "system";
            String password = args.length > 1 ? args[1] : "";

            // Establish connection (credentials provided via arguments, not hardcoded)
            Connection con = DriverManager.getConnection(
                    "jdbc:oracle:thin:@localhost:1521:xe",
                    user,
                    password
            );
            System.out.println("Connection Establishment done successfully");

            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT id, category, name, price_range FROM services");

            while (rs.next()) {
                System.out.println(rs.getInt("id") + " | "
                        + rs.getString("category") + " | "
                        + rs.getString("name") + " | "
                        + rs.getString("price_range"));
            }

            rs.close();
            stmt.close();
            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }
}