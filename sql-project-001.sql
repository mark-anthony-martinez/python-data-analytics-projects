/*

===============================================================
	Create Table Query
===============================================================
	project owner: https://www.linkedin.com/in/mrtnz/
	sql-code-formatter: https://codebeautify.org/sqlformatter
	
	project aim — demonstrate the following skills:
		→ sql proficiency
		→ importing csv data
		→ creating and updating SQL tables
		→ data cleaning and data input standardization
		→ handling missing data
		→ splitting column into multiple columns and contexts
		→ updating records

	data: simplified titanic data set
		→ sql for data engineering course (requirement)
		→ under dap dost project sparta data scientist pathway
		
*/


/*

===============================================================
	Create Table Query
===============================================================

*/


CREATE TABLE public.titanic (
  PassengerId INTEGER NOT NULL, 
  Survived INTEGER, 
  Pclass INTEGER, 
  Name CHARACTER VARYING(100), 
  Sex CHARACTER VARYING(10), 
  Age DECIMAL(4, 1), 
  SibSp INTEGER, 
  Parch INTEGER, 
  Ticket CHARACTER VARYING(20), 
  Fare DECIMAL(10, 4), 
  Cabin CHARACTER VARYING(20), 
  Embarked CHARACTER VARYING(1), 
  CONSTRAINT passenger_id_pkey PRIMARY KEY (PassengerId)
) 

/*

===============================================================
	Pulling from CSV file
===============================================================

*/

COPY titanic (
  PassengerId, Survived, Pclass, Name, 
  Sex, Age, SibSp, Parch, Ticket, Fare, 
  Cabin, Embarked
) 
FROM 
  'D:\titanic.csv' DELIMITER ',' CSV HEADER;
  
  
-- **checking data** --
SELECT 
  * 
FROM 
  public.titanic 
  
/*

===============================================================
	Task 1: Missing Data in Age and Cabin
===============================================================

    Handling Rules:
    (1) Default Age = Average Value = 30
    (2) Default Cabin = Mode = B96 B98
    (3) Convert DECIMAL values to INT

*/

-- **average age** -- 
SELECT 
  ROUND(
    AVG(age), 
    0
  ) 
FROM 
  public.titanic 
WHERE 
  age IS NOT NULL 


-- **mode cabin** --
SELECT 
  cabin, 
  COUNT(passengerid) AS count_passenger 
FROM 
  public.titanic 
WHERE 
  cabin IS NOT NULL 
GROUP BY 
  cabin 
ORDER BY 
  COUNT(passengerid) DESC, 
  cabin ASC;


-- **standardized age** --
SELECT 
  passengerid, 
  CASE WHEN ROUND(age, 0) IS NULL THEN 30 ELSE ROUND(age, 0) END AS age 
FROM 
  public.titanic -- Final Update Script:
  WITH updated_values AS (
    SELECT 
      passengerid, 
      CASE WHEN ROUND(age, 0) IS NULL THEN 30 ELSE ROUND(age, 0) END AS age 
    FROM 
      public.titanic
  ) 
UPDATE 
  public.titanic 
SET 
  age = updated_values.age 
FROM 
  updated_values 
WHERE 
  titanic.passengerid = updated_values.passengerid;


-- **converting age to integer** --
ALTER TABLE 
  public.titanic ALTER COLUMN age TYPE INTEGER;


-- **checking null age** --
SELECT 
  * 
FROM 
  public.titanic 
WHERE 
  age IS NULL 
 
 
-- **standardized cabin** --
SELECT 
  passengerid, 
  CASE WHEN cabin IS NULL THEN 'B96 B98' ELSE cabin END AS cabin 
FROM 
  public.titanic 
  
  
-- **final update sript** --
WITH updated_values AS (
    SELECT 
      passengerid, 
      CASE WHEN cabin IS NULL THEN 'B96 B98' ELSE cabin END AS cabin 
    FROM 
      public.titanic
  ) 
UPDATE 
  public.titanic 
SET 
  cabin = updated_values.cabin 
FROM 
  updated_values 
WHERE 
  titanic.passengerid = updated_values.passengerid;


-- **checking for null cabin** --
SELECT 
  * 
FROM 
  public.titanic 
WHERE 
  cabin IS NULL 
 
 
/*

===============================================================
	Task 2: Standardize Sex Column
===============================================================

*/

-- **checking distinct entries** --
SELECT 
  DISTINCT sex 
FROM 
  public.titanic 


-- **standardized sex column** --
SELECT 
  passengerid, 
  CASE WHEN sex = 'F' THEN 'female' WHEN sex = 'M' THEN 'male' ELSE sex END AS sex 
FROM 
  public.titanic 
  
-- **final update script** --
WITH updated_values AS (
    SELECT 
      passengerid, 
      CASE WHEN sex = 'F' THEN 'female' WHEN sex = 'M' THEN 'male' ELSE sex END AS sex 
    FROM 
      public.titanic
  ) 
UPDATE 
  public.titanic 
SET 
  sex = updated_values.sex 
FROM 
  updated_values 
WHERE 
  titanic.passengerid = updated_values.passengerid;

-- **re-checking distinct entries** --
SELECT 
  DISTINCT sex 
FROM 
  public.titanic 
  
/*


===============================================================
	Task 3: Last Name
===============================================================

*/

-- **querying the columns: last_name, title, and first_name** --  
SELECT 
  split_part(name, ',', 1) AS last_name, 
  split_part(
    trim(
      split_part(name, ',', 2)
    ), 
    '.', 
    1
  ) AS title, 
  trim(
    split_part(
      trim(
        split_part(name, ',', 2)
      ), 
      '.', 
      2
    )
  ) AS first_name 
FROM 
  public.titanic 
 

-- **creating the last_name column** --
ALTER TABLE 
  public.titanic 
ADD 
  COLUMN last_name CHARACTER VARYING(100);


-- **populating the last_name column** --
UPDATE 
  public.titanic 
SET 
  last_name = split_part(name, ',', 1);


-- **checking results** -- 
SELECT 
  name, 
  last_name 
FROM 
  public.titanic 


/*

===============================================================
	Task 4: Title
===============================================================

*/

-- **querying the columns: last_name, title, and first_name** --  
SELECT 
  split_part(name, ',', 1) AS last_name, 
  split_part(
    trim(
      split_part(name, ',', 2)
    ), 
    '.', 
    1
  ) AS title, 
  trim(
    split_part(
      trim(
        split_part(name, ',', 2)
      ), 
      '.', 
      2
    )
  ) AS first_name 
FROM 
  public.titanic 
 
 
-- **creating the title column** -- 
ALTER TABLE 
  public.titanic 
ADD 
  COLUMN title CHARACTER VARYING(100);


-- **populating the title column** -- 
UPDATE 
  public.titanic 
SET 
  title = split_part(
    trim(
      split_part(name, ',', 2)
    ), 
    '.', 
    1
  );
  
  
-- **checking results** -- 
SELECT 
  name, 
  title 
FROM 
  public.titanic;
  
  
/*

===============================================================
	Task 5: First Name
===============================================================

*/

-- **querying the columns: last_name, title, and first_name** --  
SELECT 
  split_part(name, ',', 1) AS last_name, 
  split_part(
    trim(
      split_part(name, ',', 2)
    ), 
    '.', 
    1
  ) AS title, 
  trim(
    split_part(
      trim(
        split_part(name, ',', 2)
      ), 
      '.', 
      2
    )
  ) AS first_name 
FROM 
  public.titanic 


-- **creating the title column** --
ALTER TABLE 
  public.titanic 
ADD 
  COLUMN first_name CHARACTER VARYING(100);
  
 
-- **populating the title column** --
UPDATE 
  public.titanic 
SET 
  first_name = trim(
    split_part(
      trim(
        split_part(name, ',', 2)
      ), 
      '.', 
      2
    )
  );
  

-- **checking results** --
SELECT 
  name, 
  first_name 
FROM 
  public.titanic;
