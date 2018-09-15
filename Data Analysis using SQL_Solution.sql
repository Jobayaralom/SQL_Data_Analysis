                                                 Jobayar Alom
                                            Data Analysis using SQL
                                              The noaacdo database

/* 1. Write a query to list how many stations are found in each location. Output should list 
the location name and the station count, and the columns should have the headers 'Location' 
and '# Stations'. Only report locations with 100 or more stations, and list locations with the most stations first.*/

SELECT l.name AS 'Location', count(DISTINCT sl.staid) AS '# Station'
FROM stationbylocation sl JOIN location l ON sl.locid = l.locationid
GROUP BY 1 HAVING count(sl.staid) >= 100 ORDER BY 2 DESC;

/*
2. Write a query to list location name, the minimum elevation of its stations, the maximum elevation of its stations, 
and the average elevation of its stations. Include only those locations with 100 or more stations, and round the average elevation 
to just 1 decimal place. Locations with the highest average elevation should be listed first.*/

SELECT l.name AS 'Location', MIN(s.elevation) AS 'Min. Elevation',
MAX(s.elevation) AS 'Max. Elevation', ROUND(AVG(s.elevation),1) AS 'Avg. Elevation'
FROM stationbylocation sl JOIN location l ON sl.locid = l.locationid
JOIN station s ON  sl.staid = s.stationid
GROUP BY 1 HAVING count(sl.staid) >= 100 ORDER BY 4 DESC;

/*
3.Write a query to list the location category name, the location name, the station name, and elevation of the locations
 that include the one station in the entire database that has the highest elevation. Your column headers should 
 be “Category”, “Location”, “Station”, and “Elevation”. HINT: the station and elevation will be the same for all five rows of your output.
*/
SELECT lc.name 'Category', l.name 'Location Name', s.name 'Station Name',s.elevation 'Elevation'
FROM location l JOIN locationbycategory lbc ON l.locationid = lbc.locid 
JOIN locationcategory lc ON lbc.catid = lc.lcid 
JOIN stationbylocation sbl ON l.locationid = sbl.locid
JOIN station s ON sbl.staid = s.stationid 
WHERE s.elevation = (SELECT max(elevation) FROM station)  order by 4 desc ;

/*
4.A. Write a query to report station elevation, absolute value of the latitude, and average of the mean daily temperature
 measured at the station. Restrict you query to the year 2008 and later. Order by elevation, and limit the query to just 50 
 results. NOTE: The “mean daily temperature” at a station should be calculated as (tmin + tmax)/2. Do not use TObs, as
 it is reported only by a small subset of the stations.*/
 
 SELECT s.name'Station',ABS(s.latitude), s.elevation 'Elevation', Round(AveTemp,2) 'Temp'
FROM station s JOIN (SELECT stationid, AVG((tmin + tmax)/2) AS AveTemp FROM 
tminmax WHERE Year >=2008 GROUP BY stationid LIMIT 50) TEMP USING (stationid);   



-- B  1)average over 50 highest elevation
select AVG(s50.elevation),AVG(s50.lat), AVG((temp.tmin + temp.tmax)/2) 
FROM tminmax temp RIGHT JOIN (SELECT stationid, elevation, abs(latitude) lat 
FROM station ORDER BY elevation DESC LIMIT 50) s50
USING (stationid) WHERE year >=2008; 
-- 	  2)average over 50 lowest elevation
select AVG(s50.elevation),AVG(ABS(s50.latitude)), AVG((temp.tmin + temp.tmax)/2) 
FROM tminmax temp RIGHT JOIN (SELECT stationid, elevation, latitude 
FROM station ORDER BY elevation LIMIT 50) s50
USING (stationid) WHERE year >=2008;
--    3)average over 50 lowest latitude
SELECT AVG(s50.elevation), AVG(s50.lat), AVG((temp.tmin + temp.tmax)/2) 'AveTemp' 
FROM tminmax temp RIGHT JOIN (SELECT stationid, elevation, abs(latitude) lat 
FROM station ORDER BY 3 LIMIT 50) s50 
USING (stationid) WHERE year >=2008;

-- 	  4)average over 50 highest latitude
SELECT AVG(s50.elevation), AVG(s50.lat), AVG((temp.tmin + temp.tmax)/2) 'AveTemp' 
FROM tminmax temp RIGHT JOIN (SELECT stationid, elevation, abs(latitude) 'lat' 
FROM station ORDER BY 3 DESC LIMIT 50) s50 
USING (stationid) WHERE year >=2008;
--/////////////////////////////////////////////////////////////////////////----------
Station_Category       Average_Elevation     Average_Latitude     Average_Temptemperature

High Elevation                4447                  34.40                    3.60       

Low Elevation                  -31                  37.70                    19.9      
   
Low Latitutes                  381                  0.02                     25.9       

High Latitudes                  26                  80.05                   -13.5       
--/////////////////////////////////////////////////////////////////////////----------

/*4.C. Do the results suggest that the hypothesis has merit? Suggest how you might 
be able to quantify the variation in temperature with latitude.*/
/*he result suggest the hypothesis has merit, we may quantify the relationship of latitude a
	nd temperature by select the latitude and average temperture group by each station and 
    calculate the change of average temperture as latitude change. ;/


/*5.A. Write a query to return the number of stations for which the station's maxdate's year is less than the 
maximum year in tminmax for that station.  Use only those entries in tminmax where year >= 2000.
*/
-- Take long time quire to run, more than 6000 second .
 SELECT count(s.stationid) 
FROM (SELECT stationid, max(year) 'maxyear' from tminmax WHERE year >= 2000 GROUP BY stationid)
  T1 JOIN station s USING(stationid) WHERE year(s.maxdate) <  T1.maxyear;
 
/*5.B. Write a query to return the count of locations for which the location's maxdate's year is less than the 
maximum year for any station in that location.  Again, use only those entries in tminmax where year >= 2000.*/
-- Take long time quire to run, more than 6000 second .
SELECT count(*)
FROM location l JOIN (SELECT sbl.locid 'locationid', MAX(T1.maxyear) 'MaxYearInLocation' FROM stationbylocation sbl JOIN  
(SELECT stationid, max(year) 'maxyear' from tminmax WHERE year >= 2000 GROUP BY 1) T1
ON sbl.staid = T1.stationid GROUP BY sbl.locid) TempmaxyearBylocation ON l.locationid
=TempmaxyearBylocation.locationid WHERE year(l.maxdate) < TempmaxyearBylocation.MaxYearInLocation;

-- 6.A. Write a query to estimate both Tmeanand A.
SELECT AVG((yearmax)-(yearmin))/2 'Amplitude',avg(yearmax) - AVG((yearmax)-(yearmin))/2 + 273  'Tmean'
from(SELECT (MAX(tmax)) 'yearmax' , MIN(tmin) 'yearmin' from tminmax 
where stationid = 1115 GROUP BY YEAR) t1 ;

/*
6.B. Estimating φ requires two steps:
1. Write a query to report the mean daily temperature averaged over the years 2008 to present.
*/

SELECT AVG((tmin + tmax)/2) AS meanDailyTemp FROM 
tminmax WHERE Year >=2008 AND stationid = 1115;

