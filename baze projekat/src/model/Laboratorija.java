package model;

public class Laboratorija {
    public int id_laboratorije;
    public String naziv;
    public String operativniSistem;

    public Laboratorija() { }

    public Laboratorija(int id_laboratorije, String naziv, String operativniSistem) {
        this.id_laboratorije = id_laboratorije;
        this.naziv = naziv;
        this.operativniSistem = operativniSistem;
    }

    @Override
    public String toString() {
        return naziv + " [" + operativniSistem + "]";
    }
}
