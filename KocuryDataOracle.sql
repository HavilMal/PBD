-- Dane funkcji
INSERT INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES
('SZEFUNIO',90,110),
('BANDZIOR',70,90),
('LOWCZY',60,70),
('LAPACZ',50,60),
('KOT',40,50),
('MILUSIA',20,30),
('DZIELCZY',45,55),
('HONOROWA',6,25)
;

-- Dane wrogów
INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES
('KAZIO',10,'CZLOWIEK','FLASZKA'),
('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK'),
('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA'),
('BUREK',4,'PIES','KOSC'),
('DZIKI BILL',10,'PIES',NULL),
('REKSIO',2,'PIES','KOSC'),
('BETHOVEN',1,'PIES','PEDIGRIPALL'),
('CHYTRUSEK',5,'LIS','KURCZAK'),
('SMUKLA',1,'SOSNA',NULL),
('BAZYLI',3,'KOGUT','KURA DO STADA')
;

-- Dane kocurów
INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES
('JACEK','M','PLACEK','LOWCZY','LYSY',TO_DATE('2008-12-01', 'yyyy-mm-dd'),67,NULL,2),
('BARI','M','RURA','LAPACZ','LYSY',TO_DATE('2009-09-01', 'yyyy-mm-dd'),56,NULL,2),
('MICKA','D','LOLA','MILUSIA','TYGRYS',TO_DATE('2009-10-14', 'yyyy-mm-dd'),25,47,1),
('LUCEK','M','ZERO','KOT','KURKA',TO_DATE('2010-03-01', 'yyyy-mm-dd'),43,NULL,3),
('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI',TO_DATE('2010-11-18', 'yyyy-mm-dd'),20,35,3),
('LATKA','D','UCHO','KOT','RAFA',TO_DATE('2011-01-01', 'yyyy-mm-dd'),40,NULL,4),
('DUDEK','M','MALY','KOT','RAFA',TO_DATE('2011-05-15', 'yyyy-mm-dd'),40,NULL,4),
('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,TO_DATE('2002-01-01', 'yyyy-mm-dd'),103,33,1),
('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS',TO_DATE('2002-05-05', 'yyyy-mm-dd'),50,NULL,1),
('KOREK','M','ZOMBI','BANDZIOR','TYGRYS',TO_DATE('2004-03-16', 'yyyy-mm-dd'),75,13,3),
('BOLEK','M','LYSY','BANDZIOR','TYGRYS',TO_DATE('2006-08-15', 'yyyy-mm-dd'),72,21,2),
('ZUZIA','D','SZYBKA','LOWCZY','LYSY',TO_DATE('2006-07-21', 'yyyy-mm-dd'),65,NULL,2),
('RUDA','D','MALA','MILUSIA','TYGRYS',TO_DATE('2006-09-17', 'yyyy-mm-dd'),22,42,1),
('PUCEK','M','RAFA','LOWCZY','TYGRYS',TO_DATE('2006-10-15', 'yyyy-mm-dd'),65,NULL,4),
('PUNIA','D','KURKA','LOWCZY','ZOMBI',TO_DATE('2008-01-01', 'yyyy-mm-dd'),61,NULL,3),
('BELA','D','LASKA','MILUSIA','LYSY',TO_DATE('2008-02-01', 'yyyy-mm-dd'),24,28,2),
('KSAWERY','M','MAN','LAPACZ','RAFA',TO_DATE('2008-07-12', 'yyyy-mm-dd'),51,NULL,4),
('MELA','D','DAMA','LAPACZ','RAFA',TO_DATE('2008-11-01', 'yyyy-mm-dd'),51,NULL,4)
;

-- Dane band
INSERT INTO Bandy(nr_bandy,nazwa,teren,szef_bandy) VALUES 
(1,'SZEFOSTWO','CALOSC','TYGRYS'),
(2,'CZARNI RYCERZE','POLE','LYSY'),
(3,'BIALI LOWCY','SAD','ZOMBI'),
(4,'LACIACI MYSLIWI','GORKA','RAFA'),
(5,'ROCKERSI','ZAGRODA',NULL)
;

-- Dane wrogów kocurów
INSERT INTO Wrogowie_kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu) VALUES
('TYGRYS','KAZIO',TO_DATE('2004-10-13', 'yyyy-mm-dd'),'USILOWAL NABIC NA WIDLY'),
('ZOMBI','SWAWOLNY DYZIO',TO_DATE('2005-03-07', 'yyyy-mm-dd'),'WYBIL OKO Z PROCY'),
('BOLEK','KAZIO',TO_DATE('2005-03-29', 'yyyy-mm-dd'),'POSZCZUL BURKIEM'),
('SZYBKA','GLUPIA ZOSKA',TO_DATE('2006-09-12', 'yyyy-mm-dd'),'UZYLA KOTA JAKO SCIERKI'),
('MALA','CHYTRUSEK',TO_DATE('2007-03-07', 'yyyy-mm-dd'),'ZALECAL SIE'),
('TYGRYS','DZIKI BILL',TO_DATE('2007-06-12', 'yyyy-mm-dd'),'USILOWAL POZBAWIC ZYCIA'),
('BOLEK','DZIKI BILL',TO_DATE('2007-11-10', 'yyyy-mm-dd'),'ODGRYZL UCHO'),
('LASKA','DZIKI BILL',TO_DATE('2008-12-12', 'yyyy-mm-dd'),'POGRYZL ZE LEDWO SIE WYLIZALA'),
('LASKA','KAZIO',TO_DATE('2009-01-07', 'yyyy-mm-dd'),'ZLAPAL ZA OGON I ZROBIL WIATRAK'),
('DAMA','KAZIO',TO_DATE('2009-02-07', 'yyyy-mm-dd'),'CHCIAL OBEDRZEC ZE SKORY'),
('MAN','REKSIO',TO_DATE('2009-04-14', 'yyyy-mm-dd'),'WYJATKOWO NIEGRZECZNIE OBSZCZEKAL'),
('LYSY','BETHOVEN',TO_DATE('2009-05-11', 'yyyy-mm-dd'),'NIE PODZIELIL SIE SWOJA KASZA'),
('RURA','DZIKI BILL',TO_DATE('2009-09-03', 'yyyy-mm-dd'),'ODGRYZL OGON'),
('PLACEK','BAZYLI',TO_DATE('2010-07-12', 'yyyy-mm-dd'),'DZIOBIAC UNIEMOZLIWIL PODEBRANIEKURCZAKA'),
('PUSZYSTA','SMUKLA',TO_DATE('2010-11-19', 'yyyy-mm-dd'),'OBRZUCILA SZYSZKAMI'),
('KURKA','BUREK',TO_DATE('2010-12-14', 'yyyy-mm-dd'),'POGONIL'),
('MALY','CHYTRUSEK',TO_DATE('2011-07-13', 'yyyy-mm-dd'),'PODEBRAL PODEBRANE JAJKA'),
('UCHO','SWAWOLNY DYZIO',TO_DATE('2011-07-14', 'yyyy-mm-dd'),'OBRZUCIL KAMIENIAMI')
;

-- Zatiwierdzenie transakcji
COMMIT;