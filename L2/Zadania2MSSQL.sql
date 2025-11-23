-- Zadanie 30
CREATE VIEW przydzialy AS
SELECT b1.nazwa,
       AVG(przydzial_myszy)                                           "avrg",
       MIN(przydzial_myszy)                                           "mini",
       MAX(przydzial_myszy)                                           "maxi",
       COUNT(*)                                                       "suma",
       SUM(CASE WHEN COALESCE(myszy_extra, 0) != 0 THEN 1 ELSE 0 END) "suma_dod"
FROM kocury k1
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
GROUP BY b1.nazwa
;

DECLARE @kot VARCHAR(15);
SET @kot = 'PLACEK';
SELECT pseudo,
       imie,
       funkcja,
       przydzial_myszy,
       'OD ' + CAST(p1."mini" AS VARCHAR) + ' DO ' + CAST(p1."maxi" AS VARCHAR),
       w_stadku_od
FROM kocury k1
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
         LEFT JOIN przydzialy p1 ON b1.nazwa = p1.nazwa
WHERE pseudo = @kot
GO

-- Zadanie 31
CREATE VIEW przydzialy_kotow AS
(
SELECT r1.pseudo,
       r1.plec,
       r1.przydzial_myszy,
       r1.myszy_extra,
       r1."przydzial_mini",
       r1."avrg_extra"
FROM (SELECT k1.*,
             RANK() OVER (PARTITION BY k1.nr_bandy ORDER BY DATEDIFF(DAY, k1.w_stadku_od, SYSDATETIME()) DESC) "staz_rank",
             MIN(przydzial_myszy) OVER ()                                                                      "przydzial_mini",
             AVG(COALESCE(myszy_extra, 0)) OVER (PARTITION BY k1.nr_bandy)                                     "avrg_extra"
      FROM kocury k1
               LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
      WHERE b1.nazwa = 'CZARNI RYCERZE'
         OR b1.nazwa = 'LACIACI MYSLIWI') r1
WHERE "staz_rank" <= 3)
;

SELECT pseudo, plec, przydzial_myszy, COALESCE(myszy_extra, 0)
FROM przydzialy_kotow;

BEGIN TRANSACTION podwyzka;
UPDATE przydzialy_kotow
SET przydzial_myszy = CASE
                          WHEN plec = 'D' THEN COALESCE(przydzial_myszy, 0) + przydzial_mini * 0.1
                          WHEN plec = 'M' THEN COALESCE(przydzial_myszy, 0) + 10 END,
    myszy_extra     = COALESCE(myszy_extra, 0) + avrg_extra * 0.15

SELECT pseudo, plec, przydzial_myszy, COALESCE(myszy_extra, 0)
FROM przydzialy_kotow;

ROLLBACK TRANSACTION podwyzka;

-- Zadanie 32a
WITH spozycie AS (SELECT funkcja, plec, nr_bandy, COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0) "suma"
                  FROM kocury),
     podzial AS (SELECT b1.nazwa,
                        CASE WHEN s1.plec = 'M' THEN 'Kocor' WHEN s1.plec = 'D' THEN 'Kotka' END "plec",
                        COUNT(*)                                                                 "ile",
                        SUM(CASE WHEN s1.funkcja = 'SZEFUNIO' THEN s1."suma" ELSE 0 END)         "SZEFUNIO",
                        SUM(CASE WHEN s1.funkcja = 'BANDZIOR' THEN s1."suma" ELSE 0 END)         "BANDZIOR",
                        SUM(CASE WHEN s1.funkcja = 'LOWCZY' THEN s1."suma" ELSE 0 END)           "LOWCZY",
                        SUM(CASE WHEN s1.funkcja = 'LAPACZ' THEN s1."suma" ELSE 0 END)           "LAPACZ",
                        SUM(CASE WHEN s1.funkcja = 'KOT' THEN s1."suma" ELSE 0 END)              "KOT",
                        SUM(CASE WHEN s1.funkcja = 'MILUSIA' THEN s1."suma" ELSE 0 END)          "MILUSIA",
                        SUM(CASE WHEN s1.funkcja = 'DZIELCZY' THEN s1."suma" ELSE 0 END)         "DZIELCZY",
                        SUM(s1."suma")                                                           "SUMA"
                 FROM bandy b1
                          INNER JOIN spozycie s1 ON b1.nr_bandy = s1.nr_bandy
                 GROUP BY b1.nazwa, s1.plec)
SELECT *
FROM podzial
UNION
SELECT 'ZJADA RAZEM',
       '',
       SUM(podzial.ile),
       SUM(podzial.szefunio),
       SUM(podzial.bandzior),
       SUM(podzial.lowczy),
       SUM(podzial.lapacz),
       SUM(podzial.kot),
       SUM(podzial.milusia),
       SUM(podzial.dzielczy),
       SUM(podzial.suma)
FROM podzial
;

-- Zadanie 32b
WITH spozycie AS (SELECT funkcja, plec, nazwa, COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0) "suma"
                  FROM kocury k1
                           INNER JOIN bandy b1 ON b1.nr_bandy = k1.nr_bandy),
     podzial AS (SELECT p1.nazwa,
                        p1.plec,
                        s2."ile",
                        COALESCE(p1."SZEFUNIO", 0) "SZEFUNIO",
                        COALESCE(p1."BANDZIOR", 0) "BANDZIOR",
                        COALESCE(p1."LOWCZY", 0)   "LOWCZY",
                        COALESCE(p1."LAPACZ", 0)   "LAPACZ",
                        COALESCE(p1."KOT", 0)      "KOT",
                        COALESCE(p1."MILUSIA", 0)  "MILUSIA",
                        COALESCE(p1."DZIELCZY", 0) "DZIELCZY",
                        s2."s"                     "SUMA"
                 FROM spozycie s1 PIVOT (
                          SUM(s1."suma") FOR funkcja IN (
                         "SZEFUNIO",
                         "BANDZIOR",
                         "LOWCZY",
                         "LAPACZ",
                         "KOT",
                         "MILUSIA",
                         "DZIELCZY"
                         )
                          ) p1
                          LEFT JOIN (SELECT SUM("suma") "s", COUNT(*) "ile", nazwa, plec
                                     FROM spozycie
                                     GROUP BY nazwa, plec) s2
                                    ON p1.nazwa = s2.nazwa AND p1.plec = s2.plec)
SELECT *
FROM podzial
UNION
(SELECT 'ZJADA RAZEM',
        NULL,
        NULL,
        SUM(p1."SZEFUNIO"),
        SUM("BANDZIOR"),
        SUM("LOWCZY"),
        SUM("LAPACZ"),
        SUM("KOT"),
        SUM("MILUSIA"),
        SUM("DZIELCZY"),
        SUM("SUMA")
 FROM podzial p1)
;
