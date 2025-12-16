-- Zadanie 2
-- todo
DECLARE @szukane_pseudo AS VARCHAR(15),
    @pseudo VARCHAR(15),
    @imie VARCHAR(15),
    @banda VARCHAR(15),
    @dzien VARCHAR(15),
    @miesiac VARCHAR(15),
    @rok VARCHAR(15),
    @sr_bandy FLOAT,
    @przydzial FLOAT;
SET @szukane_pseudo = '${pseudo}';
BEGIN
    SELECT @pseudo = pseudo,
           @imie = imie,
           @banda = b1.nazwa,
           @dzien = CAST(DAY(k1.w_stadku_od) AS VARCHAR),
           @miesiac = CAST(MONTH(k1.w_stadku_od) AS VARCHAR),
           @rok = CAST(YEAR(k1.w_stadku_od) AS VARCHAR),
           @sr_bandy = (SELECT AVG(COALESCE(k2.przydzial_myszy, 0) + COALESCE(k2.myszy_extra, 0))
                        FROM kocury k2
                        WHERE k1.nr_bandy = k2.nr_bandy),
           @przydzial = COALESCE(k1.przydzial_myszy, 0) + COALESCE(k1.myszy_extra, 0)
    FROM kocury k1
             LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
    WHERE pseudo = @szukane_pseudo;

    PRINT '|Pseudo: ' + @pseudo + '|Imie: ' + @imie + '|Banda: ' + @banda +
          IIF(@przydzial > @sr_bandy, N'|Przydiział większy od średniej', N'|Przydział nie większy od średniej') +
          '|Dzien: ' + @dzien + '|Miesiac: ' + @miesiac + '|Rok: ' + @rok + '|';
END;