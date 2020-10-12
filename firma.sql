CREATE SCHEMA firma;

CREATE TABLE firma.pracownicy(
	id_pracownika INT UNIQUE PRIMARY KEY,
	imie VARCHAR(20),
	nazwisko VARCHAR(30),
	adres VARCHAR (40),
	telefon VARCHAR (12)
);

CREATE ROLE ksiegowosc;
GRANT SELECT ON ALL TABLES IN SCHEMA firma To ksiegowosc;
COMMENT ON TABLE firma.pracownicy IS 'Pracownicy firmy X';

INSERT INTO firma.pracownicy values 
(1,'Anna','Mąka','Polna 42 Adamowice','475632295'),
(2,'Marek','Nowak','Grunwaldzka 2/56 Poznań','374572243'),
(3,'Andrzej','Kowalski','Macedońska 16/34 Kraków','274902371'),
(4,'Hanna','Gruszka','Grunwaldzka 2/56 Katowice','664374264'),
(5,'Łukasz','Michalczyk','Grunwaldzka 2/56 Warszawa','888745243'),
(6,'Katarzyna','Adamowicz','Nowosądecka 15/45 Kraków','676465343'),
(7,'Remigiusz','Letto','Łokietka 24/56 Kraków','112432345'),
(8,'Alina','Kamyk','Mickiewicza 34/23 Łódź','967463456'),
(9,'Anna','Furtman','Mickiewicza 23/33 Kraków','678767977'),
(10,'Hubert','Powązka','Herberta 13 Poznań','143556756');

CREATE TABLE firma.godziny
(
	id_godziny INT UNIQUE PRIMARY KEY,
	data DATE,
	liczba_godzin INT,
	id_pracownika INT UNIQUE REFERENCES  firma.pracownicy(id_pracownika)
);

INSERT INTO firma.godziny values 
(1,'2020-03-20',190,1),
(2,'2020-04-22',167,2),
(3,'2020-02-13',156,3),
(4,'2020-03-22',180,4),
(5,'2020-04-20',100,5),
(6,'2020-04-23',145,6),
(7,'2020-04-12',155,7),
(8,'2020-04-03',178,8),
(9,'2020-03-01',156,9),
(10,'2020-04-05',178,10);

CREATE TABLE firma.pensja
(
	id_pensji INT UNIQUE PRIMARY KEY,
	stanowisko VARCHAR(20),
	kwota FLOAT
);

INSERT INTO firma.pensja values 
(1,'kierownik',3500),
(2,'kierownik',4000),
(3,'dyrektor finansowy',8000),
(4,'księgowy',2500),
(5,'kierownik',5000),
(6,'główny księgowy',6500),
(7,'audytor',2900),
(8,'spec. ds. podatków',4000),
(9,'stażysta',950),
(10,'stażysta',800);

CREATE TABLE firma.premia
(
	id_premii INt UNIQUE PRIMARY KEY,
	rodzaj VARCHAR(20),
	kwota FLOAT
);

INSERT INTO firma.premia values 
(1,'kwartalna',500),
(2,'roczna',1000),
(3,'uznaniowa',300),
(4,'regulaminowa',450),
(5,'świąteczna',200),
(6,'rodzinna',500),
(7,'wakacyjna',350),
(8,'nadgodzinowa',100),
(9,'jubileuszowa',800),
(10,'motywacyjna',100);

CREATE TABLE firma.wynagrodzenie
(
	id_wynagrodzenia SERIAL UNIQUE PRIMARY KEY,
	data DATE,
	id_pracownika INT UNIQUE REFERENCES firma.pracownicy(id_pracownika),
	id_godziny INT UNIQUE,
	id_pensji INT,
	id_premii INT REFERENCES firma.premia(id_premii)
);

ALTER TABLE firma.wynagrodzenie
ADD FOREIGN KEY (id_godziny) REFERENCES firma.godziny(id_godziny);

ALTER TABLE firma.wynagrodzenie
ADD FOREIGN KEY (id_pensji) REFERENCES firma.pensja(id_pensji);

INSERT INTO firma.wynagrodzenie(data,id_pracownika,id_godziny,id_pensji,id_premii)
values ('2020-05-02',1,1,9,8),
('2020-05-04',2,2,10,1),
('2020-05-05',3,3,8,NULL),
('2020-05-03',4,4,6,NULL),
('2020-05-04',5,5,7,1),
('2020-05-03',6,6,3,7),
('2020-05-02',7,7,4,NULL),
('2020-05-04',8,8,5,2),
('2020-05-03',9,9,2,2),
('2020-05-06',10,10,1,10);