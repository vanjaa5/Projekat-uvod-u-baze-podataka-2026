-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 30, 2026 at 04:21 PM
-- Server version: 10.4.17-MariaDB
-- PHP Version: 7.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ekonomijaub`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_zakazi_sesiju` (IN `p_id_izvodjenja` INT, IN `p_id_racunara` INT, IN `p_datum` DATE, IN `p_pocetak` TIME, IN `p_kraj` TIME, OUT `p_id_sesije` INT)  sp:
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
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_test_ukupna_vrednost` () RETURNS TINYINT(1) READS SQL DATA
    DETERMINISTIC
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
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_ukupna_vrednost_eksperimenta` (`p_id_eksperimenta` INT) RETURNS DECIMAL(15,2) BEGIN
    DECLARE
v_ukupno DECIMAL(15,2);
SELECT COALESCE(SUM(er.kolicina * r.cena_po_komadu * jv.kurs_eur), 0)
INTO v_ukupno
FROM eksperiment_resurs er
         JOIN resurs r ON r.id_resursa = er.id_resursa
         JOIN jedinica_vrednosti jv ON jv.id_jedinice_vrednosti = r.kod_jedinice_vrednosti
WHERE er.id_eksperimenta = p_id_eksperimenta;

RETURN v_ukupno;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alat`
--

CREATE TABLE `alat` (
  `id_alata` int(11) NOT NULL,
  `id_tipa_alata` int(11) NOT NULL,
  `id_racuanra` int(11) NOT NULL,
  `identifikacioni_broj` varchar(50) NOT NULL,
  `datum_nabavke` date NOT NULL DEFAULT curdate(),
  `datum_proizvodnje` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `alat`
--

INSERT INTO `alat` (`id_alata`, `id_tipa_alata`, `id_racuanra`, `identifikacioni_broj`, `datum_nabavke`, `datum_proizvodnje`) VALUES
(1, 1, 1, 'ALAT-00001', '2026-05-17', '2026-05-11'),
(2, 2, 2, 'ALAT-00002', '2026-05-10', '2026-04-28'),
(3, 3, 3, 'ALAT-00003', '2026-05-03', '2026-04-15'),
(4, 4, 4, 'ALAT-00004', '2026-04-26', '2026-04-02'),
(5, 5, 5, 'ALAT-00005', '2026-04-19', '2026-03-20'),
(6, 6, 6, 'ALAT-00006', '2026-04-12', '2026-03-07'),
(7, 7, 7, 'ALAT-00007', '2026-04-05', '2026-02-22'),
(8, 8, 8, 'ALAT-00008', '2026-03-29', '2026-02-09'),
(9, 9, 9, 'ALAT-00009', '2026-03-22', '2026-01-27'),
(10, 10, 10, 'ALAT-00010', '2026-03-15', '2026-01-14'),
(11, 11, 11, 'ALAT-00011', '2026-03-08', '2026-01-01'),
(12, 12, 12, 'ALAT-00012', '2026-03-01', '2025-12-19'),
(13, 13, 13, 'ALAT-00013', '2026-02-22', '2025-12-06'),
(14, 14, 14, 'ALAT-00014', '2026-02-15', '2025-11-23'),
(15, 15, 15, 'ALAT-00015', '2026-02-08', '2025-11-10'),
(16, 16, 16, 'ALAT-00016', '2026-02-01', '2025-10-28'),
(17, 17, 17, 'ALAT-00017', '2026-01-25', '2025-10-15'),
(18, 18, 18, 'ALAT-00018', '2026-01-18', '2025-10-02'),
(19, 19, 19, 'ALAT-00019', '2026-01-11', '2025-09-19'),
(20, 20, 20, 'ALAT-00020', '2026-01-04', '2025-09-06'),
(21, 1, 21, 'ALAT-00021', '2025-12-28', '2025-08-24'),
(22, 2, 22, 'ALAT-00022', '2025-12-21', '2025-08-11'),
(23, 3, 23, 'ALAT-00023', '2025-12-14', '2025-07-29'),
(24, 4, 24, 'ALAT-00024', '2025-12-07', '2025-07-16'),
(25, 5, 25, 'ALAT-00025', '2025-11-30', '2025-07-03'),
(26, 6, 26, 'ALAT-00026', '2025-11-23', '2025-06-20'),
(27, 7, 27, 'ALAT-00027', '2025-11-16', '2025-06-07'),
(28, 8, 28, 'ALAT-00028', '2025-11-09', '2025-05-25'),
(29, 9, 29, 'ALAT-00029', '2025-11-02', '2025-05-12'),
(30, 10, 30, 'ALAT-00030', '2025-10-26', '2025-04-29'),
(31, 11, 31, 'ALAT-00031', '2025-10-19', '2025-04-16'),
(32, 12, 32, 'ALAT-00032', '2025-10-12', '2025-04-03'),
(33, 13, 33, 'ALAT-00033', '2025-10-05', '2025-03-21'),
(34, 14, 34, 'ALAT-00034', '2025-09-28', '2025-03-08'),
(35, 15, 35, 'ALAT-00035', '2025-09-21', '2025-02-23'),
(36, 16, 36, 'ALAT-00036', '2025-09-14', '2025-02-10'),
(37, 17, 37, 'ALAT-00037', '2025-09-07', '2025-01-28'),
(38, 18, 38, 'ALAT-00038', '2025-08-31', '2025-01-15'),
(39, 19, 39, 'ALAT-00039', '2025-08-24', '2025-01-02'),
(40, 20, 40, 'ALAT-00040', '2025-08-17', '2024-12-20'),
(41, 1, 41, 'ALAT-00041', '2025-08-10', '2024-12-07'),
(42, 2, 42, 'ALAT-00042', '2025-08-03', '2024-11-24'),
(43, 3, 43, 'ALAT-00043', '2025-07-27', '2024-11-11'),
(44, 4, 44, 'ALAT-00044', '2025-07-20', '2024-10-29'),
(45, 5, 45, 'ALAT-00045', '2025-07-13', '2024-10-16'),
(46, 6, 46, 'ALAT-00046', '2025-07-06', '2024-10-03'),
(47, 7, 47, 'ALAT-00047', '2025-06-29', '2024-09-20'),
(48, 8, 48, 'ALAT-00048', '2025-06-22', '2024-09-07'),
(49, 9, 49, 'ALAT-00049', '2025-06-15', '2024-08-25'),
(50, 10, 50, 'ALAT-00050', '2025-06-08', '2024-08-12'),
(51, 11, 51, 'ALAT-00051', '2025-06-01', '2024-07-30'),
(52, 12, 52, 'ALAT-00052', '2025-05-25', '2024-07-17'),
(53, 13, 53, 'ALAT-00053', '2025-05-18', '2024-07-04'),
(54, 14, 54, 'ALAT-00054', '2025-05-11', '2024-06-21'),
(55, 15, 55, 'ALAT-00055', '2025-05-04', '2024-06-08'),
(56, 16, 56, 'ALAT-00056', '2025-04-27', '2024-05-26'),
(57, 17, 57, 'ALAT-00057', '2025-04-20', '2024-05-13'),
(58, 18, 58, 'ALAT-00058', '2025-04-13', '2024-04-30'),
(59, 19, 59, 'ALAT-00059', '2025-04-06', '2024-04-17'),
(60, 20, 60, 'ALAT-00060', '2025-03-30', '2024-04-04'),
(61, 1, 61, 'ALAT-00061', '2025-03-23', '2024-03-22'),
(62, 2, 62, 'ALAT-00062', '2025-03-16', '2024-03-09'),
(63, 3, 63, 'ALAT-00063', '2025-03-09', '2024-02-25'),
(64, 4, 64, 'ALAT-00064', '2025-03-02', '2024-02-12'),
(65, 5, 65, 'ALAT-00065', '2025-02-23', '2024-01-30'),
(66, 6, 66, 'ALAT-00066', '2025-02-16', '2024-01-17'),
(67, 7, 67, 'ALAT-00067', '2025-02-09', '2024-01-04'),
(68, 8, 68, 'ALAT-00068', '2025-02-02', '2023-12-22'),
(69, 9, 69, 'ALAT-00069', '2025-01-26', '2023-12-09'),
(70, 10, 70, 'ALAT-00070', '2025-01-19', '2023-11-26'),
(71, 11, 71, 'ALAT-00071', '2025-01-12', '2023-11-13'),
(72, 12, 72, 'ALAT-00072', '2025-01-05', '2023-10-31'),
(73, 13, 73, 'ALAT-00073', '2024-12-29', '2023-10-18'),
(74, 14, 74, 'ALAT-00074', '2024-12-22', '2023-10-05'),
(75, 15, 75, 'ALAT-00075', '2024-12-15', '2023-09-22'),
(76, 16, 76, 'ALAT-00076', '2024-12-08', '2023-09-09'),
(77, 17, 77, 'ALAT-00077', '2024-12-01', '2023-08-27'),
(78, 18, 78, 'ALAT-00078', '2024-11-24', '2023-08-14'),
(79, 19, 79, 'ALAT-00079', '2024-11-17', '2023-08-01'),
(80, 20, 80, 'ALAT-00080', '2024-11-10', '2023-07-19'),
(81, 1, 81, 'ALAT-00081', '2024-11-03', '2023-07-06'),
(82, 2, 82, 'ALAT-00082', '2024-10-27', '2023-06-23'),
(83, 3, 83, 'ALAT-00083', '2024-10-20', '2023-06-10'),
(84, 4, 84, 'ALAT-00084', '2024-10-13', '2023-05-28'),
(85, 5, 85, 'ALAT-00085', '2024-10-06', '2023-05-15'),
(86, 6, 86, 'ALAT-00086', '2024-09-29', '2023-05-02'),
(87, 7, 87, 'ALAT-00087', '2024-09-22', '2023-04-19'),
(88, 8, 88, 'ALAT-00088', '2024-09-15', '2023-04-06'),
(89, 9, 89, 'ALAT-00089', '2024-09-08', '2023-03-24'),
(90, 10, 90, 'ALAT-00090', '2024-09-01', '2023-03-11'),
(91, 11, 91, 'ALAT-00091', '2024-08-25', '2023-02-26'),
(92, 12, 92, 'ALAT-00092', '2024-08-18', '2023-02-13'),
(93, 13, 93, 'ALAT-00093', '2024-08-11', '2023-01-31'),
(94, 14, 94, 'ALAT-00094', '2024-08-04', '2023-01-18'),
(95, 15, 95, 'ALAT-00095', '2024-07-28', '2023-01-05'),
(96, 16, 96, 'ALAT-00096', '2024-07-21', '2022-12-23'),
(97, 17, 97, 'ALAT-00097', '2024-07-14', '2022-12-10'),
(98, 18, 98, 'ALAT-00098', '2024-07-07', '2022-11-27'),
(99, 19, 99, 'ALAT-00099', '2024-06-30', '2022-11-14'),
(100, 20, 100, 'ALAT-00100', '2024-06-23', '2022-11-01'),
(101, 1, 1, 'ALAT-00101', '2024-06-16', '2022-10-19'),
(102, 2, 2, 'ALAT-00102', '2024-06-09', '2022-10-06'),
(103, 3, 3, 'ALAT-00103', '2024-06-02', '2022-09-23'),
(104, 4, 4, 'ALAT-00104', '2024-05-26', '2022-09-10'),
(105, 5, 5, 'ALAT-00105', '2024-05-19', '2022-08-28'),
(106, 6, 6, 'ALAT-00106', '2024-05-12', '2022-08-15'),
(107, 7, 7, 'ALAT-00107', '2024-05-05', '2022-08-02'),
(108, 8, 8, 'ALAT-00108', '2024-04-28', '2022-07-20'),
(109, 9, 9, 'ALAT-00109', '2024-04-21', '2022-07-07'),
(110, 10, 10, 'ALAT-00110', '2024-04-14', '2022-06-24'),
(111, 11, 11, 'ALAT-00111', '2024-04-07', '2022-06-11'),
(112, 12, 12, 'ALAT-00112', '2024-03-31', '2022-05-29'),
(113, 13, 13, 'ALAT-00113', '2024-03-24', '2022-05-16'),
(114, 14, 14, 'ALAT-00114', '2024-03-17', '2022-05-03'),
(115, 15, 15, 'ALAT-00115', '2024-03-10', '2022-04-20'),
(116, 16, 16, 'ALAT-00116', '2024-03-03', '2022-04-07'),
(117, 17, 17, 'ALAT-00117', '2024-02-25', '2022-03-25'),
(118, 18, 18, 'ALAT-00118', '2024-02-18', '2022-03-12'),
(119, 19, 19, 'ALAT-00119', '2024-02-11', '2022-02-27'),
(120, 20, 20, 'ALAT-00120', '2024-02-04', '2022-02-14'),
(121, 1, 21, 'ALAT-00121', '2024-01-28', '2022-02-01'),
(122, 2, 22, 'ALAT-00122', '2024-01-21', '2022-01-19'),
(123, 3, 23, 'ALAT-00123', '2024-01-14', '2022-01-06'),
(124, 4, 24, 'ALAT-00124', '2024-01-07', '2021-12-24'),
(125, 5, 25, 'ALAT-00125', '2023-12-31', '2021-12-11'),
(126, 6, 26, 'ALAT-00126', '2023-12-24', '2021-11-28'),
(127, 7, 27, 'ALAT-00127', '2023-12-17', '2021-11-15'),
(128, 8, 28, 'ALAT-00128', '2023-12-10', '2021-11-02'),
(129, 9, 29, 'ALAT-00129', '2023-12-03', '2021-10-20'),
(130, 10, 30, 'ALAT-00130', '2023-11-26', '2021-10-07'),
(131, 11, 31, 'ALAT-00131', '2023-11-19', '2021-09-24'),
(132, 12, 32, 'ALAT-00132', '2023-11-12', '2021-09-11'),
(133, 13, 33, 'ALAT-00133', '2023-11-05', '2021-08-29'),
(134, 14, 34, 'ALAT-00134', '2023-10-29', '2021-08-16'),
(135, 15, 35, 'ALAT-00135', '2023-10-22', '2021-08-03'),
(136, 16, 36, 'ALAT-00136', '2023-10-15', '2021-07-21'),
(137, 17, 37, 'ALAT-00137', '2023-10-08', '2021-07-08'),
(138, 18, 38, 'ALAT-00138', '2023-10-01', '2021-06-25'),
(139, 19, 39, 'ALAT-00139', '2023-09-24', '2021-06-12'),
(140, 20, 40, 'ALAT-00140', '2023-09-17', '2021-05-30'),
(141, 1, 41, 'ALAT-00141', '2023-09-10', '2021-05-17'),
(142, 2, 42, 'ALAT-00142', '2023-09-03', '2021-05-04'),
(143, 3, 43, 'ALAT-00143', '2026-05-23', '2021-04-21'),
(144, 4, 44, 'ALAT-00144', '2026-05-16', '2021-04-08'),
(145, 5, 45, 'ALAT-00145', '2026-05-09', '2021-03-26'),
(146, 6, 46, 'ALAT-00146', '2026-05-02', '2021-03-13'),
(147, 7, 47, 'ALAT-00147', '2026-04-25', '2021-02-28'),
(148, 8, 48, 'ALAT-00148', '2026-04-18', '2021-02-15'),
(149, 9, 49, 'ALAT-00149', '2026-04-11', '2021-02-02'),
(150, 10, 50, 'ALAT-00150', '2026-04-04', '2021-01-20'),
(151, 11, 51, 'ALAT-00151', '2026-03-28', '2021-01-07'),
(152, 12, 52, 'ALAT-00152', '2026-03-21', '2020-12-25'),
(153, 13, 53, 'ALAT-00153', '2026-03-14', '2020-12-12'),
(154, 14, 54, 'ALAT-00154', '2026-03-07', '2026-05-22'),
(155, 15, 55, 'ALAT-00155', '2026-02-28', '2026-05-09'),
(156, 16, 56, 'ALAT-00156', '2026-02-21', '2026-04-26'),
(157, 17, 57, 'ALAT-00157', '2026-02-14', '2026-04-13'),
(158, 18, 58, 'ALAT-00158', '2026-02-07', '2026-03-31'),
(159, 19, 59, 'ALAT-00159', '2026-01-31', '2026-03-18'),
(160, 20, 60, 'ALAT-00160', '2026-01-24', '2026-03-05'),
(161, 1, 61, 'ALAT-00161', '2026-01-17', '2026-02-20'),
(162, 2, 62, 'ALAT-00162', '2026-01-10', '2026-02-07'),
(163, 3, 63, 'ALAT-00163', '2026-01-03', '2026-01-25'),
(164, 4, 64, 'ALAT-00164', '2025-12-27', '2026-01-12'),
(165, 5, 65, 'ALAT-00165', '2025-12-20', '2025-12-30'),
(166, 6, 66, 'ALAT-00166', '2025-12-13', '2025-12-17'),
(167, 7, 67, 'ALAT-00167', '2025-12-06', '2025-12-04'),
(168, 8, 68, 'ALAT-00168', '2025-11-29', '2025-11-21'),
(169, 9, 69, 'ALAT-00169', '2025-11-22', '2025-11-08'),
(170, 10, 70, 'ALAT-00170', '2025-11-15', '2025-10-26'),
(171, 11, 71, 'ALAT-00171', '2025-11-08', '2025-10-13'),
(172, 12, 72, 'ALAT-00172', '2025-11-01', '2025-09-30'),
(173, 13, 73, 'ALAT-00173', '2025-10-25', '2025-09-17'),
(174, 14, 74, 'ALAT-00174', '2025-10-18', '2025-09-04'),
(175, 15, 75, 'ALAT-00175', '2025-10-11', '2025-08-22'),
(176, 16, 76, 'ALAT-00176', '2025-10-04', '2025-08-09'),
(177, 17, 77, 'ALAT-00177', '2025-09-27', '2025-07-27'),
(178, 18, 78, 'ALAT-00178', '2025-09-20', '2025-07-14'),
(179, 19, 79, 'ALAT-00179', '2025-09-13', '2025-07-01'),
(180, 20, 80, 'ALAT-00180', '2025-09-06', '2025-06-18'),
(181, 1, 81, 'ALAT-00181', '2025-08-30', '2025-06-05'),
(182, 2, 82, 'ALAT-00182', '2025-08-23', '2025-05-23'),
(183, 3, 83, 'ALAT-00183', '2025-08-16', '2025-05-10'),
(184, 4, 84, 'ALAT-00184', '2025-08-09', '2025-04-27'),
(185, 5, 85, 'ALAT-00185', '2025-08-02', '2025-04-14'),
(186, 6, 86, 'ALAT-00186', '2025-07-26', '2025-04-01'),
(187, 7, 87, 'ALAT-00187', '2025-07-19', '2025-03-19'),
(188, 8, 88, 'ALAT-00188', '2025-07-12', '2025-03-06'),
(189, 9, 89, 'ALAT-00189', '2025-07-05', '2025-02-21'),
(190, 10, 90, 'ALAT-00190', '2025-06-28', '2025-02-08'),
(191, 11, 91, 'ALAT-00191', '2025-06-21', '2025-01-26'),
(192, 12, 92, 'ALAT-00192', '2025-06-14', '2025-01-13'),
(193, 13, 93, 'ALAT-00193', '2025-06-07', '2024-12-31'),
(194, 14, 94, 'ALAT-00194', '2025-05-31', '2024-12-18'),
(195, 15, 95, 'ALAT-00195', '2025-05-24', '2024-12-05'),
(196, 16, 96, 'ALAT-00196', '2025-05-17', '2024-11-22'),
(197, 17, 97, 'ALAT-00197', '2025-05-10', '2024-11-09'),
(198, 18, 98, 'ALAT-00198', '2025-05-03', '2024-10-27'),
(199, 19, 99, 'ALAT-00199', '2025-04-26', '2024-10-14'),
(200, 20, 100, 'ALAT-00200', '2025-04-19', '2024-10-01');

-- --------------------------------------------------------

--
-- Table structure for table `dizajner`
--

CREATE TABLE `dizajner` (
  `id_dizajnera` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `dizajner`
--

INSERT INTO `dizajner` (`id_dizajnera`) VALUES
(2),
(4),
(6),
(8),
(10),
(12),
(14),
(16),
(18),
(20),
(22),
(24),
(26),
(28),
(30),
(32),
(34),
(36),
(38),
(40),
(42),
(44),
(46),
(48),
(50),
(52),
(54),
(56),
(58),
(60),
(62),
(64),
(66),
(68),
(70),
(72),
(74),
(76),
(78),
(80),
(82),
(84),
(86),
(88),
(90),
(92),
(94),
(96),
(98),
(100),
(102),
(104),
(106),
(108),
(110),
(112),
(114),
(116),
(118),
(120),
(122),
(124),
(126),
(128),
(130),
(132),
(134),
(136),
(138),
(140),
(142),
(144),
(146),
(148),
(150),
(152),
(154),
(156),
(158),
(160),
(162),
(164),
(166),
(168),
(170),
(172),
(174),
(176),
(178),
(180),
(182),
(184),
(186),
(188),
(190),
(192),
(194),
(196),
(198),
(200),
(202),
(204),
(206),
(208),
(210),
(212),
(214),
(216),
(218),
(220),
(222),
(224),
(226),
(228),
(230),
(232),
(234),
(236),
(238),
(240),
(242),
(244),
(246),
(248),
(250),
(252),
(254),
(256),
(258),
(260),
(262),
(264),
(266),
(268),
(270),
(272),
(274),
(276),
(278),
(280),
(282),
(284),
(286),
(288),
(290),
(292),
(294),
(296),
(298),
(300);

-- --------------------------------------------------------

--
-- Table structure for table `eksperiment`
--

CREATE TABLE `eksperiment` (
  `id_eksperimenta` int(11) NOT NULL,
  `id_okvira` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `tip` varchar(50) NOT NULL,
  `ciljevi` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `eksperiment`
--

INSERT INTO `eksperiment` (`id_eksperimenta`, `id_okvira`, `naziv`, `tip`, `ciljevi`) VALUES
(1, 1, 'Eksperiment 001 - test ravnoteze', 'simulacija trzista', 'Cilj #1: proveriti hipotezu o averziji ka gubitku'),
(2, 2, 'Eksperiment 002 - simulacija aukcije', 'dilema zatvorenika', 'Cilj #2: proveriti hipotezu o kooperativnom ponasanju'),
(3, 3, 'Eksperiment 003 - donosenje pod rizikom', 'ultimatum igra', 'Cilj #3: proveriti hipotezu o efikasnosti aukcije'),
(4, 4, 'Eksperiment 004 - tržišni eksperiment', 'javna dobra', 'Cilj #4: proveriti hipotezu o konvergenciji ka ravnotezi'),
(5, 5, 'Eksperiment 005 - grupna saradnja', 'trzisna ravnoteza', 'Cilj #5: proveriti hipotezu o racionalnosti agenata'),
(6, 6, 'Eksperiment 006 - analiza ponasanja', 'behavioralni test', 'Cilj #6: proveriti hipotezu o averziji ka gubitku'),
(7, 7, 'Eksperiment 007 - test ravnoteze', 'anketno istrazivanje', 'Cilj #7: proveriti hipotezu o kooperativnom ponasanju'),
(8, 8, 'Eksperiment 008 - simulacija aukcije', 'aukcija', 'Cilj #8: proveriti hipotezu o efikasnosti aukcije'),
(9, 9, 'Eksperiment 009 - donosenje pod rizikom', 'simulacija trzista', 'Cilj #9: proveriti hipotezu o konvergenciji ka ravnotezi'),
(10, 10, 'Eksperiment 010 - tržišni eksperiment', 'dilema zatvorenika', 'Cilj #10: proveriti hipotezu o racionalnosti agenata'),
(11, 11, 'Eksperiment 011 - grupna saradnja', 'ultimatum igra', 'Cilj #11: proveriti hipotezu o averziji ka gubitku'),
(12, 12, 'Eksperiment 012 - analiza ponasanja', 'javna dobra', 'Cilj #12: proveriti hipotezu o kooperativnom ponasanju'),
(13, 13, 'Eksperiment 013 - test ravnoteze', 'trzisna ravnoteza', 'Cilj #13: proveriti hipotezu o efikasnosti aukcije'),
(14, 14, 'Eksperiment 014 - simulacija aukcije', 'behavioralni test', 'Cilj #14: proveriti hipotezu o konvergenciji ka ravnotezi'),
(15, 15, 'Eksperiment 015 - donosenje pod rizikom', 'anketno istrazivanje', 'Cilj #15: proveriti hipotezu o racionalnosti agenata'),
(16, 1, 'Eksperiment 016 - tržišni eksperiment', 'aukcija', 'Cilj #16: proveriti hipotezu o averziji ka gubitku'),
(17, 2, 'Eksperiment 017 - grupna saradnja', 'simulacija trzista', 'Cilj #17: proveriti hipotezu o kooperativnom ponasanju'),
(18, 3, 'Eksperiment 018 - analiza ponasanja', 'dilema zatvorenika', 'Cilj #18: proveriti hipotezu o efikasnosti aukcije'),
(19, 4, 'Eksperiment 019 - test ravnoteze', 'ultimatum igra', 'Cilj #19: proveriti hipotezu o konvergenciji ka ravnotezi'),
(20, 5, 'Eksperiment 020 - simulacija aukcije', 'javna dobra', 'Cilj #20: proveriti hipotezu o racionalnosti agenata'),
(21, 6, 'Eksperiment 021 - donosenje pod rizikom', 'trzisna ravnoteza', 'Cilj #21: proveriti hipotezu o averziji ka gubitku'),
(22, 7, 'Eksperiment 022 - tržišni eksperiment', 'behavioralni test', 'Cilj #22: proveriti hipotezu o kooperativnom ponasanju'),
(23, 8, 'Eksperiment 023 - grupna saradnja', 'anketno istrazivanje', 'Cilj #23: proveriti hipotezu o efikasnosti aukcije'),
(24, 9, 'Eksperiment 024 - analiza ponasanja', 'aukcija', 'Cilj #24: proveriti hipotezu o konvergenciji ka ravnotezi'),
(25, 10, 'Eksperiment 025 - test ravnoteze', 'simulacija trzista', 'Cilj #25: proveriti hipotezu o racionalnosti agenata'),
(26, 11, 'Eksperiment 026 - simulacija aukcije', 'dilema zatvorenika', 'Cilj #26: proveriti hipotezu o averziji ka gubitku'),
(27, 12, 'Eksperiment 027 - donosenje pod rizikom', 'ultimatum igra', 'Cilj #27: proveriti hipotezu o kooperativnom ponasanju'),
(28, 13, 'Eksperiment 028 - tržišni eksperiment', 'javna dobra', 'Cilj #28: proveriti hipotezu o efikasnosti aukcije'),
(29, 14, 'Eksperiment 029 - grupna saradnja', 'trzisna ravnoteza', 'Cilj #29: proveriti hipotezu o konvergenciji ka ravnotezi'),
(30, 15, 'Eksperiment 030 - analiza ponasanja', 'behavioralni test', 'Cilj #30: proveriti hipotezu o racionalnosti agenata'),
(31, 1, 'Eksperiment 031 - test ravnoteze', 'anketno istrazivanje', 'Cilj #31: proveriti hipotezu o averziji ka gubitku'),
(32, 2, 'Eksperiment 032 - simulacija aukcije', 'aukcija', 'Cilj #32: proveriti hipotezu o kooperativnom ponasanju'),
(33, 3, 'Eksperiment 033 - donosenje pod rizikom', 'simulacija trzista', 'Cilj #33: proveriti hipotezu o efikasnosti aukcije'),
(34, 4, 'Eksperiment 034 - tržišni eksperiment', 'dilema zatvorenika', 'Cilj #34: proveriti hipotezu o konvergenciji ka ravnotezi'),
(35, 5, 'Eksperiment 035 - grupna saradnja', 'ultimatum igra', 'Cilj #35: proveriti hipotezu o racionalnosti agenata'),
(36, 6, 'Eksperiment 036 - analiza ponasanja', 'javna dobra', 'Cilj #36: proveriti hipotezu o averziji ka gubitku'),
(37, 7, 'Eksperiment 037 - test ravnoteze', 'trzisna ravnoteza', 'Cilj #37: proveriti hipotezu o kooperativnom ponasanju'),
(38, 8, 'Eksperiment 038 - simulacija aukcije', 'behavioralni test', 'Cilj #38: proveriti hipotezu o efikasnosti aukcije'),
(39, 9, 'Eksperiment 039 - donosenje pod rizikom', 'anketno istrazivanje', 'Cilj #39: proveriti hipotezu o konvergenciji ka ravnotezi'),
(40, 10, 'Eksperiment 040 - tržišni eksperiment', 'aukcija', 'Cilj #40: proveriti hipotezu o racionalnosti agenata'),
(41, 11, 'Eksperiment 041 - grupna saradnja', 'simulacija trzista', 'Cilj #41: proveriti hipotezu o averziji ka gubitku'),
(42, 12, 'Eksperiment 042 - analiza ponasanja', 'dilema zatvorenika', 'Cilj #42: proveriti hipotezu o kooperativnom ponasanju'),
(43, 13, 'Eksperiment 043 - test ravnoteze', 'ultimatum igra', 'Cilj #43: proveriti hipotezu o efikasnosti aukcije'),
(44, 14, 'Eksperiment 044 - simulacija aukcije', 'javna dobra', 'Cilj #44: proveriti hipotezu o konvergenciji ka ravnotezi'),
(45, 15, 'Eksperiment 045 - donosenje pod rizikom', 'trzisna ravnoteza', 'Cilj #45: proveriti hipotezu o racionalnosti agenata'),
(46, 1, 'Eksperiment 046 - tržišni eksperiment', 'behavioralni test', 'Cilj #46: proveriti hipotezu o averziji ka gubitku'),
(47, 2, 'Eksperiment 047 - grupna saradnja', 'anketno istrazivanje', 'Cilj #47: proveriti hipotezu o kooperativnom ponasanju'),
(48, 3, 'Eksperiment 048 - analiza ponasanja', 'aukcija', 'Cilj #48: proveriti hipotezu o efikasnosti aukcije'),
(49, 4, 'Eksperiment 049 - test ravnoteze', 'simulacija trzista', 'Cilj #49: proveriti hipotezu o konvergenciji ka ravnotezi'),
(50, 5, 'Eksperiment 050 - simulacija aukcije', 'dilema zatvorenika', 'Cilj #50: proveriti hipotezu o racionalnosti agenata'),
(51, 6, 'Eksperiment 051 - donosenje pod rizikom', 'ultimatum igra', 'Cilj #51: proveriti hipotezu o averziji ka gubitku'),
(52, 7, 'Eksperiment 052 - tržišni eksperiment', 'javna dobra', 'Cilj #52: proveriti hipotezu o kooperativnom ponasanju'),
(53, 8, 'Eksperiment 053 - grupna saradnja', 'trzisna ravnoteza', 'Cilj #53: proveriti hipotezu o efikasnosti aukcije'),
(54, 9, 'Eksperiment 054 - analiza ponasanja', 'behavioralni test', 'Cilj #54: proveriti hipotezu o konvergenciji ka ravnotezi'),
(55, 10, 'Eksperiment 055 - test ravnoteze', 'anketno istrazivanje', 'Cilj #55: proveriti hipotezu o racionalnosti agenata'),
(56, 11, 'Eksperiment 056 - simulacija aukcije', 'aukcija', 'Cilj #56: proveriti hipotezu o averziji ka gubitku'),
(57, 12, 'Eksperiment 057 - donosenje pod rizikom', 'simulacija trzista', 'Cilj #57: proveriti hipotezu o kooperativnom ponasanju'),
(58, 13, 'Eksperiment 058 - tržišni eksperiment', 'dilema zatvorenika', 'Cilj #58: proveriti hipotezu o efikasnosti aukcije'),
(59, 14, 'Eksperiment 059 - grupna saradnja', 'ultimatum igra', 'Cilj #59: proveriti hipotezu o konvergenciji ka ravnotezi'),
(60, 15, 'Eksperiment 060 - analiza ponasanja', 'javna dobra', 'Cilj #60: proveriti hipotezu o racionalnosti agenata'),
(61, 1, 'Eksperiment 061 - test ravnoteze', 'trzisna ravnoteza', 'Cilj #61: proveriti hipotezu o averziji ka gubitku'),
(62, 2, 'Eksperiment 062 - simulacija aukcije', 'behavioralni test', 'Cilj #62: proveriti hipotezu o kooperativnom ponasanju'),
(63, 3, 'Eksperiment 063 - donosenje pod rizikom', 'anketno istrazivanje', 'Cilj #63: proveriti hipotezu o efikasnosti aukcije'),
(64, 4, 'Eksperiment 064 - tržišni eksperiment', 'aukcija', 'Cilj #64: proveriti hipotezu o konvergenciji ka ravnotezi'),
(65, 5, 'Eksperiment 065 - grupna saradnja', 'simulacija trzista', 'Cilj #65: proveriti hipotezu o racionalnosti agenata'),
(66, 6, 'Eksperiment 066 - analiza ponasanja', 'dilema zatvorenika', 'Cilj #66: proveriti hipotezu o averziji ka gubitku'),
(67, 7, 'Eksperiment 067 - test ravnoteze', 'ultimatum igra', 'Cilj #67: proveriti hipotezu o kooperativnom ponasanju'),
(68, 8, 'Eksperiment 068 - simulacija aukcije', 'javna dobra', 'Cilj #68: proveriti hipotezu o efikasnosti aukcije'),
(69, 9, 'Eksperiment 069 - donosenje pod rizikom', 'trzisna ravnoteza', 'Cilj #69: proveriti hipotezu o konvergenciji ka ravnotezi'),
(70, 10, 'Eksperiment 070 - tržišni eksperiment', 'behavioralni test', 'Cilj #70: proveriti hipotezu o racionalnosti agenata'),
(71, 11, 'Eksperiment 071 - grupna saradnja', 'anketno istrazivanje', 'Cilj #71: proveriti hipotezu o averziji ka gubitku'),
(72, 12, 'Eksperiment 072 - analiza ponasanja', 'aukcija', 'Cilj #72: proveriti hipotezu o kooperativnom ponasanju'),
(73, 13, 'Eksperiment 073 - test ravnoteze', 'simulacija trzista', 'Cilj #73: proveriti hipotezu o efikasnosti aukcije'),
(74, 14, 'Eksperiment 074 - simulacija aukcije', 'dilema zatvorenika', 'Cilj #74: proveriti hipotezu o konvergenciji ka ravnotezi'),
(75, 15, 'Eksperiment 075 - donosenje pod rizikom', 'ultimatum igra', 'Cilj #75: proveriti hipotezu o racionalnosti agenata'),
(76, 1, 'Eksperiment 076 - tržišni eksperiment', 'javna dobra', 'Cilj #76: proveriti hipotezu o averziji ka gubitku'),
(77, 2, 'Eksperiment 077 - grupna saradnja', 'trzisna ravnoteza', 'Cilj #77: proveriti hipotezu o kooperativnom ponasanju'),
(78, 3, 'Eksperiment 078 - analiza ponasanja', 'behavioralni test', 'Cilj #78: proveriti hipotezu o efikasnosti aukcije'),
(79, 4, 'Eksperiment 079 - test ravnoteze', 'anketno istrazivanje', 'Cilj #79: proveriti hipotezu o konvergenciji ka ravnotezi'),
(80, 5, 'Eksperiment 080 - simulacija aukcije', 'aukcija', 'Cilj #80: proveriti hipotezu o racionalnosti agenata'),
(81, 6, 'Eksperiment 081 - donosenje pod rizikom', 'simulacija trzista', 'Cilj #81: proveriti hipotezu o averziji ka gubitku'),
(82, 7, 'Eksperiment 082 - tržišni eksperiment', 'dilema zatvorenika', 'Cilj #82: proveriti hipotezu o kooperativnom ponasanju'),
(83, 8, 'Eksperiment 083 - grupna saradnja', 'ultimatum igra', 'Cilj #83: proveriti hipotezu o efikasnosti aukcije'),
(84, 9, 'Eksperiment 084 - analiza ponasanja', 'javna dobra', 'Cilj #84: proveriti hipotezu o konvergenciji ka ravnotezi'),
(85, 10, 'Eksperiment 085 - test ravnoteze', 'trzisna ravnoteza', 'Cilj #85: proveriti hipotezu o racionalnosti agenata'),
(86, 11, 'Eksperiment 086 - simulacija aukcije', 'behavioralni test', 'Cilj #86: proveriti hipotezu o averziji ka gubitku'),
(87, 12, 'Eksperiment 087 - donosenje pod rizikom', 'anketno istrazivanje', 'Cilj #87: proveriti hipotezu o kooperativnom ponasanju'),
(88, 13, 'Eksperiment 088 - tržišni eksperiment', 'aukcija', 'Cilj #88: proveriti hipotezu o efikasnosti aukcije'),
(89, 14, 'Eksperiment 089 - grupna saradnja', 'simulacija trzista', 'Cilj #89: proveriti hipotezu o konvergenciji ka ravnotezi'),
(90, 15, 'Eksperiment 090 - analiza ponasanja', 'dilema zatvorenika', 'Cilj #90: proveriti hipotezu o racionalnosti agenata'),
(91, 1, 'Eksperiment 091 - test ravnoteze', 'ultimatum igra', 'Cilj #91: proveriti hipotezu o averziji ka gubitku'),
(92, 2, 'Eksperiment 092 - simulacija aukcije', 'javna dobra', 'Cilj #92: proveriti hipotezu o kooperativnom ponasanju'),
(93, 3, 'Eksperiment 093 - donosenje pod rizikom', 'trzisna ravnoteza', 'Cilj #93: proveriti hipotezu o efikasnosti aukcije'),
(94, 4, 'Eksperiment 094 - tržišni eksperiment', 'behavioralni test', 'Cilj #94: proveriti hipotezu o konvergenciji ka ravnotezi'),
(95, 5, 'Eksperiment 095 - grupna saradnja', 'anketno istrazivanje', 'Cilj #95: proveriti hipotezu o racionalnosti agenata'),
(96, 6, 'Eksperiment 096 - analiza ponasanja', 'aukcija', 'Cilj #96: proveriti hipotezu o averziji ka gubitku'),
(97, 7, 'Eksperiment 097 - test ravnoteze', 'simulacija trzista', 'Cilj #97: proveriti hipotezu o kooperativnom ponasanju'),
(98, 8, 'Eksperiment 098 - simulacija aukcije', 'dilema zatvorenika', 'Cilj #98: proveriti hipotezu o efikasnosti aukcije'),
(99, 9, 'Eksperiment 099 - donosenje pod rizikom', 'ultimatum igra', 'Cilj #99: proveriti hipotezu o konvergenciji ka ravnotezi'),
(100, 10, 'Eksperiment 100 - tržišni eksperiment', 'javna dobra', 'Cilj #100: proveriti hipotezu o racionalnosti agenata');

-- --------------------------------------------------------

--
-- Table structure for table `eksperiment_alat`
--

CREATE TABLE `eksperiment_alat` (
  `id_eksperimenta` int(11) NOT NULL,
  `id_alata` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `eksperiment_alat`
--

INSERT INTO `eksperiment_alat` (`id_eksperimenta`, `id_alata`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 1),
(22, 2),
(23, 3),
(24, 4),
(25, 5),
(26, 6),
(27, 7),
(28, 8),
(29, 9),
(30, 10),
(31, 11),
(32, 12),
(33, 13),
(34, 14),
(35, 15),
(36, 16),
(37, 17),
(38, 18),
(39, 19),
(40, 20),
(41, 1),
(42, 2),
(43, 3),
(44, 4),
(45, 5),
(46, 6),
(47, 7),
(48, 8),
(49, 9),
(50, 10),
(51, 11),
(52, 12),
(53, 13),
(54, 14),
(55, 15),
(56, 16),
(57, 17),
(58, 18),
(59, 19),
(60, 20),
(61, 1),
(62, 2),
(63, 3),
(64, 4),
(65, 5),
(66, 6),
(67, 7),
(68, 8),
(69, 9),
(70, 10),
(71, 11),
(72, 12),
(73, 13),
(74, 14),
(75, 15),
(76, 16),
(77, 17),
(78, 18),
(79, 19),
(80, 20),
(81, 1),
(82, 2),
(83, 3),
(84, 4),
(85, 5),
(86, 6),
(87, 7),
(88, 8),
(89, 9),
(90, 10),
(91, 11),
(92, 12),
(93, 13),
(94, 14),
(95, 15),
(96, 16),
(97, 17),
(98, 18),
(99, 19),
(100, 20);

-- --------------------------------------------------------

--
-- Table structure for table `eksperiment_dizajner`
--

CREATE TABLE `eksperiment_dizajner` (
  `id_eksperimenta` int(11) NOT NULL,
  `id_istrazivaca` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `eksperiment_dizajner`
--

INSERT INTO `eksperiment_dizajner` (`id_eksperimenta`, `id_istrazivaca`) VALUES
(1, 2),
(2, 4),
(3, 6),
(4, 8),
(5, 10),
(6, 12),
(7, 14),
(8, 16),
(9, 18),
(10, 20),
(11, 22),
(12, 24),
(13, 26),
(14, 28),
(15, 30),
(16, 32),
(17, 34),
(18, 36),
(19, 38),
(20, 40),
(21, 42),
(22, 44),
(23, 46),
(24, 48),
(25, 50),
(26, 52),
(27, 54),
(28, 56),
(29, 58),
(30, 60),
(31, 62),
(32, 64),
(33, 66),
(34, 68),
(35, 70),
(36, 72),
(37, 74),
(38, 76),
(39, 78),
(40, 80),
(41, 82),
(42, 84),
(43, 86),
(44, 88),
(45, 90),
(46, 92),
(47, 94),
(48, 96),
(49, 98),
(50, 100),
(51, 102),
(52, 104),
(53, 106),
(54, 108),
(55, 110),
(56, 112),
(57, 114),
(58, 116),
(59, 118),
(60, 120),
(61, 2),
(62, 4),
(63, 6),
(64, 8),
(65, 10),
(66, 12),
(67, 14),
(68, 16),
(69, 18),
(70, 20),
(71, 22),
(72, 24),
(73, 26),
(74, 28),
(75, 30),
(76, 32),
(77, 34),
(78, 36),
(79, 38),
(80, 40),
(81, 42),
(82, 44),
(83, 46),
(84, 48),
(85, 50),
(86, 52),
(87, 54),
(88, 56),
(89, 58),
(90, 60),
(91, 62),
(92, 64),
(93, 66),
(94, 68),
(95, 70),
(96, 72),
(97, 74),
(98, 76),
(99, 78),
(100, 80);

-- --------------------------------------------------------

--
-- Table structure for table `eksperiment_resurs`
--

CREATE TABLE `eksperiment_resurs` (
  `id_eksperimenta` int(11) NOT NULL,
  `id_resursa` int(11) NOT NULL,
  `kolicina` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `eksperiment_resurs`
--

INSERT INTO `eksperiment_resurs` (`id_eksperimenta`, `id_resursa`, `kolicina`) VALUES
(1, 7, '12.00'),
(2, 14, '23.00'),
(3, 21, '34.00'),
(4, 28, '45.00'),
(5, 35, '56.00'),
(6, 42, '67.00'),
(7, 49, '78.00'),
(8, 56, '89.00'),
(9, 63, '100.00'),
(10, 70, '111.00'),
(11, 77, '122.00'),
(12, 84, '133.00'),
(13, 91, '144.00'),
(14, 98, '155.00'),
(15, 5, '166.00'),
(16, 12, '177.00'),
(17, 19, '188.00'),
(18, 26, '199.00'),
(19, 33, '210.00'),
(20, 40, '221.00'),
(21, 47, '232.00'),
(22, 54, '243.00'),
(23, 61, '254.00'),
(24, 68, '265.00'),
(25, 75, '276.00'),
(26, 82, '287.00'),
(27, 89, '298.00'),
(28, 96, '309.00'),
(29, 3, '320.00'),
(30, 10, '331.00'),
(31, 17, '342.00'),
(32, 24, '353.00'),
(33, 31, '364.00'),
(34, 38, '375.00'),
(35, 45, '386.00'),
(36, 52, '397.00'),
(37, 59, '408.00'),
(38, 66, '419.00'),
(39, 73, '430.00'),
(40, 80, '441.00'),
(41, 87, '452.00'),
(42, 94, '463.00'),
(43, 1, '474.00'),
(44, 8, '485.00'),
(45, 15, '496.00'),
(46, 22, '7.00'),
(47, 29, '18.00'),
(48, 36, '29.00'),
(49, 43, '40.00'),
(50, 50, '51.00'),
(51, 57, '62.00'),
(52, 64, '73.00'),
(53, 71, '84.00'),
(54, 78, '95.00'),
(55, 85, '106.00'),
(56, 92, '117.00'),
(57, 99, '128.00'),
(58, 6, '139.00'),
(59, 13, '150.00'),
(60, 20, '161.00'),
(61, 27, '172.00'),
(62, 34, '183.00'),
(63, 41, '194.00'),
(64, 48, '205.00'),
(65, 55, '216.00'),
(66, 62, '227.00'),
(67, 69, '238.00'),
(68, 76, '249.00'),
(69, 83, '260.00'),
(70, 90, '271.00'),
(71, 97, '282.00'),
(72, 4, '293.00'),
(73, 11, '304.00'),
(74, 18, '315.00'),
(75, 25, '326.00'),
(76, 32, '337.00'),
(77, 39, '348.00'),
(78, 46, '359.00'),
(79, 53, '370.00'),
(80, 60, '381.00'),
(81, 67, '392.00'),
(82, 74, '403.00'),
(83, 81, '414.00'),
(84, 88, '425.00'),
(85, 95, '436.00'),
(86, 2, '447.00'),
(87, 9, '458.00'),
(88, 16, '469.00'),
(89, 23, '480.00'),
(90, 30, '491.00'),
(91, 37, '2.00'),
(92, 44, '13.00'),
(93, 51, '24.00'),
(94, 58, '35.00'),
(95, 65, '46.00'),
(96, 72, '57.00'),
(97, 79, '68.00'),
(98, 86, '79.00'),
(99, 93, '90.00'),
(100, 100, '101.00');

-- --------------------------------------------------------

--
-- Table structure for table `istrazivac`
--

CREATE TABLE `istrazivac` (
  `id_istrazivaca` int(11) NOT NULL,
  `ime` varchar(25) NOT NULL,
  `prezime` varchar(25) NOT NULL,
  `email` varchar(100) NOT NULL,
  `kvalifikacije` text DEFAULT NULL,
  `tip` varchar(30) NOT NULL DEFAULT 'ekonomista' CHECK (`tip` in ('ekonomista','bihevioralni_naucnik','statisticar','psiholog','data_scientist'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `istrazivac`
--

INSERT INTO `istrazivac` (`id_istrazivaca`, `ime`, `prezime`, `email`, `kvalifikacije`, `tip`) VALUES
(1, 'Marko', 'Djordjevic', 'istr001@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(2, 'Jelena', 'Vasic', 'istr002@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(3, 'Petar', 'Jovanovic', 'istr003@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(4, 'Milica', 'Stankovic', 'istr004@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(5, 'Stefan', 'Krstic', 'istr005@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(6, 'Jovana', 'Stojanovic', 'istr006@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(7, 'Nikola', 'Radovanovic', 'istr007@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(8, 'Tamara', 'Jankovic', 'istr008@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(9, 'Luka', 'Markovic', 'istr009@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(10, 'Sara', 'Kostic', 'istr010@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(11, 'Dusan', 'Lazic', 'istr011@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(12, 'Iva', 'Pavlovic', 'istr012@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(13, 'Vuk', 'Milosevic', 'istr013@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(14, 'Mina', 'Ciric', 'istr014@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(15, 'Filip', 'Ilic', 'istr015@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(16, 'Teodora', 'Popovic', 'istr016@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(17, 'Aleksa', 'Milic', 'istr017@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(18, 'Maja', 'Nikolic', 'istr018@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(19, 'Andrija', 'Tomic', 'istr019@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(20, 'Ana', 'Petrovic', 'istr020@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(21, 'Marko', 'Djordjevic', 'istr021@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(22, 'Jelena', 'Vasic', 'istr022@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(23, 'Petar', 'Jovanovic', 'istr023@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(24, 'Milica', 'Stankovic', 'istr024@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(25, 'Stefan', 'Krstic', 'istr025@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(26, 'Jovana', 'Stojanovic', 'istr026@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(27, 'Nikola', 'Radovanovic', 'istr027@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(28, 'Tamara', 'Jankovic', 'istr028@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(29, 'Luka', 'Markovic', 'istr029@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(30, 'Sara', 'Kostic', 'istr030@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(31, 'Dusan', 'Lazic', 'istr031@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(32, 'Iva', 'Pavlovic', 'istr032@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(33, 'Vuk', 'Milosevic', 'istr033@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(34, 'Mina', 'Ciric', 'istr034@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(35, 'Filip', 'Ilic', 'istr035@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(36, 'Teodora', 'Popovic', 'istr036@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(37, 'Aleksa', 'Milic', 'istr037@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(38, 'Maja', 'Nikolic', 'istr038@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(39, 'Andrija', 'Tomic', 'istr039@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(40, 'Ana', 'Petrovic', 'istr040@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(41, 'Marko', 'Djordjevic', 'istr041@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(42, 'Jelena', 'Vasic', 'istr042@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(43, 'Petar', 'Jovanovic', 'istr043@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(44, 'Milica', 'Stankovic', 'istr044@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(45, 'Stefan', 'Krstic', 'istr045@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(46, 'Jovana', 'Stojanovic', 'istr046@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(47, 'Nikola', 'Radovanovic', 'istr047@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(48, 'Tamara', 'Jankovic', 'istr048@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(49, 'Luka', 'Markovic', 'istr049@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(50, 'Sara', 'Kostic', 'istr050@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(51, 'Dusan', 'Lazic', 'istr051@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(52, 'Iva', 'Pavlovic', 'istr052@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(53, 'Vuk', 'Milosevic', 'istr053@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(54, 'Mina', 'Ciric', 'istr054@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(55, 'Filip', 'Ilic', 'istr055@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(56, 'Teodora', 'Popovic', 'istr056@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(57, 'Aleksa', 'Milic', 'istr057@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(58, 'Maja', 'Nikolic', 'istr058@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(59, 'Andrija', 'Tomic', 'istr059@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(60, 'Ana', 'Petrovic', 'istr060@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(61, 'Marko', 'Djordjevic', 'istr061@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(62, 'Jelena', 'Vasic', 'istr062@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(63, 'Petar', 'Jovanovic', 'istr063@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(64, 'Milica', 'Stankovic', 'istr064@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(65, 'Stefan', 'Krstic', 'istr065@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(66, 'Jovana', 'Stojanovic', 'istr066@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(67, 'Nikola', 'Radovanovic', 'istr067@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(68, 'Tamara', 'Jankovic', 'istr068@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(69, 'Luka', 'Markovic', 'istr069@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(70, 'Sara', 'Kostic', 'istr070@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(71, 'Dusan', 'Lazic', 'istr071@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(72, 'Iva', 'Pavlovic', 'istr072@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(73, 'Vuk', 'Milosevic', 'istr073@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(74, 'Mina', 'Ciric', 'istr074@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(75, 'Filip', 'Ilic', 'istr075@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(76, 'Teodora', 'Popovic', 'istr076@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(77, 'Aleksa', 'Milic', 'istr077@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(78, 'Maja', 'Nikolic', 'istr078@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(79, 'Andrija', 'Tomic', 'istr079@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(80, 'Ana', 'Petrovic', 'istr080@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(81, 'Marko', 'Djordjevic', 'istr081@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(82, 'Jelena', 'Vasic', 'istr082@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(83, 'Petar', 'Jovanovic', 'istr083@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(84, 'Milica', 'Stankovic', 'istr084@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(85, 'Stefan', 'Krstic', 'istr085@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(86, 'Jovana', 'Stojanovic', 'istr086@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(87, 'Nikola', 'Radovanovic', 'istr087@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(88, 'Tamara', 'Jankovic', 'istr088@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(89, 'Luka', 'Markovic', 'istr089@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(90, 'Sara', 'Kostic', 'istr090@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(91, 'Dusan', 'Lazic', 'istr091@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(92, 'Iva', 'Pavlovic', 'istr092@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(93, 'Vuk', 'Milosevic', 'istr093@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(94, 'Mina', 'Ciric', 'istr094@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(95, 'Filip', 'Ilic', 'istr095@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(96, 'Teodora', 'Popovic', 'istr096@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(97, 'Aleksa', 'Milic', 'istr097@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(98, 'Maja', 'Nikolic', 'istr098@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(99, 'Andrija', 'Tomic', 'istr099@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(100, 'Ana', 'Petrovic', 'istr100@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(101, 'Marko', 'Djordjevic', 'istr101@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(102, 'Jelena', 'Vasic', 'istr102@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(103, 'Petar', 'Jovanovic', 'istr103@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(104, 'Milica', 'Stankovic', 'istr104@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(105, 'Stefan', 'Krstic', 'istr105@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(106, 'Jovana', 'Stojanovic', 'istr106@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(107, 'Nikola', 'Radovanovic', 'istr107@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(108, 'Tamara', 'Jankovic', 'istr108@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(109, 'Luka', 'Markovic', 'istr109@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(110, 'Sara', 'Kostic', 'istr110@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(111, 'Dusan', 'Lazic', 'istr111@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(112, 'Iva', 'Pavlovic', 'istr112@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(113, 'Vuk', 'Milosevic', 'istr113@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(114, 'Mina', 'Ciric', 'istr114@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(115, 'Filip', 'Ilic', 'istr115@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(116, 'Teodora', 'Popovic', 'istr116@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(117, 'Aleksa', 'Milic', 'istr117@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(118, 'Maja', 'Nikolic', 'istr118@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(119, 'Andrija', 'Tomic', 'istr119@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(120, 'Ana', 'Petrovic', 'istr120@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(121, 'Marko', 'Djordjevic', 'istr121@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(122, 'Jelena', 'Vasic', 'istr122@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(123, 'Petar', 'Jovanovic', 'istr123@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(124, 'Milica', 'Stankovic', 'istr124@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(125, 'Stefan', 'Krstic', 'istr125@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(126, 'Jovana', 'Stojanovic', 'istr126@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(127, 'Nikola', 'Radovanovic', 'istr127@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(128, 'Tamara', 'Jankovic', 'istr128@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(129, 'Luka', 'Markovic', 'istr129@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(130, 'Sara', 'Kostic', 'istr130@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(131, 'Dusan', 'Lazic', 'istr131@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(132, 'Iva', 'Pavlovic', 'istr132@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(133, 'Vuk', 'Milosevic', 'istr133@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(134, 'Mina', 'Ciric', 'istr134@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(135, 'Filip', 'Ilic', 'istr135@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(136, 'Teodora', 'Popovic', 'istr136@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(137, 'Aleksa', 'Milic', 'istr137@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(138, 'Maja', 'Nikolic', 'istr138@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(139, 'Andrija', 'Tomic', 'istr139@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(140, 'Ana', 'Petrovic', 'istr140@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(141, 'Marko', 'Djordjevic', 'istr141@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(142, 'Jelena', 'Vasic', 'istr142@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(143, 'Petar', 'Jovanovic', 'istr143@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(144, 'Milica', 'Stankovic', 'istr144@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(145, 'Stefan', 'Krstic', 'istr145@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(146, 'Jovana', 'Stojanovic', 'istr146@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(147, 'Nikola', 'Radovanovic', 'istr147@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(148, 'Tamara', 'Jankovic', 'istr148@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(149, 'Luka', 'Markovic', 'istr149@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(150, 'Sara', 'Kostic', 'istr150@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(151, 'Dusan', 'Lazic', 'istr151@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(152, 'Iva', 'Pavlovic', 'istr152@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(153, 'Vuk', 'Milosevic', 'istr153@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(154, 'Mina', 'Ciric', 'istr154@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(155, 'Filip', 'Ilic', 'istr155@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(156, 'Teodora', 'Popovic', 'istr156@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(157, 'Aleksa', 'Milic', 'istr157@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(158, 'Maja', 'Nikolic', 'istr158@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(159, 'Andrija', 'Tomic', 'istr159@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(160, 'Ana', 'Petrovic', 'istr160@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(161, 'Marko', 'Djordjevic', 'istr161@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(162, 'Jelena', 'Vasic', 'istr162@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(163, 'Petar', 'Jovanovic', 'istr163@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(164, 'Milica', 'Stankovic', 'istr164@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(165, 'Stefan', 'Krstic', 'istr165@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(166, 'Jovana', 'Stojanovic', 'istr166@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(167, 'Nikola', 'Radovanovic', 'istr167@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(168, 'Tamara', 'Jankovic', 'istr168@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(169, 'Luka', 'Markovic', 'istr169@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(170, 'Sara', 'Kostic', 'istr170@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(171, 'Dusan', 'Lazic', 'istr171@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(172, 'Iva', 'Pavlovic', 'istr172@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(173, 'Vuk', 'Milosevic', 'istr173@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(174, 'Mina', 'Ciric', 'istr174@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(175, 'Filip', 'Ilic', 'istr175@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(176, 'Teodora', 'Popovic', 'istr176@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(177, 'Aleksa', 'Milic', 'istr177@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(178, 'Maja', 'Nikolic', 'istr178@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(179, 'Andrija', 'Tomic', 'istr179@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(180, 'Ana', 'Petrovic', 'istr180@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(181, 'Marko', 'Djordjevic', 'istr181@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(182, 'Jelena', 'Vasic', 'istr182@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(183, 'Petar', 'Jovanovic', 'istr183@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(184, 'Milica', 'Stankovic', 'istr184@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(185, 'Stefan', 'Krstic', 'istr185@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(186, 'Jovana', 'Stojanovic', 'istr186@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(187, 'Nikola', 'Radovanovic', 'istr187@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(188, 'Tamara', 'Jankovic', 'istr188@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(189, 'Luka', 'Markovic', 'istr189@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(190, 'Sara', 'Kostic', 'istr190@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(191, 'Dusan', 'Lazic', 'istr191@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(192, 'Iva', 'Pavlovic', 'istr192@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(193, 'Vuk', 'Milosevic', 'istr193@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(194, 'Mina', 'Ciric', 'istr194@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(195, 'Filip', 'Ilic', 'istr195@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(196, 'Teodora', 'Popovic', 'istr196@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(197, 'Aleksa', 'Milic', 'istr197@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(198, 'Maja', 'Nikolic', 'istr198@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(199, 'Andrija', 'Tomic', 'istr199@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(200, 'Ana', 'Petrovic', 'istr200@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(201, 'Marko', 'Djordjevic', 'istr201@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(202, 'Jelena', 'Vasic', 'istr202@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(203, 'Petar', 'Jovanovic', 'istr203@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(204, 'Milica', 'Stankovic', 'istr204@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(205, 'Stefan', 'Krstic', 'istr205@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(206, 'Jovana', 'Stojanovic', 'istr206@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(207, 'Nikola', 'Radovanovic', 'istr207@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(208, 'Tamara', 'Jankovic', 'istr208@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(209, 'Luka', 'Markovic', 'istr209@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(210, 'Sara', 'Kostic', 'istr210@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(211, 'Dusan', 'Lazic', 'istr211@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(212, 'Iva', 'Pavlovic', 'istr212@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(213, 'Vuk', 'Milosevic', 'istr213@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(214, 'Mina', 'Ciric', 'istr214@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(215, 'Filip', 'Ilic', 'istr215@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(216, 'Teodora', 'Popovic', 'istr216@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(217, 'Aleksa', 'Milic', 'istr217@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(218, 'Maja', 'Nikolic', 'istr218@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(219, 'Andrija', 'Tomic', 'istr219@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(220, 'Ana', 'Petrovic', 'istr220@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(221, 'Marko', 'Djordjevic', 'istr221@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(222, 'Jelena', 'Vasic', 'istr222@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(223, 'Petar', 'Jovanovic', 'istr223@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(224, 'Milica', 'Stankovic', 'istr224@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(225, 'Stefan', 'Krstic', 'istr225@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(226, 'Jovana', 'Stojanovic', 'istr226@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(227, 'Nikola', 'Radovanovic', 'istr227@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(228, 'Tamara', 'Jankovic', 'istr228@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(229, 'Luka', 'Markovic', 'istr229@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(230, 'Sara', 'Kostic', 'istr230@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(231, 'Dusan', 'Lazic', 'istr231@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(232, 'Iva', 'Pavlovic', 'istr232@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(233, 'Vuk', 'Milosevic', 'istr233@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(234, 'Mina', 'Ciric', 'istr234@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(235, 'Filip', 'Ilic', 'istr235@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(236, 'Teodora', 'Popovic', 'istr236@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(237, 'Aleksa', 'Milic', 'istr237@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(238, 'Maja', 'Nikolic', 'istr238@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(239, 'Andrija', 'Tomic', 'istr239@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(240, 'Ana', 'Petrovic', 'istr240@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(241, 'Marko', 'Djordjevic', 'istr241@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(242, 'Jelena', 'Vasic', 'istr242@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(243, 'Petar', 'Jovanovic', 'istr243@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(244, 'Milica', 'Stankovic', 'istr244@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(245, 'Stefan', 'Krstic', 'istr245@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(246, 'Jovana', 'Stojanovic', 'istr246@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(247, 'Nikola', 'Radovanovic', 'istr247@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(248, 'Tamara', 'Jankovic', 'istr248@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(249, 'Luka', 'Markovic', 'istr249@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(250, 'Sara', 'Kostic', 'istr250@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(251, 'Dusan', 'Lazic', 'istr251@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(252, 'Iva', 'Pavlovic', 'istr252@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(253, 'Vuk', 'Milosevic', 'istr253@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(254, 'Mina', 'Ciric', 'istr254@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(255, 'Filip', 'Ilic', 'istr255@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(256, 'Teodora', 'Popovic', 'istr256@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(257, 'Aleksa', 'Milic', 'istr257@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(258, 'Maja', 'Nikolic', 'istr258@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(259, 'Andrija', 'Tomic', 'istr259@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(260, 'Ana', 'Petrovic', 'istr260@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(261, 'Marko', 'Djordjevic', 'istr261@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(262, 'Jelena', 'Vasic', 'istr262@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(263, 'Petar', 'Jovanovic', 'istr263@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(264, 'Milica', 'Stankovic', 'istr264@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(265, 'Stefan', 'Krstic', 'istr265@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(266, 'Jovana', 'Stojanovic', 'istr266@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(267, 'Nikola', 'Radovanovic', 'istr267@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(268, 'Tamara', 'Jankovic', 'istr268@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(269, 'Luka', 'Markovic', 'istr269@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(270, 'Sara', 'Kostic', 'istr270@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(271, 'Dusan', 'Lazic', 'istr271@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(272, 'Iva', 'Pavlovic', 'istr272@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(273, 'Vuk', 'Milosevic', 'istr273@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(274, 'Mina', 'Ciric', 'istr274@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(275, 'Filip', 'Ilic', 'istr275@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(276, 'Teodora', 'Popovic', 'istr276@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(277, 'Aleksa', 'Milic', 'istr277@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(278, 'Maja', 'Nikolic', 'istr278@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(279, 'Andrija', 'Tomic', 'istr279@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(280, 'Ana', 'Petrovic', 'istr280@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(281, 'Marko', 'Djordjevic', 'istr281@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(282, 'Jelena', 'Vasic', 'istr282@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(283, 'Petar', 'Jovanovic', 'istr283@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(284, 'Milica', 'Stankovic', 'istr284@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(285, 'Stefan', 'Krstic', 'istr285@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(286, 'Jovana', 'Stojanovic', 'istr286@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(287, 'Nikola', 'Radovanovic', 'istr287@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(288, 'Tamara', 'Jankovic', 'istr288@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(289, 'Luka', 'Markovic', 'istr289@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(290, 'Sara', 'Kostic', 'istr290@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(291, 'Dusan', 'Lazic', 'istr291@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(292, 'Iva', 'Pavlovic', 'istr292@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(293, 'Vuk', 'Milosevic', 'istr293@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(294, 'Mina', 'Ciric', 'istr294@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(295, 'Filip', 'Ilic', 'istr295@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista'),
(296, 'Teodora', 'Popovic', 'istr296@ekonomija.rs', 'Master u statistici, sertifikat za R', 'bihevioralni_naucnik'),
(297, 'Aleksa', 'Milic', 'istr297@ekonomija.rs', 'Bachelor + 5 god istrazivanja', 'statisticar'),
(298, 'Maja', 'Nikolic', 'istr298@ekonomija.rs', 'MA u psihologiji, ekspert za eksperimente', 'psiholog'),
(299, 'Andrija', 'Tomic', 'istr299@ekonomija.rs', 'BSc data science, ML sertifikati', 'data_scientist'),
(300, 'Ana', 'Petrovic', 'istr300@ekonomija.rs', 'PhD u ekonomiji, 10 god iskustva', 'ekonomista');

-- --------------------------------------------------------

--
-- Table structure for table `izvodjac`
--

CREATE TABLE `izvodjac` (
  `id_izvodjaca` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `izvodjac`
--

INSERT INTO `izvodjac` (`id_izvodjaca`) VALUES
(1),
(2),
(4),
(5),
(7),
(8),
(10),
(11),
(13),
(14),
(16),
(17),
(19),
(20),
(22),
(23),
(25),
(26),
(28),
(29),
(31),
(32),
(34),
(35),
(37),
(38),
(40),
(41),
(43),
(44),
(46),
(47),
(49),
(50),
(52),
(53),
(55),
(56),
(58),
(59),
(61),
(62),
(64),
(65),
(67),
(68),
(70),
(71),
(73),
(74),
(76),
(77),
(79),
(80),
(82),
(83),
(85),
(86),
(88),
(89),
(91),
(92),
(94),
(95),
(97),
(98),
(100),
(101),
(103),
(104),
(106),
(107),
(109),
(110),
(112),
(113),
(115),
(116),
(118),
(119),
(121),
(122),
(124),
(125),
(127),
(128),
(130),
(131),
(133),
(134),
(136),
(137),
(139),
(140),
(142),
(143),
(145),
(146),
(148),
(149),
(151),
(152),
(154),
(155),
(157),
(158),
(160),
(161),
(163),
(164),
(166),
(167),
(169),
(170),
(172),
(173),
(175),
(176),
(178),
(179),
(181),
(182),
(184),
(185),
(187),
(188),
(190),
(191),
(193),
(194),
(196),
(197),
(199),
(200),
(202),
(203),
(205),
(206),
(208),
(209),
(211),
(212),
(214),
(215),
(217),
(218),
(220),
(221),
(223),
(224),
(226),
(227),
(229),
(230),
(232),
(233),
(235),
(236),
(238),
(239),
(241),
(242),
(244),
(245),
(247),
(248),
(250),
(251),
(253),
(254),
(256),
(257),
(259),
(260),
(262),
(263),
(265),
(266),
(268),
(269),
(271),
(272),
(274),
(275),
(277),
(278),
(280),
(281),
(283),
(284),
(286),
(287),
(289),
(290),
(292),
(293),
(295),
(296),
(298),
(299);

-- --------------------------------------------------------

--
-- Table structure for table `izvodjenje`
--

CREATE TABLE `izvodjenje` (
  `id_izvodjenja` int(11) NOT NULL,
  `id_eksperimenta` int(11) NOT NULL,
  `datum` date NOT NULL,
  `status` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `izvodjenje`
--

INSERT INTO `izvodjenje` (`id_izvodjenja`, `id_eksperimenta`, `datum`, `status`) VALUES
(1, 1, '2025-01-04', 'zapoceto'),
(2, 2, '2025-01-07', 'otkazano'),
(3, 3, '2025-01-10', 'zavrseno uspesno'),
(4, 4, '2025-01-13', 'zavrseno neuspesno'),
(5, 5, '2025-01-16', 'planirano'),
(6, 6, '2025-01-19', 'zapoceto'),
(7, 7, '2025-01-22', 'otkazano'),
(8, 8, '2025-01-25', 'zavrseno uspesno'),
(9, 9, '2025-01-28', 'zavrseno neuspesno'),
(10, 10, '2025-01-31', 'planirano'),
(11, 11, '2025-02-03', 'zapoceto'),
(12, 12, '2025-02-06', 'otkazano'),
(13, 13, '2025-02-09', 'zavrseno uspesno'),
(14, 14, '2025-02-12', 'zavrseno neuspesno'),
(15, 15, '2025-02-15', 'planirano'),
(16, 16, '2025-02-18', 'zapoceto'),
(17, 17, '2025-02-21', 'otkazano'),
(18, 18, '2025-02-24', 'zavrseno uspesno'),
(19, 19, '2025-02-27', 'zavrseno neuspesno'),
(20, 20, '2025-03-02', 'planirano'),
(21, 21, '2025-03-05', 'zapoceto'),
(22, 22, '2025-03-08', 'otkazano'),
(23, 23, '2025-03-11', 'zavrseno uspesno'),
(24, 24, '2025-03-14', 'zavrseno neuspesno'),
(25, 25, '2025-03-17', 'planirano'),
(26, 26, '2025-03-20', 'zapoceto'),
(27, 27, '2025-03-23', 'otkazano'),
(28, 28, '2025-03-26', 'zavrseno uspesno'),
(29, 29, '2025-03-29', 'zavrseno neuspesno'),
(30, 30, '2025-04-01', 'planirano'),
(31, 31, '2025-04-04', 'zapoceto'),
(32, 32, '2025-04-07', 'otkazano'),
(33, 33, '2025-04-10', 'zavrseno uspesno'),
(34, 34, '2025-04-13', 'zavrseno neuspesno'),
(35, 35, '2025-04-16', 'planirano'),
(36, 36, '2025-04-19', 'zapoceto'),
(37, 37, '2025-04-22', 'otkazano'),
(38, 38, '2025-04-25', 'zavrseno uspesno'),
(39, 39, '2025-04-28', 'zavrseno neuspesno'),
(40, 40, '2025-05-01', 'planirano'),
(41, 41, '2025-05-04', 'zapoceto'),
(42, 42, '2025-05-07', 'otkazano'),
(43, 43, '2025-05-10', 'zavrseno uspesno'),
(44, 44, '2025-05-13', 'zavrseno neuspesno'),
(45, 45, '2025-05-16', 'planirano'),
(46, 46, '2025-05-19', 'zapoceto'),
(47, 47, '2025-05-22', 'otkazano'),
(48, 48, '2025-05-25', 'zavrseno uspesno'),
(49, 49, '2025-05-28', 'zavrseno neuspesno'),
(50, 50, '2025-05-31', 'planirano'),
(51, 51, '2025-06-03', 'zapoceto'),
(52, 52, '2025-06-06', 'otkazano'),
(53, 53, '2025-06-09', 'zavrseno uspesno'),
(54, 54, '2025-06-12', 'zavrseno neuspesno'),
(55, 55, '2025-06-15', 'planirano'),
(56, 56, '2025-06-18', 'zapoceto'),
(57, 57, '2025-06-21', 'otkazano'),
(58, 58, '2025-06-24', 'zavrseno uspesno'),
(59, 59, '2025-06-27', 'zavrseno neuspesno'),
(60, 60, '2025-06-30', 'planirano'),
(61, 61, '2025-07-03', 'zapoceto'),
(62, 62, '2025-07-06', 'otkazano'),
(63, 63, '2025-07-09', 'zavrseno uspesno'),
(64, 64, '2025-07-12', 'zavrseno neuspesno'),
(65, 65, '2025-07-15', 'planirano'),
(66, 66, '2025-07-18', 'zapoceto'),
(67, 67, '2025-07-21', 'otkazano'),
(68, 68, '2025-07-24', 'zavrseno uspesno'),
(69, 69, '2025-07-27', 'zavrseno neuspesno'),
(70, 70, '2025-07-30', 'planirano'),
(71, 71, '2025-08-02', 'zapoceto'),
(72, 72, '2025-08-05', 'otkazano'),
(73, 73, '2025-08-08', 'zavrseno uspesno'),
(74, 74, '2025-08-11', 'zavrseno neuspesno'),
(75, 75, '2025-08-14', 'planirano'),
(76, 76, '2025-08-17', 'zapoceto'),
(77, 77, '2025-08-20', 'otkazano'),
(78, 78, '2025-08-23', 'zavrseno uspesno'),
(79, 79, '2025-08-26', 'zavrseno neuspesno'),
(80, 80, '2025-08-29', 'planirano'),
(81, 81, '2025-09-01', 'zapoceto'),
(82, 82, '2025-09-04', 'otkazano'),
(83, 83, '2025-09-07', 'zavrseno uspesno'),
(84, 84, '2025-09-10', 'zavrseno neuspesno'),
(85, 85, '2025-09-13', 'planirano'),
(86, 86, '2025-09-16', 'zapoceto'),
(87, 87, '2025-09-19', 'otkazano'),
(88, 88, '2025-09-22', 'zavrseno uspesno'),
(89, 89, '2025-09-25', 'zavrseno neuspesno'),
(90, 90, '2025-09-28', 'planirano'),
(91, 91, '2025-10-01', 'zapoceto'),
(92, 92, '2025-10-04', 'otkazano'),
(93, 93, '2025-10-07', 'zavrseno uspesno'),
(94, 94, '2025-10-10', 'zavrseno neuspesno'),
(95, 95, '2025-10-13', 'planirano'),
(96, 96, '2025-10-16', 'zapoceto'),
(97, 97, '2025-10-19', 'otkazano'),
(98, 98, '2025-10-22', 'zavrseno uspesno'),
(99, 99, '2025-10-25', 'zavrseno neuspesno'),
(100, 100, '2025-10-28', 'planirano'),
(101, 1, '2025-10-31', 'zapoceto'),
(102, 2, '2025-11-03', 'otkazano'),
(103, 3, '2025-11-06', 'zavrseno uspesno'),
(104, 4, '2025-11-09', 'zavrseno neuspesno'),
(105, 5, '2025-11-12', 'planirano'),
(106, 6, '2025-11-15', 'zapoceto'),
(107, 7, '2025-11-18', 'otkazano'),
(108, 8, '2025-11-21', 'zavrseno uspesno'),
(109, 9, '2025-11-24', 'zavrseno neuspesno'),
(110, 10, '2025-11-27', 'planirano'),
(111, 11, '2025-11-30', 'zapoceto'),
(112, 12, '2025-12-03', 'otkazano'),
(113, 13, '2025-12-06', 'zavrseno uspesno'),
(114, 14, '2025-12-09', 'zavrseno neuspesno'),
(115, 15, '2025-12-12', 'planirano'),
(116, 16, '2025-12-15', 'zapoceto'),
(117, 17, '2025-12-18', 'otkazano'),
(118, 18, '2025-12-21', 'zavrseno uspesno'),
(119, 19, '2025-12-24', 'zavrseno neuspesno'),
(120, 20, '2025-12-27', 'planirano'),
(121, 21, '2025-12-30', 'zapoceto'),
(122, 22, '2026-01-02', 'otkazano'),
(123, 23, '2026-01-05', 'zavrseno uspesno'),
(124, 24, '2026-01-08', 'zavrseno neuspesno'),
(125, 25, '2026-01-11', 'planirano'),
(126, 26, '2026-01-14', 'zapoceto'),
(127, 27, '2026-01-17', 'otkazano'),
(128, 28, '2026-01-20', 'zavrseno uspesno'),
(129, 29, '2026-01-23', 'zavrseno neuspesno'),
(130, 30, '2026-01-26', 'planirano'),
(131, 31, '2026-01-29', 'zapoceto'),
(132, 32, '2026-02-01', 'otkazano'),
(133, 33, '2026-02-04', 'zavrseno uspesno'),
(134, 34, '2026-02-07', 'zavrseno neuspesno'),
(135, 35, '2026-02-10', 'planirano'),
(136, 36, '2026-02-13', 'zapoceto'),
(137, 37, '2026-02-16', 'otkazano'),
(138, 38, '2026-02-19', 'zavrseno uspesno'),
(139, 39, '2026-02-22', 'zavrseno neuspesno'),
(140, 40, '2026-02-25', 'planirano'),
(141, 41, '2026-02-28', 'zapoceto'),
(142, 42, '2026-03-03', 'otkazano'),
(143, 43, '2026-03-06', 'zavrseno uspesno'),
(144, 44, '2026-03-09', 'zavrseno neuspesno'),
(145, 45, '2026-03-12', 'planirano'),
(146, 46, '2026-03-15', 'zapoceto'),
(147, 47, '2026-03-18', 'otkazano'),
(148, 48, '2026-03-21', 'zavrseno uspesno'),
(149, 49, '2026-03-24', 'zavrseno neuspesno'),
(150, 50, '2026-03-27', 'planirano');

-- --------------------------------------------------------

--
-- Table structure for table `jedinica_vrednosti`
--

CREATE TABLE `jedinica_vrednosti` (
  `id_jedinice_vrednosti` varchar(10) NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `kurs_eur` decimal(15,6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `jedinica_vrednosti`
--

INSERT INTO `jedinica_vrednosti` (`id_jedinice_vrednosti`, `naziv`, `kurs_eur`) VALUES
('AAPL', 'Apple akcija', '261.808149'),
('ADA', 'Cardano', '0.611205'),
('AED', 'UAE dirham', '0.231149'),
('AMD', 'Advanced Micro Devices akcija', '110.356537'),
('AMZN', 'Amazon akcija', '226.078098'),
('ARS', 'Argentinski pezos', '0.000616'),
('ASML', 'ASML Holding akcija', '628.183362'),
('AUD', 'Australijski dolar', '0.606061'),
('AVAX', 'Avalanche', '21.222411'),
('AVGO', 'Broadcom akcija', '165.534805'),
('BAC', 'Bank of America akcija', '38.200340'),
('BNB', 'Binance Coin', '539.049236'),
('BRENT', 'Brent nafta (barel)', '84.040747'),
('BRL', 'Brazilski real', '0.165289'),
('BTC', 'Bitcoin', '76921.052632'),
('CAD', 'Kanadski dolar', '0.636943'),
('CHF', 'Svajcarski franak', '1.106195'),
('CLP', 'Cilijski pezos', '0.000917'),
('CNY', 'Kineski juan', '0.125471'),
('COFFE', 'Kafa (libra)', '2.461800'),
('COP', 'Kolumbijski pezos', '0.000206'),
('CORN', 'Kukuruz (busel)', '3.565365'),
('COTT', 'Pamuk (libra, ICE)', '0.585739'),
('CRD', 'Kredit u eksperimentalnoj igri', '0.025000'),
('CZK', 'Ceska kruna', '0.040950'),
('DKK', 'Danska kruna', '0.133851'),
('DOGE', 'Dogecoin', '0.186757'),
('DOT', 'Polkadot', '5.517827'),
('ECU', 'Eksperiment. kreditna jedinica', '0.100000'),
('EGP', 'Egipatska funta', '0.017094'),
('ETH', 'Ethereum', '2647.707980'),
('EUR', 'Evro', '1.000000'),
('EXP', 'Eksperimentalni poen', '1.000000'),
('GBP', 'Britanska funta', '1.158749'),
('GOOGL', 'Google (Alphabet) akcija', '329.448217'),
('GS', 'Goldman Sachs akcija', '526.315789'),
('HKD', 'Hongkongski dolar', '0.110681'),
('HUF', 'Madarska forinta', '0.002532'),
('IBM', 'IBM akcija', '203.735144'),
('IDR', 'Indonezijska rupija', '0.000051'),
('ILS', 'Izraelski novi sekel', '0.246914'),
('INR', 'Indijska rupija', '0.009390'),
('INTC', 'Intel akcija', '18.675722'),
('ISK', 'Islandska kruna', '0.006897'),
('JNJ', 'Johnson & Johnson akcija', '133.276740'),
('JPM', 'JPMorgan Chase akcija', '216.468591'),
('JPY', 'Japanski jen', '0.005450'),
('KRW', 'Juznokorejski von', '0.000583'),
('LAB', 'Laboratorijski poen nizeg nivoa', '0.050000'),
('LBT', 'Laboratorijski bod', '0.500000'),
('LINK', 'Chainlink', '11.884550'),
('LLY', 'Eli Lilly akcija', '662.139219'),
('MA', 'Mastercard akcija', '432.937182'),
('META', 'Meta Platforms akcija', '526.315789'),
('MSFT', 'Microsoft akcija', '356.774194'),
('MXN', 'Meksicki pezos', '0.048426'),
('MYR', 'Malezijski ringit', '0.218341'),
('NFLX', 'Netflix akcija', '933.786078'),
('NGAS', 'Prirodni gas (MMBtu)', '3.225806'),
('NOK', 'Norveska kruna', '0.089286'),
('NVDA', 'Nvidia akcija', '189.168081'),
('NZD', 'Novozelandski dolar', '0.510204'),
('ORCL', 'Oracle akcija', '157.045840'),
('PEN', 'Peruvijski sol', '0.226244'),
('PHP', 'Filipinski pezos', '0.014535'),
('PLN', 'Poljski zlot', '0.233918'),
('PNT', 'Poen u eksperimentu', '0.200000'),
('QAR', 'Katarski rijal', '0.233213'),
('RICE', 'Pirinac (cwt, CBOT)', '14.006791'),
('RSD', 'Srpski dinar', '0.008547'),
('SAR', 'Saudijski rijal', '0.226372'),
('SCR', 'Score bod za rangiranje', '0.005000'),
('SEK', 'Svedska kruna', '0.093284'),
('SGD', 'Singapurski dolar', '0.675676'),
('SOL', 'Solana', '71.213922'),
('SOYB', 'Soja (busel, CBOT)', '8.658744'),
('SUGAR', 'Secer (libra)', '0.161290'),
('THB', 'Tajlandski bat', '0.026954'),
('TKN', 'Eksperimentalni token', '0.010000'),
('TRY', 'Turska lira', '0.019608'),
('TSLA', 'Tesla akcija', '351.239389'),
('TSM', 'TSMC akcija (ADR)', '157.045840'),
('TWD', 'Tajvanski novi dolar', '0.031250'),
('UAH', 'Ukrajinska grivna', '0.022472'),
('UNH', 'UnitedHealth Group akcija', '254.668930'),
('USD', 'Americki dolar', '0.848896'),
('V', 'Visa akcija', '288.624788'),
('VCH', 'Eksperimentalni vaucer', '2.000000'),
('VTOK', 'Virtuelni token', '0.001000'),
('WHEAT', 'Psenica (busel)', '4.668930'),
('WMT', 'Walmart akcija', '83.191851'),
('WTI', 'WTI nafta (barel)', '80.645161'),
('XAG', 'Srebro (troy unca)', '26.740238'),
('XAU', 'Zlato (troy unca)', '3820.033956'),
('XCOP', 'Bakar (libra, CME)', '4.117148'),
('XOM', 'ExxonMobil akcija', '97.623090'),
('XPD', 'Paladijum (troy unca)', '891.341256'),
('XPT', 'Platina (troy unca)', '891.341256'),
('XRP', 'Ripple XRP', '1.765705'),
('ZAR', 'Juznoafricki rand', '0.051813');

-- --------------------------------------------------------

--
-- Table structure for table `laboratorija`
--

CREATE TABLE `laboratorija` (
  `id_laboratorije` int(11) NOT NULL,
  `naziv` varchar(40) NOT NULL,
  `operativni_sistem` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `laboratorija`
--

INSERT INTO `laboratorija` (`id_laboratorije`, `naziv`, `operativni_sistem`) VALUES
(1, 'PC-001', 'Ubuntu 22.04 LTS'),
(2, 'PC-002', 'macOS Sonoma 14'),
(3, 'PC-003', 'Windows 10 Pro'),
(4, 'PC-004', 'Fedora 39'),
(5, 'PC-005', 'Debian 12'),
(6, 'PC-006', 'Windows 11 Pro'),
(7, 'PC-007', 'Ubuntu 22.04 LTS'),
(8, 'PC-008', 'macOS Sonoma 14'),
(9, 'PC-009', 'Windows 10 Pro'),
(10, 'PC-010', 'Fedora 39'),
(11, 'PC-011', 'Debian 12'),
(12, 'PC-012', 'Windows 11 Pro'),
(13, 'PC-013', 'Ubuntu 22.04 LTS'),
(14, 'PC-014', 'macOS Sonoma 14'),
(15, 'PC-015', 'Windows 10 Pro'),
(16, 'PC-016', 'Fedora 39'),
(17, 'PC-017', 'Debian 12'),
(18, 'PC-018', 'Windows 11 Pro'),
(19, 'PC-019', 'Ubuntu 22.04 LTS'),
(20, 'PC-020', 'macOS Sonoma 14'),
(21, 'PC-021', 'Windows 10 Pro'),
(22, 'PC-022', 'Fedora 39'),
(23, 'PC-023', 'Debian 12'),
(24, 'PC-024', 'Windows 11 Pro'),
(25, 'PC-025', 'Ubuntu 22.04 LTS'),
(26, 'PC-026', 'macOS Sonoma 14'),
(27, 'PC-027', 'Windows 10 Pro'),
(28, 'PC-028', 'Fedora 39'),
(29, 'PC-029', 'Debian 12'),
(30, 'PC-030', 'Windows 11 Pro'),
(31, 'PC-031', 'Ubuntu 22.04 LTS'),
(32, 'PC-032', 'macOS Sonoma 14'),
(33, 'PC-033', 'Windows 10 Pro'),
(34, 'PC-034', 'Fedora 39'),
(35, 'PC-035', 'Debian 12'),
(36, 'PC-036', 'Windows 11 Pro'),
(37, 'PC-037', 'Ubuntu 22.04 LTS'),
(38, 'PC-038', 'macOS Sonoma 14'),
(39, 'PC-039', 'Windows 10 Pro'),
(40, 'PC-040', 'Fedora 39'),
(41, 'PC-041', 'Debian 12'),
(42, 'PC-042', 'Windows 11 Pro'),
(43, 'PC-043', 'Ubuntu 22.04 LTS'),
(44, 'PC-044', 'macOS Sonoma 14'),
(45, 'PC-045', 'Windows 10 Pro'),
(46, 'PC-046', 'Fedora 39'),
(47, 'PC-047', 'Debian 12'),
(48, 'PC-048', 'Windows 11 Pro'),
(49, 'PC-049', 'Ubuntu 22.04 LTS'),
(50, 'PC-050', 'macOS Sonoma 14'),
(51, 'PC-051', 'Windows 10 Pro'),
(52, 'PC-052', 'Fedora 39'),
(53, 'PC-053', 'Debian 12'),
(54, 'PC-054', 'Windows 11 Pro'),
(55, 'PC-055', 'Ubuntu 22.04 LTS'),
(56, 'PC-056', 'macOS Sonoma 14'),
(57, 'PC-057', 'Windows 10 Pro'),
(58, 'PC-058', 'Fedora 39'),
(59, 'PC-059', 'Debian 12'),
(60, 'PC-060', 'Windows 11 Pro'),
(61, 'PC-061', 'Ubuntu 22.04 LTS'),
(62, 'PC-062', 'macOS Sonoma 14'),
(63, 'PC-063', 'Windows 10 Pro'),
(64, 'PC-064', 'Fedora 39'),
(65, 'PC-065', 'Debian 12'),
(66, 'PC-066', 'Windows 11 Pro'),
(67, 'PC-067', 'Ubuntu 22.04 LTS'),
(68, 'PC-068', 'macOS Sonoma 14'),
(69, 'PC-069', 'Windows 10 Pro'),
(70, 'PC-070', 'Fedora 39'),
(71, 'PC-071', 'Debian 12'),
(72, 'PC-072', 'Windows 11 Pro'),
(73, 'PC-073', 'Ubuntu 22.04 LTS'),
(74, 'PC-074', 'macOS Sonoma 14'),
(75, 'PC-075', 'Windows 10 Pro'),
(76, 'PC-076', 'Fedora 39'),
(77, 'PC-077', 'Debian 12'),
(78, 'PC-078', 'Windows 11 Pro'),
(79, 'PC-079', 'Ubuntu 22.04 LTS'),
(80, 'PC-080', 'macOS Sonoma 14'),
(81, 'PC-081', 'Windows 10 Pro'),
(82, 'PC-082', 'Fedora 39'),
(83, 'PC-083', 'Debian 12'),
(84, 'PC-084', 'Windows 11 Pro'),
(85, 'PC-085', 'Ubuntu 22.04 LTS'),
(86, 'PC-086', 'macOS Sonoma 14'),
(87, 'PC-087', 'Windows 10 Pro'),
(88, 'PC-088', 'Fedora 39'),
(89, 'PC-089', 'Debian 12'),
(90, 'PC-090', 'Windows 11 Pro'),
(91, 'PC-091', 'Ubuntu 22.04 LTS'),
(92, 'PC-092', 'macOS Sonoma 14'),
(93, 'PC-093', 'Windows 10 Pro'),
(94, 'PC-094', 'Fedora 39'),
(95, 'PC-095', 'Debian 12'),
(96, 'PC-096', 'Windows 11 Pro'),
(97, 'PC-097', 'Ubuntu 22.04 LTS'),
(98, 'PC-098', 'macOS Sonoma 14'),
(99, 'PC-099', 'Windows 10 Pro'),
(100, 'PC-100', 'Fedora 39');

-- --------------------------------------------------------

--
-- Table structure for table `laboratorija_resurs`
--

CREATE TABLE `laboratorija_resurs` (
  `id_laboratorije` int(11) NOT NULL,
  `id_resurs` int(11) NOT NULL,
  `kolicina` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `laboratorija_resurs`
--

INSERT INTO `laboratorija_resurs` (`id_laboratorije`, `id_resurs`, `kolicina`, `status`) VALUES
(1, 7, '18.00', 'rezervisano'),
(1, 44, '368.00', 'iskorisceno'),
(1, 81, '718.00', 'dostupno'),
(2, 14, '31.00', 'iskorisceno'),
(2, 51, '381.00', 'dostupno'),
(3, 21, '44.00', 'dostupno'),
(3, 58, '394.00', 'rezervisano'),
(4, 28, '57.00', 'rezervisano'),
(4, 65, '407.00', 'iskorisceno'),
(5, 35, '70.00', 'iskorisceno'),
(5, 72, '420.00', 'dostupno'),
(6, 42, '83.00', 'dostupno'),
(6, 79, '433.00', 'rezervisano'),
(7, 49, '96.00', 'rezervisano'),
(7, 86, '446.00', 'iskorisceno'),
(8, 56, '109.00', 'iskorisceno'),
(8, 93, '459.00', 'dostupno'),
(9, 63, '122.00', 'dostupno'),
(9, 100, '472.00', 'rezervisano'),
(10, 7, '485.00', 'iskorisceno'),
(10, 70, '135.00', 'rezervisano'),
(11, 14, '498.00', 'dostupno'),
(11, 77, '148.00', 'iskorisceno'),
(12, 21, '511.00', 'rezervisano'),
(12, 84, '161.00', 'dostupno'),
(13, 28, '524.00', 'iskorisceno'),
(13, 91, '174.00', 'rezervisano'),
(14, 35, '537.00', 'dostupno'),
(14, 98, '187.00', 'iskorisceno'),
(15, 5, '200.00', 'dostupno'),
(15, 42, '550.00', 'rezervisano'),
(16, 12, '213.00', 'rezervisano'),
(16, 49, '563.00', 'iskorisceno'),
(17, 19, '226.00', 'iskorisceno'),
(17, 56, '576.00', 'dostupno'),
(18, 26, '239.00', 'dostupno'),
(18, 63, '589.00', 'rezervisano'),
(19, 33, '252.00', 'rezervisano'),
(19, 70, '602.00', 'iskorisceno'),
(20, 40, '265.00', 'iskorisceno'),
(20, 77, '615.00', 'dostupno'),
(21, 47, '278.00', 'dostupno'),
(21, 84, '628.00', 'rezervisano'),
(22, 54, '291.00', 'rezervisano'),
(22, 91, '641.00', 'iskorisceno'),
(23, 61, '304.00', 'iskorisceno'),
(23, 98, '654.00', 'dostupno'),
(24, 5, '667.00', 'rezervisano'),
(24, 68, '317.00', 'dostupno'),
(25, 12, '680.00', 'iskorisceno'),
(25, 75, '330.00', 'rezervisano'),
(26, 19, '693.00', 'dostupno'),
(26, 82, '343.00', 'iskorisceno'),
(27, 26, '706.00', 'rezervisano'),
(27, 89, '356.00', 'dostupno'),
(28, 33, '719.00', 'iskorisceno'),
(28, 96, '369.00', 'rezervisano'),
(29, 3, '382.00', 'iskorisceno'),
(29, 40, '732.00', 'dostupno'),
(30, 10, '395.00', 'dostupno'),
(30, 47, '745.00', 'rezervisano'),
(31, 17, '408.00', 'rezervisano'),
(31, 54, '758.00', 'iskorisceno'),
(32, 24, '421.00', 'iskorisceno'),
(32, 61, '771.00', 'dostupno'),
(33, 31, '434.00', 'dostupno'),
(33, 68, '784.00', 'rezervisano'),
(34, 38, '447.00', 'rezervisano'),
(34, 75, '797.00', 'iskorisceno'),
(35, 45, '460.00', 'iskorisceno'),
(35, 82, '810.00', 'dostupno'),
(36, 52, '473.00', 'dostupno'),
(36, 89, '823.00', 'rezervisano'),
(37, 59, '486.00', 'rezervisano'),
(37, 96, '836.00', 'iskorisceno'),
(38, 3, '849.00', 'dostupno'),
(38, 66, '499.00', 'iskorisceno'),
(39, 10, '862.00', 'rezervisano'),
(39, 73, '512.00', 'dostupno'),
(40, 17, '875.00', 'iskorisceno'),
(40, 80, '525.00', 'rezervisano'),
(41, 24, '888.00', 'dostupno'),
(41, 87, '538.00', 'iskorisceno'),
(42, 31, '901.00', 'rezervisano'),
(42, 94, '551.00', 'dostupno'),
(43, 1, '564.00', 'rezervisano'),
(43, 38, '914.00', 'iskorisceno'),
(44, 8, '577.00', 'iskorisceno'),
(44, 45, '927.00', 'dostupno'),
(45, 15, '590.00', 'dostupno'),
(45, 52, '940.00', 'rezervisano'),
(46, 22, '603.00', 'rezervisano'),
(46, 59, '953.00', 'iskorisceno'),
(47, 29, '616.00', 'iskorisceno'),
(47, 66, '16.00', 'dostupno'),
(48, 36, '629.00', 'dostupno'),
(48, 73, '29.00', 'rezervisano'),
(49, 43, '642.00', 'rezervisano'),
(49, 80, '42.00', 'iskorisceno'),
(50, 50, '655.00', 'iskorisceno'),
(50, 87, '55.00', 'dostupno'),
(51, 57, '668.00', 'dostupno'),
(51, 94, '68.00', 'rezervisano'),
(52, 1, '81.00', 'iskorisceno'),
(52, 64, '681.00', 'rezervisano'),
(53, 8, '94.00', 'dostupno'),
(53, 71, '694.00', 'iskorisceno'),
(54, 15, '107.00', 'rezervisano'),
(54, 78, '707.00', 'dostupno'),
(55, 22, '120.00', 'iskorisceno'),
(55, 85, '720.00', 'rezervisano'),
(56, 29, '133.00', 'dostupno'),
(56, 92, '733.00', 'iskorisceno'),
(57, 36, '146.00', 'rezervisano'),
(57, 99, '746.00', 'dostupno'),
(58, 6, '759.00', 'rezervisano'),
(58, 43, '159.00', 'iskorisceno'),
(59, 13, '772.00', 'iskorisceno'),
(59, 50, '172.00', 'dostupno'),
(60, 20, '785.00', 'dostupno'),
(60, 57, '185.00', 'rezervisano'),
(61, 27, '798.00', 'rezervisano'),
(61, 64, '198.00', 'iskorisceno'),
(62, 34, '811.00', 'iskorisceno'),
(62, 71, '211.00', 'dostupno'),
(63, 41, '824.00', 'dostupno'),
(63, 78, '224.00', 'rezervisano'),
(64, 48, '837.00', 'rezervisano'),
(64, 85, '237.00', 'iskorisceno'),
(65, 55, '850.00', 'iskorisceno'),
(65, 92, '250.00', 'dostupno'),
(66, 62, '863.00', 'dostupno'),
(66, 99, '263.00', 'rezervisano'),
(67, 6, '276.00', 'iskorisceno'),
(67, 69, '876.00', 'rezervisano'),
(68, 13, '289.00', 'dostupno'),
(68, 76, '889.00', 'iskorisceno'),
(69, 20, '302.00', 'rezervisano'),
(69, 83, '902.00', 'dostupno'),
(70, 27, '315.00', 'iskorisceno'),
(70, 90, '915.00', 'rezervisano'),
(71, 34, '328.00', 'dostupno'),
(71, 97, '928.00', 'iskorisceno'),
(72, 4, '941.00', 'dostupno'),
(72, 41, '341.00', 'rezervisano'),
(73, 11, '954.00', 'rezervisano'),
(73, 48, '354.00', 'iskorisceno'),
(74, 18, '17.00', 'iskorisceno'),
(74, 55, '367.00', 'dostupno'),
(75, 25, '30.00', 'dostupno'),
(75, 62, '380.00', 'rezervisano'),
(76, 32, '43.00', 'rezervisano'),
(76, 69, '393.00', 'iskorisceno'),
(77, 39, '56.00', 'iskorisceno'),
(77, 76, '406.00', 'dostupno'),
(78, 46, '69.00', 'dostupno'),
(78, 83, '419.00', 'rezervisano'),
(79, 53, '82.00', 'rezervisano'),
(79, 90, '432.00', 'iskorisceno'),
(80, 60, '95.00', 'iskorisceno'),
(80, 97, '445.00', 'dostupno'),
(81, 4, '458.00', 'rezervisano'),
(81, 67, '108.00', 'dostupno'),
(82, 11, '471.00', 'iskorisceno'),
(82, 74, '121.00', 'rezervisano'),
(83, 18, '484.00', 'dostupno'),
(83, 81, '134.00', 'iskorisceno'),
(84, 25, '497.00', 'rezervisano'),
(84, 88, '147.00', 'dostupno'),
(85, 32, '510.00', 'iskorisceno'),
(85, 95, '160.00', 'rezervisano'),
(86, 2, '173.00', 'iskorisceno'),
(86, 39, '523.00', 'dostupno'),
(87, 9, '186.00', 'dostupno'),
(87, 46, '536.00', 'rezervisano'),
(88, 16, '199.00', 'rezervisano'),
(88, 53, '549.00', 'iskorisceno'),
(89, 23, '212.00', 'iskorisceno'),
(89, 60, '562.00', 'dostupno'),
(90, 30, '225.00', 'dostupno'),
(90, 67, '575.00', 'rezervisano'),
(91, 37, '238.00', 'rezervisano'),
(91, 74, '588.00', 'iskorisceno'),
(92, 44, '251.00', 'iskorisceno'),
(92, 81, '601.00', 'dostupno'),
(93, 51, '264.00', 'dostupno'),
(93, 88, '614.00', 'rezervisano'),
(94, 58, '277.00', 'rezervisano'),
(94, 95, '627.00', 'iskorisceno'),
(95, 2, '640.00', 'dostupno'),
(95, 65, '290.00', 'iskorisceno'),
(96, 9, '653.00', 'rezervisano'),
(96, 72, '303.00', 'dostupno'),
(97, 16, '666.00', 'iskorisceno'),
(97, 79, '316.00', 'rezervisano'),
(98, 23, '679.00', 'dostupno'),
(98, 86, '329.00', 'iskorisceno'),
(99, 30, '692.00', 'rezervisano'),
(99, 93, '342.00', 'dostupno'),
(100, 37, '705.00', 'iskorisceno'),
(100, 100, '355.00', 'rezervisano');

-- --------------------------------------------------------

--
-- Table structure for table `potrosnja_resursa`
--

CREATE TABLE `potrosnja_resursa` (
  `id_sesije` int(11) NOT NULL,
  `id_resursa` int(11) NOT NULL,
  `iskoriscena_kolicina` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `potrosnja_resursa`
--

INSERT INTO `potrosnja_resursa` (`id_sesije`, `id_resursa`, `iskoriscena_kolicina`) VALUES
(1, 11, '17.50'),
(2, 22, '34.50'),
(3, 33, '51.50'),
(4, 44, '68.50'),
(5, 55, '85.50'),
(6, 66, '102.50'),
(7, 77, '119.50'),
(8, 88, '136.50'),
(9, 99, '153.50'),
(10, 10, '170.50'),
(11, 21, '187.50'),
(12, 32, '204.50'),
(13, 43, '221.50'),
(14, 54, '238.50'),
(15, 65, '255.50'),
(16, 76, '272.50'),
(17, 87, '289.50'),
(18, 98, '6.50'),
(19, 9, '23.50'),
(20, 20, '40.50'),
(21, 31, '57.50'),
(22, 42, '74.50'),
(23, 53, '91.50'),
(24, 64, '108.50'),
(25, 75, '125.50'),
(26, 86, '142.50'),
(27, 97, '159.50'),
(28, 8, '176.50'),
(29, 19, '193.50'),
(30, 30, '210.50'),
(31, 41, '227.50'),
(32, 52, '244.50'),
(33, 63, '261.50'),
(34, 74, '278.50'),
(35, 85, '295.50'),
(36, 96, '12.50'),
(37, 7, '29.50'),
(38, 18, '46.50'),
(39, 29, '63.50'),
(40, 40, '80.50'),
(41, 51, '97.50'),
(42, 62, '114.50'),
(43, 73, '131.50'),
(44, 84, '148.50'),
(45, 95, '165.50'),
(46, 6, '182.50'),
(47, 17, '199.50'),
(48, 28, '216.50'),
(49, 39, '233.50'),
(50, 50, '250.50'),
(51, 61, '267.50'),
(52, 72, '284.50'),
(53, 83, '1.50'),
(54, 94, '18.50'),
(55, 5, '35.50'),
(56, 16, '52.50'),
(57, 27, '69.50'),
(58, 38, '86.50'),
(59, 49, '103.50'),
(60, 60, '120.50'),
(61, 71, '137.50'),
(62, 82, '154.50'),
(63, 93, '171.50'),
(64, 4, '188.50'),
(65, 15, '205.50'),
(66, 26, '222.50'),
(67, 37, '239.50'),
(68, 48, '256.50'),
(69, 59, '273.50'),
(70, 70, '290.50'),
(71, 81, '7.50'),
(72, 92, '24.50'),
(73, 3, '41.50'),
(74, 14, '58.50'),
(75, 25, '75.50'),
(76, 36, '92.50'),
(77, 47, '109.50'),
(78, 58, '126.50'),
(79, 69, '143.50'),
(80, 80, '160.50'),
(81, 91, '177.50'),
(82, 2, '194.50'),
(83, 13, '211.50'),
(84, 24, '228.50'),
(85, 35, '245.50'),
(86, 46, '262.50'),
(87, 57, '279.50'),
(88, 68, '296.50'),
(89, 79, '13.50'),
(90, 90, '30.50'),
(91, 1, '47.50'),
(92, 12, '64.50'),
(93, 23, '81.50'),
(94, 34, '98.50'),
(95, 45, '115.50'),
(96, 56, '132.50'),
(97, 67, '149.50'),
(98, 78, '166.50'),
(99, 89, '183.50'),
(100, 100, '200.50'),
(101, 11, '217.50'),
(102, 22, '234.50'),
(103, 33, '251.50'),
(104, 44, '268.50'),
(105, 55, '285.50'),
(106, 66, '2.50'),
(107, 77, '19.50'),
(108, 88, '36.50'),
(109, 99, '53.50'),
(110, 10, '70.50'),
(111, 21, '87.50'),
(112, 32, '104.50'),
(113, 43, '121.50'),
(114, 54, '138.50'),
(115, 65, '155.50'),
(116, 76, '172.50'),
(117, 87, '189.50'),
(118, 98, '206.50'),
(119, 9, '223.50'),
(120, 20, '240.50'),
(121, 31, '257.50'),
(122, 42, '274.50'),
(123, 53, '291.50'),
(124, 64, '8.50'),
(125, 75, '25.50'),
(126, 86, '42.50'),
(127, 97, '59.50'),
(128, 8, '76.50'),
(129, 19, '93.50'),
(130, 30, '110.50'),
(131, 41, '127.50'),
(132, 52, '144.50'),
(133, 63, '161.50'),
(134, 74, '178.50'),
(135, 85, '195.50'),
(136, 96, '212.50'),
(137, 7, '229.50'),
(138, 18, '246.50'),
(139, 29, '263.50'),
(140, 40, '280.50'),
(141, 51, '297.50'),
(142, 62, '14.50'),
(143, 73, '31.50'),
(144, 84, '48.50'),
(145, 95, '65.50'),
(146, 6, '82.50'),
(147, 17, '99.50'),
(148, 28, '116.50'),
(149, 39, '133.50'),
(150, 50, '150.50'),
(151, 61, '167.50'),
(152, 72, '184.50'),
(153, 83, '201.50'),
(154, 94, '218.50'),
(155, 5, '235.50'),
(156, 16, '252.50'),
(157, 27, '269.50'),
(158, 38, '286.50'),
(159, 49, '3.50'),
(160, 60, '20.50'),
(161, 71, '37.50'),
(162, 82, '54.50'),
(163, 93, '71.50'),
(164, 4, '88.50'),
(165, 15, '105.50'),
(166, 26, '122.50'),
(167, 37, '139.50'),
(168, 48, '156.50'),
(169, 59, '173.50'),
(170, 70, '190.50'),
(171, 81, '207.50'),
(172, 92, '224.50'),
(173, 3, '241.50'),
(174, 14, '258.50'),
(175, 25, '275.50'),
(176, 36, '292.50'),
(177, 47, '9.50'),
(178, 58, '26.50'),
(179, 69, '43.50'),
(180, 80, '60.50'),
(181, 91, '77.50'),
(182, 2, '94.50'),
(183, 13, '111.50'),
(184, 24, '128.50'),
(185, 35, '145.50'),
(186, 46, '162.50'),
(187, 57, '179.50'),
(188, 68, '196.50'),
(189, 79, '213.50'),
(190, 90, '230.50'),
(191, 1, '247.50'),
(192, 12, '264.50'),
(193, 23, '281.50'),
(194, 34, '298.50'),
(195, 45, '15.50'),
(196, 56, '32.50'),
(197, 67, '49.50'),
(198, 78, '66.50'),
(199, 89, '83.50'),
(200, 100, '100.50');

-- --------------------------------------------------------

--
-- Table structure for table `resurs`
--

CREATE TABLE `resurs` (
  `id_resursa` int(11) NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `opis` text DEFAULT NULL,
  `cena_po_komadu` decimal(15,2) NOT NULL,
  `kod_jedinice_vrednosti` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `resurs`
--

INSERT INTO `resurs` (`id_resursa`, `naziv`, `opis`, `cena_po_komadu`, `kod_jedinice_vrednosti`) VALUES
(1, 'Token za odlucivanje #001', 'Resurs koristi se u eksperimentu tip simulacija trzista', '23.00', 'USD'),
(2, 'Anketa #002', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '36.00', 'RSD'),
(3, 'Scenario #003', 'Resurs koristi se u eksperimentu tip ultimatum igra', '49.00', 'GBP'),
(4, 'Set podataka #004', 'Resurs koristi se u eksperimentu tip javna dobra', '62.00', 'CHF'),
(5, 'Skup pitanja #005', 'Resurs koristi se u eksperimentu tip aukcija', '75.00', 'JPY'),
(6, 'Bonus poen #006', 'Resurs koristi se u eksperimentu tip simulacija trzista', '88.00', 'CNY'),
(7, 'Vaucer #007', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '101.00', 'AUD'),
(8, 'Virtuelni novac #008', 'Resurs koristi se u eksperimentu tip ultimatum igra', '114.00', 'CAD'),
(9, 'Token za odlucivanje #009', 'Resurs koristi se u eksperimentu tip javna dobra', '127.00', 'MSFT'),
(10, 'Anketa #010', 'Resurs koristi se u eksperimentu tip aukcija', '140.00', 'AAPL'),
(11, 'Scenario #011', 'Resurs koristi se u eksperimentu tip simulacija trzista', '153.00', 'GOOGL'),
(12, 'Set podataka #012', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '166.00', 'AMZN'),
(13, 'Skup pitanja #013', 'Resurs koristi se u eksperimentu tip ultimatum igra', '179.00', 'TSLA'),
(14, 'Bonus poen #014', 'Resurs koristi se u eksperimentu tip javna dobra', '192.00', 'NVDA'),
(15, 'Vaucer #015', 'Resurs koristi se u eksperimentu tip aukcija', '205.00', 'BTC'),
(16, 'Virtuelni novac #016', 'Resurs koristi se u eksperimentu tip simulacija trzista', '218.00', 'ETH'),
(17, 'Token za odlucivanje #017', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '231.00', 'TKN'),
(18, 'Anketa #018', 'Resurs koristi se u eksperimentu tip ultimatum igra', '244.00', 'VTOK'),
(19, 'Scenario #019', 'Resurs koristi se u eksperimentu tip javna dobra', '257.00', 'LBT'),
(20, 'Set podataka #020', 'Resurs koristi se u eksperimentu tip aukcija', '270.00', 'EUR'),
(21, 'Skup pitanja #021', 'Resurs koristi se u eksperimentu tip simulacija trzista', '283.00', 'USD'),
(22, 'Bonus poen #022', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '296.00', 'RSD'),
(23, 'Vaucer #023', 'Resurs koristi se u eksperimentu tip ultimatum igra', '309.00', 'GBP'),
(24, 'Virtuelni novac #024', 'Resurs koristi se u eksperimentu tip javna dobra', '322.00', 'CHF'),
(25, 'Token za odlucivanje #025', 'Resurs koristi se u eksperimentu tip aukcija', '335.00', 'JPY'),
(26, 'Anketa #026', 'Resurs koristi se u eksperimentu tip simulacija trzista', '348.00', 'CNY'),
(27, 'Scenario #027', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '361.00', 'AUD'),
(28, 'Set podataka #028', 'Resurs koristi se u eksperimentu tip ultimatum igra', '374.00', 'CAD'),
(29, 'Skup pitanja #029', 'Resurs koristi se u eksperimentu tip javna dobra', '387.00', 'MSFT'),
(30, 'Bonus poen #030', 'Resurs koristi se u eksperimentu tip aukcija', '400.00', 'AAPL'),
(31, 'Vaucer #031', 'Resurs koristi se u eksperimentu tip simulacija trzista', '413.00', 'GOOGL'),
(32, 'Virtuelni novac #032', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '426.00', 'AMZN'),
(33, 'Token za odlucivanje #033', 'Resurs koristi se u eksperimentu tip ultimatum igra', '439.00', 'TSLA'),
(34, 'Anketa #034', 'Resurs koristi se u eksperimentu tip javna dobra', '452.00', 'NVDA'),
(35, 'Scenario #035', 'Resurs koristi se u eksperimentu tip aukcija', '465.00', 'BTC'),
(36, 'Set podataka #036', 'Resurs koristi se u eksperimentu tip simulacija trzista', '478.00', 'ETH'),
(37, 'Skup pitanja #037', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '491.00', 'TKN'),
(38, 'Bonus poen #038', 'Resurs koristi se u eksperimentu tip ultimatum igra', '504.00', 'VTOK'),
(39, 'Vaucer #039', 'Resurs koristi se u eksperimentu tip javna dobra', '517.00', 'LBT'),
(40, 'Virtuelni novac #040', 'Resurs koristi se u eksperimentu tip aukcija', '530.00', 'EUR'),
(41, 'Token za odlucivanje #041', 'Resurs koristi se u eksperimentu tip simulacija trzista', '543.00', 'USD'),
(42, 'Anketa #042', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '556.00', 'RSD'),
(43, 'Scenario #043', 'Resurs koristi se u eksperimentu tip ultimatum igra', '569.00', 'GBP'),
(44, 'Set podataka #044', 'Resurs koristi se u eksperimentu tip javna dobra', '582.00', 'CHF'),
(45, 'Skup pitanja #045', 'Resurs koristi se u eksperimentu tip aukcija', '595.00', 'JPY'),
(46, 'Bonus poen #046', 'Resurs koristi se u eksperimentu tip simulacija trzista', '608.00', 'CNY'),
(47, 'Vaucer #047', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '621.00', 'AUD'),
(48, 'Virtuelni novac #048', 'Resurs koristi se u eksperimentu tip ultimatum igra', '634.00', 'CAD'),
(49, 'Token za odlucivanje #049', 'Resurs koristi se u eksperimentu tip javna dobra', '647.00', 'MSFT'),
(50, 'Anketa #050', 'Resurs koristi se u eksperimentu tip aukcija', '660.00', 'AAPL'),
(51, 'Scenario #051', 'Resurs koristi se u eksperimentu tip simulacija trzista', '673.00', 'GOOGL'),
(52, 'Set podataka #052', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '686.00', 'AMZN'),
(53, 'Skup pitanja #053', 'Resurs koristi se u eksperimentu tip ultimatum igra', '699.00', 'TSLA'),
(54, 'Bonus poen #054', 'Resurs koristi se u eksperimentu tip javna dobra', '712.00', 'NVDA'),
(55, 'Vaucer #055', 'Resurs koristi se u eksperimentu tip aukcija', '725.00', 'BTC'),
(56, 'Virtuelni novac #056', 'Resurs koristi se u eksperimentu tip simulacija trzista', '738.00', 'ETH'),
(57, 'Token za odlucivanje #057', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '751.00', 'TKN'),
(58, 'Anketa #058', 'Resurs koristi se u eksperimentu tip ultimatum igra', '764.00', 'VTOK'),
(59, 'Scenario #059', 'Resurs koristi se u eksperimentu tip javna dobra', '777.00', 'LBT'),
(60, 'Set podataka #060', 'Resurs koristi se u eksperimentu tip aukcija', '790.00', 'EUR'),
(61, 'Skup pitanja #061', 'Resurs koristi se u eksperimentu tip simulacija trzista', '803.00', 'USD'),
(62, 'Bonus poen #062', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '816.00', 'RSD'),
(63, 'Vaucer #063', 'Resurs koristi se u eksperimentu tip ultimatum igra', '829.00', 'GBP'),
(64, 'Virtuelni novac #064', 'Resurs koristi se u eksperimentu tip javna dobra', '842.00', 'CHF'),
(65, 'Token za odlucivanje #065', 'Resurs koristi se u eksperimentu tip aukcija', '855.00', 'JPY'),
(66, 'Anketa #066', 'Resurs koristi se u eksperimentu tip simulacija trzista', '868.00', 'CNY'),
(67, 'Scenario #067', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '881.00', 'AUD'),
(68, 'Set podataka #068', 'Resurs koristi se u eksperimentu tip ultimatum igra', '894.00', 'CAD'),
(69, 'Skup pitanja #069', 'Resurs koristi se u eksperimentu tip javna dobra', '907.00', 'MSFT'),
(70, 'Bonus poen #070', 'Resurs koristi se u eksperimentu tip aukcija', '920.00', 'AAPL'),
(71, 'Vaucer #071', 'Resurs koristi se u eksperimentu tip simulacija trzista', '933.00', 'GOOGL'),
(72, 'Virtuelni novac #072', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '946.00', 'AMZN'),
(73, 'Token za odlucivanje #073', 'Resurs koristi se u eksperimentu tip ultimatum igra', '959.00', 'TSLA'),
(74, 'Anketa #074', 'Resurs koristi se u eksperimentu tip javna dobra', '972.00', 'NVDA'),
(75, 'Scenario #075', 'Resurs koristi se u eksperimentu tip aukcija', '985.00', 'BTC'),
(76, 'Set podataka #076', 'Resurs koristi se u eksperimentu tip simulacija trzista', '998.00', 'ETH'),
(77, 'Skup pitanja #077', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '21.00', 'TKN'),
(78, 'Bonus poen #078', 'Resurs koristi se u eksperimentu tip ultimatum igra', '34.00', 'VTOK'),
(79, 'Vaucer #079', 'Resurs koristi se u eksperimentu tip javna dobra', '47.00', 'LBT'),
(80, 'Virtuelni novac #080', 'Resurs koristi se u eksperimentu tip aukcija', '60.00', 'EUR'),
(81, 'Token za odlucivanje #081', 'Resurs koristi se u eksperimentu tip simulacija trzista', '73.00', 'USD'),
(82, 'Anketa #082', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '86.00', 'RSD'),
(83, 'Scenario #083', 'Resurs koristi se u eksperimentu tip ultimatum igra', '99.00', 'GBP'),
(84, 'Set podataka #084', 'Resurs koristi se u eksperimentu tip javna dobra', '112.00', 'CHF'),
(85, 'Skup pitanja #085', 'Resurs koristi se u eksperimentu tip aukcija', '125.00', 'JPY'),
(86, 'Bonus poen #086', 'Resurs koristi se u eksperimentu tip simulacija trzista', '138.00', 'CNY'),
(87, 'Vaucer #087', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '151.00', 'AUD'),
(88, 'Virtuelni novac #088', 'Resurs koristi se u eksperimentu tip ultimatum igra', '164.00', 'CAD'),
(89, 'Token za odlucivanje #089', 'Resurs koristi se u eksperimentu tip javna dobra', '177.00', 'MSFT'),
(90, 'Anketa #090', 'Resurs koristi se u eksperimentu tip aukcija', '190.00', 'AAPL'),
(91, 'Scenario #091', 'Resurs koristi se u eksperimentu tip simulacija trzista', '203.00', 'GOOGL'),
(92, 'Set podataka #092', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '216.00', 'AMZN'),
(93, 'Skup pitanja #093', 'Resurs koristi se u eksperimentu tip ultimatum igra', '229.00', 'TSLA'),
(94, 'Bonus poen #094', 'Resurs koristi se u eksperimentu tip javna dobra', '242.00', 'NVDA'),
(95, 'Vaucer #095', 'Resurs koristi se u eksperimentu tip aukcija', '255.00', 'BTC'),
(96, 'Virtuelni novac #096', 'Resurs koristi se u eksperimentu tip simulacija trzista', '268.00', 'ETH'),
(97, 'Token za odlucivanje #097', 'Resurs koristi se u eksperimentu tip dilema zatvorenika', '281.00', 'TKN'),
(98, 'Anketa #098', 'Resurs koristi se u eksperimentu tip ultimatum igra', '294.00', 'VTOK'),
(99, 'Scenario #099', 'Resurs koristi se u eksperimentu tip javna dobra', '307.00', 'LBT'),
(100, 'Set podataka #100', 'Resurs koristi se u eksperimentu tip aukcija', '320.00', 'EUR');

-- --------------------------------------------------------

--
-- Table structure for table `sesija`
--

CREATE TABLE `sesija` (
  `id_sesije` int(11) NOT NULL,
  `id_izvodjenja` int(11) NOT NULL,
  `id_racunara` int(11) NOT NULL,
  `datum` date NOT NULL,
  `vreme_pocetka` time NOT NULL,
  `vreme_kraja` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sesija`
--

INSERT INTO `sesija` (`id_sesije`, `id_izvodjenja`, `id_racunara`, `datum`, `vreme_pocetka`, `vreme_kraja`) VALUES
(1, 1, 1, '2026-01-02', '09:00:00', '11:00:00'),
(2, 2, 2, '2026-01-03', '10:00:00', '12:00:00'),
(3, 3, 3, '2026-01-04', '11:00:00', '13:00:00'),
(4, 4, 4, '2026-01-05', '12:00:00', '14:00:00'),
(5, 5, 5, '2026-01-06', '13:00:00', '15:00:00'),
(6, 6, 6, '2026-01-07', '14:00:00', '16:00:00'),
(7, 7, 7, '2026-01-08', '15:00:00', '17:00:00'),
(8, 8, 8, '2026-01-09', '16:00:00', '18:00:00'),
(9, 9, 9, '2026-01-10', '17:00:00', '19:00:00'),
(10, 10, 10, '2026-01-11', '08:00:00', '10:00:00'),
(11, 11, 11, '2026-01-12', '09:00:00', '11:00:00'),
(12, 12, 12, '2026-01-13', '10:00:00', '12:00:00'),
(13, 13, 13, '2026-01-14', '11:00:00', '13:00:00'),
(14, 14, 14, '2026-01-15', '12:00:00', '14:00:00'),
(15, 15, 15, '2026-01-16', '13:00:00', '15:00:00'),
(16, 16, 16, '2026-01-17', '14:00:00', '16:00:00'),
(17, 17, 17, '2026-01-18', '15:00:00', '17:00:00'),
(18, 18, 18, '2026-01-19', '16:00:00', '18:00:00'),
(19, 19, 19, '2026-01-20', '17:00:00', '19:00:00'),
(20, 20, 20, '2026-01-21', '08:00:00', '10:00:00'),
(21, 21, 21, '2026-01-22', '09:00:00', '11:00:00'),
(22, 22, 22, '2026-01-23', '10:00:00', '12:00:00'),
(23, 23, 23, '2026-01-24', '11:00:00', '13:00:00'),
(24, 24, 24, '2026-01-25', '12:00:00', '14:00:00'),
(25, 25, 25, '2026-01-26', '13:00:00', '15:00:00'),
(26, 26, 26, '2026-01-27', '14:00:00', '16:00:00'),
(27, 27, 27, '2026-01-28', '15:00:00', '17:00:00'),
(28, 28, 28, '2026-01-29', '16:00:00', '18:00:00'),
(29, 29, 29, '2026-01-30', '17:00:00', '19:00:00'),
(30, 30, 30, '2026-01-31', '08:00:00', '10:00:00'),
(31, 31, 31, '2026-02-01', '09:00:00', '11:00:00'),
(32, 32, 32, '2026-02-02', '10:00:00', '12:00:00'),
(33, 33, 33, '2026-02-03', '11:00:00', '13:00:00'),
(34, 34, 34, '2026-02-04', '12:00:00', '14:00:00'),
(35, 35, 35, '2026-02-05', '13:00:00', '15:00:00'),
(36, 36, 36, '2026-02-06', '14:00:00', '16:00:00'),
(37, 37, 37, '2026-02-07', '15:00:00', '17:00:00'),
(38, 38, 38, '2026-02-08', '16:00:00', '18:00:00'),
(39, 39, 39, '2026-02-09', '17:00:00', '19:00:00'),
(40, 40, 40, '2026-02-10', '08:00:00', '10:00:00'),
(41, 41, 41, '2026-02-11', '09:00:00', '11:00:00'),
(42, 42, 42, '2026-02-12', '10:00:00', '12:00:00'),
(43, 43, 43, '2026-02-13', '11:00:00', '13:00:00'),
(44, 44, 44, '2026-02-14', '12:00:00', '14:00:00'),
(45, 45, 45, '2026-02-15', '13:00:00', '15:00:00'),
(46, 46, 46, '2026-02-16', '14:00:00', '16:00:00'),
(47, 47, 47, '2026-02-17', '15:00:00', '17:00:00'),
(48, 48, 48, '2026-02-18', '16:00:00', '18:00:00'),
(49, 49, 49, '2026-02-19', '17:00:00', '19:00:00'),
(50, 50, 50, '2026-02-20', '08:00:00', '10:00:00'),
(51, 51, 51, '2026-02-21', '09:00:00', '11:00:00'),
(52, 52, 52, '2026-02-22', '10:00:00', '12:00:00'),
(53, 53, 53, '2026-02-23', '11:00:00', '13:00:00'),
(54, 54, 54, '2026-02-24', '12:00:00', '14:00:00'),
(55, 55, 55, '2026-02-25', '13:00:00', '15:00:00'),
(56, 56, 56, '2026-02-26', '14:00:00', '16:00:00'),
(57, 57, 57, '2026-02-27', '15:00:00', '17:00:00'),
(58, 58, 58, '2026-02-28', '16:00:00', '18:00:00'),
(59, 59, 59, '2026-03-01', '17:00:00', '19:00:00'),
(60, 60, 60, '2026-03-02', '08:00:00', '10:00:00'),
(61, 61, 61, '2026-03-03', '09:00:00', '11:00:00'),
(62, 62, 62, '2026-03-04', '10:00:00', '12:00:00'),
(63, 63, 63, '2026-03-05', '11:00:00', '13:00:00'),
(64, 64, 64, '2026-03-06', '12:00:00', '14:00:00'),
(65, 65, 65, '2026-03-07', '13:00:00', '15:00:00'),
(66, 66, 66, '2026-03-08', '14:00:00', '16:00:00'),
(67, 67, 67, '2026-03-09', '15:00:00', '17:00:00'),
(68, 68, 68, '2026-03-10', '16:00:00', '18:00:00'),
(69, 69, 69, '2026-03-11', '17:00:00', '19:00:00'),
(70, 70, 70, '2026-03-12', '08:00:00', '10:00:00'),
(71, 71, 71, '2026-03-13', '09:00:00', '11:00:00'),
(72, 72, 72, '2026-03-14', '10:00:00', '12:00:00'),
(73, 73, 73, '2026-03-15', '11:00:00', '13:00:00'),
(74, 74, 74, '2026-03-16', '12:00:00', '14:00:00'),
(75, 75, 75, '2026-03-17', '13:00:00', '15:00:00'),
(76, 76, 76, '2026-03-18', '14:00:00', '16:00:00'),
(77, 77, 77, '2026-03-19', '15:00:00', '17:00:00'),
(78, 78, 78, '2026-03-20', '16:00:00', '18:00:00'),
(79, 79, 79, '2026-03-21', '17:00:00', '19:00:00'),
(80, 80, 80, '2026-03-22', '08:00:00', '10:00:00'),
(81, 81, 81, '2026-03-23', '09:00:00', '11:00:00'),
(82, 82, 82, '2026-03-24', '10:00:00', '12:00:00'),
(83, 83, 83, '2026-03-25', '11:00:00', '13:00:00'),
(84, 84, 84, '2026-03-26', '12:00:00', '14:00:00'),
(85, 85, 85, '2026-03-27', '13:00:00', '15:00:00'),
(86, 86, 86, '2026-03-28', '14:00:00', '16:00:00'),
(87, 87, 87, '2026-03-29', '15:00:00', '17:00:00'),
(88, 88, 88, '2026-03-30', '16:00:00', '18:00:00'),
(89, 89, 89, '2026-03-31', '17:00:00', '19:00:00'),
(90, 90, 90, '2026-04-01', '08:00:00', '10:00:00'),
(91, 91, 91, '2026-04-02', '09:00:00', '11:00:00'),
(92, 92, 92, '2026-04-03', '10:00:00', '12:00:00'),
(93, 93, 93, '2026-04-04', '11:00:00', '13:00:00'),
(94, 94, 94, '2026-04-05', '12:00:00', '14:00:00'),
(95, 95, 95, '2026-04-06', '13:00:00', '15:00:00'),
(96, 96, 96, '2026-04-07', '14:00:00', '16:00:00'),
(97, 97, 97, '2026-04-08', '15:00:00', '17:00:00'),
(98, 98, 98, '2026-04-09', '16:00:00', '18:00:00'),
(99, 99, 99, '2026-04-10', '17:00:00', '19:00:00'),
(100, 100, 100, '2026-04-11', '08:00:00', '10:00:00'),
(101, 101, 1, '2026-04-12', '09:00:00', '11:00:00'),
(102, 102, 2, '2026-04-13', '10:00:00', '12:00:00'),
(103, 103, 3, '2026-04-14', '11:00:00', '13:00:00'),
(104, 104, 4, '2026-04-15', '12:00:00', '14:00:00'),
(105, 105, 5, '2026-04-16', '13:00:00', '15:00:00'),
(106, 106, 6, '2026-04-17', '14:00:00', '16:00:00'),
(107, 107, 7, '2026-04-18', '15:00:00', '17:00:00'),
(108, 108, 8, '2026-04-19', '16:00:00', '18:00:00'),
(109, 109, 9, '2026-04-20', '17:00:00', '19:00:00'),
(110, 110, 10, '2026-04-21', '08:00:00', '10:00:00'),
(111, 111, 11, '2026-04-22', '09:00:00', '11:00:00'),
(112, 112, 12, '2026-04-23', '10:00:00', '12:00:00'),
(113, 113, 13, '2026-04-24', '11:00:00', '13:00:00'),
(114, 114, 14, '2026-04-25', '12:00:00', '14:00:00'),
(115, 115, 15, '2026-04-26', '13:00:00', '15:00:00'),
(116, 116, 16, '2026-04-27', '14:00:00', '16:00:00'),
(117, 117, 17, '2026-04-28', '15:00:00', '17:00:00'),
(118, 118, 18, '2026-04-29', '16:00:00', '18:00:00'),
(119, 119, 19, '2026-04-30', '17:00:00', '19:00:00'),
(120, 120, 20, '2026-05-01', '08:00:00', '10:00:00'),
(121, 121, 21, '2026-05-02', '09:00:00', '11:00:00'),
(122, 122, 22, '2026-05-03', '10:00:00', '12:00:00'),
(123, 123, 23, '2026-05-04', '11:00:00', '13:00:00'),
(124, 124, 24, '2026-05-05', '12:00:00', '14:00:00'),
(125, 125, 25, '2026-05-06', '13:00:00', '15:00:00'),
(126, 126, 26, '2026-05-07', '14:00:00', '16:00:00'),
(127, 127, 27, '2026-05-08', '15:00:00', '17:00:00'),
(128, 128, 28, '2026-05-09', '16:00:00', '18:00:00'),
(129, 129, 29, '2026-05-10', '17:00:00', '19:00:00'),
(130, 130, 30, '2026-05-11', '08:00:00', '10:00:00'),
(131, 131, 31, '2026-05-12', '09:00:00', '11:00:00'),
(132, 132, 32, '2026-05-13', '10:00:00', '12:00:00'),
(133, 133, 33, '2026-05-14', '11:00:00', '13:00:00'),
(134, 134, 34, '2026-05-15', '12:00:00', '14:00:00'),
(135, 135, 35, '2026-05-16', '13:00:00', '15:00:00'),
(136, 136, 36, '2026-05-17', '14:00:00', '16:00:00'),
(137, 137, 37, '2026-05-18', '15:00:00', '17:00:00'),
(138, 138, 38, '2026-05-19', '16:00:00', '18:00:00'),
(139, 139, 39, '2026-05-20', '17:00:00', '19:00:00'),
(140, 140, 40, '2026-05-21', '08:00:00', '10:00:00'),
(141, 141, 41, '2026-05-22', '09:00:00', '11:00:00'),
(142, 142, 42, '2026-05-23', '10:00:00', '12:00:00'),
(143, 143, 43, '2026-05-24', '11:00:00', '13:00:00'),
(144, 144, 44, '2026-05-25', '12:00:00', '14:00:00'),
(145, 145, 45, '2026-05-26', '13:00:00', '15:00:00'),
(146, 146, 46, '2026-05-27', '14:00:00', '16:00:00'),
(147, 147, 47, '2026-05-28', '15:00:00', '17:00:00'),
(148, 148, 48, '2026-05-29', '16:00:00', '18:00:00'),
(149, 149, 49, '2026-05-30', '17:00:00', '19:00:00'),
(150, 150, 50, '2026-05-31', '08:00:00', '10:00:00'),
(151, 1, 51, '2026-06-01', '09:00:00', '11:00:00'),
(152, 2, 52, '2026-06-02', '10:00:00', '12:00:00'),
(153, 3, 53, '2026-06-03', '11:00:00', '13:00:00'),
(154, 4, 54, '2026-06-04', '12:00:00', '14:00:00'),
(155, 5, 55, '2026-06-05', '13:00:00', '15:00:00'),
(156, 6, 56, '2026-06-06', '14:00:00', '16:00:00'),
(157, 7, 57, '2026-06-07', '15:00:00', '17:00:00'),
(158, 8, 58, '2026-06-08', '16:00:00', '18:00:00'),
(159, 9, 59, '2026-06-09', '17:00:00', '19:00:00'),
(160, 10, 60, '2026-06-10', '08:00:00', '10:00:00'),
(161, 11, 61, '2026-06-11', '09:00:00', '11:00:00'),
(162, 12, 62, '2026-06-12', '10:00:00', '12:00:00'),
(163, 13, 63, '2026-06-13', '11:00:00', '13:00:00'),
(164, 14, 64, '2026-06-14', '12:00:00', '14:00:00'),
(165, 15, 65, '2026-06-15', '13:00:00', '15:00:00'),
(166, 16, 66, '2026-06-16', '14:00:00', '16:00:00'),
(167, 17, 67, '2026-06-17', '15:00:00', '17:00:00'),
(168, 18, 68, '2026-06-18', '16:00:00', '18:00:00'),
(169, 19, 69, '2026-06-19', '17:00:00', '19:00:00'),
(170, 20, 70, '2026-06-20', '08:00:00', '10:00:00'),
(171, 21, 71, '2026-06-21', '09:00:00', '11:00:00'),
(172, 22, 72, '2026-06-22', '10:00:00', '12:00:00'),
(173, 23, 73, '2026-06-23', '11:00:00', '13:00:00'),
(174, 24, 74, '2026-06-24', '12:00:00', '14:00:00'),
(175, 25, 75, '2026-06-25', '13:00:00', '15:00:00'),
(176, 26, 76, '2026-06-26', '14:00:00', '16:00:00'),
(177, 27, 77, '2026-06-27', '15:00:00', '17:00:00'),
(178, 28, 78, '2026-06-28', '16:00:00', '18:00:00'),
(179, 29, 79, '2026-06-29', '17:00:00', '19:00:00'),
(180, 30, 80, '2026-06-30', '08:00:00', '10:00:00'),
(181, 31, 81, '2026-07-01', '09:00:00', '11:00:00'),
(182, 32, 82, '2026-07-02', '10:00:00', '12:00:00'),
(183, 33, 83, '2026-07-03', '11:00:00', '13:00:00'),
(184, 34, 84, '2026-07-04', '12:00:00', '14:00:00'),
(185, 35, 85, '2026-07-05', '13:00:00', '15:00:00'),
(186, 36, 86, '2026-07-06', '14:00:00', '16:00:00'),
(187, 37, 87, '2026-07-07', '15:00:00', '17:00:00'),
(188, 38, 88, '2026-07-08', '16:00:00', '18:00:00'),
(189, 39, 89, '2026-07-09', '17:00:00', '19:00:00'),
(190, 40, 90, '2026-07-10', '08:00:00', '10:00:00'),
(191, 41, 91, '2026-07-11', '09:00:00', '11:00:00'),
(192, 42, 92, '2026-07-12', '10:00:00', '12:00:00'),
(193, 43, 93, '2026-07-13', '11:00:00', '13:00:00'),
(194, 44, 94, '2026-07-14', '12:00:00', '14:00:00'),
(195, 45, 95, '2026-07-15', '13:00:00', '15:00:00'),
(196, 46, 96, '2026-07-16', '14:00:00', '16:00:00'),
(197, 47, 97, '2026-07-17', '15:00:00', '17:00:00'),
(198, 48, 98, '2026-07-18', '16:00:00', '18:00:00'),
(199, 49, 99, '2026-07-19', '17:00:00', '19:00:00'),
(200, 50, 100, '2026-07-20', '08:00:00', '10:00:00'),
(201, 51, 1, '2026-07-21', '09:00:00', '11:00:00'),
(202, 52, 2, '2026-07-22', '10:00:00', '12:00:00'),
(203, 53, 3, '2026-07-23', '11:00:00', '13:00:00'),
(204, 54, 4, '2026-07-24', '12:00:00', '14:00:00'),
(205, 55, 5, '2026-07-25', '13:00:00', '15:00:00'),
(206, 56, 6, '2026-07-26', '14:00:00', '16:00:00'),
(207, 57, 7, '2026-07-27', '15:00:00', '17:00:00'),
(208, 58, 8, '2026-07-28', '16:00:00', '18:00:00'),
(209, 59, 9, '2026-07-29', '17:00:00', '19:00:00'),
(210, 60, 10, '2026-07-30', '08:00:00', '10:00:00'),
(211, 61, 11, '2026-07-31', '09:00:00', '11:00:00'),
(212, 62, 12, '2026-08-01', '10:00:00', '12:00:00'),
(213, 63, 13, '2026-08-02', '11:00:00', '13:00:00'),
(214, 64, 14, '2026-08-03', '12:00:00', '14:00:00'),
(215, 65, 15, '2026-08-04', '13:00:00', '15:00:00'),
(216, 66, 16, '2026-08-05', '14:00:00', '16:00:00'),
(217, 67, 17, '2026-08-06', '15:00:00', '17:00:00'),
(218, 68, 18, '2026-08-07', '16:00:00', '18:00:00'),
(219, 69, 19, '2026-08-08', '17:00:00', '19:00:00'),
(220, 70, 20, '2026-08-09', '08:00:00', '10:00:00'),
(221, 71, 21, '2026-08-10', '09:00:00', '11:00:00'),
(222, 72, 22, '2026-08-11', '10:00:00', '12:00:00'),
(223, 73, 23, '2026-08-12', '11:00:00', '13:00:00'),
(224, 74, 24, '2026-08-13', '12:00:00', '14:00:00'),
(225, 75, 25, '2026-08-14', '13:00:00', '15:00:00'),
(226, 76, 26, '2026-08-15', '14:00:00', '16:00:00'),
(227, 77, 27, '2026-08-16', '15:00:00', '17:00:00'),
(228, 78, 28, '2026-08-17', '16:00:00', '18:00:00'),
(229, 79, 29, '2026-08-18', '17:00:00', '19:00:00'),
(230, 80, 30, '2026-08-19', '08:00:00', '10:00:00'),
(231, 81, 31, '2026-08-20', '09:00:00', '11:00:00'),
(232, 82, 32, '2026-08-21', '10:00:00', '12:00:00'),
(233, 83, 33, '2026-08-22', '11:00:00', '13:00:00'),
(234, 84, 34, '2026-08-23', '12:00:00', '14:00:00'),
(235, 85, 35, '2026-08-24', '13:00:00', '15:00:00'),
(236, 86, 36, '2026-08-25', '14:00:00', '16:00:00'),
(237, 87, 37, '2026-08-26', '15:00:00', '17:00:00'),
(238, 88, 38, '2026-08-27', '16:00:00', '18:00:00'),
(239, 89, 39, '2026-08-28', '17:00:00', '19:00:00'),
(240, 90, 40, '2026-08-29', '08:00:00', '10:00:00'),
(241, 91, 41, '2026-08-30', '09:00:00', '11:00:00'),
(242, 92, 42, '2026-08-31', '10:00:00', '12:00:00'),
(243, 93, 43, '2026-09-01', '11:00:00', '13:00:00'),
(244, 94, 44, '2026-09-02', '12:00:00', '14:00:00'),
(245, 95, 45, '2026-09-03', '13:00:00', '15:00:00'),
(246, 96, 46, '2026-09-04', '14:00:00', '16:00:00'),
(247, 97, 47, '2026-09-05', '15:00:00', '17:00:00'),
(248, 98, 48, '2026-09-06', '16:00:00', '18:00:00'),
(249, 99, 49, '2026-09-07', '17:00:00', '19:00:00'),
(250, 100, 50, '2026-09-08', '08:00:00', '10:00:00'),
(251, 101, 51, '2026-09-09', '09:00:00', '11:00:00'),
(252, 102, 52, '2026-09-10', '10:00:00', '12:00:00'),
(253, 103, 53, '2026-09-11', '11:00:00', '13:00:00'),
(254, 104, 54, '2026-09-12', '12:00:00', '14:00:00'),
(255, 105, 55, '2026-09-13', '13:00:00', '15:00:00'),
(256, 106, 56, '2026-09-14', '14:00:00', '16:00:00'),
(257, 107, 57, '2026-09-15', '15:00:00', '17:00:00'),
(258, 108, 58, '2026-09-16', '16:00:00', '18:00:00'),
(259, 109, 59, '2026-09-17', '17:00:00', '19:00:00'),
(260, 110, 60, '2026-09-18', '08:00:00', '10:00:00'),
(261, 111, 61, '2026-09-19', '09:00:00', '11:00:00'),
(262, 112, 62, '2026-09-20', '10:00:00', '12:00:00'),
(263, 113, 63, '2026-09-21', '11:00:00', '13:00:00'),
(264, 114, 64, '2026-09-22', '12:00:00', '14:00:00'),
(265, 115, 65, '2026-09-23', '13:00:00', '15:00:00'),
(266, 116, 66, '2026-09-24', '14:00:00', '16:00:00'),
(267, 117, 67, '2026-09-25', '15:00:00', '17:00:00'),
(268, 118, 68, '2026-09-26', '16:00:00', '18:00:00'),
(269, 119, 69, '2026-09-27', '17:00:00', '19:00:00'),
(270, 120, 70, '2026-09-28', '08:00:00', '10:00:00'),
(271, 121, 71, '2026-09-29', '09:00:00', '11:00:00'),
(272, 122, 72, '2026-09-30', '10:00:00', '12:00:00'),
(273, 123, 73, '2026-10-01', '11:00:00', '13:00:00'),
(274, 124, 74, '2026-10-02', '12:00:00', '14:00:00'),
(275, 125, 75, '2026-10-03', '13:00:00', '15:00:00'),
(276, 126, 76, '2026-10-04', '14:00:00', '16:00:00'),
(277, 127, 77, '2026-10-05', '15:00:00', '17:00:00'),
(278, 128, 78, '2026-10-06', '16:00:00', '18:00:00'),
(279, 129, 79, '2026-10-07', '17:00:00', '19:00:00'),
(280, 130, 80, '2026-10-08', '08:00:00', '10:00:00'),
(281, 131, 81, '2026-10-09', '09:00:00', '11:00:00'),
(282, 132, 82, '2026-10-10', '10:00:00', '12:00:00'),
(283, 133, 83, '2026-10-11', '11:00:00', '13:00:00'),
(284, 134, 84, '2026-10-12', '12:00:00', '14:00:00'),
(285, 135, 85, '2026-10-13', '13:00:00', '15:00:00'),
(286, 136, 86, '2026-10-14', '14:00:00', '16:00:00'),
(287, 137, 87, '2026-10-15', '15:00:00', '17:00:00'),
(288, 138, 88, '2026-10-16', '16:00:00', '18:00:00'),
(289, 139, 89, '2026-10-17', '17:00:00', '19:00:00'),
(290, 140, 90, '2026-10-18', '08:00:00', '10:00:00'),
(291, 141, 91, '2026-10-19', '09:00:00', '11:00:00'),
(292, 142, 92, '2026-10-20', '10:00:00', '12:00:00'),
(293, 143, 93, '2026-10-21', '11:00:00', '13:00:00'),
(294, 144, 94, '2026-10-22', '12:00:00', '14:00:00'),
(295, 145, 95, '2026-10-23', '13:00:00', '15:00:00'),
(296, 146, 96, '2026-10-24', '14:00:00', '16:00:00'),
(297, 147, 97, '2026-10-25', '15:00:00', '17:00:00'),
(298, 148, 98, '2026-10-26', '16:00:00', '18:00:00'),
(299, 149, 99, '2026-10-27', '17:00:00', '19:00:00'),
(300, 150, 100, '2026-10-28', '08:00:00', '10:00:00'),
(512, 1, 1, '2027-01-01', '09:00:00', '10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `teorijski_okvir`
--

CREATE TABLE `teorijski_okvir` (
  `id_okvira` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `oznaka` varchar(30) DEFAULT NULL,
  `opis` text DEFAULT NULL,
  `tip` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `teorijski_okvir`
--

INSERT INTO `teorijski_okvir` (`id_okvira`, `naziv`, `oznaka`, `opis`, `tip`) VALUES
(1, 'Teorija igara', 'TIG', 'Model strateskih interakcija', 'okvir ekonomskih modela'),
(2, 'Aukcijska teorija', 'AUK', 'Modeli aukcija i licitiranja', 'okvir ekonomskih modela'),
(3, 'Bihevioralna ekonomija', 'BEK', 'Kombinacija ekonomije i psihologije', 'okvir ekonomskih modela'),
(4, 'Prospect teorija', 'PRT', 'Donosenje odluka pod rizikom', 'okvir ekonomskih modela'),
(5, 'Klasicna mikroekonomija', 'MIK', 'Model ponasanja pojedinca i firme', 'okvir ekonomskih modela'),
(6, 'Teorija opste ravnoteze', 'OPR', 'Walras-ova ravnoteza', 'okvir ekonomskih modela'),
(7, 'Ekonometrija', 'EKM', 'Empirijska analiza ekonomskih podataka', 'okvir analitickih metoda'),
(8, 'Regresiona analiza', 'REG', 'Linearne i nelinearne regresije', 'okvir analitickih metoda'),
(9, 'Analiza vremenskih serija', 'TSA', 'Analiza serija u vremenu', 'okvir analitickih metoda'),
(10, 'Kauzalno zakljucivanje', 'CAU', 'DID, IV, RDD pristupi', 'okvir analitickih metoda'),
(11, 'Bajesovska statistika', 'BAY', 'Statistika sa Bayes-ovim pravilom', 'okvir analitickih metoda'),
(12, 'Monte Karlo simulacija', 'MCS', 'Slucajne simulacije', 'okvir analitickih metoda'),
(13, 'Pandas biblioteka', 'PND', 'Manipulacija podacima u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(14, 'Statsmodels biblioteka', 'STM', 'Statisticki modeli u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(15, 'Quantecon biblioteka', 'QEC', 'Kvantitativna ekonomija u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(16, 'Teorija javnog izbora', 'TJI', 'Primena ekonomske analize na politicke procese', 'okvir ekonomskih modela'),
(17, 'Teorija ugovora', 'TUG', 'Dizajn ugovora u uslovima asimetricnih informacija', 'okvir ekonomskih modela'),
(18, 'Teorija principala i agenta', 'TPA', 'Odnos nalodgavaca i izvrsavaca pod asimetr. inform.', 'okvir ekonomskih modela'),
(19, 'Teorija mehanizama', 'TMH', 'Dizajn pravila radi postizanja drustveno zeljenih ish.', 'okvir ekonomskih modela'),
(20, 'Teorija traga', 'TRS', 'Signalizacija i screening u uslovima asim. informacija', 'okvir ekonomskih modela'),
(21, 'Evoluciona teorija igara', 'ETI', 'Evolucija strategija u populacijama tokom vremena', 'okvir ekonomskih modela'),
(22, 'Teorija ponovljenih igara', 'TPG', 'Strategije saradnje u beskonacno ponavljanim igrama', 'okvir ekonomskih modela'),
(23, 'Teorija koalicija', 'TKO', 'Formiranje kooperativnih grupnih aranzmana', 'okvir ekonomskih modela'),
(24, 'Teorija trzista sa fricijama', 'TTF', 'Modeli trg. sa troskovima pretrazivanja i uskladjiv.', 'okvir ekonomskih modela'),
(25, 'Teorija pretrazivanja', 'TSR', 'Search modeli na trzistima rada i robnih razmena', 'okvir ekonomskih modela'),
(26, 'DSGE modelovanje', 'DSG', 'Dinamicki stohasticki modeli opste ravnoteze', 'okvir ekonomskih modela'),
(27, 'Model preklapajucih generacija', 'OLG', 'Medjugeneracijski transfer resursa i stednja', 'okvir ekonomskih modela'),
(28, 'Teorija realnih poslovnih ciklusa', 'RBC', 'Poslovni ciklusi kao efikasni odgovor na sokove', 'okvir ekonomskih modela'),
(29, 'Novokejnzijanski model', 'NKM', 'Lepljive cene, monetarna politika i agregatna traznja', 'okvir ekonomskih modela'),
(30, 'Model agentskog ponasanja (ABM)', 'ABM', 'Simulacija ekonomije kao sistema interakt. agenata', 'okvir ekonomskih modela'),
(31, 'Kompjutacionalna opsta ravnoteza', 'CGE', 'Numericki model celokupne ekonomije za pol. analizu', 'okvir ekonomskih modela'),
(32, 'Moderna teorija portfelja', 'MPT', 'Markowitz-ev model diversifikacije i rizika', 'okvir ekonomskih modela'),
(33, 'Model vrednovanja kapitalnih pri.', 'CAP', 'CAPM – odnos prinosa i sistematskog rizika', 'okvir ekonomskih modela'),
(34, 'Hipoteza efikasnog trzista', 'EMH', 'Cene hartija odrazavaju sve dostupne informacije', 'okvir ekonomskih modela'),
(35, 'Teorija arbitraznog vrednov.', 'APT', 'Multifaktorski model rizika i prinosa', 'okvir ekonomskih modela'),
(36, 'Teorija realnih opcija', 'TRO', 'Opcioni pristup vrednovanju investicionih odluka', 'okvir ekonomskih modela'),
(37, 'Teorija mentalnog racunovodstva', 'MRA', 'Thallerovo modelovanje neformalnih mentalnih kont.', 'okvir ekonomskih modela'),
(38, 'Teorija zavisti i reciprociteta', 'TZR', 'Fehr-Schmidt model preferencija prema pravednosti', 'okvir ekonomskih modela'),
(39, 'Teorija vremenskog diskontov.', 'TVD', 'Hiperbolicki i eksponencijalni modeli strpljenja', 'okvir ekonomskih modela'),
(40, 'Teorija srecanog izbora', 'TSI', 'Salience teorija – paznja kao osnova odlucivanja', 'okvir ekonomskih modela'),
(41, 'Model kognitivnih ogranicenja', 'MKO', 'Bounded rationality – Simon-ov model zadovolj. resenja', 'okvir ekonomskih modela'),
(42, 'Nudge teorija', 'NDG', 'Arhitektura izbora i libertarijanski paternalizam', 'okvir ekonomskih modela'),
(43, 'Teorija referentnih tacaka', 'TRT', 'Status quo i referentna tacka u donos. odluka', 'okvir ekonomskih modela'),
(44, 'Difference-in-Differences', 'DID', 'Procena efekta intervencije poredjenje panel podataka', 'okvir analitickih metoda'),
(45, 'Regresiona diskontinuitet analiza', 'RDD', 'Eksploatacija praga za kauzalnu identifikaciju', 'okvir analitickih metoda'),
(46, 'Instrumentalne promenljive', 'IVE', 'IV pristup za resavanje endogenosti u regresiji', 'okvir analitickih metoda'),
(47, 'Matching metode', 'MTH', 'PSM i ostale metode uparivanja tretmana i kontrole', 'okvir analitickih metoda'),
(48, 'Sintetska kontrola', 'SYN', 'Konstruisanje sintetske kontrolne grupe iz podataka', 'okvir analitickih metoda'),
(49, 'Randomizovana kontrolna studija', 'RCT', 'Nasumicna dodela tretmana za kauzalnu analizu', 'okvir analitickih metoda'),
(50, 'VAR modelovanje', 'VAR', 'Vektorski autoregresivni modeli za vise vremenskih ser.', 'okvir analitickih metoda'),
(51, 'ARIMA modelovanje', 'ARM', 'Autoregresivni integrisani modeli pokretnih proseka', 'okvir analitickih metoda'),
(52, 'GARCH modelovanje', 'GRC', 'Modeli heteroskedasticnosti za finansijske serije', 'okvir analitickih metoda'),
(53, 'Kointegracija i ECM', 'KOI', 'Dugorocna ravnoteza i model korekcije greske', 'okvir analitickih metoda'),
(54, 'Filtri za vremenske serije', 'FVS', 'Hodrick-Prescott i Kalman-ov filtar za cikluse', 'okvir analitickih metoda'),
(55, 'Spektralna analiza', 'SPA', 'Fourier i wavelet analiza periodicnih komponenti', 'okvir analitickih metoda'),
(56, 'Stabla odlucivanja i random for.', 'SOR', 'Decision trees, random forests za predikciju', 'okvir analitickih metoda'),
(57, 'Gradient Boosting metode', 'GBM', 'XGBoost, LightGBM i slicni ansambli', 'okvir analitickih metoda'),
(58, 'Regulizacione regresije', 'REL', 'LASSO, Ridge i ElasticNet za selekciju varijabli', 'okvir analitickih metoda'),
(59, 'Analiza glavnih komponenti', 'PCA', 'Redukcija dimenzija ortogonalnom transformacijom', 'okvir analitickih metoda'),
(60, 'Klasterska analiza', 'KLA', 'k-means, hierarhijsko i DBSCAN klasterovanje', 'okvir analitickih metoda'),
(61, 'Neuronske mreze', 'ANN', 'Duboko ucenje za prepoznavanje sablona u podacima', 'okvir analitickih metoda'),
(62, 'Analiza panelnih podataka', 'PAN', 'Fixed i random effects modeli za panel podatke', 'okvir analitickih metoda'),
(63, 'Visenivoovsko modelovanje', 'HLM', 'Hijerarhijski linearni modeli za ugnjezdene podatke', 'okvir analitickih metoda'),
(64, 'Strukturno jednacinsko model.', 'SEM', 'Latentne promenljive i putna analiza', 'okvir analitickih metoda'),
(65, 'Analiza prezivljavanja', 'SUR', 'Hazardni modeli i Kaplan-Meier procenilac', 'okvir analitickih metoda'),
(66, 'Diskretni modeli izbora', 'DMI', 'Logit, probit i multinomijalni modeli', 'okvir analitickih metoda'),
(67, 'Bootstrap metode', 'BST', 'Resampling za procenu preciznosti i intervala poverjav.', 'okvir analitickih metoda'),
(68, 'Analiza osetljivosti', 'OST', 'Testiranje robustnosti rezultata na promenu pretpost.', 'okvir analitickih metoda'),
(69, 'Faktorska analiza', 'FAK', 'Ekstrakcija latentnih faktora iz korelacione strukture', 'okvir analitickih metoda'),
(70, 'Prostorna ekonometrija', 'SPE', 'Modeli koji uzimaju u obzir prostornu zavisnost', 'okvir analitickih metoda'),
(71, 'Kvantilna regresija', 'KVR', 'Regresija za razlicite kvantile distribucije', 'okvir analitickih metoda'),
(72, 'NumPy biblioteka', 'NPY', 'Osnovna biblioteka za numericko racunanje u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(73, 'SciPy biblioteka', 'SPY', 'Naucno racunanje: optimizacija, integracija, statistika', 'okvir biblioteka za ekonomsku analizu podataka'),
(74, 'Scikit-learn biblioteka', 'SKL', 'Masinsko ucenje: klasifikacija, regresija, klasteriz.', 'okvir biblioteka za ekonomsku analizu podataka'),
(75, 'Matplotlib biblioteka', 'MPL', 'Osnovna vizuelizacija u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(76, 'Seaborn biblioteka', 'SBN', 'Statisticka vizuelizacija zasnovana na Matplotlib', 'okvir biblioteka za ekonomsku analizu podataka'),
(77, 'PyMC biblioteka', 'PMC', 'Bajezovsko probabilisticko programiranje u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(78, 'Linearmodels biblioteka', 'LML', 'Panel podaci, IV regresija i SUR u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(79, 'Pingouin biblioteka', 'PNG', 'Statisticke analize u stilu SciPy za istrazivace', 'okvir biblioteka za ekonomsku analizu podataka'),
(80, 'NetworkX biblioteka', 'NTX', 'Analiza grafova i mreznih struktura u Python-u', 'okvir biblioteka za ekonomsku analizu podataka'),
(81, 'NLTK biblioteka', 'NLT', 'Obrada prirodnog jezika za tekstualne ekonomske podatke', 'okvir biblioteka za ekonomsku analizu podataka'),
(82, 'Keras biblioteka', 'KRS', 'Visoko-nivo API za neuronske mreze na TensorFlow', 'okvir biblioteka za ekonomsku analizu podataka'),
(83, 'PyTorch biblioteka', 'PTC', 'Fleksibilno duboko ucenje i automatsko diferenciranje', 'okvir biblioteka za ekonomsku analizu podataka'),
(84, 'Plotly biblioteka', 'PLT', 'Interaktivna vizuelizacija za web i Jupyter okruzenje', 'okvir biblioteka za ekonomsku analizu podataka'),
(85, 'ggplot2 paket', 'GGP', 'Deklarativna vizuelizacija podataka u R jeziku', 'okvir biblioteka za ekonomsku analizu podataka'),
(86, 'dplyr paket', 'DPL', 'Manipulacija tabelarnim podacima u R jeziku', 'okvir biblioteka za ekonomsku analizu podataka'),
(87, 'tidyr paket', 'TDR', 'Uredjivanje i preoblikovanje podataka u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(88, 'lme4 paket', 'LM4', 'Mesoviti efekti i multilevel modeli u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(89, 'plm paket', 'PLM', 'Panel podaci i ekonometrijski modeli u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(90, 'AER paket', 'AER', 'Primenjena ekonometrija u R: IV, panel, tobit', 'okvir biblioteka za ekonomsku analizu podataka'),
(91, 'forecast paket', 'FRC', 'Predvidjanje vremenskih serija u R (Hyndman)', 'okvir biblioteka za ekonomsku analizu podataka'),
(92, 'quantmod paket', 'QMD', 'Kvantitativno finansijsko modelovanje u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(93, 'MatchIt paket', 'MCI', 'Matching metode za kauzalnu analizu u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(94, 'rdrobust paket', 'RDR', 'RDD analiza sa robustnim standardnim greskama u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(95, 'caret paket', 'CAR', 'Unifikovan interfejs za masinsko ucenje u R', 'okvir biblioteka za ekonomsku analizu podataka'),
(96, 'DYNARE paket', 'DYN', 'Resavanje i estimacija DSGE modela (MATLAB/Octave)', 'okvir biblioteka za ekonomsku analizu podataka'),
(97, 'Stan probabilisticki jezik', 'STN', 'Bayesovska statistika: MCMC i varijaciona inferencija', 'okvir biblioteka za ekonomsku analizu podataka'),
(98, 'Apache Spark okvir', 'SPK', 'Distribuirana obrada velikih ekonomskih dataseta', 'okvir biblioteka za ekonomsku analizu podataka'),
(99, 'DuckDB analiticki sistem', 'DDB', 'In-process OLAP za brzu analizu lokalnih dataseta', 'okvir biblioteka za ekonomsku analizu podataka'),
(100, 'Jupyter okruzenje', 'JPT', 'Interaktivni notesi za reproduktivna istrazivanja', 'okvir biblioteka za ekonomsku analizu podataka');

-- --------------------------------------------------------

--
-- Table structure for table `tip_alata`
--

CREATE TABLE `tip_alata` (
  `id_tipa_alata` int(11) NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `opis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tip_alata`
--

INSERT INTO `tip_alata` (`id_tipa_alata`, `naziv`, `opis`) VALUES
(1, 'Java', 'Programski jezik Java'),
(2, 'Python', 'Programski jezik Python'),
(3, 'R', 'Statisticki programski jezik R'),
(4, 'MATLAB', 'Numericko okruzenje MATLAB'),
(5, 'Julia', 'Visokoperformantni jezik za naucno racunanje'),
(6, 'Scala', 'Funkcionalni JVM programski jezik'),
(7, 'C++', 'Sistemski programski jezik C++'),
(8, 'Fortran', 'Programski jezik za naucne proracune'),
(9, 'Haskell', 'Funkcionalni programski jezik Haskell'),
(10, 'Lua', 'Lagani skriptni programski jezik'),
(11, 'Stata', 'Statisticki paket za ekonomiju'),
(12, 'SPSS', 'Statisticki paket za drustvene nauke'),
(13, 'EViews', 'Ekonometrijski softver za vremenske serije'),
(14, 'Gretl', 'Besplatni ekonometrijski softver'),
(15, 'SAS', 'Statisticki i analiticki softver'),
(16, 'Minitab', 'Statisticki softver za kvalitet i istrazivanje'),
(17, 'RATS', 'Regresijska analiza vremenskih serija'),
(18, 'OxMetrics', 'Paket za ekonometrijsko modelovanje'),
(19, 'Gauss', 'Matricki programski jezik za statistiku'),
(20, 'TSP', 'Time Series Processor za ekonometriju'),
(21, 'WinBUGS', 'Bajezijanska statisticka analiza'),
(22, 'Stan', 'Probabilisticko programiranje i MCMC'),
(23, 'LIMDEP', 'Softver za diskretne i ogranicene zavisne promenljive'),
(24, 'Mplus', 'Strukturno modelovanje i latentne promenljive'),
(25, 'AMOS', 'Analiza strukturnih jednacina (SEM)'),
(26, 'zTree', 'Platforma za laboratorijske ekonomske eksperimente'),
(27, 'oTree', 'Open-source eksperimentalna platforma'),
(28, 'LIONESS', 'Online eksperimentalna platforma'),
(29, 'PsychoPy', 'Biblioteka za psiholoske eksperimente'),
(30, 'Qualtrics', 'Platforma za ankete i eksperimentalna istrazivanja'),
(31, 'Gorilla', 'Online eksperimentalna platforma za bihevioralna istrazivanja'),
(32, 'LabVanced', 'Web platforma za kognitivne eksperimente'),
(33, 'MTurk', 'Amazon platforma za crowdsourcing eksperimente'),
(34, 'Prolific', 'Platforma za akademska online istrazivanja'),
(35, 'VECONLAB', 'Virginia Economics Laboratory eksperimentalna platforma'),
(36, 'Pandas', 'Python biblioteka za manipulaciju podacima'),
(37, 'NumPy', 'Python biblioteka za numericko racunanje'),
(38, 'Scikit-learn', 'Masinsko ucenje u Python-u'),
(39, 'TensorFlow', 'Google biblioteka za duboko ucenje'),
(40, 'PyTorch', 'Facebook biblioteka za duboko ucenje'),
(41, 'SciPy', 'Python biblioteka za naucno racunanje'),
(42, 'Statsmodels', 'Python biblioteka za statisticke modele'),
(43, 'Matplotlib', 'Python biblioteka za vizuelizaciju podataka'),
(44, 'Seaborn', 'Statisticka vizuelizacija zasnovana na Matplotlib'),
(45, 'Keras', 'Visoko-nivo API za neuronske mreze'),
(46, 'NLTK', 'Python alati za obradu prirodnog jezika'),
(47, 'Spacy', 'Industrijska biblioteka za NLP'),
(48, 'Pingouin', 'Python statisticka biblioteka za psihologe i ekonomiste'),
(49, 'Linearmodels', 'Python panel i IV modeli za ekonometriju'),
(50, 'Pymc', 'Verovatnosno programiranje u Python-u'),
(51, 'ggplot2', 'R paket za deklarativnu vizuelizaciju podataka'),
(52, 'dplyr', 'R paket za manipulaciju tabelarnim podacima'),
(53, 'tidyr', 'R paket za uredivanje podataka'),
(54, 'lme4', 'R paket za mesovite efekte i panel modele'),
(55, 'plm', 'R paket za panel podatke u ekonometriji'),
(56, 'AER', 'R paket za primenjenu ekonometriju'),
(57, 'forecast', 'R paket za predvidjanje vremenskih serija'),
(58, 'quantmod', 'R paket za kvantitativno finansijsko modelovanje'),
(59, 'MatchIt', 'R paket za matching u kauzalnoj analizi'),
(60, 'rdrobust', 'R paket za regresijsku diskontinuitet analizu'),
(61, 'Tableau', 'Interaktivna vizuelizacija podataka'),
(62, 'PowerBI', 'Microsoft platforma za poslovnu analitiku'),
(63, 'Looker', 'Google platforma za poslovnu inteligenciju'),
(64, 'D3.js', 'JavaScript biblioteka za dinamicku vizuelizaciju'),
(65, 'Plotly', 'Interaktivna vizuelizacija za web i Python/R'),
(66, 'Shiny', 'R okvir za interaktivne web aplikacije'),
(67, 'Dash', 'Python okvir za analiticki web interfejs'),
(68, 'PostgreSQL', 'Relaciona baza podataka otvorenog koda'),
(69, 'MySQL', 'Siroko raspostranjena relaciona baza podataka'),
(70, 'SQLite', 'Ugradjena lagana relaciona baza podataka'),
(71, 'MongoDB', 'Dokumentno orijentisana NoSQL baza podataka'),
(72, 'Redis', 'In-memory baza podataka za kesh i redove'),
(73, 'DuckDB', 'Analiticki OLAP sistem upravljanja bazom podataka'),
(74, 'Spark', 'Apache platforma za distribuiranu obradu podataka'),
(75, 'Hadoop', 'Apache okvir za distribuiranu obradu velikih podataka'),
(76, 'Snowflake', 'Cloud skladiste podataka'),
(77, 'Git', 'Sistem za kontrolu verzija'),
(78, 'GitHub', 'Platforma za kolaborativni razvoj softvera'),
(79, 'Jupyter', 'Interaktivno okruzenje za naucne proracune'),
(80, 'RStudio', 'Integrisano razvojno okruzenje za R'),
(81, 'VS Code', 'Microsoft editor koda za razlicite jezike'),
(82, 'Docker', 'Platforma za kontejnerizaciju aplikacija'),
(83, 'LaTeX', 'Sistem za pripremu naucnih dokumenata'),
(84, 'XGBoost', 'Gradijentno pojacavanje za strukturirane podatke'),
(85, 'LightGBM', 'Microsoft brzi okvir za gradijentno pojacavanje'),
(86, 'CatBoost', 'Yandex biblioteka za gradijentno pojacavanje'),
(87, 'H2O', 'Platforma za automatizovano masinsko ucenje'),
(88, 'WEKA', 'Java platforma za masinsko ucenje'),
(89, 'RapidMiner', 'Platforma za naprednu analitiku i ML'),
(90, 'Orange', 'Vizuelna platforma za analizu i ML'),
(91, 'Excel', 'Microsoft tabelarni kalkulator'),
(92, 'DYNARE', 'MATLAB/Octave paket za DSGE modele'),
(93, 'AMPL', 'Jezik za matematicko programiranje i optimizaciju'),
(94, 'CPLEX', 'IBM resavac za linearno i kvadratno programiranje'),
(95, 'Gurobi', 'Komercijalni resavac za matematicku optimizaciju'),
(96, 'NLOGIT', 'Softver za diskretne modele izbora'),
(97, 'Gephi', 'Platforma za analizu i vizuelizaciju mreza'),
(98, 'NetLogo', 'Platforma za agent-zasnovano modelovanje'),
(99, 'AnyLogic', 'Softver za viseparadigmalno simulaciono modelovanje'),
(100, 'GEMPACK', 'Softver za opstu ravnotezu i CGE modele');

-- --------------------------------------------------------

--
-- Table structure for table `uloga_izvodjaca`
--

CREATE TABLE `uloga_izvodjaca` (
  `id_izvodjenja` int(11) NOT NULL,
  `id_izvodjaca` int(11) NOT NULL,
  `opis_uloge` varchar(200) DEFAULT NULL,
  `putanja_belezaka` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `uloga_izvodjaca`
--

INSERT INTO `uloga_izvodjaca` (`id_izvodjenja`, `id_izvodjaca`, `opis_uloge`, `putanja_belezaka`) VALUES
(1, 1, 'asistent na sesiji', '/beleske/exp_0001.txt'),
(1, 106, 'asistent na sesiji', '/beleske/exp_0151.txt'),
(2, 2, 'analiticar podataka', '/beleske/exp_0002.txt'),
(2, 107, 'analiticar podataka', '/beleske/exp_0152.txt'),
(3, 4, 'koordinator ucesnika', '/beleske/exp_0003.txt'),
(3, 109, 'koordinator ucesnika', '/beleske/exp_0153.txt'),
(4, 5, 'tehnicka podrska', '/beleske/exp_0004.txt'),
(4, 110, 'tehnicka podrska', '/beleske/exp_0154.txt'),
(5, 7, 'glavni eksperimentator', '/beleske/exp_0005.txt'),
(5, 112, 'glavni eksperimentator', '/beleske/exp_0155.txt'),
(6, 8, 'asistent na sesiji', '/beleske/exp_0006.txt'),
(6, 113, 'asistent na sesiji', '/beleske/exp_0156.txt'),
(7, 10, 'analiticar podataka', '/beleske/exp_0007.txt'),
(7, 115, 'analiticar podataka', '/beleske/exp_0157.txt'),
(8, 11, 'koordinator ucesnika', '/beleske/exp_0008.txt'),
(8, 116, 'koordinator ucesnika', '/beleske/exp_0158.txt'),
(9, 13, 'tehnicka podrska', '/beleske/exp_0009.txt'),
(9, 118, 'tehnicka podrska', '/beleske/exp_0159.txt'),
(10, 14, 'glavni eksperimentator', '/beleske/exp_0010.txt'),
(10, 119, 'glavni eksperimentator', '/beleske/exp_0160.txt'),
(11, 1, 'asistent na sesiji', '/beleske/exp_0161.txt'),
(11, 16, 'asistent na sesiji', '/beleske/exp_0011.txt'),
(12, 2, 'analiticar podataka', '/beleske/exp_0162.txt'),
(12, 17, 'analiticar podataka', '/beleske/exp_0012.txt'),
(13, 4, 'koordinator ucesnika', '/beleske/exp_0163.txt'),
(13, 19, 'koordinator ucesnika', '/beleske/exp_0013.txt'),
(14, 5, 'tehnicka podrska', '/beleske/exp_0164.txt'),
(14, 20, 'tehnicka podrska', '/beleske/exp_0014.txt'),
(15, 7, 'glavni eksperimentator', '/beleske/exp_0165.txt'),
(15, 22, 'glavni eksperimentator', '/beleske/exp_0015.txt'),
(16, 8, 'asistent na sesiji', '/beleske/exp_0166.txt'),
(16, 23, 'asistent na sesiji', '/beleske/exp_0016.txt'),
(17, 10, 'analiticar podataka', '/beleske/exp_0167.txt'),
(17, 25, 'analiticar podataka', '/beleske/exp_0017.txt'),
(18, 11, 'koordinator ucesnika', '/beleske/exp_0168.txt'),
(18, 26, 'koordinator ucesnika', '/beleske/exp_0018.txt'),
(19, 13, 'tehnicka podrska', '/beleske/exp_0169.txt'),
(19, 28, 'tehnicka podrska', '/beleske/exp_0019.txt'),
(20, 14, 'glavni eksperimentator', '/beleske/exp_0170.txt'),
(20, 29, 'glavni eksperimentator', '/beleske/exp_0020.txt'),
(21, 16, 'asistent na sesiji', '/beleske/exp_0171.txt'),
(21, 31, 'asistent na sesiji', '/beleske/exp_0021.txt'),
(22, 17, 'analiticar podataka', '/beleske/exp_0172.txt'),
(22, 32, 'analiticar podataka', '/beleske/exp_0022.txt'),
(23, 19, 'koordinator ucesnika', '/beleske/exp_0173.txt'),
(23, 34, 'koordinator ucesnika', '/beleske/exp_0023.txt'),
(24, 20, 'tehnicka podrska', '/beleske/exp_0174.txt'),
(24, 35, 'tehnicka podrska', '/beleske/exp_0024.txt'),
(25, 22, 'glavni eksperimentator', '/beleske/exp_0175.txt'),
(25, 37, 'glavni eksperimentator', '/beleske/exp_0025.txt'),
(26, 23, 'asistent na sesiji', '/beleske/exp_0176.txt'),
(26, 38, 'asistent na sesiji', '/beleske/exp_0026.txt'),
(27, 25, 'analiticar podataka', '/beleske/exp_0177.txt'),
(27, 40, 'analiticar podataka', '/beleske/exp_0027.txt'),
(28, 26, 'koordinator ucesnika', '/beleske/exp_0178.txt'),
(28, 41, 'koordinator ucesnika', '/beleske/exp_0028.txt'),
(29, 28, 'tehnicka podrska', '/beleske/exp_0179.txt'),
(29, 43, 'tehnicka podrska', '/beleske/exp_0029.txt'),
(30, 29, 'glavni eksperimentator', '/beleske/exp_0180.txt'),
(30, 44, 'glavni eksperimentator', '/beleske/exp_0030.txt'),
(31, 31, 'asistent na sesiji', '/beleske/exp_0181.txt'),
(31, 46, 'asistent na sesiji', '/beleske/exp_0031.txt'),
(32, 32, 'analiticar podataka', '/beleske/exp_0182.txt'),
(32, 47, 'analiticar podataka', '/beleske/exp_0032.txt'),
(33, 34, 'koordinator ucesnika', '/beleske/exp_0183.txt'),
(33, 49, 'koordinator ucesnika', '/beleske/exp_0033.txt'),
(34, 35, 'tehnicka podrska', '/beleske/exp_0184.txt'),
(34, 50, 'tehnicka podrska', '/beleske/exp_0034.txt'),
(35, 37, 'glavni eksperimentator', '/beleske/exp_0185.txt'),
(35, 52, 'glavni eksperimentator', '/beleske/exp_0035.txt'),
(36, 38, 'asistent na sesiji', '/beleske/exp_0186.txt'),
(36, 53, 'asistent na sesiji', '/beleske/exp_0036.txt'),
(37, 40, 'analiticar podataka', '/beleske/exp_0187.txt'),
(37, 55, 'analiticar podataka', '/beleske/exp_0037.txt'),
(38, 41, 'koordinator ucesnika', '/beleske/exp_0188.txt'),
(38, 56, 'koordinator ucesnika', '/beleske/exp_0038.txt'),
(39, 43, 'tehnicka podrska', '/beleske/exp_0189.txt'),
(39, 58, 'tehnicka podrska', '/beleske/exp_0039.txt'),
(40, 44, 'glavni eksperimentator', '/beleske/exp_0190.txt'),
(40, 59, 'glavni eksperimentator', '/beleske/exp_0040.txt'),
(41, 46, 'asistent na sesiji', '/beleske/exp_0191.txt'),
(41, 61, 'asistent na sesiji', '/beleske/exp_0041.txt'),
(42, 47, 'analiticar podataka', '/beleske/exp_0192.txt'),
(42, 62, 'analiticar podataka', '/beleske/exp_0042.txt'),
(43, 49, 'koordinator ucesnika', '/beleske/exp_0193.txt'),
(43, 64, 'koordinator ucesnika', '/beleske/exp_0043.txt'),
(44, 50, 'tehnicka podrska', '/beleske/exp_0194.txt'),
(44, 65, 'tehnicka podrska', '/beleske/exp_0044.txt'),
(45, 52, 'glavni eksperimentator', '/beleske/exp_0195.txt'),
(45, 67, 'glavni eksperimentator', '/beleske/exp_0045.txt'),
(46, 53, 'asistent na sesiji', '/beleske/exp_0196.txt'),
(46, 68, 'asistent na sesiji', '/beleske/exp_0046.txt'),
(47, 55, 'analiticar podataka', '/beleske/exp_0197.txt'),
(47, 70, 'analiticar podataka', '/beleske/exp_0047.txt'),
(48, 56, 'koordinator ucesnika', '/beleske/exp_0198.txt'),
(48, 71, 'koordinator ucesnika', '/beleske/exp_0048.txt'),
(49, 58, 'tehnicka podrska', '/beleske/exp_0199.txt'),
(49, 73, 'tehnicka podrska', '/beleske/exp_0049.txt'),
(50, 59, 'glavni eksperimentator', '/beleske/exp_0200.txt'),
(50, 74, 'glavni eksperimentator', '/beleske/exp_0050.txt'),
(51, 61, 'asistent na sesiji', '/beleske/exp_0201.txt'),
(51, 76, 'asistent na sesiji', '/beleske/exp_0051.txt'),
(52, 77, 'analiticar podataka', '/beleske/exp_0052.txt'),
(53, 79, 'koordinator ucesnika', '/beleske/exp_0053.txt'),
(54, 80, 'tehnicka podrska', '/beleske/exp_0054.txt'),
(55, 82, 'glavni eksperimentator', '/beleske/exp_0055.txt'),
(56, 83, 'asistent na sesiji', '/beleske/exp_0056.txt'),
(57, 85, 'analiticar podataka', '/beleske/exp_0057.txt'),
(58, 86, 'koordinator ucesnika', '/beleske/exp_0058.txt'),
(59, 88, 'tehnicka podrska', '/beleske/exp_0059.txt'),
(60, 89, 'glavni eksperimentator', '/beleske/exp_0060.txt'),
(61, 91, 'asistent na sesiji', '/beleske/exp_0061.txt'),
(62, 92, 'analiticar podataka', '/beleske/exp_0062.txt'),
(63, 94, 'koordinator ucesnika', '/beleske/exp_0063.txt'),
(64, 95, 'tehnicka podrska', '/beleske/exp_0064.txt'),
(65, 97, 'glavni eksperimentator', '/beleske/exp_0065.txt'),
(66, 98, 'asistent na sesiji', '/beleske/exp_0066.txt'),
(67, 100, 'analiticar podataka', '/beleske/exp_0067.txt'),
(68, 101, 'koordinator ucesnika', '/beleske/exp_0068.txt'),
(69, 103, 'tehnicka podrska', '/beleske/exp_0069.txt'),
(70, 104, 'glavni eksperimentator', '/beleske/exp_0070.txt'),
(71, 106, 'asistent na sesiji', '/beleske/exp_0071.txt'),
(72, 107, 'analiticar podataka', '/beleske/exp_0072.txt'),
(73, 109, 'koordinator ucesnika', '/beleske/exp_0073.txt'),
(74, 110, 'tehnicka podrska', '/beleske/exp_0074.txt'),
(75, 112, 'glavni eksperimentator', '/beleske/exp_0075.txt'),
(76, 113, 'asistent na sesiji', '/beleske/exp_0076.txt'),
(77, 115, 'analiticar podataka', '/beleske/exp_0077.txt'),
(78, 116, 'koordinator ucesnika', '/beleske/exp_0078.txt'),
(79, 118, 'tehnicka podrska', '/beleske/exp_0079.txt'),
(80, 119, 'glavni eksperimentator', '/beleske/exp_0080.txt'),
(81, 1, 'asistent na sesiji', '/beleske/exp_0081.txt'),
(82, 2, 'analiticar podataka', '/beleske/exp_0082.txt'),
(83, 4, 'koordinator ucesnika', '/beleske/exp_0083.txt'),
(84, 5, 'tehnicka podrska', '/beleske/exp_0084.txt'),
(85, 7, 'glavni eksperimentator', '/beleske/exp_0085.txt'),
(86, 8, 'asistent na sesiji', '/beleske/exp_0086.txt'),
(87, 10, 'analiticar podataka', '/beleske/exp_0087.txt'),
(88, 11, 'koordinator ucesnika', '/beleske/exp_0088.txt'),
(89, 13, 'tehnicka podrska', '/beleske/exp_0089.txt'),
(90, 14, 'glavni eksperimentator', '/beleske/exp_0090.txt'),
(91, 16, 'asistent na sesiji', '/beleske/exp_0091.txt'),
(92, 17, 'analiticar podataka', '/beleske/exp_0092.txt'),
(93, 19, 'koordinator ucesnika', '/beleske/exp_0093.txt'),
(94, 20, 'tehnicka podrska', '/beleske/exp_0094.txt'),
(95, 22, 'glavni eksperimentator', '/beleske/exp_0095.txt'),
(96, 23, 'asistent na sesiji', '/beleske/exp_0096.txt'),
(97, 25, 'analiticar podataka', '/beleske/exp_0097.txt'),
(98, 26, 'koordinator ucesnika', '/beleske/exp_0098.txt'),
(99, 28, 'tehnicka podrska', '/beleske/exp_0099.txt'),
(100, 29, 'glavni eksperimentator', '/beleske/exp_0100.txt'),
(101, 31, 'asistent na sesiji', '/beleske/exp_0101.txt'),
(102, 32, 'analiticar podataka', '/beleske/exp_0102.txt'),
(103, 34, 'koordinator ucesnika', '/beleske/exp_0103.txt'),
(104, 35, 'tehnicka podrska', '/beleske/exp_0104.txt'),
(105, 37, 'glavni eksperimentator', '/beleske/exp_0105.txt'),
(106, 38, 'asistent na sesiji', '/beleske/exp_0106.txt'),
(107, 40, 'analiticar podataka', '/beleske/exp_0107.txt'),
(108, 41, 'koordinator ucesnika', '/beleske/exp_0108.txt'),
(109, 43, 'tehnicka podrska', '/beleske/exp_0109.txt'),
(110, 44, 'glavni eksperimentator', '/beleske/exp_0110.txt'),
(111, 46, 'asistent na sesiji', '/beleske/exp_0111.txt'),
(112, 47, 'analiticar podataka', '/beleske/exp_0112.txt'),
(113, 49, 'koordinator ucesnika', '/beleske/exp_0113.txt'),
(114, 50, 'tehnicka podrska', '/beleske/exp_0114.txt'),
(115, 52, 'glavni eksperimentator', '/beleske/exp_0115.txt'),
(116, 53, 'asistent na sesiji', '/beleske/exp_0116.txt'),
(117, 55, 'analiticar podataka', '/beleske/exp_0117.txt'),
(118, 56, 'koordinator ucesnika', '/beleske/exp_0118.txt'),
(119, 58, 'tehnicka podrska', '/beleske/exp_0119.txt'),
(120, 59, 'glavni eksperimentator', '/beleske/exp_0120.txt'),
(121, 61, 'asistent na sesiji', '/beleske/exp_0121.txt'),
(122, 62, 'analiticar podataka', '/beleske/exp_0122.txt'),
(123, 64, 'koordinator ucesnika', '/beleske/exp_0123.txt'),
(124, 65, 'tehnicka podrska', '/beleske/exp_0124.txt'),
(125, 67, 'glavni eksperimentator', '/beleske/exp_0125.txt'),
(126, 68, 'asistent na sesiji', '/beleske/exp_0126.txt'),
(127, 70, 'analiticar podataka', '/beleske/exp_0127.txt'),
(128, 71, 'koordinator ucesnika', '/beleske/exp_0128.txt'),
(129, 73, 'tehnicka podrska', '/beleske/exp_0129.txt'),
(130, 74, 'glavni eksperimentator', '/beleske/exp_0130.txt'),
(131, 76, 'asistent na sesiji', '/beleske/exp_0131.txt'),
(132, 77, 'analiticar podataka', '/beleske/exp_0132.txt'),
(133, 79, 'koordinator ucesnika', '/beleske/exp_0133.txt'),
(134, 80, 'tehnicka podrska', '/beleske/exp_0134.txt'),
(135, 82, 'glavni eksperimentator', '/beleske/exp_0135.txt'),
(136, 83, 'asistent na sesiji', '/beleske/exp_0136.txt'),
(137, 85, 'analiticar podataka', '/beleske/exp_0137.txt'),
(138, 86, 'koordinator ucesnika', '/beleske/exp_0138.txt'),
(139, 88, 'tehnicka podrska', '/beleske/exp_0139.txt'),
(140, 89, 'glavni eksperimentator', '/beleske/exp_0140.txt'),
(141, 91, 'asistent na sesiji', '/beleske/exp_0141.txt'),
(142, 92, 'analiticar podataka', '/beleske/exp_0142.txt'),
(143, 94, 'koordinator ucesnika', '/beleske/exp_0143.txt'),
(144, 95, 'tehnicka podrska', '/beleske/exp_0144.txt'),
(145, 97, 'glavni eksperimentator', '/beleske/exp_0145.txt'),
(146, 98, 'asistent na sesiji', '/beleske/exp_0146.txt'),
(147, 100, 'analiticar podataka', '/beleske/exp_0147.txt'),
(148, 101, 'koordinator ucesnika', '/beleske/exp_0148.txt'),
(149, 103, 'tehnicka podrska', '/beleske/exp_0149.txt'),
(150, 104, 'glavni eksperimentator', '/beleske/exp_0150.txt');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_aktivna_izvodjenja`
-- (See below for the actual view)
--
CREATE TABLE `v_aktivna_izvodjenja` (
`id_izvodjenja` int(11)
,`datum_unosa_izvodjenja` date
,`nziv_eksperimenta` varchar(100)
,`tip_eksperimenta` varchar(50)
,`teorijski_okvir` varchar(100)
,`broj_sesija` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_aktivni_eksperimenti`
-- (See below for the actual view)
--
CREATE TABLE `v_aktivni_eksperimenti` (
`id_eksperimenta` int(11)
,`naziv_eksperimenta` varchar(100)
,`tip_eksperimenta` varchar(50)
,`teorijski_okvir` varchar(100)
,`broj_izvodjenja` bigint(21)
,`broj_sesija` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure for view `v_aktivna_izvodjenja`
--
DROP TABLE IF EXISTS `v_aktivna_izvodjenja`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_aktivna_izvodjenja`  AS SELECT `iz`.`id_izvodjenja` AS `id_izvodjenja`, `iz`.`datum` AS `datum_unosa_izvodjenja`, `e`.`naziv` AS `nziv_eksperimenta`, `e`.`tip` AS `tip_eksperimenta`, `t`.`naziv` AS `teorijski_okvir`, count(distinct `s`.`id_sesije`) AS `broj_sesija` FROM (((`izvodjenje` `iz` join `eksperiment` `e` on(`e`.`id_eksperimenta` = `iz`.`id_eksperimenta`)) join `teorijski_okvir` `t` on(`t`.`id_okvira` = `e`.`id_okvira`)) join `sesija` `s` on(`s`.`id_izvodjenja` = `iz`.`id_izvodjenja`)) WHERE `iz`.`status` = 'zapoceto' GROUP BY `iz`.`id_izvodjenja`, `e`.`naziv`, `e`.`tip`, `t`.`naziv` ;

-- --------------------------------------------------------

--
-- Structure for view `v_aktivni_eksperimenti`
--
DROP TABLE IF EXISTS `v_aktivni_eksperimenti`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_aktivni_eksperimenti`  AS SELECT `e`.`id_eksperimenta` AS `id_eksperimenta`, `e`.`naziv` AS `naziv_eksperimenta`, `e`.`tip` AS `tip_eksperimenta`, `t`.`naziv` AS `teorijski_okvir`, count(distinct `iz`.`id_izvodjenja`) AS `broj_izvodjenja`, count(distinct `s`.`id_sesije`) AS `broj_sesija` FROM (((`eksperiment` `e` join `teorijski_okvir` `t` on(`t`.`id_okvira` = `e`.`id_okvira`)) join `izvodjenje` `iz` on(`iz`.`id_eksperimenta` = `e`.`id_eksperimenta`)) join `sesija` `s` on(`s`.`id_izvodjenja` = `iz`.`id_izvodjenja`)) GROUP BY `e`.`id_eksperimenta`, `e`.`naziv`, `e`.`tip`, `t`.`naziv` HAVING max(`s`.`datum`) >= curdate() - interval 1 month ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alat`
--
ALTER TABLE `alat`
  ADD PRIMARY KEY (`id_alata`),
  ADD KEY `id_tipa_alata` (`id_tipa_alata`),
  ADD KEY `id_racuanra` (`id_racuanra`);

--
-- Indexes for table `dizajner`
--
ALTER TABLE `dizajner`
  ADD PRIMARY KEY (`id_dizajnera`);

--
-- Indexes for table `eksperiment`
--
ALTER TABLE `eksperiment`
  ADD PRIMARY KEY (`id_eksperimenta`),
  ADD KEY `id_okvira` (`id_okvira`);

--
-- Indexes for table `eksperiment_alat`
--
ALTER TABLE `eksperiment_alat`
  ADD PRIMARY KEY (`id_eksperimenta`,`id_alata`),
  ADD KEY `id_tipa_alata` (`id_alata`);

--
-- Indexes for table `eksperiment_dizajner`
--
ALTER TABLE `eksperiment_dizajner`
  ADD PRIMARY KEY (`id_eksperimenta`,`id_istrazivaca`),
  ADD KEY `eksperiment_dizajner_ibfk_2` (`id_istrazivaca`);

--
-- Indexes for table `eksperiment_resurs`
--
ALTER TABLE `eksperiment_resurs`
  ADD PRIMARY KEY (`id_eksperimenta`,`id_resursa`),
  ADD KEY `id_resursa` (`id_resursa`);

--
-- Indexes for table `istrazivac`
--
ALTER TABLE `istrazivac`
  ADD PRIMARY KEY (`id_istrazivaca`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `izvodjac`
--
ALTER TABLE `izvodjac`
  ADD PRIMARY KEY (`id_izvodjaca`);

--
-- Indexes for table `izvodjenje`
--
ALTER TABLE `izvodjenje`
  ADD PRIMARY KEY (`id_izvodjenja`),
  ADD KEY `id_eksperimenta` (`id_eksperimenta`);

--
-- Indexes for table `jedinica_vrednosti`
--
ALTER TABLE `jedinica_vrednosti`
  ADD PRIMARY KEY (`id_jedinice_vrednosti`);

--
-- Indexes for table `laboratorija`
--
ALTER TABLE `laboratorija`
  ADD PRIMARY KEY (`id_laboratorije`);

--
-- Indexes for table `laboratorija_resurs`
--
ALTER TABLE `laboratorija_resurs`
  ADD PRIMARY KEY (`id_laboratorije`,`id_resurs`),
  ADD KEY `id_resurs` (`id_resurs`);

--
-- Indexes for table `potrosnja_resursa`
--
ALTER TABLE `potrosnja_resursa`
  ADD PRIMARY KEY (`id_sesije`,`id_resursa`),
  ADD KEY `id_resursa` (`id_resursa`);

--
-- Indexes for table `resurs`
--
ALTER TABLE `resurs`
  ADD PRIMARY KEY (`id_resursa`),
  ADD KEY `resurs_ibfk_valuta` (`kod_jedinice_vrednosti`);

--
-- Indexes for table `sesija`
--
ALTER TABLE `sesija`
  ADD PRIMARY KEY (`id_sesije`),
  ADD KEY `id_izvodjenja` (`id_izvodjenja`),
  ADD KEY `id_racunara` (`id_racunara`);

--
-- Indexes for table `teorijski_okvir`
--
ALTER TABLE `teorijski_okvir`
  ADD PRIMARY KEY (`id_okvira`);

--
-- Indexes for table `tip_alata`
--
ALTER TABLE `tip_alata`
  ADD PRIMARY KEY (`id_tipa_alata`);

--
-- Indexes for table `uloga_izvodjaca`
--
ALTER TABLE `uloga_izvodjaca`
  ADD PRIMARY KEY (`id_izvodjenja`,`id_izvodjaca`),
  ADD KEY `id_izvodjaca` (`id_izvodjaca`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alat`
--
ALTER TABLE `alat`
  MODIFY `id_alata` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=201;

--
-- AUTO_INCREMENT for table `eksperiment`
--
ALTER TABLE `eksperiment`
  MODIFY `id_eksperimenta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `istrazivac`
--
ALTER TABLE `istrazivac`
  MODIFY `id_istrazivaca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=301;

--
-- AUTO_INCREMENT for table `izvodjenje`
--
ALTER TABLE `izvodjenje`
  MODIFY `id_izvodjenja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT for table `laboratorija`
--
ALTER TABLE `laboratorija`
  MODIFY `id_laboratorije` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `resurs`
--
ALTER TABLE `resurs`
  MODIFY `id_resursa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `sesija`
--
ALTER TABLE `sesija`
  MODIFY `id_sesije` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=513;

--
-- AUTO_INCREMENT for table `teorijski_okvir`
--
ALTER TABLE `teorijski_okvir`
  MODIFY `id_okvira` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `tip_alata`
--
ALTER TABLE `tip_alata`
  MODIFY `id_tipa_alata` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alat`
--
ALTER TABLE `alat`
  ADD CONSTRAINT `alat_ibfk_1` FOREIGN KEY (`id_tipa_alata`) REFERENCES `tip_alata` (`id_tipa_alata`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `alat_ibfk_2` FOREIGN KEY (`id_racuanra`) REFERENCES `laboratorija` (`id_laboratorije`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `dizajner`
--
ALTER TABLE `dizajner`
  ADD CONSTRAINT `dizajner_ibfk_1` FOREIGN KEY (`id_dizajnera`) REFERENCES `istrazivac` (`id_istrazivaca`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eksperiment`
--
ALTER TABLE `eksperiment`
  ADD CONSTRAINT `eksperiment_ibfk_1` FOREIGN KEY (`id_okvira`) REFERENCES `teorijski_okvir` (`id_okvira`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `eksperiment_alat`
--
ALTER TABLE `eksperiment_alat`
  ADD CONSTRAINT `eksperiment_alat_ibfk_1` FOREIGN KEY (`id_eksperimenta`) REFERENCES `eksperiment` (`id_eksperimenta`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eksperiment_alat_ibfk_2` FOREIGN KEY (`id_alata`) REFERENCES `alat` (`id_alata`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `eksperiment_dizajner`
--
ALTER TABLE `eksperiment_dizajner`
  ADD CONSTRAINT `eksperiment_dizajner_ibfk_1` FOREIGN KEY (`id_eksperimenta`) REFERENCES `eksperiment` (`id_eksperimenta`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eksperiment_dizajner_ibfk_2` FOREIGN KEY (`id_istrazivaca`) REFERENCES `dizajner` (`id_dizajnera`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `eksperiment_resurs`
--
ALTER TABLE `eksperiment_resurs`
  ADD CONSTRAINT `eksperiment_resurs_ibfk_1` FOREIGN KEY (`id_eksperimenta`) REFERENCES `eksperiment` (`id_eksperimenta`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eksperiment_resurs_ibfk_2` FOREIGN KEY (`id_resursa`) REFERENCES `resurs` (`id_resursa`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `izvodjac`
--
ALTER TABLE `izvodjac`
  ADD CONSTRAINT `izvodjac_ibfk_1` FOREIGN KEY (`id_izvodjaca`) REFERENCES `istrazivac` (`id_istrazivaca`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `izvodjenje`
--
ALTER TABLE `izvodjenje`
  ADD CONSTRAINT `izvodjenje_ibfk_1` FOREIGN KEY (`id_eksperimenta`) REFERENCES `eksperiment` (`id_eksperimenta`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `laboratorija_resurs`
--
ALTER TABLE `laboratorija_resurs`
  ADD CONSTRAINT `laboratorija_resurs_ibfk_1` FOREIGN KEY (`id_laboratorije`) REFERENCES `laboratorija` (`id_laboratorije`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `laboratorija_resurs_ibfk_2` FOREIGN KEY (`id_resurs`) REFERENCES `resurs` (`id_resursa`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `potrosnja_resursa`
--
ALTER TABLE `potrosnja_resursa`
  ADD CONSTRAINT `potrosnja_resursa_ibfk_1` FOREIGN KEY (`id_sesije`) REFERENCES `sesija` (`id_sesije`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `potrosnja_resursa_ibfk_2` FOREIGN KEY (`id_resursa`) REFERENCES `resurs` (`id_resursa`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `resurs`
--
ALTER TABLE `resurs`
  ADD CONSTRAINT `resurs_ibfk_valuta` FOREIGN KEY (`kod_jedinice_vrednosti`) REFERENCES `jedinica_vrednosti` (`id_jedinice_vrednosti`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `sesija`
--
ALTER TABLE `sesija`
  ADD CONSTRAINT `sesija_ibfk_1` FOREIGN KEY (`id_izvodjenja`) REFERENCES `izvodjenje` (`id_izvodjenja`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `sesija_ibfk_2` FOREIGN KEY (`id_racunara`) REFERENCES `laboratorija` (`id_laboratorije`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `uloga_izvodjaca`
--
ALTER TABLE `uloga_izvodjaca`
  ADD CONSTRAINT `uloga_izvodjaca_ibfk_1` FOREIGN KEY (`id_izvodjenja`) REFERENCES `izvodjenje` (`id_izvodjenja`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `uloga_izvodjaca_ibfk_2` FOREIGN KEY (`id_izvodjaca`) REFERENCES `izvodjac` (`id_izvodjaca`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
