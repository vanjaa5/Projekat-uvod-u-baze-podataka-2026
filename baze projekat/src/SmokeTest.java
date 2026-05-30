import baza.Konekcija;
import dao.IstrazivacDAO;
import dao.LaboratorijaDAO;
import model.Istrazivac;
import model.Laboratorija;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

public class SmokeTest {
    public static void main(String[] args) throws Exception {
        System.out.println("== JDBC konekcija ==");
        try (Connection c = Konekcija.otvori();
             Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM laboratorija")) {
            rs.next();
            System.out.println("laboratorija: " + rs.getInt(1));
        }

        System.out.println("== DAO: prvih 3 laboratorija ==");
        List<Laboratorija> labs = new LaboratorijaDAO().sve();
        labs.stream().limit(3).forEach(l ->
                System.out.println("  " + l.id_laboratorije + ": " + l.naziv + " (" + l.operativniSistem + ")"));

        if (!labs.isEmpty()) {
            int idLab = labs.get(0).id_laboratorije;
            System.out.println("== DAO: istrazivaci u lab " + idLab + " ==");
            List<Istrazivac> ist = new IstrazivacDAO().uLaboratoriji(idLab);
            ist.stream().limit(5).forEach(i ->
                    System.out.println("  " + i.id_istrazivaca + ": " + i.ime + " " + i.prezime + " [" + i.tip + "]"));
        }

        System.out.println("OK");
    }
}
