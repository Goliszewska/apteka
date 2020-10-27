DROP TABLE apteki CASCADE;
DROP SEQUENCE apteki_id_apteka_seq;
DROP TABLE dostawca CASCADE;
DROP SEQUENCE dostawca_id_dostawca_seq;
DROP TABLE dyzur CASCADE;
DROP SEQUENCE dyzur_id_dyzuru_apteki_seq;
DROP TABLE dyzur_pracownik CASCADE;
DROP TABLE magazyn CASCADE;
DROP TABLE miasta CASCADE;
DROP SEQUENCE miasta_id_miasto_seq_1;
DROP TABLE NFZ CASCADE;
DROP TABLE odbiorca CASCADE;
DROP SEQUENCE odbiorca_id_odbiorca_seq CASCADE;
DROP TABLE pracownicy CASCADE;
DROP SEQUENCE pracownicy_id_pracownika_seq CASCADE;
DROP TABLE produkt CASCADE;
DROP SEQUENCE produkt_id_produktu_seq CASCADE;
DROP TABLE zamowienie CASCADE;
DROP SEQUENCE zamowienie_id_zamowienia_seq CASCADE;
DROP TABLE zamowienie_produkt CASCADE;
DROP SEQUENCE sprzedaz_id_seq CASCADE;
DROP TABLE sprzedaz CASCADE;
DROP SEQUENCE zmiana_id_seq CASCADE;
DROP TABLE zmiana CASCADE;



--tworzenie tabel i sekwencji

CREATE SEQUENCE odbiorca_id_odbiorca_seq;

CREATE TABLE Odbiorca (
                id_odbiorca INTEGER NOT NULL DEFAULT nextval('odbiorca_id_odbiorca_seq'),
                imie VARCHAR NOT NULL,
                nazwisko VARCHAR NOT NULL,
                adres VARCHAR NOT NULL,
                PESEL VARCHAR CHECK(LENGTH(PESEL)=11) UNIQUE NOT NULL,
                nr_telefonu VARCHAR CHECK(LENGTH(nr_telefonu)=9),
                NIP VARCHAR CHECK(LENGTH(NIP)=10) , 
                czy_staly BOOLEAN NOT NULL,

                CONSTRAINT odbiorca_pk PRIMARY KEY (id_odbiorca)
);

ALTER SEQUENCE odbiorca_id_odbiorca_seq OWNED BY Odbiorca.id_odbiorca; --powiazanie sekwencji i kolumny

CREATE SEQUENCE produkt_id_produktu_seq;

CREATE TABLE Produkt (
                id_produktu INTEGER NOT NULL DEFAULT nextval('produkt_id_produktu_seq'),
                nazwa VARCHAR NOT NULL,
                ilosc_w_opakowaniu INTEGER NOT NULL,
                cena DOUBLE PRECISION NOT NULL,
                cena_dostawcy DOUBLE PRECISION NOT NULL,
                postac VARCHAR NOT NULL,
                producent VARCHAR NOT NULL,
                czy_refundowane BOOLEAN NOT NULL,
                procent_refundacji INTEGER NOT NULL CHECK(procent_refundacji>=0 AND procent_refundacji<=100),
                czy_na_recepte BOOLEAN NOT NULL,
                CONSTRAINT produkt_pk PRIMARY KEY (id_produktu)
);


ALTER SEQUENCE produkt_id_produktu_seq OWNED BY Produkt.id_produktu;

CREATE SEQUENCE zmiana_id_seq;

CREATE TABLE Zmiana (
                 id_zmiana INTEGER NOT NULL DEFAULT nextval('zmiana_id_seq'),
                 godzina_rozpoczecia TIME NOT NULL,
                 godzina_zakonczenia TIME NOT NULL,
                 CONSTRAINT zmiana_fk PRIMARY KEY(id_zmiana)
);

ALTER SEQUENCE zmiana_id_seq OWNED BY Zmiana.id_zmiana;




CREATE SEQUENCE sprzedaz_id_seq;

CREATE TABLE Sprzedaz(
               id_sprzedazy INTEGER NOT NULL DEFAULT nextval('sprzedaz_id_seq'), 
               id_produktu INTEGER NOT NULL,
               id_pracownika INTEGER NOT NULL,
               ilosc_sprzedana INTEGER NOT NULL,
               id_zmiana INTEGER NOT NULL,
               CONSTRAINT sprzedaz_pk PRIMARY KEY (id_sprzedazy)
);

ALTER SEQUENCE sprzedaz_id_seq OWNED BY Sprzedaz.id_sprzedazy;


CREATE SEQUENCE miasta_id_miasto_seq_1;

CREATE TABLE Miasta (
                id_miasto INTEGER NOT NULL DEFAULT nextval('miasta_id_miasto_seq_1'),
                nazwa VARCHAR NOT NULL,
                CONSTRAINT miasta_pk PRIMARY KEY (id_miasto)
);


ALTER SEQUENCE miasta_id_miasto_seq_1 OWNED BY Miasta.id_miasto;

CREATE SEQUENCE apteki_id_apteka_seq;

CREATE TABLE Apteki (
                id_apteka INTEGER NOT NULL DEFAULT nextval('apteki_id_apteka_seq'),
                adres VARCHAR NOT NULL,
                id_miasto INTEGER NOT NULL,
                nr_telefonu VARCHAR CHECK(LENGTH(nr_telefonu)=9) NOT NULL,
                przychody REAL,
                koszty REAL,
                NIP VARCHAR CHECK(LENGTH(NIP)=10) NOT NULL,
                CONSTRAINT apteki_pk PRIMARY KEY (id_apteka)
);

ALTER SEQUENCE apteki_id_apteka_seq OWNED BY Apteki.id_apteka;

CREATE SEQUENCE zamowienie_id_zamowienia_seq;

CREATE TABLE Zamowienie (
                id_zamowienia INTEGER NOT NULL DEFAULT nextval('zamowienie_id_zamowienia_seq'),
                id_odbiorca INTEGER references Odbiorca(id_odbiorca),
                id_apteka INTEGER NOT NULL,
                id_dostawca INTEGER NOT NULL,
		data_sprzedazy TIMESTAMP,
                platnosc VARCHAR,
                CONSTRAINT zamowienie_pk PRIMARY KEY (id_zamowienia)


);


ALTER SEQUENCE zamowienie_id_zamowienia_seq OWNED BY Zamowienie.id_zamowienia;

CREATE TABLE zamowienie_produkt (
                id_zamowienia INTEGER NOT NULL,
                id_produktu INTEGER NOT NULL,
                id_dostawca INTEGER NOT NULL,
                ilosc INTEGER NOT NULL,
                CONSTRAINT zamowienie_produkt_pk PRIMARY KEY (id_zamowienia, id_produktu)
);

CREATE TABLE Magazyn (
                id_apteka INTEGER NOT NULL,
                id_produktu INTEGER NOT NULL,
                ilosc INTEGER NOT NULL,
                CONSTRAINT magazyn_pk PRIMARY KEY (id_apteka, id_produktu)
);


CREATE SEQUENCE pracownicy_id_pracownika_seq;

CREATE TABLE Pracownicy (
                id_pracownika INTEGER NOT NULL DEFAULT nextval('pracownicy_id_pracownika_seq'),
                imie VARCHAR NOT NULL,
                nazwisko VARCHAR NOT NULL,
                stanowisko VARCHAR NOT NULL,
                id_apteka INTEGER NOT NULL,
                pensja INTEGER NOT NULL,
                nr_telefonu VARCHAR CHECK(LENGTH(nr_telefonu)=9) NOT NULL,
                PESEL VARCHAR CHECK(LENGTH(PESEL)=11) UNIQUE NOT NULL,
                CONSTRAINT pracownicy_pk PRIMARY KEY (id_pracownika)
);


ALTER SEQUENCE pracownicy_id_pracownika_seq OWNED BY Pracownicy.id_pracownika;

CREATE SEQUENCE dyzur_id_dyzuru_apteki_seq;


CREATE TABLE Dyzur (
                id_dyzuru_apteki INTEGER NOT NULL DEFAULT nextval('dyzur_id_dyzuru_apteki_seq'),
                id_apteka INTEGER NOT NULL,
                data_rozpoczecia TIMESTAMP NOT NULL,
                data_zakonczenia TIMESTAMP NOT NULL,
                id_zmiana INTEGER UNIQUE NOT NULL,
                czy_specjalny BOOLEAN NOT NULL,
                CONSTRAINT dyzur_pk PRIMARY KEY (id_dyzuru_apteki)
);


ALTER SEQUENCE dyzur_id_dyzuru_apteki_seq OWNED BY Dyzur.id_dyzuru_apteki;


CREATE TABLE dyzur_pracownik (
                id_dyzuru_apteki INTEGER NOT NULL,
                id_pracownika INTEGER NOT NULL,
                CONSTRAINT dyzur_pracownik_pk PRIMARY KEY (id_dyzuru_apteki, id_pracownika)
);
 
CREATE SEQUENCE dostawca_id_dostawca_seq;

CREATE TABLE Dostawca (
                id_dostawca INTEGER NOT NULL DEFAULT nextval('dostawca_id_dostawca_seq'),
                nazwa VARCHAR NOT NULL,
                adres VARCHAR NOT NULL,
                nr_telefonu VARCHAR CHECK(LENGTH(nr_telefonu)=9),
                NIP VARCHAR CHECK(LENGTH(NIP)=10), 

                CONSTRAINT dostawca_pk PRIMARY KEY (id_dostawca)
);

ALTER SEQUENCE dostawca_id_dostawca_seq OWNED BY Dostawca.id_dostawca; 



--dodawanie kluczy obcych
ALTER TABLE Sprzedaz ADD CONSTRAINT id_produktu_s_p_fk
FOREIGN KEY(id_produktu)
REFERENCES Produkt(id_produktu)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Sprzedaz ADD CONSTRAINT id_prac_s_p_fk
FOREIGN KEY(id_pracownika)
REFERENCES Pracownicy(id_pracownika)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Sprzedaz ADD CONSTRAINT id_zmiana_s_z_fk
FOREIGN KEY(id_zmiana)
REFERENCES Zmiana(id_zmiana)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Zmiana ADD CONSTRAINT zmiana_z_d_fk
FOREIGN KEY(id_zmiana)
REFERENCES Dyzur(id_zmiana)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Magazyn ADD CONSTRAINT magazyn_m_p_fk
FOREIGN KEY (id_produktu)
REFERENCES Produkt (id_produktu)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


ALTER TABLE Apteki ADD CONSTRAINT apteki_a_m_fk
FOREIGN KEY (id_miasto)
REFERENCES Miasta (id_miasto)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Pracownicy ADD CONSTRAINT pracownicy_p_a_fk
FOREIGN KEY (id_apteka)
REFERENCES Apteki (id_apteka)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Magazyn ADD CONSTRAINT magazyn_m_a_fk
FOREIGN KEY (id_apteka)
REFERENCES Apteki (id_apteka)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Zamowienie ADD CONSTRAINT zamowienie_z_a_fk
FOREIGN KEY (id_apteka)
REFERENCES Apteki (id_apteka)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE dyzur_pracownik ADD CONSTRAINT dyzur_pracownik_dp_pfk
FOREIGN KEY (id_pracownika)
REFERENCES Pracownicy (id_pracownika)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE dyzur_pracownik ADD CONSTRAINT dyzur_pracownik_dp_dfk
FOREIGN KEY (id_dyzuru_apteki)
REFERENCES Dyzur (id_dyzuru_apteki)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Zamowienie ADD CONSTRAINT id_dostawca_z_d_fk
FOREIGN KEY (id_dostawca)
REFERENCES Dostawca (id_dostawca)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE Dyzur ADD CONSTRAINT id_apteka_d_a_fk
FOREIGN KEY (id_apteka)
REFERENCES Apteki (id_apteka)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE zamowienie_produkt ADD CONSTRAINT id_zamowienia_zp_zfk
FOREIGN KEY (id_zamowienia)
REFERENCES Zamowienie (id_zamowienia)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE zamowienie_produkt ADD CONSTRAINT id_produktu_zp_pfk
FOREIGN KEY (id_produktu)
REFERENCES Produkt(id_produktu)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

