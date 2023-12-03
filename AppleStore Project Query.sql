-- The Stakeholder is an app developer who needs analysis to decide what type of app to build. 
-- They are seeking answers to questions like 1) What app categories are most popular 2)What price should they set 3) How can they maximise their ratings 

Select *  FROM AppleStore
Select * From appleStore_description

-- EDA
-- Checking the number of unique apps in both the tables (for missing values in case of discrenencies)

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description

-- Check for any missing values in the key fields 

Select Count(*) As MissingValues
FROM AppleStore
Where track_name IS null OR user_rating IS null OR prime_genre IS null

Select Count(*) As MissingValues
FROM appleStore_description
Where app_desc IS null

-- Finding the number of apps per genre

Select prime_genre, COUNT(*) AS NumApps
From AppleStore 
Group By prime_genre
Order By NumApps DESC

--Getting an overview of the apps ratings

Select min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
	   avg(user_rating) AS AvgRating
 FROM AppleStore


 ** DATA ANALYSIS**

 --Determine whether the paid apps have higher ratings then the free apps

 SELECT CASE 
 WHEN price > 0 THEN 'Paid'
 ELSE 'Free' 
      END AS App_Type,
 avg(user_rating) AS Avg_rating
 FROM AppleStore
 GROUP BY App_Type

 --This query repeats the CASE expression in the GROUP BY clause.

SELECT 
    CASE 
        WHEN price > 0 THEN 'Paid'
        ELSE 'Free' 
    END AS App_Type,
    AVG(user_rating) AS Avg_rating
FROM AppleStore
GROUP BY 
    CASE 
        WHEN price > 0 THEN 'Paid'
        ELSE 'Free' 
    END;

 -- Check if apps with more supported languages have higher ratings

SELECT CASE 
		WHEN lang_num < 10 THEN '<10 languages'
		WHEN lang_num  BETWEEN 10 AND 30 THEN '10 - 30 languages'
		ELSE '>30 languages'
       END AS language_bucket,
	avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

-- Trying with SUB QUERY
-- In this query, I wrapped the original query in a subquery, and then I used the alias language_bucket in the outer query's GROUP BY clause.

SELECT language_bucket, AVG(user_rating) AS Avg_Rating
FROM (
    SELECT 
        CASE 
            WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10 - 30 languages'
            ELSE '>30 languages'
        END AS language_bucket,
        user_rating
    FROM AppleStore
) AS subquery
GROUP BY language_bucket
ORDER BY Avg_Rating DESC;

-- Check genre with low ratings 
-- ( Using TOP instead of LIMIT)

SELECT TOP 10 prime_genre, 
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY Prime_genre
ORDER BY Avg_Rating ASC

-- Checking if there is a corelation between the length of the app description and the user rating 

SELECT CASE 
			WHEN LENGTH(b.app_desc)<500 THEN 'Short'
			WHEN LENGTH(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
			ELSE 'Long'
	   END AS description_length_bucket,
	   avg(A.user_rating) AS average_rating

FROM AppleStore AS a
JOIN appleStore_description AS b
ON A.id = B.id 
GROUP BY description_length_bucket
ORDER BY average_rating DESC

-- In Microsoft SQL Server, the function for getting the length of a string is LEN, not LENGTH as in some other database systems.
SELECT 
    CASE 
        WHEN LEN(b.app_desc) < 500 THEN 'Short'
        WHEN LEN(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Long'
    END AS description_length_bucket,
    AVG(A.user_rating) AS average_rating
FROM AppleStore AS A
JOIN appleStore_description AS B ON A.id = B.id
GROUP BY 
    CASE 
        WHEN LEN(b.app_desc) < 500 THEN 'Short'
        WHEN LEN(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Long'
    END
ORDER BY average_rating DESC;


-- Checking the TOP rated aps for each genre 
-- ( Using the rank over window function - It assigns a rank to each row withoin a window of rows and then 
-- partioning by genre which creates a seperate window for each unique genre)

SELECT prime_genre, track_name,user_rating 
FROM ( 
	  SELECT prime_genre, track_name,user_rating, 
	  RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
	  FROM AppleStore) AS a
	  WHERE a.rank = 1

-- * INSIGHTS *

--1) Paid Apps have better Ratings 
--2) Apps supporting between 10 and 30 languages hae better ratings 
--3) Finance and Book apps have low ratings 
--4) Apps with a longer descriptin have better ratings 
--5) A new app shuld aim for an average rating above 3.5
--6) Games and Entertainment have high competition 


