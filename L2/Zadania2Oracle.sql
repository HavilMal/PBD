-- head: Zadanie 30
-- desc: utworzenie widoku, zliczenie lie kotów dostaje dodatkowe myszy, przy użyciu sum i case
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


-- desc: użycie widoku do wykonania zapytania z parametrem
DEFINE kot = ''
ACCEPT kot PROMPT 'Podaj pseudonim kota:'
SELECT pseudo,
       imie,
       funkcja,
       przydzial_myszy,
       'OD ' || TO_CHAR(p1."mini") || ' DO ' || TO_CHAR(p1."maxi") "granice",
       w_stadku_od
FROM kocury k1
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
         LEFT JOIN przydzialy p1 ON b1.nazwa = p1.nazwa
WHERE pseudo = '&kot'
;

-- head: Zadanie 31
-- desc: zdefiniowanie perspektywy znajdującej koty z band CZARNI RYCERZE i ŁACIACI MYŚLIWI o 3 najwyższych stażach
CREATE VIEW przydzialy_kotow AS
(
SELECT r1.pseudo,
       r1.plec,
       r1.przydzial_myszy,
       r1.myszy_extra,
       r1."przydzial_mini",
       r1."avrg_extra"
FROM (SELECT k1.*,
             RANK() OVER (PARTITION BY k1.nr_bandy ORDER BY SYSDATE - k1.w_stadku_od DESC) "staz_rank",
             MIN(przydzial_myszy) OVER ()                                                  "przydzial_mini",
             AVG(COALESCE(myszy_extra, 0)) OVER (PARTITION BY k1.nr_bandy)                 "avrg_extra"
      FROM kocury k1
               LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
      WHERE b1.nazwa = 'CZARNI RYCERZE'
         OR b1.nazwa = 'LACIACI MYSLIWI') r1
WHERE "staz_rank" <= 3)
;

-- desc: wyświetlenie przydziałów przed podwyżką
-- run
SELECT pseudo, plec, przydzial_myszy, COALESCE(myszy_extra, 0)
FROM przydzialy_kotow;

-- desc: aktualizacja danych z perspektywy przy pomocy zadanych formuł, wszelkie zmiany w bazie nie są trwałe do polecenia COMMIT. Oracle nie pozwala modyfikować kolumn, które nie odwołują się bezpośrednio do tabeli
-- silent
UPDATE kocury k1
SET przydzial_myszy = CASE
                          WHEN plec = 'D' THEN COALESCE(przydzial_myszy, 0) +
                                               (SELECT "przydzial_mini" FROM przydzialy_kotow WHERE k1.pseudo = pseudo) *
                                               0.1
                          WHEN plec = 'M' THEN COALESCE(przydzial_myszy, 0) + 10 END,
    myszy_extra     = COALESCE(myszy_extra, 0) +
                      (SELECT "avrg_extra" FROM przydzialy_kotow WHERE k1.pseudo = pseudo) * 0.15;

-- desc: wyświetlenie zaktualizowanych danych po podwyżce
-- run
SELECT pseudo, plec, przydzial_myszy, COALESCE(myszy_extra, 0)
FROM przydzialy_kotow;

-- desc: cofnięcie UPDATE
-- silent
ROLLBACK;

-- head: Zadanie 32a
-- desc: zdefiniowanie dwóch CTE całkowitego spożycia dla wszystkich kotów oraz przydziału według funkcji i płci z podziałem na bandę, a także całkowitej sumy w bandzie. Następnie złączenie z sumami przydziałów ze względu na funkcje.
-- run
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
FROM podzial p1
UNION
SELECT 'ZJADA RAZEM',
       '',
       SUM(p2."ile"),
       SUM(p2."SZEFUNIO"),
       SUM(p2."BANDZIOR"),
       SUM(p2."LOWCZY"),
       SUM(p2."LAPACZ"),
       SUM(p2."KOT"),
       SUM(p2."MILUSIA"),
       SUM(p2."DZIELCZY"),
       SUM(p2."SUMA")
FROM podzial p2
;

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
FROM podzial p1
UNION
SELECT 'ZJADA RAZEM',
       '',
       SUM(p2."ile"),
       SUM(p2."SZEFUNIO"),
       SUM(p2."BANDZIOR"),
       SUM(p2."LOWCZY"),
       SUM(p2."LAPACZ"),
       SUM(p2."KOT"),
       SUM(p2."MILUSIA"),
       SUM(p2."DZIELCZY"),
       SUM(p2."SUMA")
FROM podzial p2
;

-- head: Zadanie 32b
-- desc: znalezienie całkowitego spożycia dla kotów, zdefiniowanie tabeli przestawnej z tabeli spożycia i złączenie jej z suma w bandach z podziałem na płeć. Następnie złączamy tabelę przestawną z sumami z podziałem na funkcję
-- run
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
                         'SZEFUNIO' AS szefunio,
                         'BANDZIOR' AS bandzior,
                         'LOWCZY' AS lowczy,
                         'LAPACZ' AS lapacz,
                         'KOT' AS kot,
                         'MILUSIA' AS milusia,
                         'DZIELCZY' AS dzielczy
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
