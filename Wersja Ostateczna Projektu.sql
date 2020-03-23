IF OBJECT_ID('DodajAutora') IS NOT NULL
DROP View DodajAutora

IF OBJECT_ID('DodajDostawce') IS NOT NULL
DROP View DodajDostawce

IF OBJECT_ID('DodajKlienta') IS NOT NULL
DROP View DodajKlienta

IF OBJECT_ID('DodajKsiazki') IS NOT NULL
DROP View DodajKsiazki

IF OBJECT_ID('Ranking') IS NOT NULL
DROP View Ranking

IF OBJECT_ID('KsiazkiZamowienia') IS NOT NULL
DROP TABLE KsiazkiZamowienia

IF OBJECT_ID('Zamowienia') IS NOT NULL
DROP TABLE Zamowienia

IF OBJECT_ID('autor') IS NOT NULL
DROP TABLE autor

IF OBJECT_ID('Dostawca') IS NOT NULL
DROP TABLE Dostawca

IF OBJECT_ID('Klient') IS NOT NULL
DROP TABLE Klient

IF OBJECT_ID('Firma') IS NOT NULL
DROP TABLE Firma

IF OBJECT_ID('Epoka') IS NOT NULL
DROP TABLE Epoka

IF OBJECT_ID('Ksiazki') IS NOT NULL
DROP TABLE Ksiazki

IF OBJECT_ID('Osoba') IS NOT NULL
DROP TABLE Osoba

IF OBJECT_ID('Kategoria') IS NOT NULL
DROP TABLE Kategoria

IF OBJECT_ID('Wydawnictwo') IS NOT NULL
DROP TABLE Wydawnictwo


CREATE TABLE epoka (
    id_epoka                bigint NOT NULL Primary Key,
    nazwa_epoki             VARCHAR(128) NOT NULL,
    rok_rozpoczecia_epoki   INT NOT NULL,
    rok_zakonczenia_epoki   INT NOT NULL
)

CREATE TABLE firma (
    id_firmy              bigint NOT NULL Primary Key,
    nazwa_firmy           VARCHAR(128) NOT NULL,
    miejsce_siedziby      VARCHAR(128) NOT NULL,
    rok_zalozenia_firmy   INT NOT NULL,
    nip                   VARCHAR(10) NOT NULL
)

CREATE TABLE wydawnictwo (
    id_wydawnictwa      bigint NOT NULL Primary Key,
    nazwa_wydawnictwa   VARCHAR(128) NOT NULL
)

CREATE TABLE osoba (
    id_osoba         bigint NOT NULL Primary Key,
    imie             VARCHAR(128) NOT NULL,
    nazwisko         VARCHAR(128) NOT NULL,
    plec             VARCHAR(2) NOT NULL,
    data_urodzenia   INT NOT NULL,
    pesel            VARCHAR(11)
)

CREATE TABLE autor (
    id_osoba   bigint NOT NULL Foreign Key References Osoba(ID_Osoba) Unique,
    id_epoka   bigint Foreign Key REFERENCES Epoka(ID_Epoka)
)

CREATE TABLE dostawca (
    id_osoba   bigint NOT NULL foreign Key References Osoba(ID_Osoba) Unique,
    id_firmy   bigint Foreign Key References Firma(ID_Firmy)
)

CREATE TABLE klient (
    id_osoba       bigint NOT NULL Foreign Key References Osoba(ID_Osoba) Unique,
    ulica          VARCHAR(128) NOT NULL,
    miejscowosc    VARCHAR(128) NOT NULL,
    kod_pocztowy   bigint NOT NULL
)

CREATE TABLE kategoria (
    id_kategoria      bigint NOT NULL Primary Key,
    nazwa_kategorii   VARCHAR(128) NOT NULL
)

CREATE TABLE zamowienia (
    id_zamowienia      bigint NOT NULL Primary Key,
    id_osoba           bigint NOT NULL Foreign Key References Osoba(ID_Osoba),
    data_zaplaty       DATE NOT NULL,
    rodzaj_platnosci   VARCHAR(128) NOT NULL
)

CREATE TABLE ksiazki (
    isbn                bigint NOT NULL Primary Key,
    tytul               VARCHAR(128) NOT NULL,
    id_wydawnictwa      bigint NOT NULL Foreign Key References Wydawnictwo(ID_Wydawnictwa),
    rok_wydania         SMALLINT NOT NULL,
    miejsce_wydania     VARCHAR(128) NOT NULL,
    id_kategoria        bigint NOT NULL Foreign Key References Kategoria(ID_Kategoria),
    cena                money NOT NULL,
    ilosc_w_magazynie   bigint NOT NULL
)

CREATE TABLE ksiazkizamowienia (
    id_zamowienia   bigint NOT NULL Foreign Key References Zamowienia(ID_Zamowienia),
    isbn            bigint NOT NULL Foreign Key References Ksiazki(ISBN),
    ilosc_ksiazek   bigint NOT NULL
)
Go

CREATE VIEW DodajAutora  AS 
SELECT Imie, Nazwisko, Plec, Data_Urodzenia, PESEL, Nazwa_Epoki, Rok_Rozpoczecia_Epoki, Rok_Zakonczenia_Epoki FROM Autor 
left JOIN Osoba
on Autor.ID_Osoba=Osoba.ID_Osoba
LEFT JOIN Epoka
on Autor.ID_Epoka=Epoka.ID_Epoka 
GO

CREATE VIEW DodajDostawce  AS 
SELECT Imie, Nazwisko, Plec, Data_Urodzenia, PESEL, Nazwa_Firmy, Miejsce_Siedziby, Rok_Zalozenia_Firmy FROM Dostawca
Left join Firma
on Dostawca.ID_Firmy=Firma.ID_Firmy
Left Join Osoba
on Dostawca.ID_Osoba=Osoba.ID_Osoba 
GO

CREATE VIEW DodajKlienta  AS 
SELECT Imie, Nazwisko, Plec, Data_Urodzenia, PESEL, Ulica, Miejscowosc, Kod_Pocztowy FROM Klient
Left Join Osoba
on Klient.Id_Osoba=Osoba.ID_Osoba 
GO

CREATE VIEW DodajKsiazki  AS 
SELECT ISBN, Tytul, Nazwa_Kategorii, Rok_Wydania, Miejsce_Wydania, Nazwa_Wydawnictwa, Cena, Ilosc_w_Magazynie FROM Ksiazki
Left Join Wydawnictwo
On Ksiazki.ID_Wydawnictwa=Wydawnictwo.ID_Wydawnictwa
Left Join Kategoria
On Ksiazki.ID_Kategoria=Kategoria.ID_Kategoria 
GO

CREATE VIEW Ranking  AS 
SELECT KsiazkiZamowienia.ISBN, SUM(KsiazkiZamowienia.Ilosc_Ksiazek) AS SumaZamowien FROM KsiazkiZamowienia
Left Join Ksiazki
ON KsiazkiZamowienia.ISBN=Ksiazki.ISBN
Group By KsiazkiZamowienia.ISBN 
GO

--trigger sprawdzajacy poprawnosc peselu
if Object_ID('pesel') IS NOT NULL
Drop Trigger pesel

go 

CREATE TRIGGER pesel ON osoba
FOR INSERT, UPDATE
AS
DECLARE @pesel VARCHAR(11)
SELECT @pesel=Pesel FROM Inserted
IF
( (((CAST(SUBSTRING(@pesel,1,1) AS tinyint)*9)
+(CAST(SUBSTRING(@pesel,2,1) AS BIGINT)*7)
+(CAST(SUBSTRING(@pesel,3,1) AS BIGINT)*3)
+(CAST(SUBSTRING(@pesel,4,1) AS BIGINT)*1)
+(CAST(SUBSTRING(@pesel,5,1) AS BIGINT)*9)
+(CAST(SUBSTRING(@pesel,6,1) AS BIGINT)*7)
+(CAST(SUBSTRING(@pesel,7,1) AS BIGINT)*3)
+(CAST(SUBSTRING(@pesel,8,1) AS BIGINT)*1)
+(CAST(SUBSTRING(@pesel,9,1) AS BIGINT)*9)
+(CAST(SUBSTRING(@pesel,10,1) AS BIGINT)*7))%10)=(CAST(SUBSTRING(@pesel,11,1) AS BIGINT)*1))
BEGIN
PRINT 'Wprowadzony pesel jest poprawny!'
END
ELSE
BEGIN
PRINT 'Wprowadzono niepoprawny pesel!'
ROLLBACK
END
--Insert Into Firma Values
--(1, 'Pawel', 'Rys', '1994-01-12', '6750002236') 
go 

--trigger sprawdzajacy czy ktos nie zamawia ksiazek wiecej niz jest w magazynie
CREATE TRIGGER IloscKsiazekWMagazynie ON ksiazkizamowienia
for insert, update
as
declare @il bigint
declare @isbn varchar(128)
select @il=ilosc_ksiazek from inserted
select @isbn=isbn From inserted
if(@il>(SELECT Ilosc_w_magazynie From Ksiazki where Ksiazki.ISBN=@isbn))
begin
rollback
end
GO

--trigger sprawdzajacy czy epoka wedlug wstawianego rekordu nie zakonczyla sie szybciej niz rozpoczela wedlug atrybutow
CREATE TRIGGER PoprawnyRok ON EPOKA
FOR INSERT, Update
AS
Declare @RRE INT
Declare @RZE INT
SELECT @RRE=Rok_Rozpoczecia_epoki From Inserted
SELECT @RZE=Rok_Zakonczenia_epoki From Inserted
If(@RZE<@RRE)
BEGIN
ROLLBACK
END
Go

--trigger sprawdzajacy czy ktos nie zamowil 0 ksiazek
CREATE TRIGGER NiezerowaIlosc ON ksiazkizamowienia 
FOR INSERT, UPDATE
AS
declare @il bigint
select @il=ilosc_ksiazek from inserted
if(@il=0) Or (@il<0)
begin rollback
end
GO

if Object_ID('nip') IS NOT NULL
Drop Trigger nip
GO

--trigger sprawdzajacy poprawnosc nip
CREATE TRIGGER nip ON Firma
FOR INSERT, UPDATE
AS
DECLARE @nip VARCHAR(11)
SELECT @nip=nip FROM Inserted
IF
( (((CAST(SUBSTRING(@nip,1,1) AS tinyint)*6)
+(CAST(SUBSTRING(@nip,2,1) AS BIGINT)*5)
+(CAST(SUBSTRING(@nip,3,1) AS BIGINT)*7)
+(CAST(SUBSTRING(@nip,4,1) AS BIGINT)*2)
+(CAST(SUBSTRING(@nip,5,1) AS BIGINT)*3)
+(CAST(SUBSTRING(@nip,6,1) AS BIGINT)*4)
+(CAST(SUBSTRING(@nip,7,1) AS BIGINT)*5)
+(CAST(SUBSTRING(@nip,8,1) AS BIGINT)*6)
+(CAST(SUBSTRING(@nip,9,1) AS BIGINT)*7))%11
=(CAST(SUBSTRING(@nip,10,1) AS BIGINT))))
BEGIN
PRINT 'Wprowadzony nip jest poprawny!'
END
ELSE
BEGIN
PRINT 'Wprowadzono niepoprawny nip!'
ROLLBACK
END
GO

IF OBJECT_ID('DodajKategorie') IS NOT NULL
DROP PROCEDURE DodajKategorie
GO

IF OBJECT_ID('UsunWydawnictwo') IS NOT NULL
DROP PROCEDURE UsunWydawnictwo
GO

IF OBJECT_ID('WiekEpoki') IS NOT NULL
DROP PROCEDURE WiekEpoki
GO

IF OBJECT_ID('Wiek') IS NOT NULL
DROP PROCEDURE Wiek
GO

IF OBJECT_ID('Starsze') IS NOT NULL
DROP PROCEDURE Starsze
GO

--Dodanie kategorii o danym id i danej nazwie
CREATE PROCEDURE DodajKategorie (@ID bigint, @nazwa varchar(128))
AS BEGIN
	Insert Into kategoria Values(@ID, @nazwa)
END
GO

--Usuniecie wydawnictwa o danej nazwie
CREATE PROCEDURE UsunWydawnictwo (@nazwa varchar(128))
AS BEGIN
	Delete wydawnictwo where wydawnictwo.nazwa_wydawnictwa = @nazwa
END
GO 

--Obliczenie ile trwala epoka o podanym ID
CREATE PROCEDURE WiekEpoki (@ID_EPOKA bigint)
AS BEGIN
	DECLARE @RRE INT =(SELECT Rok_Rozpoczecia_Epoki FROM Epoka where Epoka.id_epoka=@ID_EPOKA)
	DECLARE @RZE INT =(SELECT Rok_Zakonczenia_Epoki FROM Epoka where Epoka.id_epoka=@ID_EPOKA)
	DECLARE @CMD INT = (ABS(@RZE-@RRE))
	Print @CMD
END
GO

--Wypisuje wszystkie epoki, ktore trwaly podana ilosc lat
CREATE PROCEDURE Wiek (@WIEK bigint)
AS BEGIN
	SELECT * FROM EPOKA
	WHERE @WIEK=ABS(Epoka.rok_zakonczenia_epoki-Epoka.rok_zakonczenia_epoki)
END
GO
--EXEC WIEK @WIEK=150

--Sprawcza czy osoba o danym id jest starsza od firmy o danym id
CREATE PROCEDURE Starsze(@IDFIRMA bigint, @IDOSOBA Bigint)
AS BEGIN
	DECLARE @DATAUR INT = (SELECT Data_Urodzenia FROM Osoba Where Osoba.id_osoba=@IDOSOBA)
	DECLARE @DATAZAL INT = (SELECT Rok_Zalozenia_Firmy FROM Firma Where Firma.id_firmy=@IDFIRMA)
	IF(@DATAUR>@DATAZAL)
	PRINT 'Osoba o danym ID jest mlodsza od Firmy o danym ID'
	ELSE
	PRINT 'Osoba o danym ID jest starsza od Firmy o danym ID'
END
GO

IF OBJECT_ID('LiczbaDostawcow') IS NOT NULL
DROP FUNCTION LiczbaDostawcow
GO

IF OBJECT_ID('LiczbaAutorow') IS NOT NULL
DROP FUNCTION LiczbaAutorow
GO

IF OBJECT_ID('LiczbaCzytelnikow') IS NOT NULL
DROP FUNCTION LiczbaCzytelnikow
GO

IF OBJECT_ID('WiekEpoki2') IS NOT NULL
DROP FUNCTION WiekEpoki2
GO

IF OBJECT_ID('IloscKsiazek') IS NOT NULL
DROP FUNCTION IloscKsiazek
GO

--funkcja zliczajaca ilosc dostawcow w firmie
CREATE FUNCTION LiczbaDostawcow (@IDFIRMY BIGINT)
RETURNS INT
AS
BEGIN
	DECLARE @ZM INT = (SELECT COUNT(*) FROM Dostawca Where dostawca.id_firmy=@IDFIRMY)
	Return @ZM
END
GO

--funkcja zliczajaca ilosc autorow w epoce
CREATE FUNCTION LiczbaAutorow (@IDEPOKI BIGINT)
RETURNS INT
AS
BEGIN
	DECLARE @ZM INT = (SELECT COUNT(*) FROM Autor Where Autor.id_epoka=@IDEPOKI)
	Return @ZM
END
GO

--funkcja zwracajaca ile osob czyta dana ksiazke
CREATE FUNCTION LiczbaCzytelnikow (@ISBN BIGINT)
RETURNS INT
AS
BEGIN
	DECLARE @ZM INT = (SELECT COUNT(*) FROM Osoba O JOIN
	zamowienia z on o.id_osoba = z.id_osoba join
	ksiazkizamowienia k on z.id_zamowienia=k.id_zamowienia 
	where k.isbn=@ISBN)
	Return @ZM
END
GO

--Funkcja zwracaj¹ca ile trwala dana epoko
CREATE FUNCTION WiekEpoki2 (@ID BIGINT)
RETURNS INT
AS
BEGIN
	DECLARE @RRE INT =(SELECT Rok_Rozpoczecia_Epoki FROM Epoka where Epoka.id_epoka=@ID)
	DECLARE @RZE INT =(SELECT Rok_Zakonczenia_Epoki FROM Epoka where Epoka.id_epoka=@ID)
	DECLARE @CMD INT = (ABS(@RZE-@RRE))
    RETURN @CMD             
END
GO

--Funkcja zwracajaca ile jest ksiazek z jednej kategorii
CREATE FUNCTION IloscKsiazek (@NAZWAKATEGORII VARCHAR(128))
RETURNS INT
AS 
BEGIN
	DECLARE @ZM INT =(SELECT COUNT(*) FROM ksiazki ks JOIN
	kategoria ka on ks.id_kategoria=ka.id_kategoria 
	where ka.nazwa_kategorii=@NAZWAKATEGORII)
	RETURN @ZM
END
GO 

INSERT INTO wydawnictwo values
(1, 'OPOKA')
delete from kategoria where kategoria.id_kategoria = 1

INSERT INTO kategoria values
(1, 'POWIESC')

INSERT INTO OSOBA VALUES
(1, 'Pawel', 'Rys', 'M', 1999, '99010104419')

INSERT INTO KLIENT VALUES
(1, 'Zielona', 'Krakow', 95910)

INSERT INTO Zamowienia VALUES
(1, 1, '2018-01-01', 'karta')

INSERT INTO KSIAZKI VALUES
(123, 'Pan Tadeusz', 1, 1999, 'Warszawa', 1, 20, 100)

INSERT INTO ksiazkizamowienia VALUES
(1, 123, 15)
SeLECT * FROM ksiazkizamowienia