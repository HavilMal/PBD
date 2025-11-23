-- head: Zadanie 1
-- desc: Hello world
-- run
SELECT k1.imie
FROM kocury k1
         LEFT JOIN kocury k2
                   ON k1.szef = k2.pseudo
         LEFT JOIN wrogowie_kocurow w1
                   ON k1.pseudo = w1.pseudo
WHERE k1.w_stadku_od < k2.w_stadku_od
   OR w1.pseudo IS NULL;
  

-- head: Zadanie 2
SELECT k1.pseudo, w1.imie_wroga, w1.opis_incydentu
FROM kocury k1
         LEFT JOIN wrogowie_kocurow w1
                   ON k1.pseudo = w1.pseudo
WHERE k1.plec = 'D'
  AND w1.imie_wroga IS NOT NULL;

-- head: Zadanie 3
-- Tygrys nie ma szefa
SELECT k1.pseudo, k1.nr_bandy
FROM kocury k1
         INNER JOIN kocury k2 ON k1.szef = k2.pseudo
WHERE k1.nr_bandy != k2.nr_bandy;

-- head: Zadanie 4
SELECT COALESCE(k1.pseudo, 'Brak przelozonego') "Przelozony",
       COALESCE(k2.pseudo, 'Brak podwladnego')  "Podwladny"
FROM kocury k1
         FULL JOIN kocury k2 ON k1.pseudo = k2.szef
WHERE COALESCE(k1.plec, 'M') = 'M'
  AND COALESCE(k2.plec, 'M') = 'M'
ORDER BY "Przelozony";

-- head: Zadanie 5
SELECT DISTINCT k1.pseudo,
                k1.przydzial_myszy,
                k1."suma_bandy",
                ROUND(k1.przydzial_myszy / k1."suma_bandy" * 100, 0) "procent"
FROM (SELECT k2.*, SUM(k2.przydzial_myszy) OVER (PARTITION BY k2.nr_bandy) "suma_bandy" FROM kocury k2) k1
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
         LEFT JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
         LEFT JOIN wrogowie w1 ON wk1.imie_wroga = w1.imie_wroga
WHERE b1.teren IN ('POLE', 'CALOSC')
  AND w1.stopien_wrogosci > 5
;

-- head: Zadanie 6
SELECT pseudo, przydzial_myszy, nr_bandy, 'Prominent'
FROM kocury k1
WHERE przydzial_myszy > (SELECT AVG(przydzial_myszy) FROM kocury)
UNION
SELECT pseudo, przydzial_myszy, nr_bandy, 'Szarak'
FROM kocury k2
WHERE przydzial_myszy = (SELECT MIN(przydzial_myszy) FROM kocury WHERE k2.nr_bandy = nr_bandy)
;

-- head: Zadanie 7
SELECT pseudo, "Srednia"
FROM kocury k1
         LEFT JOIN LATERAL (SELECT nr_bandy, AVG(przydzial_myszy) "Srednia" FROM kocury GROUP BY nr_bandy) a1
                   ON k1.nr_bandy = a1.nr_bandy
WHERE k1.plec = 'M'
ORDER BY "Srednia";

-- head: Zadanie 8a
SELECT pseudo, s1."srednia_bandy", s1."srednia"
FROM kocury k1
         LEFT JOIN (SELECT DISTINCT nr_bandy,
                                    AVG(przydzial_myszy) OVER (PARTITION BY nr_bandy) "srednia_bandy",
                                    AVG(przydzial_myszy) OVER ()                      "srednia"
                    FROM kocury) s1
                   ON k1.nr_bandy = s1.nr_bandy
WHERE s1."srednia_bandy" > (s1."srednia");

-- head: Zadanie 8b
SELECT pseudo, s1."srednia_bandy", s1."srednia", "srednia_bandy"
FROM kocury k1
         LEFT JOIN (SELECT DISTINCT nr_bandy,
                                    AVG(przydzial_myszy) OVER (PARTITION BY nr_bandy) "srednia_bandy",
                                    AVG(przydzial_myszy) OVER ()                      "srednia"
                    FROM kocury) s1
                   ON k1.nr_bandy = s1.nr_bandy
WHERE s1."srednia_bandy" > (s1."srednia");

-- head: Zadanie 9
SELECT "Miesiac", COUNT("Miesiac")
FROM (SELECT TO_CHAR(w_stadku_od, 'MONTH') "Miesiac", EXTRACT(MONTH FROM w_stadku_od) "nr" FROM kocury)
GROUP BY "nr", "Miesiac"
ORDER BY "nr";

-- head: Zadanie 10
SELECT *
FROM (SELECT k1.funkcja, b1.nazwa, COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) "myszy"
      FROM kocury k1
               LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy)
    PIVOT (
    SUM("myszy") FOR nazwa IN ('CZARNI RYCERZE', 'BIALI LOWCY')
    )
WHERE funkcja != 'SZEFUNIO'
ORDER BY funkcja;

-- head: Zadanie 11
SELECT *
FROM (SELECT k1.funkcja, k1.plec, b1.nazwa, COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) "myszy"
      FROM kocury k1
               LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy) PIVOT (
    SUM("myszy") FOR nazwa IN ('CZARNI RYCERZE', 'BIALI LOWCY')
    )
ORDER BY funkcja;