package dao;

import baza.Konekcija;
import model.Laboratorija;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class LaboratorijaDAO {


    public List<Laboratorija> sve() throws SQLException {
        String sql = "SELECT id_laboratorije, naziv, operativni_sistem FROM laboratorija ORDER BY naziv";
        List<Laboratorija> rez = new ArrayList<>();
        try (Connection c = Konekcija.otvori();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                rez.add(new Laboratorija(
                        rs.getInt("id_laboratorije"),
                        rs.getString("naziv"),
                        rs.getString("operativni_sistem")
                ));
            }
        }
        return rez;
    }
}
