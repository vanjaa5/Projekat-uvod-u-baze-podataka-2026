package ui;

import util.KorisnikStore;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;

public class BrisanjeNalogaDijalog extends JDialog {

    private final String korisnik;
    private boolean obrisan = false;

    private final JPasswordField pfLozinka = UiKit.lozinkaPolje("Lozinka");

    public BrisanjeNalogaDijalog(Frame vlasnik, String korisnik) {
        super(vlasnik, "Brisanje naloga", true);
        this.korisnik = korisnik;

        getContentPane().setBackground(UiKit.BG);
        setLayout(new GridBagLayout());

        JPanel kartica = UiKit.kartica();
        kartica.setLayout(new GridBagLayout());

        GridBagConstraints g = new GridBagConstraints();
        g.gridx = 0; g.gridwidth = 2; g.anchor = GridBagConstraints.WEST;
        g.insets = new Insets(2, 0, 2, 0);

        g.gridy = 0; kartica.add(UiKit.naslov("Brisanje naloga"), g);
        g.gridy = 1; kartica.add(UiKit.podnaslov(
                "Ova radnja je trajna. Unesite lozinku za '" + korisnik + "' da potvrdite."), g);

        g.insets = new Insets(14, 0, 4, 0);
        g.gridy = 2; kartica.add(new JLabel("Lozinka"), g);
        g.insets = new Insets(0, 0, 16, 0);
        g.gridy = 3; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(pfLozinka, g);

        JButton bObrisi  = UiKit.opasno("Obrisi nalog");
        JButton bOdustani = UiKit.sekundarno("Odustani");
        bObrisi.addActionListener(e -> obrisi());
        bOdustani.addActionListener(e -> dispose());

        JPanel dug = new JPanel(new GridLayout(1, 2, 10, 0));
        dug.setOpaque(false);
        dug.add(bObrisi);
        dug.add(bOdustani);

        g.fill = GridBagConstraints.HORIZONTAL;
        g.insets = new Insets(4, 0, 0, 0);
        g.gridy = 4; kartica.add(dug, g);

        add(kartica);
        pack();
        setSize(Math.max(getWidth(), 460), getHeight());
        setLocationRelativeTo(vlasnik);
        getRootPane().setDefaultButton(bOdustani);
    }

    public boolean jeObrisan() {
        return obrisan;
    }

    private void obrisi() {
        String p = new String(pfLozinka.getPassword());
        if (p.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Unesite lozinku.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        int odgovor = JOptionPane.showConfirmDialog(this,
                "Zaista zelite trajno da obrisete svoj nalog?",
                "Potvrda brisanja", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);
        if (odgovor != JOptionPane.YES_OPTION) return;

        try {
            if (KorisnikStore.obrisi(korisnik, p)) {
                obrisan = true;
                JOptionPane.showMessageDialog(this, "Nalog je obrisan.",
                        "Uspeh", JOptionPane.INFORMATION_MESSAGE);
                dispose();
            } else {
                JOptionPane.showMessageDialog(this, "Pogresna lozinka.",
                        "Greska", JOptionPane.ERROR_MESSAGE);
            }
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(this,
                    "Greska pri brisanju: " + ex.getMessage(),
                    "Greska", JOptionPane.ERROR_MESSAGE);
        }
    }
}
