-- head: Zadanie 1
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
-- run
SELECT k1.pseudo, w1.imie_wroga, w1.opis_incydentu
FROM kocury k1
         LEFT JOIN wrogowie_kocurow w1
                   ON k1.pseudo = w1.pseudo
WHERE k1.plec = 'D'
  AND w1.imie_wroga IS NOT NULL;

-- head: Zadanie 3
-- desc: złączenie z szefami pozwala znaleźć koty, których szefowie są z innych band niż oni sami
-- run
SELECT k1.pseudo, k1.nr_bandy
FROM kocury k1
         INNER JOIN kocury k2 ON k1.szef = k2.pseudo
WHERE k1.nr_bandy != k2.nr_bandy;

-- head: Zadanie 4
-- desc: złączenie kocurów z kocurami, wybranie tylko kotów płci męskiej. Jeśli przełożony lub podwłądny jest null wyświetla odpowiedni komunikat przy pomocy COALESCE
-- run
SELECT COALESCE(k1.pseudo, 'Brak przelozonego') "Przelozony",
       COALESCE(k2.pseudo, 'Brak podwladnego')  "Podwladny"
FROM kocury k1
         FULL JOIN kocury k2 ON k1.pseudo = k2.szef
WHERE COALESCE(k1.plec, 'M') = 'M'
  AND COALESCE(k2.plec, 'M') = 'M'
ORDER BY "Przelozony";

-- head: Zadanie 5
-- desc: dla każdego kota obliczamy sumę myszy w jego bandzie w podzapytaniu, a następnie obliczamy procent dla wybranych kotów
-- run
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
-- desc: złączenie poziome dwóch zapytań, w których wybrani zostali prominenci i szaracy
-- run
SELECT pseudo, przydzial_myszy, nr_bandy, 'Prominent'
FROM kocury k1
WHERE przydzial_myszy > (SELECT AVG(przydzial_myszy) FROM kocury)
UNION
SELECT pseudo, przydzial_myszy, nr_bandy, 'Szarak'
FROM kocury k2
WHERE przydzial_myszy = (SELECT MIN(przydzial_myszy) FROM kocury WHERE k2.nr_bandy = nr_bandy)
;

-- head: Zadanie 7
-- desc: dla każdego kota płci męskiej w podzapytaniu obliczono średni przydział z kotów z jego bandy
-- run
SELECT pseudo, (SELECT AVG(przydzial_myszy) "Srednia" FROM kocury WHERE k1.nr_bandy = nr_bandy) "Srednia"
FROM kocury k1
WHERE k1.plec = 'M'
ORDER BY "Srednia";

-- head: Zadanie 8a
-- desc: w podzapytaniu obliczane są dla każdej bandy średni przydział i całkowity średni przydział w bandzie i dla wszystkich kotów (bandy są wybierane na podstawie całkowitego przydziału natomiast, wyświetlany jest zwykły przydział — tak jak jest w przykłądize)
-- run
SELECT s1.nr_bandy, s1.srednia_bandy
FROM (SELECT DISTINCT nr_bandy,
                      AVG(przydzial_myszy) OVER (PARTITION BY nr_bandy)                    srednia_bandy,
                      AVG(COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0)) OVER () c_srednia,
                      AVG(COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0))
                          OVER (PARTITION BY nr_bandy)                                     c_srednia_bandy
      FROM kocury) s1
WHERE s1.c_srednia_bandy > (s1.c_srednia);

-- head: Zadanie 8b
-- desc: obliczony i wyświetlony jest również średni przydział
-- run
SELECT s1.nr_bandy, s1.srednia_bandy, s1.srednia
FROM (SELECT DISTINCT nr_bandy,
                      AVG(przydzial_myszy) OVER ()                                         srednia,
                      AVG(przydzial_myszy) OVER (PARTITION BY nr_bandy)                    srednia_bandy,
                      AVG(COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0)) OVER () c_srednia,
                      AVG(COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0))
                          OVER (PARTITION BY nr_bandy)                                     c_srednia_bandy
      FROM kocury) s1
WHERE s1.c_srednia_bandy > (s1.c_srednia);

-- head: Zadanie 9
-- desc: zliczenie tych samych miesięcy z dat przystąpienia do stadka
-- run
SELECT "Miesiac", COUNT("Miesiac")
FROM (SELECT DATENAME(MONTH, w_stadku_od) "Miesiac", MONTH(w_stadku_od) "nr" FROM kocury) s1
GROUP BY "nr", "Miesiac"
ORDER BY "nr";

-- head: Zadanie 10
-- desc: znalezienie całkowitego przydziału dla każdego kota następnie użycie tabeli przestawnej do zsumowania przydziałów z podziałem na funkcję i wybrane bandy
-- run
SELECT *
FROM (SELECT k1.funkcja, b1.nazwa, COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) "myszy"
      FROM kocury k1
               LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy) s1
    PIVOT (
    SUM(s1."myszy") FOR nazwa IN ("CZARNI RYCERZE", "BIALI LOWCY")
    ) p1
WHERE p1.funkcja != 'SZEFUNIO'
ORDER BY p1.funkcja;

-- head: Zadanie 11
-- desc: w tabeli przestawnej dodano podział na płeć
-- run
SELECT *
FROM (SELECT k1.funkcja, k1.plec, b1.nazwa, COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0) "myszy"
      FROM kocury k1
               LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy) s1 PIVOT (
    SUM("myszy") FOR nazwa IN ("CZARNI RYCERZE", "BIALI LOWCY")
    ) p1
ORDER BY p1.funkcja;