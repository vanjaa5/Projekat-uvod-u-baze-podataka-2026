package ui;

import util.KorisnikStore;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;

public class RegistracijaForma extends JFrame {

    private final JTextField     tfKorisnik = UiKit.polje("Izaberi korisnicko ime");
    private final JPasswordField pfLozinka  = UiKit.lozinkaPolje("Lozinka");
    private final JPasswordField pfPotvrda  = UiKit.lozinkaPolje("Potvrdi lozinku");

    public RegistracijaForma() {
        setTitle("Pracenje eksperimenata - Registracija");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(520, 520);
        setLocationRelativeTo(null);
        getContentPane().setBackground(UiKit.BG);
        setLayout(new GridBagLayout());

        JPanel kartica = UiKit.kartica();
        kartica.setLayout(new GridBagLayout());

        GridBagConstraints g = new GridBagConstraints();
        g.insets = new Insets(6, 0, 6, 0);
        g.gridx = 0; g.gridwidth = 2; g.anchor = GridBagConstraints.WEST;

        g.gridy = 0; kartica.add(UiKit.naslov("Registracija"), g);
        g.gridy = 1; kartica.add(UiKit.podnaslov("Novi nalog se cuva u fajlu users.txt."), g);

        g.insets = new Insets(14, 0, 4, 0);
        g.gridy = 2; kartica.add(new JLabel("Korisnicko ime"), g);
        g.insets = new Insets(0, 0, 8, 0);
        g.gridy = 3; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(tfKorisnik, g);

        g.fill = GridBagConstraints.NONE;
        g.insets = new Insets(8, 0, 4, 0);
        g.gridy = 4; kartica.add(new JLabel("Lozinka"), g);
        g.insets = new Insets(0, 0, 8, 0);
        g.gridy = 5; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(pfLozinka, g);

        g.fill = GridBagConstraints.NONE;
        g.insets = new Insets(8, 0, 4, 0);
        g.gridy = 6; kartica.add(new JLabel("Potvrda lozinke"), g);
        g.insets = new Insets(0, 0, 16, 0);
        g.gridy = 7; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(pfPotvrda, g);

        JButton bRegistruj = UiKit.primarno("Registruj se");
        JButton bNazad = UiKit.sekundarno("Nazad na prijavu");
        bRegistruj.addActionListener(e -> registruj());
        bNazad.addActionListener(e -> {
            new PrijavaForma().setVisible(true);
            dispose();
        });

        JPanel dugmici = new JPanel(new GridLayout(1, 2, 10, 0));
        dugmici.setOpaque(false);
        dugmici.add(bRegistruj);
        dugmici.add(bNazad);

        g.fill = GridBagConstraints.HORIZONTAL;
        g.insets = new Insets(4, 0, 0, 0);
        g.gridy = 8; kartica.add(dugmici, g);

        add(kartica);
        getRootPane().setDefaultButton(bRegistruj);
    }

    private void registruj() {
        String u = tfKorisnik.getText().trim();
        String p1 = new String(pfLozinka.getPassword());
        String p2 = new String(pfPotvrda.getPassword());

        if (u.isEmpty() || p1.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Sva polja su obavezna.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        if (!p1.equals(p2)) {
            JOptionPane.showMessageDialog(this, "Lozinke se ne poklapaju.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        if (u.contains(":")) {
            JOptionPane.showMessageDialog(this, "Korisnicko ime ne sme sadrzati znak ':'.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        try {
            if (KorisnikStore.registruj(u, p1)) {
                JOptionPane.showMessageDialog(this, "Uspesna registracija. Sad mozete da se prijavite.",
                        "Uspeh", JOptionPane.INFORMATION_MESSAGE);
                new PrijavaForma().setVisible(true);
                dispose();
            } else {
                JOptionPane.showMessageDialog(this, "Korisnik sa tim imenom vec postoji.",
                        "Greska", JOptionPane.ERROR_MESSAGE);
            }
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(this,
                    "Greska pri upisu u users.txt: " + ex.getMessage(),
                    "Greska", JOptionPane.ERROR_MESSAGE);
        }
    }
}
