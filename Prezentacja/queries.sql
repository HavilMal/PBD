
-- Ł
-- wstąpienia w latach
WITH wystapienia AS (
    SELECT
        EXTRACT(YEAR FROM K.w_stadku_od) AS "_rok",
        COUNT(*) AS "_count"
    FROM Kocury K
    GROUP BY EXTRACT(YEAR FROM K.w_stadku_od)),

-- średnia wstąpień
srednia AS
(SELECT AVG("_count") AS "_srednia"
FROM wystapienia),

-- znalezienie maksymalnych wartości mniejszej do średniej
dolna_granica AS
(SELECT wystapienia."_rok", wystapienia."_count"
FROM wystapienia, srednia
WHERE wystapienia."_count" = (SELECT MAX(w0."_count")
        FROM wystapienia w0, srednia s0
        WHERE w0."_count" < s0."_srednia")
),

-- znalezienie minimalnej wartości większej od średniej
gorna_granica AS
(SELECT wystapienia."_rok", wystapienia."_count"
FROM wystapienia, srednia
WHERE wystapienia."_count" = (SELECT MIN(w0."_count")
        FROM wystapienia w0, srednia s0
        WHERE w0."_count" > s0."_srednia")
)

-- złączenie poziome
SELECT TO_CHAR(dolna_granica."_rok") AS "ROK",
dolna_granica."_count" AS "WYSTAPIENIA"
FROM dolna_granica

UNION ALL

SELECT 'srednia' AS "ROK",
srednia."_srednia" AS "WYSTAPIENIA"
FROM srednia

UNION ALL

SELECT TO_CHAR(gorna_granica."_rok") AS "ROK",
gorna_granica."_count" AS "WYSTAPIENIA"
FROM gorna_granica
;

-- M
-- wystąpienia
WITH liczby AS (
    SELECT EXTRACT(YEAR FROM w_stadku_od) AS rok,
           COUNT(*) AS liczba_wstapien
    FROM Kocury
    GROUP BY EXTRACT(YEAR FROM w_stadku_od)
-- średnia
), stat AS (
    SELECT liczba_wstapien,
           AVG(liczba_wstapien) OVER () AS srednia
    FROM liczby
-- znalezienie minimalnej wartości większej od średniej i maksymalnej wartości większej od średniej
), granice AS (
    SELECT MAX(CASE WHEN liczba_wstapien <= srednia THEN liczba_wstapien END) AS od_dolu,
           MIN(CASE WHEN liczba_wstapien >= srednia THEN liczba_wstapien END) AS od_gory
    FROM stat
)
-- złączenie liczby wystąpień i granic tak, aby wybrać lata z liczbą wystąpień równą jednej z granic
SELECT TO_CHAR(l.rok) AS rok, l.liczba_wstapien
FROM liczby l
JOIN granice g
  ON l.liczba_wstapien = g.od_dolu
     OR l.liczba_wstapien = g.od_gory

-- złączenie poziome
UNION ALL

SELECT 'Srednia', AVG(liczba_wstapien)
FROM liczby;