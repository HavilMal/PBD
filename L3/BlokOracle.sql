-- head: Zadanie 1
-- desc: znajduje kota o podanej funkcji i przypisuję tą funkcję do zmiennej jeśli nie zostanie znaleziony żaden kot rzucony zostanie wyjątek no_data_found który jest obsługiwany w EXCEPTION
-- todo parameter
DECLARE
    szukana_funkcja    kocury.funkcja%type := '${funkcja}';
    znaleziona_funkcja kocury.funkcja%type;
BEGIN
    SELECT funkcja
    INTO znaleziona_funkcja
    FROM kocury
    WHERE funkcja = szukana_funkcja
      AND ROWNUM = 1;

    dbms_output.put_line('Znaleziono kota pełniącego funkcję: ' || znaleziona_funkcja);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nie znaleziono żadnego kota');
END;


-- head: Zadanie 3
-- desc: znajduję i wyliczam dane dla kocura o podanym pseudo a następnie wyświetlam pierwszy spełniony warunek dla wybranego kota
-- todo parameter
DECLARE
    szukany_kocur kocury.pseudo%type := '${pseudo}';
    rocznie       Int;
    imie          kocury.imie%type;
    miesiac       Int;
BEGIN
    SELECT (COALESCE(przydzial_myszy, 0) + COALESCE(myszy_extra, 0)) * 12,
           imie,
           miesiac
    INTO
        rocznie, imie, miesiac
    FROM kocury
    WHERE pseudo = szukany_kocur;
    CASE
        WHEN rocznie > 700 THEN dbms_output.put_line('calkowity roczny przydzial myszy > 700');
        WHEN REGEXP_LIKE(imie, '.*A.*') THEN dbms_output.put_line('imię zawiera litere A');
        WHEN miesiac = 5 THEN dbms_output.put_line('maj jest miesiacem przystapienia do stada');
        ELSE dbms_output.put_line('nie odpowiada kryteriom');
        END CASE;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('nie znaleziono kocura o pseudonimie: ' || szukany_kocur);
END;

-- head: Zadanie 4
-- desc: koty o najniższym stażu to koty, które dołączyły najpóźniej do stada; wybieram numery bady, które występują w tabeli kocury i wypisuję tabele
DECLARE
    TYPE nowi_table IS TABLE OF kocury%ROWTYPE INDEX BY BINARY_INTEGER;
    nowi nowi_table;
BEGIN
    FOR i IN (
        SELECT k1.*
        FROM kocury k1
                 LEFT JOIN (SELECT MAX(w_stadku_od) "najnowszy", nr_bandy
                            FROM kocury
                            GROUP BY nr_bandy) n1 ON k1.nr_bandy = n1.nr_bandy
        WHERE k1.w_stadku_od = n1."najnowszy"
        )
        LOOP
            nowi(i.nr_bandy) := i;
        END LOOP;


    dbms_output.put_line(RPAD('|Pseudo ', 15) || RPAD('|Staż', 10) || '|');
    dbms_output.put_line('--------------------------');
    FOR j IN (SELECT DISTINCT nr_bandy FROM kocury)
        LOOP
            dbms_output.put(RPAD('|' || nowi(j.nr_bandy).pseudo, 15));
            dbms_output.put(RPAD('|' || TO_CHAR(SYSDATE - nowi(j.nr_bandy).w_stadku_od), 10));
            dbms_output.put('|');
            dbms_output.put_line('');
        END LOOP;
END;

-- head: Zadanie 5
-- desc: tworzę kursor który przechodzi po złączeniu kotów i ich funkcji, tworzę typ kot, który przechowuje potrzebne dane; w pętli iteruje, dopóki suma nie przekroczy żądanej wartości, jeśli kursor dochodzi do końca danych, otwieram go ponownie. Następnie wypisuje dane w tabeli.
DECLARE
    CURSOR koty IS
        SELECT k1.pseudo, k1.przydzial_myszy, f1.max_myszy
        FROM kocury k1
                 LEFT JOIN funkcje f1 ON k1.funkcja = f1.funkcja
        ORDER BY przydzial_myszy
            FOR UPDATE OF k1.przydzial_myszy
    ;
    TYPE kot_type IS RECORD
                     (
                         pseudo    kocury.pseudo%TYPE,
                         przydzial kocury.przydzial_myszy%TYPE,
                         maks      funkcje.max_myszy%TYPE
                     );
    kot            kot_type;
    suma           INTEGER;
    nowy_przydzial NUMBER(3);
    zmiany         INTEGER;
BEGIN
    zmiany := 0;
    OPEN koty;
    FETCH koty INTO kot;
    SELECT SUM(przydzial_myszy) INTO suma FROM kocury;
    WHILE suma <= 1050
        LOOP
            IF koty%NOTFOUND THEN
                CLOSE koty;
                OPEN koty;
                FETCH koty INTO kot;
            END IF;

            nowy_przydzial := LEAST(kot.maks, kot.przydzial * 1.1);
            IF nowy_przydzial <> kot.przydzial THEN
                UPDATE kocury
                SET przydzial_myszy = nowy_przydzial
                WHERE CURRENT OF koty;
                zmiany := zmiany + 1;
            END IF;

            FETCH koty INTO kot;

            SELECT SUM(przydzial_myszy) INTO suma FROM kocury;
        END LOOP;

    CLOSE koty;
    dbms_output.put_line('Całkowity przydział: ' || suma || ' Liczba Zmian: ' || zmiany);
    dbms_output.put_line('IMIE            Myszki po podwyzce');
    dbms_output.put_line('--------------- ------------------');
    FOR k IN (SELECT * FROM kocury)
        LOOP
            dbms_output.put_line(
                    RPAD(k.imie, 16) || LPAD(k.przydzial_myszy, 18)
            );
        END LOOP;

    ROLLBACK;
END;


-- head: Zadanie 6
-- desc: tworzę kursor który iteruje po kotach i ich całkowitych przydziałach w malejącej kolejności. Wypisuje 5 pierwszych rekordów
DECLARE
    CURSOR koty IS
        SELECT pseudo, przydzial_myszy + COALESCE(myszy_extra, 0) "zjada"
        FROM kocury
        ORDER BY przydzial_myszy + COALESCE(myszy_extra, 0);
    TYPE wybrani_type IS RECORD (pseudo kocury.pseudo%TYPE, zjada kocury.przydzial_myszy%type);
    TYPE wybrani_table IS TABLE OF wybrani_type INDEX BY BINARY_INTEGER;
    wybrani wybrani_table;
    liczba  BINARY_INTEGER;
BEGIN
    liczba := 0;
    FOR kot IN koty
        LOOP
            IF liczba < 5 THEN
                wybrani(liczba) := kot;
                liczba := liczba + 1;
            END IF;
        END LOOP;

    dbms_output.put_line('Nr  Pseudonim  Zjada');
    dbms_output.put_line('--------------------');
    FOR liczba IN 0..wybrani.count - 1
        LOOP
            dbms_output.put_line(
                    RPAD(TO_CHAR(liczba + 1), 4) || RPAD(wybrani(liczba).pseudo, 11) || LPAD(wybrani(liczba).zjada, 4)
            );
        END LOOP;
END;

-- Zadanie 7
-- todo
DECLARE

BEGIN

END;

SELECT *
FROM (SELECT CONNECT_BY_ROOT k2.imie "imie",
             k2.szef                 "szef",
--              SYS_CONNECT_BY_PATH(RPAD(pseudo, 10, ' '), '|') || '|' "szefowie",
             level                   "lvl"
      FROM kocury k2
      CONNECT BY PRIOR k2.szef = k2.pseudo) PIVOT (
    MAX("szef") FOR "lvl" IN (1, 2, 3, 4, 5)
    )
;



-- head: Zdanie 8
-- desc: sprawdzam czy numer jest dodatni i czy istnieje już banda z tym samym atrybutem, jeśli jest rzucam wyjątek. W przeciwnym wypadku dodaje bandę pod koniec cofam transakcję.
-- todo parametry
DECLARE
    nr_bandy_in bandy.nr_bandy%type := '${nr_bandy_in}';
    nazwa_in    bandy.nazwa%type    := '${nazwa_in}';
    teren_in    bandy.teren%type    := '${teren_in}';
    correct     Boolean;
BEGIN
    BEGIN
        IF nr_bandy_in <= 0 THEN
            RAISE invalid_number;
        END IF;

        SELECT FALSE
        INTO correct
        FROM bandy
        WHERE nr_bandy = nr_bandy_in
           OR nazwa = nazwa_in
           OR teren = teren_in
            FETCH FIRST 1 ROW ONLY;


        RAISE dup_val_on_index;
    EXCEPTION
        WHEN no_data_found THEN
            NULL;
    END;

    INSERT INTO bandy (nr_bandy, nazwa, teren)
    VALUES (nr_bandy_in, nazwa_in, teren_in);

    ROLLBACK;

EXCEPTION
    WHEN dup_val_on_index THEN
        dbms_output.put_line('Banda o z jedna z podanych cech już istnieje.');
    WHEN invalid_number THEN
        dbms_output.put_line('Numer bandy musi być dodatni.');
END;

-- head: Zadanie 9
-- desc: definjuję procedurę, która jako argument przyjmuje funkcję oraz przydział, który ma ustawić wszystkim kotom o podanej funkcji
CREATE OR REPLACE PROCEDURE zmienprzydizal(funkcja_in IN kocury.funkcja%type,
                                           przydzial_in IN kocury.przydzial_myszy%type) IS
    maxi     funkcje.max_myszy%type;
    mini     funkcje.max_myszy%type;
    istnieje funkcje.funkcja%type;
BEGIN
    SELECT funkcja, max_myszy, min_myszy INTO istnieje, maxi, mini FROM funkcje WHERE funkcja = funkcja_in;

    IF NOT przydzial_in BETWEEN mini AND maxi THEN
        RAISE invalid_number;
    END IF;

    UPDATE kocury
    SET przydzial_myszy = przydzial_in
    WHERE funkcja = funkcja_in;
EXCEPTION
    WHEN invalid_number THEN
        dbms_output.put_line('Podany przydział nie jest dozwolony.');
    WHEN no_data_found THEN
        dbms_output.put_line('Podana funkcja nie istnieje.');
END;

-- desc: wykonanie procedury i cofnięcie transakcji
DECLARE
    funkcja_in   kocury.funkcja%type         := '${funkcja}';
    przydzial_in kocury.przydzial_myszy%type := '${przydzial}';
BEGIN
    zmienprzydizal(funkcja_in, przydzial_in);
    ROLLBACK;
END;


-- head: Zadanie 10
-- desc: definuję kursor kota z potrzebnymi danymi to jest: z przychodami, podwładnym, wrogiem i bandą
-- todo left join makes it so cats are duplicated
CREATE OR REPLACE FUNCTION podatek(pseudo_in IN kocury.pseudo%type) RETURN NUMBER IS
    CURSOR koty IS SELECT k1.przydzial_myszy + COALESCE(k1.myszy_extra, 0) "przychody",
                          k2.pseudo                                        "podwladny",
                          wk1.imie_wroga                                   "wrog",
                          b1.nazwa                                         "banda"
                   FROM kocury k1
                            LEFT JOIN kocury k2 ON k1.pseudo = k2.szef
                            LEFT JOIN wrogowie_kocurow wk1 ON k1.pseudo = wk1.pseudo
                            LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
                   WHERE k1.pseudo = pseudo_in;
    TYPE kot_type IS RECORD
                     (
                         przychody kocury.przydzial_myszy%type,
                         podwladny kocury.pseudo%type,
                         wrog      wrogowie_kocurow.imie_wroga%type,
                         banda     bandy.nazwa%type
                     );
    kot     kot_type;
    podatek kocury.przydzial_myszy%type;
BEGIN
    OPEN koty;
    FETCH koty INTO kot;

    podatek := CEIL(kot.przychody * 0.05);
    IF kot.podwladny IS NULL THEN
        podatek := podatek + 2;
    END IF;

    IF kot.wrog IS NULL THEN
        podatek := podatek + 1;
    END IF;

    -- koty z szefostwa oddają 2 myszy
    IF kot.banda = 'SZEFOSTWO' THEN
        podatek := podatek + 2;
    END IF;

    CLOSE koty;

    RETURN podatek;
END;

-- head: Zdanie 11a
-- todo: użyc kursora z parametrem chyba
DECLARE
    CURSOR plec(
        band bandy.nazwa%type
        ) IS
        SELECT plec
        FROM kocury k1
                 LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
        WHERE b1.nazwa = band;
    CURSOR suma(
        banda bandy.nazwa%type, pl kocury.plec%type, fn kocury.funkcja%type
        ) IS
        SELECT SUM(przydzial_myszy)
        FROM kocury k1
                 LEFT JOIN bandy b1 ON k1.nr_bandy = b1.nr_bandy
        WHERE b1.nazwa = banda
          AND k1.plec = pl
          AND k1.funkcja = fn;
    s kocury.przydzial_myszy%type;
BEGIN
    FOR for b IN
    (SELECT k1.funkcja, k1.plec, b2.nazwa, COUNT(*) "ile"
     FROM kocury k1
              LEFT JOIN bandy b2 ON k1.nr_bandy = b2.nr_bandy
     GROUP BY k1.funkcja, k1.plec, b2.nazwa)
    LOOP
        OPEN suma(b.nazwa, b.plec, b.funkcja);
        FETCH suma INTO s;
        dbms_output.put_line(s);
        CLOSE suma;
    END LOOP;
END;


