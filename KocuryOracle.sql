-- Tabela funkcje
CREATE TABLE Funkcje (
    funkcja VARCHAR2(10) PRIMARY KEY,
    min_myszy NUMBER(3) CHECK (min_myszy > 5),
    max_myszy NUMBER(3),
    CONSTRAINT chk_myszy CHECK (max_myszy < 200 AND max_myszy >= min_myszy)
);

-- Tabela wrogowie
CREATE TABLE Wrogowie (
    imie_wroga VARCHAR2(15) PRIMARY KEY,
    stopien_wrogosci NUMBER(2) CHECK (1 <= stopien_wrogosci AND stopien_wrogosci <= 10),
    gatunek VARCHAR2(15),
    lapowka VARCHAR2(20)
);

-- Tabela bandy klucz obcy dodany pod koniec za pomocą alter
CREATE TABLE Bandy (
    nr_bandy NUMBER(2) PRIMARY KEY,
    nazwa VARCHAR2(20) not null,
    teren VARCHAR2(15) UNIQUE,
    szef_bandy VARCHAR2(15)
);

-- Tabela kocury DEFFERABLE INITIALLY DEFERRED pozwala odroczyć sprawdzanie ograniczeń aż do wywołania COMMIT
CREATE TABLE Kocury (
    imie VARCHAR2(15) not null,
    plec VARCHAR2(1) CHECK (plec = 'M' OR plec = 'D'), 
    pseudo VARCHAR2(15) PRIMARY KEY,
    funkcja VARCHAR2(10), -- foregin key
    szef VARCHAR2(15), -- foregin key
    w_stadku_od DATE default SYSDATE, -- curernt date
    przydzial_myszy NUMBER(3),
    myszy_extra NUMBER(3),
    nr_bandy NUMBER(2), -- foregin key
    FOREIGN KEY(funkcja) REFERENCES Funkcje(funkcja),
    FOREIGN KEY(szef) REFERENCES Kocury(pseudo) DEFERRABLE INITIALLY DEFERRED,
    FOREIGN KEY(nr_bandy) REFERENCES Bandy(nr_bandy) DEFERRABLE INITIALLY DEFERRED
);

-- Tabela wrogowie
CREATE TABLE Wrogowie_kocurow (
    pseudo VARCHAR2(15),
    imie_wroga VARCHAR2(15),
    data_incydentu DATE not NULL,
    opis_incydentu VARCHAR2(50),
    PRIMARY KEY(pseudo, imie_wroga),
    FOREIGN KEY(pseudo) REFERENCES Kocury(pseudo),
    FOREIGN KEY(imie_wroga) REFERENCES Wrogowie(imie_wroga)
);


-- Dodanie klucza obcego do tabeli band za pomoca ALTER
ALTER TABLE Bandy ADD FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo) DEFERRABLE INITIALLY DEFERRED;

