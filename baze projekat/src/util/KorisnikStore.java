package util;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class KorisnikStore {

    private static final Path PUT = Paths.get("users.txt");

    private KorisnikStore() { }

    public static Map<String, String> ucitaj() throws IOException {
        Map<String, String> mapa = new LinkedHashMap<>();
        if (!Files.exists(PUT)) {
            Files.createFile(PUT);
            return mapa;
        }
        for (String linija : Files.readAllLines(PUT, StandardCharsets.UTF_8)) {
            if (linija.isEmpty()) continue;
            int i = linija.indexOf(':');
            if (i > 0) {
                mapa.put(linija.substring(0, i), linija.substring(i + 1));
            }
        }
        return mapa;
    }

    private static void sacuvaj(Map<String, String> mapa) throws IOException {
        List<String> linije = new ArrayList<>();
        for (Map.Entry<String, String> e : mapa.entrySet()) {
            linije.add(e.getKey() + ":" + e.getValue());
        }
        Files.write(PUT, linije, StandardCharsets.UTF_8);
    }

    public static boolean registruj(String korisnickoIme, String lozinka) throws IOException {
        Map<String, String> m = ucitaj();
        if (m.containsKey(korisnickoIme)) return false;
        m.put(korisnickoIme, lozinka);
        sacuvaj(m);
        return true;
    }

    public static boolean proveriPrijavu(String korisnickoIme, String lozinka) throws IOException {
        Map<String, String> m = ucitaj();
        return lozinka.equals(m.get(korisnickoIme));
    }

    public static boolean azuriraj(String staroIme, String novoIme, String novaLozinka) throws IOException {
        Map<String, String> m = ucitaj();
        if (!m.containsKey(staroIme)) return false;
        if (!staroIme.equals(novoIme) && m.containsKey(novoIme)) return false;
        m.remove(staroIme);
        m.put(novoIme, novaLozinka);
        sacuvaj(m);
        return true;
    }

    public static boolean obrisi(String korisnickoIme, String lozinkaPotvrda) throws IOException {
        if (!proveriPrijavu(korisnickoIme, lozinkaPotvrda)) return false;
        Map<String, String> m = ucitaj();
        m.remove(korisnickoIme);
        sacuvaj(m);
        return true;
    }
}
