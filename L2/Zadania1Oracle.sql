-- head: Zadanie 12
-- run
SELECT k1.pseudo, k1.przydzial_myszy, b1.nazwa
FROM kocury k1
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
WHERE b1.teren IN ('POLE', 'CALOSC')
  AND k1.przydzial_myszy > 50
ORDER BY k1.przydzial_myszy DESC;

-- head: Zadanie 13
-- run
SELECT k1.imie, k1.w_stadku_od
FROM kocury k1
         INNER JOIN kocury k2 ON k1.w_stadku_od < k2.w_stadku_od
WHERE k2.imie = 'JACEK'
ORDER BY k1.w_stadku_od DESC;

-- head: Zadanie 14a
-- run
SELECT k1.imie, k1.funkcja, k2.imie "Szef 1", k3.imie "Szef 2", k4.imie "Szef 3"
FROM kocury k1
         LEFT JOIN kocury k2 ON k1.szef = k2.pseudo
         LEFT JOIN kocury k3 ON k2.szef = k3.pseudo
         LEFT JOIN kocury k4 ON k3.szef = k4.pseudo
WHERE k1.funkcja IN ('KOT', 'MILUSIA');

-- head: Zadanie 14b
-- run
SELECT "imie", k2.funkcja, "Szef 1", "Szef 2", "Szef 3"
FROM (SELECT *
      FROM (SELECT CONNECT_BY_ROOT imie "imie", level "lvl", imie
            FROM kocury k1
            START WITH k1.funkcja IN ('KOT', 'MILUSIA')
            CONNECT BY PRIOR k1.szef = k1.pseudo)
          PIVOT (
          MAX(imie) FOR "lvl" IN (2 "Szef 1", 3 "Szef 2", 4 "Szef 3")
          ))
         LEFT JOIN kocury k2 ON "imie" = k2.imie
;

-- head: Zadanie 14c
-- desc: Dla każdego kota z funkcją kot lub milusia znajduję najdłuższą ścieżkę zaczynającą się od szefa wybranego kota
-- run
SELECT k1.imie, k1.funkcja, MAX("szefowie")
FROM kocury k1
         LEFT JOIN LATERAL (SELECT CONNECT_BY_ROOT k1.imie                              "imie",
                                   SYS_CONNECT_BY_PATH(RPAD(imie, 10, ' '), '|') || '|' "szefowie"
                            FROM kocury k2
                            START WITH k2.pseudo = k1.szef
                            CONNECT BY PRIOR k2.szef = k2.pseudo
    ) s1 ON k1.imie = s1."imie"
WHERE k1.funkcja IN ('KOT', 'MILUSIA')
GROUP BY k1.imie, k1.funkcja
;

-- head: Zadanie 15
-- run
SELECT k1.imie, b1.nazwa, wk1.imie_wroga, w1.stopien_wrogosci, wk1.data_incydentu
FROM kocury k1
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
         LEFT JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
         LEFT JOIN wrogowie w1 ON wk1.imie_wroga = w1.imie_wroga
WHERE k1.plec = 'D'
  AND wk1.data_incydentu > '2007-01-01'
ORDER BY k1.imie
;


-- head: Zadanie 16
-- run
SELECT b1.nazwa, COUNT(DISTINCT k1.pseudo) "Koty z wrogami"
FROM koty.bandy b1
         INNER JOIN kocury k1 ON b1.nr_bandy = k1.nr_bandy
         INNER JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
GROUP BY b1.nazwa
;

-- head: Zadanie 17
-- run
SELECT *
FROM (SELECT k1.funkcja, k1.pseudo, COUNT(*) "Liczba wrogow"
      FROM kocury k1
               INNER JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
      GROUP BY k1.pseudo, k1.funkcja)
WHERE "Liczba wrogow" > 1
;

-- head: Zadanie 18
-- run
SELECT imie, "Dawka roczna", DECODE(SIGN("Dawka roczna" - 864), 1, 'POWYRZEJ 864', 0, '864', -1, 'Ponizej 864')
FROM (SELECT k1.imie, 12 * (COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)) "Dawka roczna"
      FROM kocury k1)
;

-- head: Zadanie 19a
-- Jeśli banda nie jest powiązana z żadnym kotem pseudo będzie wartością null
-- run
SELECT b1.nr_bandy, b1.nazwa
FROM bandy b1
         LEFT JOIN kocury k1 ON b1.nr_bandy = k1.nr_bandy
WHERE k1.pseudo IS NULL
;

-- head: Zadanie 20
-- run
SELECT k1.pseudo, k1.funkcja, k1.przydzial_myszy
FROM kocury k1
WHERE k1.przydzial_myszy >=
      (SELECT 3 * k2.przydzial_myszy
       FROM kocury k2
                LEFT JOIN bandy b1 ON k2.nr_bandy = b1.nr_bandy
       WHERE k2.funkcja = 'MILUSIA'
         AND (b1.teren = 'SAD' OR b1.teren = 'CALOSC')
       ORDER BY k2.przydzial_myszy DESC
           FETCH FIRST 1 ROW ONLY)
;

-- head: Zadanie 21
-- desc: Obliczenie średniej dla każdej funkcji, następnie wybranie funkcji, która jest mniejsza lub równa od wszystkich i większa, lub równa od wszystkich
-- run
WITH spozycie AS (SELECT funkcja, AVG(COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0)) "avrg"
                  FROM kocury
                  WHERE funkcja != 'SZEFUNIO'
                  GROUP BY funkcja)
SELECT *
FROM spozycie
WHERE "avrg" >= ALL (SELECT "avrg" FROM spozycie)
   OR "avrg" <= ALL (SELECT "avrg" FROM spozycie)
;


-- head: Zadanie 22a
-- desc: W podzapytaniu zliczana jest ilość unikalnych wierszy, następnie wybierane są tylko te spełniające warunek
-- DEFINE i ACCEPT pozwalają definować zmienną i przyjmować dane od użytkownika
DEFINE numer =  0
ACCEPT numer PROMPT 'Podaj liczbę kotów:'
SELECT pseudo, "suma1"
FROM (SELECT pseudo, COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0) "suma1"
      FROM kocury
      ORDER BY "suma1" DESC),
     LATERAL (
              SELECT COUNT(DISTINCT "suma2") "no"
              FROM (SELECT COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0) "suma2"
                    FROM kocury)
              WHERE "suma2" >= "suma1"
         )
WHERE "no" <= &numer
;

-- head: Zadanie 22b
-- desc: rownum jest evaluowany przed order by natomiast where jest ewaluowany po wiec potrzebne są 3 SELECT-y, żeby znaleźć wartość w 6 rzędzie
DEFINE numer =  0
ACCEPT numer PROMPT 'Podaj liczbę kotów:'
SELECT pseudo, "suma1"
FROM (SELECT pseudo, COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0) "suma1"
      FROM kocury
      ORDER BY "suma1" DESC)
WHERE "suma1" >= (SELECT "suma2"
                  FROM (SELECT "suma2", ROWNUM "row"
                        FROM (SELECT DISTINCT COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0) "suma2"
                              FROM kocury
                              ORDER BY "suma2" DESC))
                  WHERE "row" = 6)
;

-- head: Zadanie 22c
-- desc: dla każdego kota zliczam liczbę kotów ze spożyciem większym od danego kota uzyskując przez to jego rangę
DEFINE numer =  0
ACCEPT numer PROMPT 'Podaj liczbę kotów:'
SELECT k1.pseudo, COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) "spozycie", s1."rank"
FROM kocury k1
         LEFT JOIN LATERAL (
    SELECT k1.pseudo, COUNT(DISTINCT COALESCE(k2.przydzial_myszy, 0) + COALESCE(k2.myszy_extra, 0)) "rank"
    FROM kocury k2
    WHERE COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) <
          COALESCE(k2.przydzial_myszy, 0) + COALESCE(k2.myszy_extra, 0)
    GROUP BY k1.pseudo
    ) s1 ON k1.pseudo = s1.pseudo
-- WHERE COALESCE(s1."rank" + 1, 1) <=6
ORDER BY "spozycie" DESC
;


-- head: Zadanie 22d
-- desc: RANK nadaje rekordom rangę (taką samą w przypadku remisów)
DEFINE numer =  0
ACCEPT numer PROMPT 'Podaj liczbę kotów:'
SELECT pseudo, "zjada"
FROM (SELECT k1.pseudo,
             COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)                             "zjada",
             RANK() OVER (ORDER BY COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) DESC) "rank"
      FROM kocury k1)
WHERE "rank" <= &numer
;

-- head: Zadanie 23
-- desc: zliczam wystąpienia następnie szereguje rekordy według odległości od średniej w podziale na 2 partycję mniejszą i większą od średniej
-- run
(SELECT "rok", "wstapienia"
 FROM (SELECT "rok",
              "wstapienia",
              RANK() OVER (PARTITION BY CASE
                                            WHEN "wstapienia" < "avrg" THEN 1
                                            WHEN "wstapienia" > "avrg" THEN 2
                                            ELSE 0
                  END ORDER BY ABS("wstapienia" - "avrg")
                  ) "group_rank"
       FROM (SELECT TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "rok",
                    COUNT(*)                                "wstapienia",
                    AVG(COUNT(*)) OVER ()                   "avrg"
             FROM kocury
             GROUP BY EXTRACT(YEAR FROM w_stadku_od)))
 WHERE "group_rank" = 1)
UNION
(SELECT 'Srednia' "rok", AVG(COUNT(*)) OVER () "wstapienia"
 FROM kocury
 GROUP BY EXTRACT(YEAR FROM w_stadku_od)
     FETCH FIRST 1 ROW ONLY)
ORDER BY "wstapienia"
;


-- head: Zadanie 24a
-- desc: W CTE obliczenie średniego przydziału dla bandy, następnie złączenie kotów z bandami, w których średni przydział jest większy od przedziału kota
-- run
WITH przydzialy AS (SELECT nr_bandy,
                           AVG(COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)) "avrg"
                    FROM kocury k1
                    GROUP BY nr_bandy)
SELECT k2.imie,
       COALESCE(k2.przydzial_myszy, 0) + COALESCE(k2.myszy_extra, 0) "zjada",
       k2.nr_bandy,
       przydzialy."avrg"
FROM przydzialy
         INNER JOIN kocury k2 ON k2.nr_bandy = przydzialy.nr_bandy AND
                                 COALESCE(k2.przydzial_myszy, 0) + COALESCE(k2.myszy_extra, 0) <= przydzialy."avrg"
WHERE k2.plec = 'M'
;

-- head: Zadanie 24b
-- desc: w podzapytaniu obliczam sumę i średnie sumy w bandach następnie wybieram tylko kocury z przydziałem mniejszym niż średnia
-- run
SELECT s1.imie, s1."sum", s1.nr_bandy, s1."avrg"
FROM (SELECT k1.*,
             COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)                                      "sum",
             AVG(COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)) OVER (PARTITION BY k1.nr_bandy) "avrg"
      FROM kocury k1) s1
         INNER JOIN kocury k2 ON s1.pseudo = k2.pseudo AND
                                 COALESCE(k2.przydzial_myszy, 0) + COALESCE(k2.myszy_extra, 0) < s1."avrg"
WHERE s1.plec = 'M'
;

-- head: Zadanie 24c
-- desc: podzapytanie w WHERE jest niepotrzebne, bo można zrobić "sum" < "avrg" ale tak każe polecenie
-- run
SELECT s1.imie, s1."sum", s1.nr_bandy, s1."avrg"
FROM (SELECT k1.*,
             COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)                                      "sum",
             AVG(COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)) OVER (PARTITION BY k1.nr_bandy) "avrg"
      FROM kocury k1) s1
WHERE s1.plec = 'M'
  AND "sum" <
      (SELECT AVG(COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0)) FROM kocury WHERE nr_bandy = s1.nr_bandy)
;

-- head: Zadanie 25
-- desc: w CTE znajduje najmniejszy i największy staż w danej bandzie, po czym wybieram koty z tymi stażami, należy użyć operatorów zbiorowych dlatego nie użyłem CASE
-- run
WITH stats AS (SELECT k1.imie,
                      b1.nazwa,
                      k1.w_stadku_od,
                      SYSDATE - k1.w_stadku_od                                      "staz",
                      MIN(SYSDATE - k1.w_stadku_od) OVER (PARTITION BY k1.nr_bandy) "mini",
                      MAX(SYSDATE - k1.w_stadku_od) OVER (PARTITION BY k1.nr_bandy) "maxi"
               FROM kocury k1
                        LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy)
SELECT s1.imie, s1.w_stadku_od, '<--- NAJMLODSZY STAZEM W BANDZIE' || s1.nazwa " "
FROM stats s1
WHERE "staz" = "mini"
UNION
SELECT s1.imie, s1.w_stadku_od, '<--- NAJSTARSZY STAZEM W BANDZIE' || s1.nazwa " "
FROM stats s1
WHERE "staz" = "maxi"
UNION
SELECT s1.imie, s1.w_stadku_od, '' " "
FROM stats s1
WHERE "staz" != "mini"
  AND "staz" != "maxi"
;

