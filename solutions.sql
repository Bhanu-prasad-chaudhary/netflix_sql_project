-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE  netflix (
show_id VARCHAR(6) PRIMARY KEY,
type VARCHAR(10),
title VARCHAR(150),	
director VARCHAR(208),
casts VARCHAR(1000), -- in dataset give as cast but we have to change casts 
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description	 VARCHAR(250)
);

SELECT * FROM netflix;

SELECT 
	COUNT(*) AS total_contents
FROM netflix;

SELECT 
      DISTINCT type
FROM netflix;	


-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
    SELECT 
	    type,
	    COUNT(*) AS total_contents
	FROM netflix
	GROUP BY 1;	
-- 2. Find the most common rating for movies and TV shows
     
	 WITH most_common_rate_table
	 as
	 (
	 SELECT 
			 type,
			 rating,
			 COUNT(rating) as number_of_rate,
			 RANK() OVER(PARTITION  BY type ORDER BY COUNT(rating) DESC ) AS rank
	 FROM netflix
	 GROUP BY 1,2 
	 )
	 SELECT *
	  FROM most_common_rate_table
	 WHERE rank = 1
	 

	 
-- 3. List all movies released in a specific year (e.g., 2020)
     SELECT 
	 *
	 FROM netflix
	 WHERE 
	      type = 'Movie'
		  AND
		  release_year = 2020
	 
-- 4. Find the top 5 countries with the most content on Netflix
--unnest is used for split like ('Germany', 'Czech Republic ') into 1)Germany and  2)Czech Republic
--STRING_TO_ARRAY is used for convert into array like 'Germany, Czech Republic ' into ('Germany', 'Czech Republic ')
   SELECT
       UNNEST(STRING_TO_ARRAY(country ,',')) as new_country,
	   COUNT(show_id) as total_contents
    FROM netflix
    GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5

   
-- 5. Identify the longest movie
SELECT * 
	FROM netflix
WHERE type = 'Movie'
      AND
	  duration = (SELECT MAX(duration) FROM netflix);

	  
-- 6. Find content added in the last 5 years
 SELECT 
      * 
  FROM netflix
WHERE  TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
    SELECT *
	 FROM netflix
	 WHERE directoR LIKE '%Rajiv Chilaka%'

	 -- WHERE WE USE 'LIKE' INSTEAD OF '=' BEACAUSE LIKE GIVE AS ALL THE DIRECTOR WHICH ARE FRONT OR BACK OF 'Rajiv Chilaka' SUCH AS 'Rajiv Chilaka, Anirban Majumder, Alka Amarkant Dubey' 

-- 8. List all TV shows with more than 5 seasons
-- use of SPLIT_PART
-- SPLIT_PART('Apple Banana Cherry',' ',1) answer = Apple
     SELECT 
	     *    
	 FROM  netflix
	  WHERE 
	      type = 'TV Show'
		  AND 
		 SPLIT_PART(duration,' ',1) :: numeric > 5

		  
-- 9. Count the number of content items in each genre like 'Action Comedy Drama Horror Documentaries Children & Family International Movies Crime TV Shows'
      SELECT 
	        UNNEST(STRING_TO_ARRAY(listed_in ,',')) as Genre,
			COUNT(*) AS total_contents
		 FROM netflix
	  GROUP BY 1
	  ORDER BY 2 DESC
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
     SELECT 
	     EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
         COUNT(*),
		ROUND (COUNT(*)::numeric /(SELECT COUNT(*) FROM netflix  WHERE country = 'India')* 100 ,2) as avg_contents
	 FROM netflix
	 WHERE country = 'India'
	 GROUP BY 1
	 ORDER BY 3 DESC
	 LIMIT 5
	

-- 11. List all movies that are documentaries
   SELECT * 
   FROM netflix
   WHERE type = 'Movie'
         AND
		 listed_in Ilike '%documentaries%' -- this Ilike support upper and lower 
	
-- 12. Find all content without a director
     SELECT * 
	    FROM netflix
		WHERE 
		  director IS NULL;
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
       SELECT * 
	   FROM netflix
	   WHERE type = 'Movie'
	       AND 
		   casts Ilike  '%Salman Khan%'
		   AND
		   release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
		   
		   -- WHERE  cond_n MUST BE IN NUMERIC 
		   
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
   SELECT 
       UNNEST(STRING_TO_ARRAY(casts,','))AS actor_name,
	   COUNT(*) AS total_contents
   FROM netflix
   WHERE 
   type = 'Movie'
   AND
   country Ilike '%india%'
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 10

   
-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
WITH new_table
as
(SELECT * ,
     CASE 
	    WHEN description Ilike '%kill%' OR description Ilike '%violence%' THEN 'Bad_content'
	    ELSE 'Good_content'
	END AS category	

FROM netflix
)
SELECT 
     category,
	 COUNT(*) AS total_contents
FROM new_table
GROUP BY 1

