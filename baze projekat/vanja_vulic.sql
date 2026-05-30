SELECT
    i.id_istrazivaca,
    i.ime,
    i.prezime,
    i.tip,
    COUNT(DISTINCT izvoe.id_eksperimenta) AS broj_eksperimenata,
    COUNT(DISTINCT s.id_sesije)                AS ukupno_sesija
FROM istrazivac i
         JOIN izvodjac       izvoa   ON izvoa.id_izvodjaca = i.id_istrazivaca
         JOIN uloga_izvodjaca ui ON ui.id_izvodjaca = izvoa.id_izvodjaca
         JOIN izvodjenje      izvoe ON izvoe.id_izvodjenja = ui.id_izvodjenja
         JOIN sesija          s   ON s.id_izvodjenja = izvoe.id_izvodjenja
GROUP BY i.id_istrazivaca, i.ime, i.prezime, i.tip
HAVING COUNT(DISTINCT izvoe.id_eksperimenta) >= 3
ORDER BY broj_eksperimenata DESC, ukupno_sesija DESC
LIMIT 15