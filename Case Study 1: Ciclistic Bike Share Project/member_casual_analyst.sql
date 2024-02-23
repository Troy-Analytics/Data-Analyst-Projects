-- Now lets explore casual vs member riders 
-- Average trip duration fo casual riders is 13 minutes where as member riders average ride time is 10 minutes

SELECT member_casual,
   ROUND(AVG(trip_duration_minutes), 0) 
   AS avg_trip_min
FROM 
   dbo.bike_data
GROUP BY
   member_casual

-- Max of total rides by user*
-- There are more member rider than casual riders annually*
SELECT member_casual,
   COUNT(*) 
   AS total_trips
FROM 
   dbo.bike_data
GROUP BY
   member_casual

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
-- member riders top days are durring the week
-- casual riders top days are durring the weekend monday being the onky exception*
SELECT 
    day_of_week,
    MAX(CASE WHEN member_casual = 'casual' THEN ride_count END) AS casual_users,
    MAX(CASE WHEN member_casual = 'member' THEN ride_count END) AS member_users
FROM (
    SELECT 
        DATENAME(WEEKDAY, DATEADD(DAY, day_of_week - 1, '19000101')) AS day_of_week,
        COUNT(*) AS ride_count,
        member_casual
    FROM dbo.bike_data
    GROUP BY day_of_week, member_casual
) AS DayOfWeekCounts
GROUP BY day_of_week
ORDER BY day_of_week;

-- Peak hours for member riders 
-- the most common time for member to rider bikes are between 3pm-8pm

SELECT 
    FORMAT(started_at, 'hh tt') AS formatted_hour,
    member_casual,
    COUNT(*) AS total_rides 
FROM dbo.bike_data
WHERE member_casual IN ('member')
GROUP BY FORMAT(started_at, 'hh tt'), member_casual
ORDER BY total_rides DESC;

-- most commom time for casual riders is 3pm-6pm 
 
 SELECT 
    FORMAT(started_at, 'hh tt') AS formatted_hour,
    member_casual,
    COUNT(*) AS total_rides 
FROM dbo.bike_data
WHERE member_casual IN ('casual')
GROUP BY FORMAT(started_at, 'hh tt'), member_casual
ORDER BY total_rides DESC

-- what percentage of riders where casual or member 
-- 66% of riders are members, 33% od riders are casual*
SELECT 
    member_casual,
	COUNT(*) total_rides,
	COUNT(*) * 100 / SUM(COUNT(*)) OVER () AS percentage
       FROM (
	         SELECT member_casual 
			 FROM dbo.bike_data) AS annual_table 
			                   GROUP BY 
							    member_casual

-- Top 5 start and end locations for members 

-- start station members 
SELECT TOP 5
    start_station_name,
	COUNT(*) AS member_start_count
FROM
    dbo.bike_data
WHERE 
    member_casual ='member'
	GROUP BY start_station_name
	ORDER BY member_start_count DESC

--end station members 
SELECT TOP 5
    end_station_name,
	COUNT(*) AS member_end_count
FROM
    dbo.bike_data
WHERE 
    member_casual ='member'
	GROUP BY end_station_name
	ORDER BY member_end_count DESC


-- repeat previous for casual riders 
-- start station casual
SELECT TOP 5
    start_station_name,
	COUNT(*) AS casual_start_count
FROM
    dbo.bike_data
WHERE 
    member_casual ='casual'
	GROUP BY start_station_name
	ORDER BY casual_start_count DESC

--end station casual
SELECT TOP 5
    end_station_name,
	COUNT(*) AS casual_end_count
FROM
    dbo.bike_data
WHERE 
    member_casual ='casual'
	GROUP BY end_station_name
	ORDER BY casual_end_count DESC

-- since August is the busiest month lest see what the top 5 station are for that month 
-- member rider start station 
SELECT TOP 5
    start_station_name,
    COUNT(*) AS member_start_count
FROM
    dbo.bike_data
WHERE 
    member_casual = 'member'
    AND MONTH(start_date) = 8 -- Filter for the month of August
GROUP BY start_station_name
ORDER BY member_start_count DESC

-- member rider end station 
SELECT TOP 5
    end_station_name,
    COUNT(*) AS member_end_count
FROM
    dbo.bike_data
WHERE 
    member_casual = 'member'
    AND MONTH(start_date) = 8 -- Filter for the month of August
GROUP BY end_station_name
ORDER BY member_end_count DESC

--casual rider start station 
SELECT TOP 5
    start_station_name,
    COUNT(*) AS casual_start_count
FROM
    dbo.bike_data
WHERE 
    member_casual = 'casual'
    AND MONTH(start_date) = 8 -- Filter for the month of August
GROUP BY start_station_name
ORDER BY casual_start_count DESC

--casual rider end station 
SELECT TOP 5
    end_station_name,
    COUNT(*) AS casual_end_count
FROM
    dbo.bike_data
WHERE 
    member_casual = 'casual'
    AND MONTH(start_date) = 8 -- Filter for the month of August
GROUP BY end_station_name
ORDER BY casual_end_count DESC