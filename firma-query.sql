-- ZADANIE 6
-- A)
SELECT id_pracownika,nazwisko FROM firma.pracownicy;
--B)
SELECT nazwisko,kwota FROM
firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn ON prac.id_pracownika = wyn.id_pracownika JOIN
firma.pensja AS pen ON wyn.id_pensji = pen.id_pensji WHERE kwota >1000;
--C)
SELECT nazwisko,prem.kwota AS premia,pen.kwota AS pensja FROM
firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn ON prac.id_pracownika = wyn.id_pracownika JOIN
firma.pensja AS pen ON wyn.id_pensji = pen.id_pensji JOIN firma.premia AS prem ON wyn.id_premii = prem.id_premii
WHERE pen.kwota >2000 AND prem.kwota IS NOT NULL ;
--D)
SELECT imie,nazwisko FROM firma.pracownicy WHERE imie LIKE 'A%';
--E)
SELECT imie,nazwisko FROM firma.pracownicy WHERE imie LIKE '%a' AND nazwisko LIKE '%n%';
--F)
SELECT imie,nazwisko,(liczba_godzin - 160) AS nadgodziny FROM firma.pracownicy AS prac JOIN firma.godziny AS godz ON
(prac.id_pracownika =  godz.id_pracownika) WHERE liczba_godzin >160;
--G)
SELECT imie,nazwisko,kwota FROM firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn ON (prac.id_pracownika = wyn.id_pracownika) JOIN
firma.pensja AS pen ON (pen.id_pensji = wyn.id_pensji) WHERE kwota BETWEEN 1500 AND 3000;
--H)
SELECT imie,nazwisko, (liczba_godzin - 160) AS nadgodziny ,id_premii FROM firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn 
ON (prac.id_pracownika = wyn.id_pracownika) JOIN firma.godziny AS godz ON (godz.id_pracownika = prac.id_pracownika) 
WHERE liczba_godzin >160 AND id_premii IS NULL;
-- ZADANIE 7
--A)
SELECT imie,nazwisko,kwota FROM firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn ON prac.id_pracownika = wyn.id_pracownika 
JOIN firma.pensja AS pen ON wyn.id_pensji = pen.id_pensji ORDER BY kwota ASC;
--B)
SELECT imie,nazwisko,pen.kwota AS pensja,prem.kwota AS premia FROM firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn ON prac.id_pracownika = wyn.id_pracownika 
JOIN firma.pensja AS pen ON wyn.id_pensji = pen.id_pensji JOIN firma.premia AS prem ON (prem.id_premii = wyn.id_premii) 
ORDER BY (prem.kwota ,pen.kwota) DESC;
--C)
SELECT stanowisko,COUNT(stanowisko) AS liczebność FROM firma.pensja GROUP BY stanowisko;
--D)
SELECT stanowisko, MAX(kwota) AS maksimum, AVG(kwota) AS średnia, MIN(kwota) AS minimum FROM firma.pensja AS pen
GROUP BY stanowisko HAVING stanowisko LIKE 'kierownik';
--E)
SELECT SUM(kwota) FROM firma.pensja;
--F)
SELECT stanowisko,SUM(kwota) FROM firma.pensja GROUP BY stanowisko;
--G)
SELECT stanowisko, COUNT(prem.id_premii) FROM firma.wynagrodzenie AS wyn  JOIN firma.pensja AS pen ON ( wyn.id_pensji = pen.id_pensji) JOIN firma.premia AS prem
ON (wyn.id_premii = prem.id_premii) GROUP BY stanowisko;
--F)
DELETE FROM firma.wynagrodzenie AS wyn USING firma.pensja AS pen WHERE pen.kwota < 1200 AND wyn.id_pensji = pen.id_pensji;
--ZADANIE 8
--A)
UPDATE firma.pracownicy AS prac SET telefon='+48' || prac.telefon;
SELECT * FROM firma.pracownicy;
--B)
UPDATE firma.pracownicy AS prac SET telefon = SUBSTRING(prac.telefon,1,3) || '-' ||
SUBSTRING(prac.telefon,3,3) || '-' ||
SUBSTRING(prac.telefon,6,3) ;
SELECT * FROM firma.pracownicy;
--C)
SELECT UPPER(imie),UPPER(nazwisko),LENGTH(imie) FROM firma.pracownicy ORDER BY LENGTH(imie) DESC LIMIT 1;
--D)
SELECT prac.id_pracownika,MD5(prac.imie), MD5(prac.nazwisko) ,MD5(CAST(pen.kwota AS VARCHAR)) AS kwota FROM firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn 
ON (prac.id_pracownika = wyn.id_pracownika) JOIN firma.pensja AS pen ON (pen.id_pensji = wyn.id_pensji);
--ZADANIE 9

SELECT CONCAT('Pracownik ' || prac.imie || ' ' || prac.nazwisko || ' w dniu ' || CURRENT_DATE || ' otrzymał pensję na kwotę ' ||
			 pen.kwota + prem.kwota || ' gdzie wynagrodzenie zasadnicze wynosiło ' || pen.kwota || ' a premia ' || prem.kwota)AS messages FROM
			 firma.pracownicy AS prac JOIN firma.wynagrodzenie AS wyn ON prac.id_pracownika = wyn.id_pracownika JOIN
			 firma.pensja AS pen ON wyn.id_pensji = pen.id_pensji JOIN firma.premia AS prem ON wyn.id_premii = prem.id_premii;



