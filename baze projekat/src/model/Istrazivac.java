package model;

public class Istrazivac {
    public int id_istrazivaca;
    public String ime;
    public String prezime;
    public String email;
    public String tip;

    public Istrazivac() { }

    public Istrazivac(int id_istrazivaca, String ime, String prezime, String email, String tip) {
        this.id_istrazivaca = id_istrazivaca;
        this.ime = ime;
        this.prezime = prezime;
        this.email = email;
        this.tip = tip;
    }
}
