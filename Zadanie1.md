###  Zadanie 1
```sql
SELECT imie_wroga, DATA_INCYDENTU From Wrogowie_kocurow WHERE data_incydentu >= '01-01-2009' AND data_incydentu <= '31-12-2009';
```

###  Zadanie 2
```sql
SELECT imie, w_stadku_od FROM KOCURY WHERE W_STADKU_OD >= '01-09-2005' AND W_STADKU_OD <= '31-07-2007';
```

###  Zadanie 3
```sql
SELECT imie_wroga, gatunek, stopien_wrogosci FROM WROGOWIE WHERE LAPOWKA IS NULL ORDER BY STOPIEN_WROGOSCI ASC;
```

###  Zadanie 4
```sql
SELECT imie, ' zwany ', pseudo, ' (fun. ', funkcja, ') lowi myszki w bandzie ', nr_bandy, ' od ', w_stadku_od From KOCURY Where PLEC = 'M';
```

###  Zadanie 5
```sql
SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'L', '#', 1, 1), 'A', '%', 1, 1) as Replacement
FROM KOCURY Where INSTR(pseudo, 'A') > 0 AND INSTR(pseudo, 'L') > 0;
```

###  Zadanie 6
```sql
SELECT imie, w_stadku_od, przydzial_myszy/1.1 as Zjadal, ADD_MONTHS(w_stadku_od, 6) AS Podwyzka, przydzial_myszy as Zjada FROM KOCURY where 
(SYSDATE - w_stadku_od) / 365 > 15 AND
EXTRACT(MONTH FROM w_stadku_od) >= 3 AND
EXTRACT(MONTH FROM w_stadku_od) <= 9 
;
```

###  Zadanie 7
```sql
SELECT imie, przydzial_myszy * 4 as Kwartalnie, myszy_extra FROM KOCURY WHERE PRZYDZIAL_MYSZY > (MYSZY_EXTRA * 2) AND PRZYDZIAL_MYSZY >= 55;
```

###  Zadanie 8 todo change
```sql
SELECT imie, CASE
    WHEN (przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) > 55 THEN TO_CHAR((przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) * 12)
    WHEN (przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) = 55 THEN 'LIMIT'
    WHEN (przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) < 55 THEN 'PONIZEJ 660' 
END AS Zjada_rocznie
FROM KOCURY;
```

###  Zadanie 9a
```sql
SELECT CONCAT(pseudo,
CASE 
    WHEN COUNT(PSEUDO) = 1 THEN ' - Unikalny' 
    ELSE ' - Nie unikalny'
END) as Unikalny FROM KOCURY GROUP BY pseudo;
```

###  Zadanie 9b
```sql
SELECT CONCAT(SZEF,
CASE 
    WHEN COUNT(SZEF) = 1 THEN ' - Unikalny' 
    ELSE ' - Nie unikalny'
END) as Unikalny FROM KOCURY WHERE SZEF IS NOT NULL GROUP BY SZEF; 
```

###  Zadanie 10
```sql
SELECT pseudo, COUNT(pseudo) as Liczba_worgow FROM Wrogowie_kocurow WHERE Liczba_worgow >= 2 GROUP BY PSEUDO;
```

