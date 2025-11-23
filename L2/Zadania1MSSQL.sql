-- Zadanie 26
-- Stworzenie perspektywy
CREATE VIEW zadziorne_kotki AS
WITH kotki AS (SELECT *
               FROM kocury
               WHERE plec = 'D'),
     zadziorni AS (SELECT DISTINCT k1.pseudo
                   FROM kocury k1
                            LEFT JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
                            LEFT JOIN wrogowie w1 ON wk1.imie_wroga = w1.imie_wroga
                   WHERE w1.stopien_wrogosci > 5)
SELECT kotki.pseudo
FROM kotki
         INNER JOIN zadziorni ON kotki.pseudo = zadziorni.pseudo;

-- Zadanie 26
-- Użycie perspektywy
SELECT *
FROM zadziorne_kotki;

-- Zadanie 27
WITH hierarhia AS (SELECT 1 AS lvl, kocury.*
                   FROM kocury
                   WHERE funkcja = 'BANDZIOR'
                   UNION ALL
                   SELECT lvl + 1, kocury.*
                   FROM kocury
                            INNER JOIN hierarhia ON hierarhia.pseudo = kocury.szef)
SELECT lvl, pseudo, funkcja, nr_bandy
FROM hierarhia
WHERE plec = 'M'
ORDER BY lvl;

-- Zadanie 28
WITH hierarhia AS (SELECT 0 AS lvl, kocury.*
                   FROM kocury
                   WHERE szef IS NULL
                   UNION ALL
                   SELECT lvl + 1, kocury.*
                   FROM kocury
                            INNER JOIN hierarhia ON hierarhia.pseudo = kocury.szef)
SELECT REPLICATE('===>', lvl) + CAST(lvl AS VARCHAR) + ' ' + imie, COALESCE(szef, 'Sam sobie panem'), funkcja
FROM hierarhia
WHERE COALESCE(myszy_extra, 0) != 0
;

-- Zadanie 29
-- todo inaczej niż w przykladzie
SELECT DISTINCT k1.pseudo, b1.nazwa, s1."mini" + (s1."maxi" - s1."mini") / 3, k1.przydzial_myszy
FROM kocury k1
         LEFT JOIN (SELECT funkcja, MIN(przydzial_myszy) "mini", MAX(przydzial_myszy) "maxi"
                    FROM kocury
                    GROUP BY funkcja) s1
                   ON k1.funkcja = s1.funkcja
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
         RIGHT JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
WHERE k1.pseudo NOT IN (SELECT szef FROM kocury WHERE szef IS NOT NULL)
  AND s1."mini" + (s1."maxi" - s1."mini") / 3 <= k1.przydzial_myszy
;

