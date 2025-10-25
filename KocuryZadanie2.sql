-- Zadanie 11a
-- jeśli następna środa jest w innym miesiącu szukaj ostatniej środy w następnym miesiącu w przeciwnym razie szukaj w postępuj zgodnie z zasadami
SELECT pseudo, w_stadku_od, 
CASE
    WHEN EXTRACT(MONTH FROM NEXT_DAY(DATE '2024-10-29', 'WEDNESDAY')) = EXTRACT(MONTH FROM DATE '2024-10-29')
    THEN
        CASE
            WHEN EXTRACT(DAY FROM W_STADKU_OD) <= 15 THEN NEXT_DAY(LAST_DAY(DATE '2024-10-29') - 7, 'WEDNESDAY') 
            ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2024-10-29', 1)) - 7, 'WEDNESDAY')
        END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2024-10-29', 1)) - 7, 'WEDNESDAY')
END AS wyplata
FROM KOCURY ORDER BY W_STADKU_OD;



-- Zadanie 11b
SELECT pseudo, w_stadku_od, 
CASE
    WHEN EXTRACT(MONTH FROM NEXT_DAY(DATE '2024-10-31', 'WEDNESDAY')) = EXTRACT(MONTH FROM DATE '2024-10-31')
    THEN
        CASE
            WHEN EXTRACT(DAY FROM W_STADKU_OD) <= 15 THEN NEXT_DAY(LAST_DAY(DATE '2024-10-31') - 7, 'WEDNESDAY') 
            ELSE NEXT_DAY(LAST_DAY(DATE '2024-10-31') - 7, 'WEDNESDAY')
        END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS(DATE '2024-10-31', 1)) - 7, 'WEDNESDAY')
END AS wyplata
FROM KOCURY ORDER BY W_STADKU_OD;


-- Zadanie 12
SELECT
'Liczba kotow=' || COUNT(funkcja) || ' lowi jako ' || funkcja || ' i zjada max. ' || MAX(COALESCE(PRZYDZIAL_MYSZY, 0) + COALESCE(MYSZY_EXTRA, 0)) || ' myszy miesiecznie'
FROM Kocury WHERE
funkcja != 'SZEFUNCIO' AND plec != 'M' GROUP BY funkcja HAVING AVG(COALESCE(PRZYDZIAL_MYSZY, 0) + COALESCE(MYSZY_EXTRA, 0)) > 50; 

-- Zadanie 13
SELECT nr_bandy, plec, MIN(PRZYDZIAL_MYSZY) FROM KOCURY GROUP BY NR_BANDY, PLEC; 


