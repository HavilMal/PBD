ALTER TABLE Kocury DROP CONSTRAINT fk_kocury_kocury;
ALTER TABLE Kocury DROP CONSTRAINT fk_kocury_bandy;
ALTER TABLE Kocury DROP CONSTRAINT fk_kocury_funkcje;
ALTER TABLE Bandy DROP CONSTRAINT fk_bandy_kocury;
ALTER TABLE Wrogowie_kocurow DROP CONSTRAINT fk_wrogowie_kocurow_kocury;
ALTER TABLE Wrogowie_kocurow DROP CONSTRAINT fk_wrogowie_kocurow_wrogowie;

DROP TABLE Kocury;
DROP TABLE Funkcje;
DROP TABLE Wrogowie_kocurow;
DROP TABLE Wrogowie;
DROP TABLE Bandy;
