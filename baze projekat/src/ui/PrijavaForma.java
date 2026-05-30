package ui;

import util.KorisnikStore;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;

public class PrijavaForma extends JFrame {

    private final JTextField     tfKorisnik = UiKit.polje("npr. admin");
    private final JPasswordField pfLozinka  = UiKit.lozinkaPolje("Lozinka");

    public PrijavaForma() {
        setTitle("Pracenje eksperimenata - Prijava");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(520, 460);
        setLocationRelativeTo(null);
        getContentPane().setBackground(UiKit.BG);
        setLayout(new GridBagLayout());

        JPanel kartica = UiKit.kartica();
        kartica.setLayout(new GridBagLayout());

        GridBagConstraints g = new GridBagConstraints();
        g.insets = new Insets(6, 0, 6, 0);
        g.gridx = 0; g.gridwidth = 2; g.anchor = GridBagConstraints.WEST;

        g.gridy = 0; kartica.add(UiKit.naslov("Prijava"), g);
        g.gridy = 1; kartica.add(UiKit.podnaslov("Unesite svoje korisnicke podatke za nastavak."), g);

        g.insets = new Insets(14, 0, 4, 0);
        g.gridy = 2; kartica.add(new JLabel("Korisnicko ime"), g);
        g.insets = new Insets(0, 0, 8, 0);
        g.gridy = 3; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(tfKorisnik, g);

        g.fill = GridBagConstraints.NONE;
        g.insets = new Insets(8, 0, 4, 0);
        g.gridy = 4; kartica.add(new JLabel("Lozinka"), g);
        g.insets = new Insets(0, 0, 16, 0);
        g.gridy = 5; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(pfLozinka, g);

        JButton bPrijava = UiKit.primarno("Prijavi se");
        JButton bRegistracija = UiKit.sekundarno("Nemam nalog - registracija");
        bPrijava.addActionListener(e -> prijavi());
        bRegistracija.addActionListener(e -> {
            new RegistracijaForma().setVisible(true);
            dispose();
        });

        JPanel dugmici = new JPanel(new GridLayout(1, 2, 10, 0));
        dugmici.setOpaque(false);
        dugmici.add(bPrijava);
        dugmici.add(bRegistracija);

        g.fill = GridBagConstraints.HORIZONTAL;
        g.insets = new Insets(4, 0, 0, 0);
        g.gridy = 6; kartica.add(dugmici, g);

        add(kartica);
        getRootPane().setDefaultButton(bPrijava);
    }

    private void prijavi() {
        String u = tfKorisnik.getText().trim();
        String p = new String(pfLozinka.getPassword());
        if (u.isEmpty() || p.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Unesite korisnicko ime i lozinku.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        try {
            if (KorisnikStore.proveriPrijavu(u, p)) {
                new GlavniProzor(u).setVisible(true);
                dispose();
            } else {
                JOptionPane.showMessageDialog(this, "Pogresno korisnicko ime ili lozinka.",
                        "Greska", JOptionPane.ERROR_MESSAGE);
            }
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(this,
                    "Greska pri citanju users.txt: " + ex.getMessage(),
                    "Greska", JOptionPane.ERROR_MESSAGE);
        }
    }
}
