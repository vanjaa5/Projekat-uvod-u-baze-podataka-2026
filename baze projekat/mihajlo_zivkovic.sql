USE ekonomijaub;
SELECT
    t.naziv                                AS teorijski_okvir,
    t.tip                                  AS tip_okvira,
    COUNT(DISTINCT e.id_eksperimenta)                   AS broj_eksperimenata,
    ROUND(AVG(f_ukupna_vrednost_eksperimenta(e.id_eksperimenta)), 2) AS prosecna_vrednost_eur
FROM teorijski_okvir t
         JOIN eksperiment      e  ON e.id_okvira = t.id_okvira
         JOIN izvodjenje       iz ON iz.id_eksperimenta = e.id_eksperimenta
         JOIN sesija           s  ON s.id_izvodjenja = iz.id_izvodjenja
GROUP BY t.id_okvira, t.naziv, t.tip, e.id_eksperimenta
HAVING COUNT(DISTINCT s.id_sesije) > 3
ORDER BY prosecna_vrednost_eur DESC;