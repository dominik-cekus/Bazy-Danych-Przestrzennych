--ZAD4
SELECT COUNT(*) FROM (SELECT p.* FROM popp p , majrivers mr
WHERE ST_DWithin(mr.geom,p.geom,100000) = 'true' AND p.f_codedesc LIKE 'Building'
GROUP BY p.gid) AS budynki

CREATE TABLE tableB AS  SELECT p.* FROM popp p , majrivers mr
WHERE ST_DWithin(mr.geom,p.geom,100000) = 'true' AND p.f_codedesc LIKE 'Building'
GROUP BY p.gid
--ZAD5
CREATE TABLE aiportsNew as SELECT elev,name,geom FROM airports;

(SELECT a.name,a.geom FROM aiportsNew a ORDER BY ST_X(a.geom) DESC LIMIT 1) UNION ALL
(SELECT a.name,a.geom FROM aiportsNew a ORDER BY ST_X(a.geom) ASC LIMIT 1) ;

SELECT a.name, a.geom AS EW FROM airports a WHERE ST_X(a.geom) IN (SELECT MAX(ST_X(a.geom)) FROM airports a) 
OR ST_X(a.geom) IN (SELECT MIN(ST_X(a.geom)) FROM airports a);

SELECT ST_Centroid(ST_Union(SELECT a.geom FROM airports a WHERE ST_X(a.geom) IN (SELECT MAX(ST_X(a.geom)) FROM airports a) 
OR ST_X(a.geom) IN (SELECT MIN(ST_X(a.geom)) FROM airports a) AS g)) FROM g;


INSERT INTO aiportsNew values (200,'Cekus',
(SELECT ST_Centroid(ST_Union(a.geom)) FROM airports a WHERE ST_X(a.geom) IN (SELECT MAX(ST_X(a.geom)) FROM airports a) 
OR ST_X(a.geom) IN (SELECT MIN(ST_X(a.geom)) FROM airports a)));

--ZAD6
SELECT ST_Area(ST_Buffer(ST_ShortestLine(l.geom,a.geom),1000)) FROM lakes l, airports a 
WHERE l.names LIKE 'Iliamna Lake' AND a.name LIKE 'AMBLER'

--ZAD7

SELECT SUM(temp.area_km2),temp.vegdesc FROM (
SELECT t.area_km2, tr.vegdesc FROM tundra t, trees tr WHERE ST_CONTAINS(tr.geom,t.geom) = 'true' 
 UNION ALL
SELECT s.areakm2 , tr.vegdesc FROM swamp s, trees tr WHERE ST_CONTAINS(tr.geom,s.geom) = 'true'
	) AS temp
GROUP BY temp.vegdesc

