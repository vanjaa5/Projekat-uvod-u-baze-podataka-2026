package ui;

import util.KorisnikStore;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;

public class IzmenaNalogaDijalog extends JDialog {

    private final String staroIme;
    private String novoIme = null;

    private final JTextField     tfNovoIme = UiKit.polje("Novo korisnicko ime");
    private final JPasswordField pfNovaLoz = UiKit.lozinkaPolje("Nova lozinka");
    private final JPasswordField pfPotvrda = UiKit.lozinkaPolje("Potvrdi novu lozinku");

    public IzmenaNalogaDijalog(Frame vlasnik, String staroIme) {
        super(vlasnik, "Izmena naloga", true);
        this.staroIme = staroIme;
        tfNovoIme.setText(staroIme);

        getContentPane().setBackground(UiKit.BG);
        setLayout(new GridBagLayout());

        JPanel kartica = UiKit.kartica();
        kartica.setLayout(new GridBagLayout());

        GridBagConstraints g = new GridBagConstraints();
        g.gridx = 0; g.gridwidth = 2; g.anchor = GridBagConstraints.WEST;
        g.insets = new Insets(2, 0, 2, 0);

        g.gridy = 0; kartica.add(UiKit.naslov("Izmena naloga"), g);
        g.gridy = 1; kartica.add(UiKit.podnaslov("Trenutni nalog: " + staroIme), g);

        g.insets = new Insets(14, 0, 4, 0);
        g.gridy = 2; kartica.add(new JLabel("Novo korisnicko ime"), g);
        g.insets = new Insets(0, 0, 8, 0);
        g.gridy = 3; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(tfNovoIme, g);

        g.fill = GridBagConstraints.NONE;
        g.insets = new Insets(8, 0, 4, 0);
        g.gridy = 4; kartica.add(new JLabel("Nova lozinka"), g);
        g.insets = new Insets(0, 0, 8, 0);
        g.gridy = 5; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(pfNovaLoz, g);

        g.fill = GridBagConstraints.NONE;
        g.insets = new Insets(8, 0, 4, 0);
        g.gridy = 6; kartica.add(new JLabel("Potvrda lozinke"), g);
        g.insets = new Insets(0, 0, 16, 0);
        g.gridy = 7; g.fill = GridBagConstraints.HORIZONTAL;
        kartica.add(pfPotvrda, g);

        JButton bSacuvaj = UiKit.primarno("Sacuvaj");
        JButton bOdustani = UiKit.sekundarno("Odustani");
        bSacuvaj.addActionListener(e -> sacuvaj());
        bOdustani.addActionListener(e -> dispose());

        JPanel dug = new JPanel(new GridLayout(1, 2, 10, 0));
        dug.setOpaque(false);
        dug.add(bSacuvaj);
        dug.add(bOdustani);

        g.fill = GridBagConstraints.HORIZONTAL;
        g.insets = new Insets(4, 0, 0, 0);
        g.gridy = 8; kartica.add(dug, g);

        add(kartica);
        pack();
        setSize(Math.max(getWidth(), 460), getHeight());
        setLocationRelativeTo(vlasnik);
        getRootPane().setDefaultButton(bSacuvaj);
    }

    public String getNoviKorisnik() {
        return novoIme;
    }

    private void sacuvaj() {
        String noviU = tfNovoIme.getText().trim();
        String p1 = new String(pfNovaLoz.getPassword());
        String p2 = new String(pfPotvrda.getPassword());

        if (noviU.isEmpty() || p1.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Sva polja su obavezna.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        if (!p1.equals(p2)) {
            JOptionPane.showMessageDialog(this, "Lozinke se ne poklapaju.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        if (noviU.contains(":")) {
            JOptionPane.showMessageDialog(this, "Korisnicko ime ne sme sadrzati znak ':'.",
                    "Provera", JOptionPane.WARNING_MESSAGE);
            return;
        }
        try {
            if (KorisnikStore.azuriraj(staroIme, noviU, p1)) {
                novoIme = noviU;
                JOptionPane.showMessageDialog(this, "Nalog je uspesno azuriran.",
                        "Uspeh", JOptionPane.INFORMATION_MESSAGE);
                dispose();
            } else {
                JOptionPane.showMessageDialog(this,
                        "Novo korisnicko ime je vec zauzeto.",
                        "Greska", JOptionPane.ERROR_MESSAGE);
            }
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(this,
                    "Greska pri upisu users.txt: " + ex.getMessage(),
                    "Greska", JOptionPane.ERROR_MESSAGE);
        }
    }
}
