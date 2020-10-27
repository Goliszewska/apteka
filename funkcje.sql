drop view zamowienia_info cascade;
drop view wszystkie_zamowienia cascade;
drop view sprzedaz_lekow_refundowanych cascade;
drop view sprzedaz_lekow_nierefundowanych cascade;
drop function dodaj_dostawca cascade;
drop function dodaj_odbiorca cascade;
drop function dodaj_pracownika cascade;
drop function dodaj_produkt cascade;
drop function dodaj_zamowienie_do_dostawcy cascade;
drop function nazwa_id_produktu cascade;
drop function przyjmowanie_towaru_magazyn cascade;
drop function sprawdz_ile_sztuk_w_magazynie cascade;
drop function rozliczanie_dostawca cascade;

--widok zamowienia_info
--pokazuje informacje o sprzedanym produkcie i kliencie
CREATE VIEW zamowienia_info AS SELECT z.id_apteka, z.id_zamowienia, p.id_produktu, p.nazwa AS nazwa_leku,p.czy_refundowane,p.procent_refundacji, p.producent, p.postac, p.ilosc_w_opakowaniu, p.cena, zp.ilosc, o.imie, o.nazwisko,o.adres,o.nr_telefonu,o.czy_staly, o.pesel, z.data_sprzedazy, o.NIP FROM zamowienie z, zamowienie_produkt zp, produkt p, odbiorca o WHERE o.id_odbiorca=z.id_odbiorca AND z.id_zamowienia=zp.id_zamowienia AND zp.id_produktu=p.id_produktu;
--wypisuje zamowienia z wybranej apteki
CREATE OR REPLACE FUNCTION wypisz_zamowienia(integer) RETURNS setof zamowienia_info AS '
	SELECT * from zamowienia_info WHERE id_apteka=$1;
' LANGUAGE sql;
--podobnie jak poprzednio widok pokazuje informacje o zamówieniu, jednak zawarte sa w nim informacje o zamowieniach, 
--o których nie mamy danych o kliencie

CREATE VIEW wszystkie_zamowienia AS SELECT z.id_apteka,
    z.id_zamowienia,
    p.nazwa AS nazwa_leku,
    p.producent,
    p.postac,
    p.ilosc_w_opakowaniu,
    p.cena,
    zp.ilosc,
    o.imie,
    o.nazwisko,
    o.pesel,
    o.nr_telefonu,
    z.data_sprzedazy
   FROM zamowienie_produkt zp,
    produkt p,
    zamowienie z
     FULL JOIN Odbiorca o ON o.id_odbiorca = z.id_odbiorca
  WHERE z.id_zamowienia = zp.id_zamowienia AND zp.id_produktu = p.id_produktu;

--wypisuje wszystkie zamowienia, niekoniecznie powiązane z klientem
CREATE OR REPLACE FUNCTION wypisz_wszystkie_zamowienia(integer) RETURNS setof wszystkie_zamowienia AS '
	SELECT * from wszystkie_zamowienia WHERE id_apteka=$1;
' LANGUAGE sql;


--a)rozliczanie sie z dostawcami oraz NFZ(recepty refundowane)
--skladanie zamowien na leki do dostawcow
CREATE OR REPLACE FUNCTION dodaj_zamowienie_do_dostawcy(integer,integer,integer) RETURNS void AS'
DECLARE
nowy_produkt ALIAS FOR $1;
nowa_ilosc ALIAS FOR $2;
nowy_dostawca ALIAS FOR $3;
BEGIN
INSERT INTO zamowienie_produkt VALUES(DEFAULT,nowy_produkt,nowa_ilosc,nowy_dostawca);
RETURN;
END;
' LANGUAGE plpgsql;

--przyjmowanie towaru( na podstawie zamowien)
  --wyświetlenie nazwy, id i innych informacji o produkcie
CREATE OR REPLACE FUNCTION nazwa_id_produktu(varchar) RETURNS setof Produkt AS '
	SELECT * from Produkt WHERE nazwa=$1;
' LANGUAGE sql;

   --dodanie produktu
CREATE OR REPLACE FUNCTION dodaj_produkt(varchar,integer,double precision,varchar,varchar,boolean,boolean) RETURNS void AS'
DECLARE
nowa_nazwa ALIAS FOR $1;
nowa_ilop ALIAS FOR $2;
nowa_cena ALIAS FOR $3;
nowa_pos ALIAS FOR $4;
nowy_prod ALIAS FOR $5;
nowy_czyref ALIAS FOR $6;
nowy_czynarec ALIAS FOR $7;
BEGIN
INSERT INTO Produkt VALUES(DEFAULT,nowa_nazwa,nowa_ilop,nowa_cena,nowa_pos,nowy_prod, nowy_czyref,nowy_czynarec);
RETURN;
END;
' LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION przyjmowanie_towaru_magazyn(integer,integer,integer) RETURNS void AS'
DECLARE
jaka_apteka ALIAS FOR $1;
jaki_id_produktu ALIAS FOR $2;
ile ALIAS FOR $3;
BEGIN
UPDATE Magazyn SET ilosc=ilosc+ile WHERE id_produktu=jaki_id_produktu AND jaka_apteka=id_a;
RETURN;
END;
'LANGUAGE plpgsql;

--rejestrowanie sprzedazy lekow refundowanych w celu rozliczenia z NFZ

CREATE VIEW sprzedaz_lekow_refundowanych AS 
SELECT id_produktu, data_sprzedazy, ilosc, cena, czy_refundowane, procent_refundacji
FROM zamowienia_info zi WHERE czy_refundowane=TRUE;

--i podobnie jak wyzej rejestrowanie sprzedazy lekow nierefundowanych
CREATE VIEW sprzedaz_lekow_nierefundowanych AS 
SELECT id_produktu, data_sprzedazy, ilosc, cena, czy_refundowane
FROM zamowienia_info WHERE czy_refundowane=FALSE;

--rozliczanie z dostawcami, wykorzystanie funkcji nazwa_id_produktu( w celu ustalenia id produktu)
CREATE OR REPLACE FUNCTION rozliczanie_dostawca(integer,integer) RETURNS double precision AS'
DECLARE
id ALIAS FOR $1;
ilosc ALIAS FOR $2;
ile_dac double precision;
BEGIN
SELECT ilosc*cena_dostawcy INTO ile_dac  from Produkt WHERE id_produktu=id; 
RETURN ile_dac;
END;
' LANGUAGE plpgsql;

--rozliczanie się z NFZ

CREATE OR REPLACE FUNCTION rozliczanie_nfz(integer) RETURNS double precision AS'
DECLARE
id_prod ALIAS FOR $1;
ile_zwroci_nfz double precision;
c double precision;
p integer;
BEGIN
SELECT procent_refundacji INTO p FROM sprzedaz_lekow_refundowanych WHERE data_sprzedazy IS NOT NULL;
SELECT ilosc*cena INTO c FROM sprzedaz_lekow_refundowanych WHERE data_sprzedazy IS NOT NULL;
c=c-c*(p/100);
RETURN c;
END;
' LANGUAGE plpgsql;

--rozliczanie sprzedazy zmiany:
--raporty ilosciowo wartosciowe sprzedazy w ujeciu pracownika
CREATE VIEW sprzedaz_pracownik AS
SELECT s.id_produktu,s.id_pracownika, s.id_zmiana, p.cena*ilosc_sprzedana suma_sprzedazy FROM sprzedaz s, produkt p WHERE s.id_produktu=p.id_produktu;


CREATE OR REPLACE FUNCTION sprzedaz_pracownik(integer) RETURNS double precision AS'
DECLARE
id_prac ALIAS FOR $1;
s double precision;
BEGIN
SELECT SUM(suma_sprzedazy) INTO s FROM sprzedaz_pracownik WHERE id_pracownika=id_prac;
RETURN s;
END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sprzedaz_zmiana(integer) RETURNS double precision AS'
DECLARE
id_zmian ALIAS FOR $1;
s double precision;
BEGIN
SELECT SUM(suma_sprzedazy) INTO s FROM sprzedaz_pracownik WHERE id_zmiana=id_zmian;
RETURN s;
END;
' LANGUAGE plpgsql;

--monitorowanie aktualnego stanu lekow, aby moc zlozyc zamowienie w odpowiednim czasie

CREATE OR REPLACE FUNCTION sprawdz_ile_sztuk_w_magazynie(integer,integer) RETURNS integer AS '
DECLARE
id ALIAS FOR $1;
apteka ALIAS FOR $2;
ile integer;
BEGIN
SELECT ilosc INTO ile FROM Magazyn WHERE id_produktu=id AND id_apteka=apteka;
RETURN ile;
END;
' LANGUAGE plpgsql;



---c) Funkcje dodawania danych kontaktowych odbiorców, dostawców oraz pracownikow

CREATE OR REPLACE FUNCTION dodaj_odbiorca(varchar,varchar,varchar,varchar,varchar,varchar,boolean) RETURNS void AS'
DECLARE
nowe_imie ALIAS FOR $1;
nowe_nazwisko ALIAS FOR $2;
nowy_adres ALIAS FOR $3;
nowy_pesel ALIAS FOR $4;
nowy_nr_telefonu ALIAS FOR $5;
nowy_nip ALIAS FOR $6;
nowy_czy_staly ALIAS FOR $7;
BEGIN
INSERT INTO Odbiorca VALUES(DEFAULT,nowe_imie,nowe_nazwisko,nowy_adres,nowy_pesel,nowy_nr_telefonu, nowy_nip,nowy_czy_staly);
RETURN;
END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dodaj_dostawca(varchar,varchar,varchar,varchar) RETURNS void AS'
DECLARE
nowa_nazwa ALIAS FOR $1;
nowy_adres ALIAS FOR $2;
nowy_nr_telefonu ALIAS FOR $3;
nowy_NIP ALIAS FOR $4;
BEGIN
INSERT INTO Dostawca VALUES(DEFAULT,nowa_nazwa,nowy_adres,nowy_nr_telefonu,nowy_NIP);
RETURN;
END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dodaj_pracownika(varchar,varchar,varchar,integer,integer,varchar,varchar) RETURNS void AS'
DECLARE
nowe_imie ALIAS FOR $1;
nowe_nazwisko ALIAS FOR $2;
nowe_stanowisko ALIAS FOR $3;
nowy_id_apteka ALIAS FOR $4;
nowa_pensja ALIAS FOR $5;
nowy_nr_telefonu ALIAS FOR $6;
nowy_pesel ALIAS FOR $7;
BEGIN
INSERT INTO Odbiorca VALUES(DEFAULT,nowe_imie,nowe_nazwisko,nowe_stanowisko,nowy_id_apteka,nowa_pensja, nowy_nr_telefonu,nowy_pesel);
RETURN;
END;
' LANGUAGE plpgsql;

--d)wystawianie faktur dla klientow, ktorzy dokonali zakupu
CREATE VIEW faktura_klient AS
SELECT a.adres,m.nazwa miasto, a.nip ,zi.id_produktu,zi.cena, zi.cena*zi.ilosc suma_cen, zi.imie, zi.nazwisko, zi.adres adres_klienta, zi.data_sprzedazy,zi.nip nip_klienta from Miasta m,apteki a, zamowienia_info zi where a.id_miasto=m.id_miasto AND zi.id_apteka=a.id_apteka;

CREATE OR REPLACE FUNCTION wystaw_fakture_klient(varchar, timestamp)RETURNS double precision AS'
DECLARE
nip ALIAS FOR $1;
czas ALIAS FOR $2; 
s double precision;
BEGIN
SELECT SUM(suma_cen) INTO s FROM faktura_klient WHERE nip_klienta=nip AND data_sprzedazy=czas;
RETURN s;
END;
' LANGUAGE plpgsql;

--rejestrowanie i planowanie grafikow pracownikow

CREATE OR REPLACE FUNCTION dodaj_dyzur(integer,timestamp,timestamp,integer,boolean) RETURNS void AS'
DECLARE
id_a ALIAS FOR $1;
start_date ALIAS FOR $2;
end_date ALIAS FOR $3;
id_zm ALIAS FOR $4;
special ALIAS FOR $5;
BEGIN
INSERT INTO Dyzur VALUES(DEFAULT,id_a,start_date,end_date,id_zm,special);
RETURN;
END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dodaj_dyzur_pracownika(integer,integer) RETURNS void AS'
DECLARE
id_a ALIAS FOR $1;
id_prac ALIAS FOR $2;
BEGIN
INSERT INTO Dyzur VALUES(id_a,id_prac);
RETURN;
END;
' LANGUAGE plpgsql;


