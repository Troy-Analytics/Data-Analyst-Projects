--Hotel Booking: Data Exploration
--This code was used to explore Hotel Booking data from 2018-2019 to answer business questions using various techniques, including:
--aggregate functions, joins, union , temp tables, arithmetic functions.

--Our questions are:
 --Is our hotel revenue growing yearly?
 --What trends can we see in the data?
 --Should we increase our parking lot size?


 --Lest begin viewing the dataset*

 SELECT *
 FROM dbo.[2018]

 SELECT *
 FROM dbo.[2019]

 SELECT *
 FROM dbo.[2020]


 --Creating temp table for easier access and analysis*

WITH hotels AS(
    SELECT *
      FROM dbo.[2018]
UNION
    SELECT *
      FROM dbo.[2019]
UNION
    SELECT *
      FROM dbo.[2020]
	  )

SELECT *
FROM hotels

--Is hotel revenue growing yearly?
--Creating revenue column using adr(average daily rate)*

WITH hotels AS(
    SELECT *
      FROM dbo.[2018]
UNION
    SELECT *
      FROM dbo.[2019]
UNION
    SELECT *
      FROM dbo.[2020]
	  )

SELECT (stays_in_week_nights + stays_in_weekend_nights) * adr AS revenue
FROM hotels 


--Creating another column to calcutale the sum of revenue, grouping data by year
--With this query we can see that revenue increased from 2018-2019 but then decreased in 2020*

WITH hotels AS(
    SELECT *
      FROM dbo.[2018]
UNION
    SELECT *
      FROM dbo.[2019]
UNION
    SELECT *
      FROM dbo.[2020]
	  )

SELECT arrival_date_year,
    SUM((stays_in_week_nights+stays_in_weekend_nights)*adr) 
	AS revenue 
FROM hotels
GROUP BY arrival_date_year


--Deeper dive: Now lest determine revenue trend by hotel type to see which hotels generated most revenue*

WITH hotels AS(
    SELECT *
      FROM dbo.[2018]
UNION
    SELECT *
      FROM dbo.[2019]
UNION
    SELECT *
      FROM dbo.[2020]
	  )

SELECT arrival_date_year,hotel,
    SUM((stays_in_week_nights+stays_in_weekend_nights)*adr) 
	AS revenue 
FROM hotels
GROUP BY arrival_date_year,hotel


--Should we increase our parking lot size?*
--This query can show that based on total parking spaces and number of guest staying at hotels  
--Additional parking is not needed 
WITH hotels AS(
    SELECT *
      FROM dbo.[2018]
UNION
    SELECT *
      FROM dbo.[2019]
UNION
    SELECT *
      FROM dbo.[2020]
	  )

SELECT arrival_date_year, hotel,
    SUM((stays_in_week_nights + stays_in_weekend_nights) *adr) 
	AS revenue,
	CONCAT(
	    ROUND(SUM(required_car_parking_spaces) / SUM(stays_in_week_nights + stays_in_weekend_nights) *100,2),
		'%') 
	AS parking_percentage
FROM hotels
GROUP BY arrival_date_year, hotel

--Time to join tables for use in PowerBI

WITH hotels AS(
    SELECT *
      FROM dbo.[2018]
UNION
    SELECT *
      FROM dbo.[2019]
UNION
    SELECT *
      FROM dbo.[2020]
	  )

SELECT *
FROM hotels
LEFT JOIN dbo.market_segment$
    ON hotels.market_segment = market_segment$.market_segment
LEFT JOIN dbo.meal_cost$
    ON meal_cost$.meal = hotels.meal