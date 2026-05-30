USE
ekonomijaub;



-- Pregled aktvnih eksperimenata, onih koje imaju bar ejdnu sesju koja se desila u zadnih mesec dana.
-- Za svaki eskepriemtn priakzujemo naziv, teorijski okvir, broj razlicith izvodjenja i ukupan broj sesija

-- Uvodi se da bi administratori imali uvid u aktivne eksperimente
DROP VIEW IF EXISTS v_aktivni_eksperimenti;
CREATE VIEW v_aktivni_eksperimenti AS
SELECT e.id_eksperimenta,
       e.naziv                          AS naziv_eksperimenta,
       e.tip                            AS tip_eksperimenta,
       t.naziv                          AS teorijski_okvir,
       COUNT(DISTINCT iz.id_izvodjenja) AS broj_izvodjenja,
       COUNT(DISTINCT s.id_sesije)      AS broj_sesija
FROM eksperiment e
         JOIN teorijski_okvir t ON t.id_okvira = e.id_okvira
         JOIN izvodjenje iz ON iz.id_eksperimenta = e.id_eksperimenta
         JOIN sesija s ON s.id_izvodjenja = iz.id_izvodjenja
GROUP BY e.id_eksperimenta, e.naziv, e.tip, t.naziv
HAVING MAX(s.datum) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- Prelged aktivnih izvodjenja, onih kojima je status zapoceto
-- Za svako aktivno izvodjenje prikazuje id izvodenja, datum unosa izvodjenja, naziv eksperimenta, tip eksperimenta, teorijski okvir, broj sesija izvodjenja

-- Uvodi se da bi adminstratori imali uvid u aktivna izvodjenja

DROP VIEW IF EXISTS v_aktivna_izvodjenja;
CREATE VIEW v_aktivna_izvodjenja AS
SELECT iz.id_izvodjenja,
       iz.datum                    AS datum_unosa_izvodjenja,
       e.naziv                     AS nziv_eksperimenta,
       e.tip                       AS tip_eksperimenta,
       t.naziv                     AS teorijski_okvir,
       COUNT(DISTINCT s.id_sesije) AS broj_sesija
FROM izvodjenje iz
         JOIN eksperiment e ON e.id_eksperimenta = iz.id_eksperimenta
         JOIN teorijski_okvir t ON t.id_okvira = e.id_okvira
         JOIN sesija s ON s.id_izvodjenja = iz.id_izvodjenja
WHERE iz.status = 'zapoceto'
GROUP BY iz.id_izvodjenja, e.naziv, e.tip, t.naziv;



-- Procedura za bezbedan unos nove sesije, gde s proverava da ne postoji sesija koja se na istom racuanra preklapa sa
-- novounetom sesijom, ako dodje do preklapnja pokrecemo rollback i setujemmo p_id_sesije na -1, kako bi mogli da znamo da je doslo do greske
-- tu poruku mozemo iskoristi u daljim modifikacijama

-- Uvodi se zarad kontorlisanog zakazivanja sesija i izbegavanje gresaka

DROP PROCEDURE IF EXISTS p_zakazi_sesiju;
DELIMITER
$$
CREATE PROCEDURE p_zakazi_sesiju(
    IN p_id_izvodjenja INT,
    IN p_id_racunara INT,
    IN p_datum DATE,
    IN p_pocetak TIME,
    IN p_kraj TIME,
    OUT p_id_sesije INT
) sp:
BEGIN
    DECLARE
v_broj_preklapanja INT DEFAULT 0;

    DECLARE
EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
SET
p_id_sesije = -1;
END;

START TRANSACTION;


SELECT COUNT(*)
INTO v_broj_preklapanja
FROM sesija
WHERE id_racunara = p_id_racunara
  AND datum = p_datum
  AND NOT (vreme_kraja <= p_pocetak OR vreme_pocetka >= p_kraj);

IF
v_broj_preklapanja > 0 THEN
        ROLLBACK;
        SET
p_id_sesije = -1;
        LEAVE
sp;
END IF;


INSERT INTO sesija (id_izvodjenja, id_racunara, datum, vreme_pocetka, vreme_kraja)
VALUES (p_id_izvodjenja, p_id_racunara, p_datum, p_pocetak, p_kraj);

SET
p_id_sesije = LAST_INSERT_ID();


UPDATE izvodjenje
SET status = 'zapoceto'
WHERE id_izvodjenja = p_id_izvodjenja
  AND status = 'planirano';

COMMIT;
END
$$
DELIMITER ;

-- Funkcija koja vraca ukupnu vrednost nekog eksperimenta

-- Koristi se zarad retrospektive pri pregledu eksperimenata

DROP FUNCTION IF EXISTS f_ukupna_vrednost_eksperimenta;
DELIMITER
$$
CREATE FUNCTION f_ukupna_vrednost_eksperimenta(p_id_eksperimenta INT)
    RETURNS DECIMAL(15, 2)
BEGIN
    DECLARE
v_ukupno DECIMAL(15,2);
SELECT COALESCE(SUM(er.kolicina * r.cena_po_komadu * jv.kurs_eur), 0)
INTO v_ukupno
FROM eksperiment_resurs er
         JOIN resurs r ON r.id_resursa = er.id_resursa
         JOIN jedinica_vrednosti jv ON jv.id_jedinice_vrednosti = r.kod_jedinice_vrednosti
WHERE er.id_eksperimenta = p_id_eksperimenta;

RETURN v_ukupno;
END
$$
DELIMITER ;


-- test funkcija prethodne
DROP FUNCTION IF EXISTS f_test_ukupna_vrednost;
DELIMITER
//
CREATE FUNCTION f_test_ukupna_vrednost()
    RETURNS BOOLEAN
    DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE
v_ok  BOOLEAN        DEFAULT TRUE;
    DECLARE
v_rez DECIMAL(15,2);

    -- 1.  id=1    rezultat  >= 0
    SET
v_rez = f_ukupna_vrednost_eksperimenta(1);
    IF
v_rez IS NULL OR v_rez < 0 THEN SET v_ok = FALSE;
END IF;

    -- 2.  id=10        rezultat >= 0
    SET
v_rez = f_ukupna_vrednost_eksperimenta(10);
    IF
v_rez IS NULL OR v_rez < 0 THEN SET v_ok = FALSE;
END IF;

    -- 3.  id=50          rezultat >= 0
    SET
v_rez = f_ukupna_vrednost_eksperimenta(50);
    IF
v_rez IS NULL OR v_rez < 0 THEN SET v_ok = FALSE;
END IF;

    -- 4. nepostojeci id        rezultat = 0
    SET
v_rez = f_ukupna_vrednost_eksperimenta(999999);
    IF
v_rez IS NULL OR v_rez <> 0 THEN SET v_ok = FALSE;
END IF;

    -- 5. negativan id          rezultat = 0
    SET
v_rez = f_ukupna_vrednost_eksperimenta(-1);
    IF
v_rez IS NULL OR v_rez <> 0 THEN SET v_ok = FALSE;
END IF;

RETURN v_ok;
END
//
DELIMITER ;

-- =============================================================
-- Generisan dodatna provera:
--   SELECT * FROM v_aktivni_eksperimenti;
--   SELECT * FROM v_aktivna_izvodjenja;
--   SELECT f_ukupna_vrednost_eksperimenta(1);
--   SELECT f_test_ukupna_vrednost();
--   CALL p_zakazi_sesiju(1, 1, '2027-01-01', '09:00:00', '10:00:00', @id);
--   SELECT @id;
-- =============================================================
