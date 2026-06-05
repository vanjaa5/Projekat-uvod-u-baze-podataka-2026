USE ekonomijaub;

-- Pošto je baza rađena u PhPMyAdmin-u na žalost nije moguće korsititi bit mape, već samo B stablo,
-- tako da je svaka preporuka za bitmape hipotetička.


-- 1) sesija (id_racunara, datum, vreme_pocetka, vreme_kraja) — kompozitni
-- Pošto se sesije zakazuju po datumu i bitno nam je da se ne poklapaju na istom račuanru
-- ovaj indeks pomaže da se ubrza nešto što pretpostavljamo da bi bila veoma česta radnja unutar ove baze
-- Ovaj indeks je naročtio krostian za trenutnu bazu zbog procedure
-- p_zakazi_sesiju koja filtrira sesije po datumu.
-- Takođe je praktičan i za druge manje pretrage po LEFTMOST principu.

-- Bolje je korsititi B stablo zbog visoke kardinalnosti, kao i pordjenja.

-- Ovaj indeks izgleda kao dobar kandidat za klasterovani indeks, jer bi svakako bilo praktično da čitava tabela bude
-- hronološki rasporedjena.

CREATE INDEX IX_sesija_racunar_termin
    ON sesija (id_racunara, datum, vreme_pocetka, vreme_kraja);

-- 2) izvodjenje.status
-- Veoma je očekivano da ce istraživači ili administratori tražiti izvodjenja prema statusu
-- ovaj indeks bi drastično poboljsao filtriiranje kao i grupisanje.

-- Ovaj indeks ne izgleda kao dobar kandidat za klasterovani indeks,
-- jer bi bilo potrebno konstanto sortiranje podataka pri svakom unosu.

-- Zbog malog broja mogućih vrednosti bitmapa bi ovde bila pogodnija.

CREATE INDEX IX_izvodjenje_status ON izvodjenje (status);

-- 3) istrazivac (prezime, ime) — kompozitni
-- Očekivano je da će se raditi neka pretraga prema istraživačima zarad evidentiranja
-- ovaj indeks to olakšava i omogućava sortiranje prema imenu i prezimenu
-- Takođe je prktičan i za pretragu samo po prezimenu.

-- Ovaj indeks predstavlja dobar kandidat za kompozitni indeks, jer je logično da tabela istraživača bude sortirana
-- po prezimenima i imenima abecedno.

-- Zbog visoke kardinalnosti bolje je koristiti B stablo.

CREATE INDEX IX_istrazivac_prezime_ime ON istrazivac (prezime, ime);

-- 4) eksperiment.tip
-- Zarad dalje statistkie očekivano je da će se eksperiemnti grupisati ili 
-- filtrirati po tipu.

-- Ovaj indeks ne izgleda kao dobar kandidat za klasterovani indeks,
-- jer bi bilo potrebno konstanto sortiranje podataka pri svakom unosu.

-- Zbog malog broja mogućih vrednosti bitmapa bi ovde bila pogodnija.

CREATE INDEX IX_eksperiment_tip ON eksperiment (tip);

-- 5) laboratorija_resurs.status
-- Ovaj indeks olakšava praćenje statusa resursa unutar laboratorija
-- Očekivano je da će za dalja istraživanja ovo biti veoma korisno istraživačima.

-- Ovaj indeks ne izgleda kao dobar kandidat za klasterovani indeks,
-- jer bi bilo potrebno konstanto sortiranje podataka pri svakom unosu.

-- Zbog malog broja mogućih vrednosti bitmapa bi ovde bila pogodnija.

CREATE INDEX IX_lab_resurs_status ON laboratorija_resurs (status);

-- 6) teorijski_okvir.tip
-- Tip teorijskog okvira predstavlja jedan od logičnih načina grupisanja eksperimenata zarad statistike
-- mi smo ga krostili kao paramter za grupisanje unutar više objekata, tako da on u ovoj bazi ima i aktivnu primenu.

-- Ovaj indeks ne izgleda kao dobar kandidat za klasterovani indeks,
-- jer bi bilo potrebno konstanto sortiranje podataka pri svakom unosu.

-- Zbog malog broja mogućih vrednosti bitmapa bi ovde bila pogodnija.

CREATE INDEX IX_teorijski_okvir_tip ON teorijski_okvir (tip);

-- 7) resurs.kod_jedinice_vrednosti
-- Ovaj indeks ubrzava pretragu resursa koje koriste istu jedinicu vrednosti
-- omogućava lakše grupisanje i pretragu radi statistike.

-- Ovaj indeks ne izgleda kao dobar kandidat za klasterovani ključ, jer nema dovoljno veliku logičku celinu za sortiranje
-- ima dosta različitih jedinica vrednosti, koje međusobno nisu povezane, tako da nema smisla sortirati po njima.

-- Zbog visoke kardinalnosti bolje je koristiti B stablo.

CREATE INDEX IX_resurs_kod_jedinice_vrednosti ON resurs (kod_jedinice_vrednosti);

-- 8) alat.datum_nabavke
-- Ovaj indeks ubrzava pregledanje inventara istraživačima, kao i adminstratorima.

-- Ovaj indeks je dobar kandidat za klasterovani indeks, jer je sortiranje po datumu logično i praktično za dalju upotrebu.

-- Zbog visoke kardinalnosti bolje je koristiti B stablo.

CREATE INDEX IX_alat_datum_nabavke ON alat (datum_nabavke);

-- 9) jedinica_vrednosti.id_jedinice_vrednosti
-- Primarni ključ uvek predstavlja logičan kandidat za indeks, zarad lakšeg pristupa, 
-- kao i logičan kandidat za klasterovani indeks.

-- Zbog visoke kardinalnosti bolje je koristiti B stablo, u ovom slučaju je stablo naročito praktično, 
-- jer je za razilu od većine priamrnih ključeva ovaj primarni ključ VARCHAR, čiji je poređenje skuplje nego brojeva.

CREATE INDEX IX_jedinica_vrednosti_id_jedinice_vrednosti
    ON jedinica_vrednosti (id_jedinice_vrednosti)