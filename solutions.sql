
'''
SQL Logical Execution Order
----------------------------------------------------------------------
Step	     Clause	                 What It Does
----------------------------------------------------------------------
1	          FROM	           Chooses and joins tables or views.
2	          ON	           Applies join conditions (for JOIN).
3	          JOIN	           Combines rows from multiple tables.
4	          WHERE	           Filters rows before grouping.
5	         GROUP BY	       Groups rows into summary rows.
6	         HAVING	           Filters groups after grouping.
7	         SELECT	           Chooses which columns/expressions to return.
8	         DISTINCT	       Removes duplicates from the result set.
9	         ORDER BY	       Sorts the result set.
10	         LIMIT / OFFSET	   Limits the number of rows returned.
----------------------------------------------------------------------

'''

-- BASIC SELECTS

-- Japanese Cities' Attributes

SELECT * FROM CITY WHERE countrycode='JPN';

-- Japanese Cities' Names
SELECT name FROM CITY WHERE countrycode='JPN';


-- Weather Observation Station 1
SELECT city, state from STATION;

-- Weather Observation Station 3
SELECT DISTINCT(city) FROM STATION WHERE ID % 2 = 0;
SELECT DISTINCT(city) FROM STATION WHERE MOD(ID, 2) = 0;

-- Weather Observation Station 4
SELECT COUNT(city) - COUNT(DISTINCT(city)) FROM STATION;
SELECT COUNT(*) - COUNT(DISTINCT(city)) FROM STATION;

-- Weather Observation Station 5
SELECT city, LENGTH(city) AS longest_city FROM STATION 
ORDER BY LENGTH(city) DESC, city 
LIMIT 1;
SELECT city, LENGTH(city) AS shortest_city FROM STATION 
ORDER BY LENGTH(city) ASC, city 
LIMIT 1;

----- OR ------


SELECT * FROM (
    SELECT city, LENGTH(city) 
    FROM station
    ORDER BY LENGTH(city), city 
    LIMIT 1
) AS min_city

UNION 

SELECT * FROM (
    SELECT city, LENGTH(city) 
    FROM station
    ORDER BY LENGTH(city) DESC, city
    LIMIT 1
) AS max_city;

-- Weather Observation Station 6
SELECT distinct(city) FROM STATION
WHERE city LIKE 'a%' OR city LIKE 'e%' OR city LIKE 'i%' OR city LIKE 'o%' OR city LIKE 'u%';

SELECT CITY FROM STATION WHERE LEFT(CITY,1) IN ("a","e","i","o","u");

SELECT DISTINCT CITY FROM STATION WHERE CITY REGEXP '^[aeiou]';

-- Weather Observation Station 7
SELECT DISTINCT(city) FROM STATION WHERE city LIKE '%a' OR city LIKE '%e' OR city LIKE '%i' OR city LIKE '%o' OR city LIKE '%u';

SELECT distinct City FROM STATION WHERE City LIKE '[a,e,i,o,u]%' and city LIKE '%[a,e,i,o,u]';

SELECT DISTINCT(city) FROM STATION WHERE RIGHT(city,1) IN ('a','e','i','o','u');

SELECT DISTINCT city FROM STATION WHERE city REGEXP '[aeiou]$';

-- Weather Observation Station 8

SELECT DISTINCT city FROM STATION
WHERE LEFT(city,1) 
    IN ('a','e','i','o','u') 
    AND RIGHT(city,1) 
    IN ('a','e','i','o','u');

SELECT DISTINCT city FROM STATION
WHERE city REGEXP '^[aeiou].*[aeiou]$'; 
-- . matches any character
-- * to match a character zero or more times

-- Weather Observation Station 9
SELECT DISTINCT city FROM STATION WHERE city NOT LIKE 'a%' AND city NOT LIKE 'e%' AND city NOT LIKE 'i%' AND city NOT LIKE 'o%' AND city NOT LIKE 'u%';

SELECT distinct City FROM STATION WHERE City NOT LIKE '[a,e,i,o,u]%';

SELECT DISTINCT city FROM STATION WHERE city not regexp '^[aeiou]';

SELECT DISTINCT city FROM STATION WHERE LEFT(city,1) NOT  IN ('a','e','i','o','u');

-- Weather Observation Station 10
SELECT DISTINCT city FROM STATION WHERE city NOT LIKE '%a' AND city NOT LIKE '%e' AND city NOT LIKE '%i' AND city NOT LIKE '%o' AND city NOT LIKE '%u';

SELECT distinct City FROM STATION WHERE City NOT LIKE '%[a,e,i,o,u]';

SELECT DISTINCT city FROM STATION WHERE city not regexp '[aeiou]$';

SELECT DISTINCT city FROM STATION WHERE RIGHT(city,1) NOT  IN ('a','e','i','o','u');

    
-- Weather Observation Station 11
SELECT DISTINCT city FROM STATION WHERE city NOT REGEXP '^[aeiou].*[aeiou]$';

-- Weather Observation Station 12
SELECT DISTINCT city FROM station WHERE city REGEXP '^[^aeiouAEIOU].*[^aeiouAEIOU]$';
-- [^aeiouAEIOU] here ^ sign is for NOT

-- Higher Than 75 Marks
SELECT name FROM STUDENTS WHERE marks > 75
ORDER BY RIGHT(name,3),id;

-- Employee Names

SELECT name FROM Employee ORDER BY name;

-- Employee Salaries
SELECT name FROM EMPLOYEE WHERE salary > 2000 AND months < 10 ORDER BY employee_id;


-- Advanced Select
'''
1. (INNER) JOIN: Returns records that have matching values in both tables
2. LEFT (OUTER) JOIN: Returns all records from the left table, and the matched records from the right table
3. RIGHT (OUTER) JOIN: Returns all records from the right table, and the matched records from the left table
4. FULL (OUTER) JOIN: Returns all records when there is a match in either left or right table
'''

-- The PADS

SELECT CONCAT(NAME,'(',LEFT(occupation,1) ,')') FROM OCCUPATIONS ORDER BY NAME; 

SELECT CONCAT('There are a total of ', COUNT(OCCUPATION),' ',LOWER(OCCUPATION),'s.') 
FROM OCCUPATIONS 
GROUP BY OCCUPATION 
ORDER BY COUNT(OCCUPATION) ASC, OCCUPATION ASC;

-- Contest Leaderboard

SELECT s.hacker_id, h.name, SUM(max_score) AS total_score
FROM (SELECT hacker_id, challenge_id, MAX(score) AS max_score
     FROM Submissions 
     GROUP BY hacker_id, challenge_id) s
JOIN Hackers h
ON h.hacker_id = s.hacker_id 
GROUP BY s.hacker_id, h.name
HAVING total_score > 0
ORDER BY total_score DESC, hacker_id;

'''
Using Aliases in HAVING - Summary (MySQL)
In SQL, the logical order is: GROUP BY → HAVING → SELECT.

So technically, HAVING comes before SELECT, and should not see column aliases.

🔹 But in MySQL:
We can use aliases from SELECT in the HAVING clause.

MySQL allows this as a convenience feature, even though it is not standard SQL.

so total_score (alias) works in HAVING in MySQL.
-------------------------

Not allowed in WHERE:
-- ❌ This will fail
SELECT score * 2 AS double_score
FROM submissions
WHERE double_score > 100;
Aliases can not be used in WHERE (because WHERE is processed before SELECT).

🔸 In other RDBMS (e.g., PostgreSQL, SQL Server):
Use the full expression instead of alias in HAVING.
'''

-- OR --

WITH max_score_cte AS ( 
    SELECT hacker_id, challenge_id, MAX(score) AS max_score 
    FROM Submissions 
    GROUP BY hacker_id, challenge_id 
),

total_score_cte AS ( 
    SELECT hacker_id, SUM(max_score) AS total_score 
    FROM max_score_cte 
    GROUP BY hacker_id 
)

SELECT t.hacker_id, h.name, t.total_score 
FROM total_score_cte t 
INNER JOIN Hackers h ON t.hacker_id = h.hacker_id 
WHERE t.total_score != 0 
ORDER BY t.total_score DESC, t.hacker_id ASC

-- Aggregation

-- Weather Observation Station 15

SELECT ROUND(long_w, 4)
FROM STATION
WHERE lat_n = (
    SELECT MAX(lat_n)
    FROM STATION
    WHERE lat_n < 137.2345
);

-- Weather Observation Station 16
SELECT ROUND(MIN(lat_n),4) 
FROM STATION
WHERE lat_n > 38.7780;

-- Weather Observation Station 17
 -- we cannot use aggregate functions like MIN() directly in a WHERE clause.

SELECT ROUND(long_w,4) 
FROM STATION 
WHERE lat_n = (SELECT MIN(lat_n) 
               FROM STATION 
               WHERE lat_n > 38.7780);

-- Weather Observation Station 18
'''
Manhattan distance
The distance between two points measured along axes at right angles. In a plane with p1 at (x1, y1) and p2 at (x2, y2), it is |x1 - x2| + |y1 - y2|.
'''

SELECT ABS(ROUND(MIN(lat_n) - MAX(lat_n) + MIN(long_w) - MAX(long_w),4)) AS manhattan_distance
FROM STATION;

-- OR --

SELECT ROUND(ABS(MAX(lat_n) - MIN(lat_n)) + ABS(MAX(long_w) - MIN(long_w)), 4) AS manhattan_distance
FROM STATION;

-- Weather Observation Station 19

'''
d(p,q) = SQRT( (MAX(lat_n) - MIN(lat_n))^2 + (MAX(long_w) - MIN(long_w))^2 )
'''
SELECT ROUND(
    SQRT(POW(MAX(lat_n) - MIN(lat_n), 2) + POW(MAX(long_w) - MIN(long_w), 2))
, 4) AS euclidean_distance
FROM STATION;

-- Weather Observation Station 20

'''
FLOOR(x): Returns the largest integer less than or equal to x (i.e., rounds down).

Example: FLOOR(4.9) → 4

PERCENT_RANK(): A window function that gives the relative rank of a row as a percentage (from 0 to 1) within its partition.

Formula: (rank - 1) / (total_rows - 1)
'''

SELECT ROUND(lat_n,4) FROM (SELECT lat_n, ROW_NUMBER() OVER (ORDER BY lat_n) AS row_num FROM STATION) AS s
WHERE row_num = (SELECT FLOOR(COUNT(1)/2 + 1) FROM STATION);

--OR--

SELECT ROUND(lat_n,4) FROM (SELECT lat_n, PERCENT_RANK() OVER (ORDER BY lat_n) AS p_rank FROM STATION) AS s
WHERE p_rank = 0.5;

-- Weather Observation Station 2
SELECT ROUND(SUM(lat_n),2), ROUND(SUM(long_w),2) FROM STATION;

-- Weather Observation Station 13

SELECT ROUND(SUM(lat_n),4) FROM STATION 
WHERE lat_n BETWEEN 38.7880 AND 137.2345;

-- Weather Observation Station 14
SELECT ROUND(MAX(lat_n),4) FROM STATION WHERE lat_n < 137.2345;

-- Top Earners
'''
-- In SQL, when you use a subquery in the FROM clause, it must have a name (alias) e.g. "max_earning_employees".
'''
SELECT 
  total_earning, COUNT(dense_ranking)
FROM 
  (SELECT
   (salary * months) AS total_earning, 
   DENSE_RANK() OVER (ORDER BY (salary * months) DESC) AS dense_ranking 
   FROM EMPLOYEE) AS max_earning_employees
WHERE dense_ranking = 1
GROUP BY total_earning;

--OR--

'''
MAX(...) returns a single value, not multiple rows.

To get all rows with the max value, you must filter using a WHERE clause (or a DENSE_RANK() trick).
'''
SELECT 
    MAX(total_earning), 
    COUNT(*)
FROM
    (SELECT 
    salary * months AS total_earning,
    DENSE_RANK() OVER (ORDER BY salary * months DESC) AS dense_ranking
    FROM EMPLOYEE) AS max_total_earning
WHERE dense_ranking = 1;

--OR--

SELECT  
    salary * months AS total_earning, 
    COUNT(*) AS total_employees
FROM EMPLOYEE
WHERE salary * months = (
    SELECT MAX(salary * months) FROM EMPLOYEE
)
GROUP BY total_earning;

-- Japan Population
SELECT 
    SUM(population) AS japanese_population
FROM CITY 
WHERE countrycode='JPN';

-- Population Density Difference
SELECT 
    MAX(population)-MIN(population) AS population_difference
FROM CITY;

-- The Blunder
SELECT CEIL(AVG(salary) - AVG(REPLACE(salary, '0', ''))) AS amount_of_error FROM EMPLOYEES;

-- OR --

''' 
Use CAST(... AS UNSIGNED) instead of INT because salaries are non-negative, and UNSIGNED more accurately reflects that constraint.
'''
SELECT CEIL(
  AVG(salary) - AVG(CAST(REPLACE(CAST(salary AS CHAR), '0', '') AS UNSIGNED))
) AS amount_of_error
FROM EMPLOYEES;

-- Advanced Join
-- Interviews

SELECT 
    C.contest_id, 
    C.hacker_id, 
    C.name, 
    COALESCE(SUM(ST.total_submissions), 0) AS total_submissions,                           
    COALESCE(SUM(ST.total_accepted_submissions), 0) AS total_accepted_submissions,         
    COALESCE(SUM(VW.total_views), 0) AS total_views,                          
    COALESCE(SUM(VW.total_unique_views), 0) AS total_unique_views 
FROM Contests C 
JOIN Colleges CL ON CL.contest_id = C.contest_id 
LEFT JOIN Challenges CH ON CH.college_id = CL.college_id 
LEFT JOIN (SELECT challenge_id, 
           SUM(total_views) AS total_views,                                                     
           SUM(total_unique_views) AS total_unique_views 
           FROM View_Stats 
           GROUP BY challenge_id) VW 
           ON VW.challenge_id = CH.challenge_id 
LEFT JOIN (SELECT challenge_id, 
           SUM(total_submissions) AS total_submissions,                                          
           SUM(total_accepted_submissions) AS total_accepted_submissions 
           FROM Submission_Stats 
           GROUP BY challenge_id) ST ON ST.challenge_id = CH.challenge_id 
GROUP BY C.contest_id, C.hacker_id, C.name 
HAVING SUM(ST.total_submissions) +
        SUM(ST.total_accepted_submissions) + 
        SUM(VW.total_views) + 
        SUM(VW.total_unique_views) > 0 
ORDER BY C.contest_id;
