-- Here we will be applying some discriptive analysist to the data

-- Average annual ride duration in minutes for all users is 11 min*

SELECT
   ROUND(AVG(trip_duration_minutes), 0) 
   AS avg_trip_min
FROM 
   dbo.bike_data

--Max annual ride duration in minutes for all users is 59 min*

SELECT
   ROUND(MAX(trip_duration_minutes), 0) 
   AS max_trip_min
FROM 
   dbo.bike_data

-- Our search here is to determine which day of the week has the most riders*
-- The day with the most rides annually is 5(Thursday)*

SELECT TOP 1
   day_of_week
FROM 
   dbo.bike_data
GROUP BY
   day_of_week
ORDER BY
   COUNT(*) DESC

--Here will we determine how many rides take place on every day of the week*
--Thrusday has the most rides and Sunday has the least amount of rides 
SELECT 
    day_of_week, 
	COUNT(*) AS total_rides
FROM
    dbo.bike_data
GROUP BY
    day_of_week
ORDER BY
    total_rides


-- Which months have the most distinct riders*
-- The month of August has the most riders where as january has the least amount of riders*
SELECT TOP 12
    FORMAT(start_date, 'yyyy-MM') AS month_year,
    COUNT(DISTINCT ride_id) AS riders_count
FROM 
    dbo.bike_data
GROUP BY
    FORMAT(start_date, 'yyyy-MM')
ORDER BY
    riders_count DESC

-- total number of riders for the entire year of 2023
-- total number of riders 768,246*
SELECT 
    YEAR(start_date) AS ride_year,
    COUNT(DISTINCT ride_id) AS total_riders
FROM 
    dbo.bike_data
GROUP BY
    YEAR(start_date)

-- Total distinct trip duration for the year 
-- there are 1170*
SELECT 
    SUM(DISTINCT trip_duration_minutes) AS total_distinct_trip_duration
FROM 
    dbo.bike_data
WHERE
    YEAR(start_date) = 2023


-- Which season between Winter,Spring, Summer, and Fall have to most riders
-- Summer has the most distinct riders where as Winter has the least amount of riders*
SELECT 
    CASE 
        WHEN MONTH(start_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(start_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(start_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(start_date) IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'  -- Handle any unexpected months
    END AS season,
    COUNT(DISTINCT ride_id) AS riders_count
FROM 
    dbo.bike_data
GROUP BY
    CASE 
        WHEN MONTH(start_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(start_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(start_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(start_date) IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'
    END


-- Calculate the average and maximum trip duration for each season*
SELECT 
    CASE 
        WHEN MONTH(start_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(start_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(start_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(start_date) IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'  -- Handle any unexpected months
    END AS season,
    ROUND(AVG(trip_duration_minutes),0) AS avg_trip_duration,
    ROUND(MAX(trip_duration_minutes),0) AS max_trip_duration
FROM 
    dbo.bike_data
GROUP BY
    CASE 
        WHEN MONTH(start_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(start_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(start_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(start_date) IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'
    END
ORDER BY
    season

-- Now lets see what bike is the most popular 
-- Classic bike are the most used bike, docked bikes are the least used bike*
SELECT rideable_type, 
    COUNT(*) AS total_rides 
FROM
    dbo.bike_data
GROUP BY 
    rideable_type
ORDER BY 
    total_rides

--ride count for casual member each month 
-- the casual riders seem to match the same pattern as the total rides for all data 
-- with the months december-march being the times where bikes are used less
-- July and August have the highest bike usage*

SELECT 
    YEAR(start_date) AS ride_year,
    DATENAME(MONTH, start_date) AS ride_month,
    COUNT(*) AS casual_rides_count
FROM 
    dbo.bike_data
WHERE
    member_casual = 'casual'
GROUP BY
    YEAR(start_date), DATENAME(MONTH, start_date)
ORDER BY
    ride_year, MIN(DATEPART(MONTH, start_date))

-- Now lets do the same for member riders 
-- The member riders also matches the same tred with the december- march being the time where bikes are used least 
-- although the main difference between casuals and members is member riders are more consistant throughout the year
-- casuals have a greater peek and a steeper drop off than members*

SELECT 
    YEAR(start_date) AS ride_year,
    DATENAME(MONTH, start_date) AS ride_month,
    COUNT(*) AS member_rides_count
FROM 
    dbo.bike_data
WHERE
    member_casual = 'member'
GROUP BY
    YEAR(start_date), DATENAME(MONTH, start_date)
ORDER BY
    ride_year, MIN(DATEPART(MONTH, start_date))

-- Lets check to see which bike is mostly used by each user type 
-- both casual and member riders favor the classic bike the most and docked bikes the least
-- you will notice that no data is showen for docked bikes by member riders
-- there are 0 instances where docked bikes are used by member riders*

SELECT 
    rideable_type, 
    member_casual,
    COUNT(*) AS total_rides,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY member_casual) AS percentage 
FROM 
    dbo.bike_data
GROUP BY 
    rideable_type, member_casual
ORDER BY 
    rideable_type


--lets single out peak days for both casual and member riders 
-- using the SUM function i was able to calculate the peak usage for each user type
-- per day*

SELECT 
    DATENAME(WEEKDAY, DATEADD(DAY, day_of_week - 1, '19000101')) AS day_of_week,
    SUM(casual_users) AS peak_casual_users,
    SUM(member_users) AS peak_member_users
FROM (
    SELECT 
        COUNT(*) AS casual_users,
        0 AS member_users,
        day_of_week
    FROM dbo.bike_data
    WHERE member_casual = 'casual'
    GROUP BY day_of_week

    UNION ALL

    SELECT 
        0 AS casual_users,
        COUNT(*) AS member_users,
        day_of_week
    FROM dbo.bike_data
    WHERE member_casual = 'member'
    GROUP BY day_of_week
) AS subquery
GROUP BY day_of_week;


