-- Zadanie 14
SELECT level, pseudo, funkcja, nr_bandy
From KOCURY WHERE plec = 'M'
START WITH funkcja = 'BANDZIOR' CONNECT by Prior PSEUDO = szef;

-- Zadanie 15
SELECT LPAD(level - 1 || ' ' || imie, (level - 1) * 4 + Length(level - 1 || imie) + (level-1)/10, '===>'), SZEF, funkcja FROM KOCURY
WHERE COALESCE(MYSZY_EXTRA, 0) != 0
START WITH SZEF IS NULL
CONNECT BY PRIOR PSEUDO = SZEF;  


-- Zadanie 16
SELECT LPAD(pseudo, 4 * (level-1) + LENGTH(pseudo))
FROM KOCURY 
START WITH plec = 'M' 
AND COALESCE(MYSZY_EXTRA, 0) = 0
AND SYSDATE - W_STADKU_OD > 365 * 15
CONNECT BY PRIOR SZEF = PSEUDO;
