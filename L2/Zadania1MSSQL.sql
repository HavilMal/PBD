-- head: Zadanie 26
-- desc: Stworzenie perspektywy
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

-- desc: Użycie perspektywy
-- run
SELECT *
FROM zadziorne_kotki;

-- head: Zadanie 27
-- desc: użycie rekursywnego CTE, aby przechodzić po drzewie
-- run
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

-- head: Zadanie 28
-- desc: Ponowne użycie rekursywnego CTE do rekursywnego przechodzenia drzewa, replicate pozwala na duplikowanie ciągów znaków N razy
-- run
WITH hierarhia AS (SELECT 0 AS lvl, kocury.*
                   FROM kocury
                   WHERE szef IS NULL
                   UNION ALL
                   SELECT lvl + 1, kocury.*
                   FROM kocury
                            INNER JOIN hierarhia ON hierarhia.pseudo = kocury.szef)
SELECT REPLICATE('===>', lvl) + CAST(lvl AS VARCHAR) + ' ' +
       imie,
       COALESCE(szef, 'Sam sobie panem'),
       funkcja
FROM hierarhia
WHERE myszy_extra IS NOT NULL
;

-- head: Zadanie 29
-- desc: w podzapytaniu znajduje minimalny i maksymalny przydział myszy dla funkcji następnie, następnie wybieram koty, które nie są szefami żadnego innego kota i które spełniają warunek (w przykładzie jest nierówność ostra co według mnie nie jest zgodne z treścią zadania)
-- run
SELECT DISTINCT k1.pseudo, b1.nazwa
FROM kocury k1
         LEFT JOIN funkcje f1 ON k1.funkcja = f1.funkcja
         LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
         INNER JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
WHERE k1.pseudo NOT IN (SELECT szef FROM kocury WHERE szef IS NOT NULL)
  AND f1.min_myszy + (f1.max_myszy - f1.min_myszy) / 3 <= k1.przydzial_myszy
;

