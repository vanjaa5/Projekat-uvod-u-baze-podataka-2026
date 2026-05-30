package ui;

import dao.IstrazivacDAO;
import dao.LaboratorijaDAO;
import model.Istrazivac;
import model.Laboratorija;

import javax.swing.*;
import javax.swing.border.Border;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.JTableHeader;
import java.awt.*;
import java.sql.SQLException;
import java.util.List;

public class GlavniProzor extends JFrame {

    private String trenutniKorisnik;

    private final DefaultListModel<Laboratorija> modelLab = new DefaultListModel<>();
    private final JList<Laboratorija> listaLab = new JList<>(modelLab);

    private final DefaultTableModel modelIstr = new DefaultTableModel(
            new Object[]{"ID", "Ime", "Prezime", "Email", "Tip"}, 0) {
        @Override public boolean isCellEditable(int r, int c) { return false; }
    };
    private final JTable tabelaIstr = new JTable(modelIstr);

    private final JLabel lblOdabrana = new JLabel("Izaberite laboratoriju levo.");
    private final JLabel lblStatus   = new JLabel(" ");

    public GlavniProzor(String korisnik) {
        this.trenutniKorisnik = korisnik;

        setTitle("Pracenje eksperimenata");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(1080, 640);
        setLocationRelativeTo(null);
        getContentPane().setBackground(UiKit.BG);
        setLayout(new BorderLayout());

        add(zaglavlje(),    BorderLayout.NORTH);
        add(centralniDeo(), BorderLayout.CENTER);
        add(statusna(),     BorderLayout.SOUTH);

        listaLab.addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting()) ucitajIstrazivace();
        });

        ucitajLaboratorije();
    }

    private JComponent zaglavlje() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBackground(Color.WHITE);
        panel.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createMatteBorder(0, 0, 1, 0, new Color(0xE2E8F0)),
                UiKit.padding(14, 20, 14, 20)));

        JPanel levo = new JPanel();
        levo.setOpaque(false);
        levo.setLayout(new BoxLayout(levo, BoxLayout.Y_AXIS));
        JLabel naslov = new JLabel("Pracenje laboratorijskih eksperimenata");
        naslov.setFont(naslov.getFont().deriveFont(Font.BOLD, 20f));
        JLabel pod = new JLabel("Pregled laboratorija i istrazivaca u njima.");
        pod.setForeground(UiKit.MUTED);
        pod.setFont(pod.getFont().deriveFont(13f));
        levo.add(naslov);
        levo.add(Box.createVerticalStrut(2));
        levo.add(pod);

        JPanel desno = new JPanel(new FlowLayout(FlowLayout.RIGHT, 8, 0));
        desno.setOpaque(false);
        JLabel ko = new JLabel("Prijavljen: ");
        ko.setForeground(UiKit.MUTED);
        JLabel korisnik = new JLabel(trenutniKorisnik);
        korisnik.setFont(korisnik.getFont().deriveFont(Font.BOLD));
        JButton bIzmena = UiKit.sekundarno("Izmeni nalog");
        JButton bBrisi  = UiKit.sekundarno("Obrisi nalog");
        bBrisi.setForeground(UiKit.DANGER);
        JButton bOdjava = UiKit.primarno("Odjava");
        bIzmena.addActionListener(e -> otvoriIzmenu());
        bBrisi.addActionListener(e -> otvoriBrisanje());
        bOdjava.addActionListener(e -> {
            new PrijavaForma().setVisible(true);
            dispose();
        });
        desno.add(ko);
        desno.add(korisnik);
        desno.add(Box.createHorizontalStrut(12));
        desno.add(bIzmena);
        desno.add(bBrisi);
        desno.add(bOdjava);

        panel.add(levo,  BorderLayout.WEST);
        panel.add(desno, BorderLayout.EAST);
        return panel;
    }

    private JComponent centralniDeo() {
        JPanel levo = panelKartica("Laboratorije (" + 0 + ")");
        listaLab.setCellRenderer((lst, val, idx, sel, foc) -> {
            JLabel l = new JLabel();
            l.setOpaque(true);
            l.setBorder(UiKit.padding(6, 12, 6, 12));
            if (val != null) {
                l.setText("<html><b>" + val.naziv + "</b>  "
                        + "<span style='color:#64748B'>" + val.operativniSistem + "</span></html>");
            }
            l.setBackground(sel ? new Color(0xDBEAFE) : (idx % 2 == 0 ? Color.WHITE : new Color(0xF6F8FB)));
            return l;
        });
        JScrollPane spLab = new JScrollPane(listaLab);
        spLab.setBorder(BorderFactory.createLineBorder(new Color(0xE2E8F0)));
        levo.add(spLab, BorderLayout.CENTER);

        JPanel desno = new JPanel(new BorderLayout(0, 10));
        desno.setOpaque(false);
        desno.add(lblOdabrana, BorderLayout.NORTH);
        lblOdabrana.setFont(lblOdabrana.getFont().deriveFont(Font.BOLD, 14f));
        lblOdabrana.setBorder(UiKit.padding(0, 4, 0, 0));

        tabelaIstr.setRowHeight(28);
        tabelaIstr.setShowVerticalLines(false);
        tabelaIstr.setIntercellSpacing(new Dimension(0, 0));
        JTableHeader h = tabelaIstr.getTableHeader();
        h.setFont(h.getFont().deriveFont(Font.BOLD));
        h.setReorderingAllowed(false);

        JScrollPane spTab = new JScrollPane(tabelaIstr);
        spTab.setBorder(BorderFactory.createLineBorder(new Color(0xE2E8F0)));
        desno.add(spTab, BorderLayout.CENTER);

        JPanel desnaKartica = panelKartica(null);
        desnaKartica.add(desno, BorderLayout.CENTER);

        JSplitPane split = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, levo, desnaKartica);
        split.setBorder(null);
        split.setDividerLocation(360);
        split.setResizeWeight(0.32);
        split.setOpaque(false);

        JPanel okvir = new JPanel(new BorderLayout());
        okvir.setOpaque(false);
        okvir.setBorder(UiKit.padding(16, 20, 16, 20));
        okvir.add(split, BorderLayout.CENTER);
        return okvir;
    }

    private JPanel panelKartica(String naslov) {
        JPanel p = new JPanel(new BorderLayout(0, 10));
        p.setBackground(UiKit.CARD_BG);
        Border line = BorderFactory.createLineBorder(new Color(0xE2E8F0), 1, true);
        p.setBorder(BorderFactory.createCompoundBorder(line, UiKit.padding(14, 16, 14, 16)));
        if (naslov != null) {
            JLabel l = new JLabel(naslov);
            l.setFont(l.getFont().deriveFont(Font.BOLD, 14f));
            p.add(l, BorderLayout.NORTH);
        }
        return p;
    }

    private JComponent statusna() {
        JPanel s = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 6));
        s.setBackground(new Color(0xF1F5F9));
        s.setBorder(BorderFactory.createMatteBorder(1, 0, 0, 0, new Color(0xE2E8F0)));
        lblStatus.setForeground(UiKit.MUTED);
        s.add(lblStatus);
        return s;
    }

    private void otvoriIzmenu() {
        IzmenaNalogaDijalog d = new IzmenaNalogaDijalog(this, trenutniKorisnik);
        d.setVisible(true);
        if (d.getNoviKorisnik() != null) {
            trenutniKorisnik = d.getNoviKorisnik();
            setTitle("Pracenje eksperimenata - " + trenutniKorisnik);

            getContentPane().removeAll();
            add(zaglavlje(),    BorderLayout.NORTH);
            add(centralniDeo(), BorderLayout.CENTER);
            add(statusna(),     BorderLayout.SOUTH);
            revalidate();
            repaint();
            ucitajLaboratorije();
        }
    }

    private void otvoriBrisanje() {
        BrisanjeNalogaDijalog d = new BrisanjeNalogaDijalog(this, trenutniKorisnik);
        d.setVisible(true);
        if (d.jeObrisan()) {
            new PrijavaForma().setVisible(true);
            dispose();
        }
    }

    private void ucitajLaboratorije() {
        try {
            List<Laboratorija> sve = new LaboratorijaDAO().sve();
            modelLab.clear();
            for (Laboratorija l : sve) modelLab.addElement(l);
            lblStatus.setText("Ukupno laboratorija: " + sve.size());
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this,
                    "Greska pri ucitavanju laboratorija: " + ex.getMessage(),
                    "Greska", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void ucitajIstrazivace() {
        Laboratorija lab = listaLab.getSelectedValue();
        modelIstr.setRowCount(0);
        if (lab == null) {
            lblOdabrana.setText("Izaberite laboratoriju levo.");
            return;
        }
        lblOdabrana.setText("Istrazivaci na: " + lab.naziv);
        try {
            List<Istrazivac> istr = new IstrazivacDAO().uLaboratoriji(lab.id_laboratorije);
            for (Istrazivac i : istr) {
                modelIstr.addRow(new Object[]{i.id_istrazivaca, i.ime, i.prezime, i.email, i.tip});
            }
            lblStatus.setText("Laboratorija " + lab.naziv + " - istrazivaca: " + istr.size());
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this,
                    "Greska pri ucitavanju istrazivaca: " + ex.getMessage(),
                    "Greska", JOptionPane.ERROR_MESSAGE);
        }
    }
}
