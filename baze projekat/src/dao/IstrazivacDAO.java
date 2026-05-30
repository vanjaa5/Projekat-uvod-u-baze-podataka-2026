package dao;

import baza.Konekcija;
import model.Istrazivac;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class IstrazivacDAO {


    public List<Istrazivac> uLaboratoriji(int idLaboratorije) throws SQLException {
        String sql =
                "SELECT DISTINCT i.id_istrazivaca, i.ime, i.prezime, i.email, i.tip " +
                "FROM istrazivac i " +
                "JOIN izvodjac iz        ON iz.id_izvodjaca = i.id_istrazivaca " +
                "JOIN uloga_izvodjaca ui ON ui.id_izvodjaca = iz.id_izvodjaca " +
                "JOIN izvodjenje izv     ON izv.id_izvodjenja = ui.id_izvodjenja " +
                "JOIN sesija s           ON s.id_izvodjenja = izv.id_izvodjenja " +
                "WHERE s.id_racunara = ? " +
                "ORDER BY i.prezime, i.ime";

        List<Istrazivac> rez = new ArrayList<>();
        try (Connection c = Konekcija.otvori();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idLaboratorije);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rez.add(new Istrazivac(
                            rs.getInt("id_istrazivaca"),
                            rs.getString("ime"),
                            rs.getString("prezime"),
                            rs.getString("email"),
                            rs.getString("tip")
                    ));
                }
            }
        }
        return rez;
    }
}
