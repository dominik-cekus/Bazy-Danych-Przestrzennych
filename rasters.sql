--w konsoli CMD
raster2pgsql -s 3763 -N -32767 -t 100x100 -I -C -M -d 
D:\Dane\Geoinformatyka\Semestr5\BazyDanychPrzestrzennych\cw5\rasters\srtm_1arc_v3.tif rasters.dem > 
D:\Dane\Geoinformatyka\Semestr5\BazyDanychPrzestrzennych\cw5\dem.sql
/*
-s raster wyjsciowy o okreslonym SRID
   -N wartosc NoData do uzycia na pasmach bez wartosci NoData
   -t wytnij raster na plytki, aby wstawic po jednym w kazdym wierszu tabeli (WIDTHxHEIGHT)
   -I utworz przeglad rastra , gdy wiecej niz jeden oddziel przecinkiem
   -C 
   -M analiza prozniowa tabeli rastrowej
   -d
*/
--
create extension postgis_raster;
raster2pgsql -s 3763 -N -32767 -t 100x100 -I -C -M -d D:\Dane\Geoinformatyka\Semestr5\BazyDanychPrzestrzennych\cw5\rasters\srtm_1arc_v3.tif rasters.dem | psql -d zad5 -h localhost -U postgres -p 5432
raster2pgsql -s 3763 -N -32767 -t 128x128 -I -C -M -d D:\Dane\Geoinformatyka\Semestr5\BazyDanychPrzestrzennych\cw5\rasters\Landsat8_L1TP_RGBN.TIF rasters.landsat8 | psql -d zad5 -h localhost -U postgres -p 5432


--Przykład 1

CREATE TABLE cekus.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';
-- dodanie serial primary key
alter table cekus.intersects
add column rid SERIAL PRIMARY KEY;
--utworzenie indeksu przestrzennego
CREATE INDEX idx_intersects_rast_gist ON cekus.intersects
USING gist (ST_ConvexHull(rast));
--dodanie raster constraints
--schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('cekus'::name, 'intersects'::name,'rast'::name);

--Przykład 2
--Obcinanie rastra na podstawie wektora.
CREATE TABLE cekus.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--Połączenie wielu kafelków w jeden raster.
CREATE TABLE cekus.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--Przykład 3
CREATE TABLE cekus.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przyklad 4
DROP TABLE cekus.porto_parishes; --> drop table porto_parishes first
CREATE TABLE cekus.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przykład 5
DROP TABLE cekus.porto_parishes; --> drop table porto_parishes first
CREATE TABLE cekus.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przykład 6
create table cekus.intersection as
SELECT a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przykład 7
CREATE TABLE cekus.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przykład 8
CREATE TABLE cekus.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--Przykład 9
CREATE TABLE cekus.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przykład 10
CREATE TABLE cekus.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM cekus.paranhos_dem AS a;

--Przykład 11
CREATE TABLE cekus.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM cekus.paranhos_slope AS a;

--Przykład 12
SELECT st_summarystats(a.rast) AS stats
FROM cekus.paranhos_dem AS a;


--Przykład 13
SELECT st_summarystats(ST_Union(a.rast))
FROM cekus.paranhos_dem AS a;

--Przykład 14
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM cekus.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--Przykład 15
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--Przykład 16
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--Przykład 17
create table cekus.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON cekus.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('cekus'::name, 'tpi30'::name,'rast'::name);

--Problem do samodzielnego rozwiązania:
CREATE TABLE cekus.tpi30_porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem a, vectors.porto_parishes AS b WHERE  ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

CREATE INDEX idx_tpi30_porto_rast_gist ON cekus.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('cekus'::name, 'tpi30_porto'::name,'rast'::name);

--Przykład 18 Algebra mapy

CREATE TABLE cekus.porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON cekus.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('cekus'::name, 'porto_ndvi'::name,'rast'::name);

--Przykład 19
create or replace function cekus.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE cekus.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'cekus.ndvi(double precision[], integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON cekus.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('cekus'::name, 'porto_ndvi2'::name,'rast'::name);


--Przykład 20

SELECT ST_AsTiff(ST_Union(rast))
FROM cekus.porto_ndvi;

SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM cekus.porto_ndvi;

--Przykład 21
SELECT ST_GDALDrivers();

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM cekus.porto_ndvi;
-- eksport
SELECT lo_export(loid, 'D:\myraster.tiff') --> Save the file in a place where the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp_out;
-- 
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.

--Przykład 22 Użycie gdal
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 PG:"host=localhost port=5432 dbname=zad5 user=postgres 
password=1234 schema=cekus table=porto_ndvi mode=2" porto_ndvi.tiff



--Przykład 23
MAP
NAME 'map'
SIZE 800 650
STATUS ON
EXTENT -58968 145487 30916 206234
UNITS METERS
WEB
METADATA
'wms_title' 'Terrain wms'
'wms_srs' 'EPSG:3763 EPSG:4326 EPSG:3857'
'wms_enable_request' '*'
'wms_onlineresource' 'http://54.37.13.53/mapservices/srtm'
END
END
PROJECTION
'init=epsg:3763'
END
LAYER
NAME srtm
TYPE raster
STATUS OFF
DATA "PG:host=localhost port=5432 dbname='zad5' user='postgres' password='postgis' schema='rasters' table='dem' mode='2'"
PROCESSING "SCALE=AUTO"
PROCESSING "NODATA=-32767"
OFFSITE 0 0 0
METADATA
'wms_title' 'srtm'
END
END
END