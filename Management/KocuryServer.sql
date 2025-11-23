-- Tabela funkcji
CREATE TABLE Funkcje (
    funkcja VARCHAR(10) PRIMARY KEY,
    min_myszy DECIMAL(3) CHECK (min_myszy > 5),
    max_myszy DECIMAL(3),
    CONSTRAINT chk_myszy CHECK (max_myszy < 200 AND max_myszy >= min_myszy)
);

-- Tabela wrogów
CREATE TABLE Wrogowie (
    imie_wroga VARCHAR(15) PRIMARY KEY,
    stopien_wrogosci DECIMAL(2) CHECK (1 <= stopien_wrogosci AND stopien_wrogosci <= 10),
    gatunek VARCHAR(15),
    lapowka VARCHAR(20)
);

-- Tabela band
-- Klucz obcy dodany na koniec za pomocą ALTER
CREATE TABLE Bandy (
    nr_bandy DECIMAL(2) PRIMARY KEY,
    nazwa VARCHAR(20) not null,
    teren VARCHAR(15) UNIQUE,
    szef_bandy VARCHAR(15)
);

-- Tabela kocurów
CREATE TABLE Kocury (
    imie VARCHAR(15) not null,
    plec VARCHAR(1) CHECK (plec = 'M' OR plec = 'D'), 
    pseudo VARCHAR(15) PRIMARY KEY,
    funkcja VARCHAR(10), -- foregin key
    szef VARCHAR(15), -- foregin key
    w_stadku_od DATE default SYSDATETIME(), -- curernt date
    przydzial_myszy DECIMAL(3),
    myszy_extra DECIMAL(3),
    nr_bandy DECIMAL(2), -- foregin key
    CONSTRAINT fk_kocury_funkcje FOREIGN KEY(funkcja) REFERENCES Funkcje(funkcja),
    CONSTRAINT fk_kocury_kocury FOREIGN KEY(szef) REFERENCES Kocury(pseudo),
    CONSTRAINT fk_kocury_bandy FOREIGN KEY(nr_bandy) REFERENCES Bandy(nr_bandy)
);

-- Tabela wrogów kocurów
CREATE TABLE Wrogowie_kocurow (
    pseudo VARCHAR(15),
    imie_wroga VARCHAR(15),
    data_incydentu DATE not NULL,
    opis_incydentu VARCHAR(50),
    PRIMARY KEY(pseudo, imie_wroga),
    CONSTRAINT fk_wrogowie_kocurow_kocury FOREIGN KEY(pseudo) REFERENCES Kocury(pseudo),
    CONSTRAINT fk_wrogowie_kocurow_wrogowie FOREIGN KEY(imie_wroga) REFERENCES Wrogowie(imie_wroga)
);


-- Dodanie klucza obcego do tabeli band
ALTER TABLE Bandy ADD CONSTRAINT fk_bandy_kocury FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo);

