CREATE EXTENSION postgis;

CREATE TABLE budynki(id INT UNIQUE,name VARCHAR(30),geometria GEOMETRY);
CREATE TABLE drogi(id INT UNIQUE, name VARCHAR(30),geometria GEOMETRY);
CREATE TABLE punkty_informacyjne(id INT UNIQUE, name VARCHAR(30),geometria GEOMETRY);

INSERT INTO budynki values(1,'buildingF',ST_GeomFromText('POLYGON((1 1,1 2,2 2,2 1,1 1))',0)),
(2,'buildingA',ST_GeomFromText('POLYGON((8 4,10.5 4,10.5 1.5,8 1.5, 8 4))',0)),
(3,'buildingB',ST_GeomFromText('POLYGON((4 5,4 7,6 7,6 5,4 5))',0)),
(4,'buildingC',ST_GeomFromText('POLYGON((3 6,3 8,5 8,5 6,3 6))',0)),
(5,'buildingD',ST_GeomFromText('POLYGON((9 9,10 9,10 8,9 8,9 9))',0));

INSERT INTO drogi values(1,'RoadY',ST_GeomFromText('LINESTRING(7.5 10.5,7.5 0)',0)),
(2,'RoadX',ST_GeomFromText('LINESTRING(0 4.5,12 4.5)',0));

INSERT INTO punkty_informacyjne values(1,'G',ST_GeomFromText('POINT(1 3.5)',0)),
(2,'H',ST_GeomFromText('POINT(5.5 1.5)',0)),
(3,'I',ST_GeomFromText('POINT(9.5 6)',0)),
(4,'J',ST_GeomFromText('POINT(6.5 6)',0)),
(5,'K',ST_GeomFromText('POINT(6 9.5)',0));

SELECT * FROM budynki;
SELECT * FROM drogi;
SELECT * FROM punkty_informacyjne;

--A)
SELECT SUM(ST_Length(geometria)) AS Drogi_dlugosc FROM drogi;

--B)
SELECT ST_AsText(geometria), ST_Area(geometria), ST_Perimeter(geometria) 
FROM budynki WHERE name LIKE 'buildingA'; 

--C)
SELECT name, ST_Area(geometria) AS Pole FROM budynki ORDER BY name ASC;

--D)
SELECT name, ST_Area(geometria) AS Pole FROM budynki ORDER BY Pole DESC LIMIT 2;

--E)
SELECT ST_Distance(budynki.geometria,punkty_informacyjne.geometria) FROM budynki,punkty_informacyjne WHERE budynki.name LIKE 'buildingC' AND
punkty_informacyjne.name LIKE 'G';
--RETURN 3.201

--F)
SELECT ST_Area(ST_Difference(budynki.geometria,(SELECT ST_Buffer(geometria,0.5) FROM budynki WHERE name LIKE 'buildingB')) )
FROM budynki WHERE name LIKE 'buildingC';
--RETURN 1.8049

--G)
SELECT name, ST_AsText(ST_Centroid(geometria)) AS centrum FROM budynki 
WHERE ST_Y(ST_Centroid(geometria)) > (SELECT ST_Y(ST_Centroid(geometria)) FROM drogi WHERE name LIKE 'RoadX');
--RETURN BUILDINGS B,C,D

--H)
SELECT ST_AREA(ST_SymDifference(geometria,ST_GeomFromText('POLYGON((4 7,6 7,6 8,4 8,4 7))',0))) FROM budynki 
WHERE name='buildingC';
--RETURN 4
