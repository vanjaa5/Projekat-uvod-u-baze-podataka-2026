package ui;

import javax.swing.*;
import javax.swing.border.Border;
import java.awt.*;


public final class UiKit {

    public static final Color BG       = new Color(0xF7F9FC);
    public static final Color CARD_BG  = Color.WHITE;
    public static final Color ACCENT   = new Color(0x2563EB);
    public static final Color DANGER   = new Color(0xDC2626);
    public static final Color MUTED    = new Color(0x64748B);

    private UiKit() { }

    public static JLabel naslov(String tekst) {
        JLabel l = new JLabel(tekst);
        l.setFont(l.getFont().deriveFont(Font.BOLD, 22f));
        return l;
    }

    public static JLabel podnaslov(String tekst) {
        JLabel l = new JLabel(tekst);
        l.setForeground(MUTED);
        l.setFont(l.getFont().deriveFont(Font.PLAIN, 13f));
        return l;
    }

    public static JButton primarno(String tekst) {
        JButton b = new JButton(tekst);
        b.putClientProperty("JButton.buttonType", "roundRect");
        b.setBackground(ACCENT);
        b.setForeground(Color.WHITE);
        b.setFocusPainted(false);
        b.setFont(b.getFont().deriveFont(Font.BOLD, 14f));
        Dimension d = b.getPreferredSize();
        b.setPreferredSize(new Dimension(Math.max(d.width, 140), 36));
        return b;
    }

    public static JButton sekundarno(String tekst) {
        JButton b = new JButton(tekst);
        b.putClientProperty("JButton.buttonType", "roundRect");
        b.setFocusPainted(false);
        Dimension d = b.getPreferredSize();
        b.setPreferredSize(new Dimension(Math.max(d.width, 140), 36));
        return b;
    }

    public static JButton opasno(String tekst) {
        JButton b = primarno(tekst);
        b.setBackground(DANGER);
        return b;
    }

    public static JTextField polje(String placeholder) {
        JTextField tf = new JTextField(20);
        tf.putClientProperty("JTextField.placeholderText", placeholder);
        tf.setPreferredSize(new Dimension(tf.getPreferredSize().width, 34));
        return tf;
    }

    public static JPasswordField lozinkaPolje(String placeholder) {
        JPasswordField pf = new JPasswordField(20);
        pf.putClientProperty("JTextField.placeholderText", placeholder);
        pf.putClientProperty("JPasswordField.showRevealButton", Boolean.TRUE);
        pf.setPreferredSize(new Dimension(pf.getPreferredSize().width, 34));
        return pf;
    }

    public static Border padding(int gore, int levo, int dole, int desno) {
        return BorderFactory.createEmptyBorder(gore, levo, dole, desno);
    }

    public static JPanel kartica() {
        JPanel p = new JPanel();
        p.setBackground(CARD_BG);
        p.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(0xE2E8F0), 1, true),
                padding(20, 24, 20, 24)));
        return p;
    }
}
