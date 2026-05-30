import com.formdev.flatlaf.FlatLightLaf;
import ui.PrijavaForma;

import javax.swing.*;
import java.awt.*;

public class Main {
    public static void main(String[] args) {
        try {
            FlatLightLaf.setup();
            UIManager.put("Component.arc",            16);
            UIManager.put("Button.arc",               16);
            UIManager.put("TextComponent.arc",        12);
            UIManager.put("ProgressBar.arc",          12);
            UIManager.put("Table.rowHeight",          28);
            UIManager.put("TableHeader.height",       32);
            UIManager.put("List.rowHeight",           26);
            UIManager.put("Table.alternateRowColor",  new Color(0xF6F8FB));

            Font base = new Font("Segoe UI", Font.PLAIN, 14);
            UIManager.put("defaultFont", base);
        } catch (Exception ignored) { }

        SwingUtilities.invokeLater(() -> new PrijavaForma().setVisible(true));
    }
}
