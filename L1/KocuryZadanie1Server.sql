-- Zadanie 1
-- BETWEEN zastępuje dwie nierówności
SELECT imie_wroga, DATA_INCYDENTU From Wrogowie_kocurow WHERE data_incydentu BETWEEN '2009-01-01' AND '2009-12-31';

-- Zadanie 2
SELECT imie, w_stadku_od FROM KOCURY WHERE W_STADKU_OD BETWEEN '2005-09-01' AND '2007-07-31';

-- Zadanie 3
SELECT imie_wroga, gatunek, stopien_wrogosci FROM WROGOWIE WHERE LAPOWKA IS NULL ORDER BY STOPIEN_WROGOSCI ASC;

-- Zadanie 4
SELECT Concat(
imie, ' zwany ', pseudo, ' (fun. ', funkcja, ') lowi myszki w bandzie ', nr_bandy,  ' od ', w_stadku_od)
AS "Wszystko o Kocurach" From KOCURY Where PLEC = 'M';

-- Zadanie 5
-- CHARINDEX tylko w sql server zwraca 0 jeśli znaku nie ma w ciągu, STUFF pozwala na zamiane znaku na wybranej pozycji innym znakiem
SELECT pseudo, STUFF(STUFF(pseudo, CHARINDEX('L', pseudo), 1, '#'), CHARINDEX('A', pseudo), 1, '%') as Replacement
FROM KOCURY Where CHARINDEX(pseudo, 'A') > 0 AND CHARINDEX(pseudo, 'L') > 0;

-- Zadanie 6
-- DATEADD dodaje wartość do daty we wskazanym interwalem, DATEDIFF oblicza rónice ze wskazanym interwałem
SELECT imie, w_stadku_od, przydzial_myszy/1.1 as Zjadal, DATEADD(month, 6, w_stadku_od) AS Podwyzka, przydzial_myszy as Zjada FROM KOCURY where 
    DATEDIFF(year, w_stadku_od, SYSDATETIME()) > 15
    AND MONTH(w_stadku_od) BETWEEN 3 AND 9;
;

-- Zadanie 7
SELECT imie, przydzial_myszy * 4 as Kwartalnie, myszy_extra FROM KOCURY WHERE PRZYDZIAL_MYSZY > (MYSZY_EXTRA * 2) AND PRZYDZIAL_MYSZY >= 55;

-- Zadanie 8
-- CONVERT pozwala zamieniać na wybrany typ, natomiast COALESCE zwraca pierwszy argument nie będący nullem jest w Oracle i SQL server
SELECT imie, CASE
    WHEN (przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) > 55 THEN CONVERT(VARCHAR(15), przydzial_myszy + COALESCE(MYSZY_EXTRA, 0) * 12)
    WHEN (przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) = 55 THEN 'LIMIT'
    WHEN (przydzial_myszy + COALESCE(MYSZY_EXTRA, 0)) < 55 THEN 'PONIZEJ 660' 
END AS Zjada_rocznie
FROM KOCURY;


-- Zadanie 9a
-- CONCAT pozwala na łączenie ciągów znaków w Oracle i SQL Server
SELECT CONCAT(pseudo,
CASE 
    WHEN COUNT(PSEUDO) = 1 THEN ' - Unikalny' 
    ELSE ' - Nie unikalny'
END) as Unikalny FROM KOCURY GROUP BY pseudo;

-- Zadanie 9b
SELECT CONCAT(SZEF,
CASE 
    WHEN COUNT(SZEF) = 1 THEN ' - Unikalny' 
    ELSE ' - Nie unikalny'
END) as Unikalny FROM KOCURY WHERE SZEF IS NOT NULL GROUP BY SZEF; 

-- Zadanie 10
-- COUNT zlicza wystąpienia tej samej wartości w danej kolumnie, natomiast HAVING pozwala ograniczyć zwracane wartości
SELECT pseudo, COUNT(pseudo) as Liczba_worgow FROM Wrogowie_kocurow GROUP BY PSEUDO HAVING COUNT(pseudo) >= 2;
