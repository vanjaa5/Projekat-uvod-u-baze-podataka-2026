package baza;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class Konekcija {

    private static final String URL  =
            "jdbc:mysql://localhost:3306/ekonomijaub" +
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=utf8";
    private static final String USER = "root";
    private static final String PASS = "";

    private Konekcija() { }

    public static Connection otvori() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
