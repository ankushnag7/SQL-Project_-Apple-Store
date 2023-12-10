-- The Stakeholder is an app developer who needs analysis to decide what type of app to build. 
-- They are seeking answers to questions like 1) What app categories are most popular 2)What price should they set 3) How can they maximise their ratings 

select*  from AppleStore
select * from appleStore_description

-- EDA
-- Checking the number of unique apps in both the tables (for missing values in case of discrenencies)

select count(distinct id) as UniqueAppIDs
from AppleStore

select count(distinct id) as UniqueAppIDs
from appleStore_description

-- Check for any missing values in the key fields 

select count(*) as MissingValues
from AppleStore
where track_name IS null OR user_rating IS null OR prime_genre IS null

select count(*) as MissingValues
from appleStore_description
where app_desc IS null

-- Finding the number of apps per genre

select prime_genre, count(*) as NumApps
from AppleStore 
group by prime_genre
order by NumApps desc

--Getting an overview of the apps ratings

select min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
	   avg(user_rating) as AvgRating
 from AppleStore


 ** DATA ANALYSIS**

 --Determine whether the paid apps have higher ratings then the free apps

 select case 
 when price > 0 then 'Paid'
 else 'Free' 
      end as App_Type,
 avg(user_rating) as Avg_rating
 from AppleStore
 group by App_Type

 --This query repeats the case expression in the group by clause.

select 
    case 
        when price > 0 then 'Paid'
        else 'Free' 
    end as App_Type,
    AVG(user_rating) as Avg_rating
from AppleStore
group by 
    case 
        when price > 0 then 'Paid'
        else 'Free' 
    end;

 -- Check if apps with more supported languages have higher ratings

select case 
		when lang_num < 10 then '<10 languages'
		when lang_num  between 10 and 30 then '10 - 30 languages'
		else '>30 languages'
       end as language_bucket,
	avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
order by Avg_Rating desc

-- Trying with SUB QUERY
-- In this query, I wrapped the original query in a subquery, and then I used the alias language_bucket in the outer query's group by clause.

select language_bucket, AVG(user_rating) as Avg_Rating
from (
    select 
        case 
            when lang_num < 10 then '<10 languages'
            when lang_num between 10 and 30 then '10 - 30 languages'
            else '>30 languages'
        end as language_bucket,
        user_rating
    from AppleStore
) as subquery
group by language_bucket
order by Avg_Rating desc;

-- Check genre with low ratings 
-- ( Using TOP instead of LIMIT)

select TOP 10 prime_genre, 
       avg(user_rating) as Avg_Rating
from AppleStore
group by Prime_genre
order by Avg_Rating asC

-- Checking if there is a corelation between the length of the app description and the user rating 

select case 
			when LENGTH(b.app_desc)<500 then 'Short'
			when LENGTH(b.app_desc) between 500 and 1000 then 'Medium'
			else 'Long'
	   end as description_length_bucket,
	   avg(A.user_rating) as average_rating

from AppleStore as a
join appleStore_description as b
ON A.id = B.id 
group by description_length_bucket
order by average_rating desc

-- In Microsoft SQL Server, the function for getting the length of a string is LEN, not LENGTH as in some other database systems.
select 
    case 
        when LEN(b.app_desc) < 500 then 'Short'
        when LEN(b.app_desc) between 500 and 1000 then 'Medium'
        else 'Long'
    end as description_length_bucket,
    AVG(A.user_rating) as average_rating
from AppleStore as A
join appleStore_description as B ON A.id = B.id
group by 
    case 
        when LEN(b.app_desc) < 500 then 'Short'
        when LEN(b.app_desc) between 500 and 1000 then 'Medium'
        else 'Long'
    end
order by average_rating desc;


-- Checking the TOP rated aps for each genre 
-- ( Using the rank over window function - It assigns a rank to each row withoin a window of rows and then 
-- partioning by genre which creates a seperate window for each unique genre)

select prime_genre, track_name,user_rating 
from ( 
	  select prime_genre, track_name,user_rating, 
	  RANK() OVER(PARTITION by prime_genre order by user_rating desc, rating_count_tot desc) as rank
	  from AppleStore) as a
	  where a.rank = 1

-- * INSIGHTS *

--1) Paid Apps have better Ratings 
--2) Apps supporting between 10 and 30 languages hae better ratings 
--3) Finance and Book apps have low ratings 
--4) Apps with a longer descriptin have better ratings 
--5) A new app shuld aim for an average rating above 3.5
--6) Games and Entertainment have high competition 


