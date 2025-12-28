/*

	project owner: https://www.linkedin.com/in/mrtnz/
	sql-code-formatter: https://codebeautify.org/sqlformatter
	
	project aim — demonstrate the following skills:
		→ sql proficiency
		→ apply sql to feature engineering concepts

	data: property sales data
		→ sql for data engineering course (requirement)
		→ under dap dost project sparta data scientist pathway
		
*/


/*

===============================================================
	Create Table Query
===============================================================

*/

CREATE TABLE public.property_sales (
  Id INTEGER NOT NULL, 
  MSSubClass VARCHAR(100), 
  LotShape VARCHAR(100), 
  LandContour VARCHAR(100), 
  LandSlope VARCHAR(100), 
  BldgType VARCHAR(100), 
  HouseStyle VARCHAR(100), 
  OverallQual VARCHAR(100), 
  OverallCond VARCHAR(100), 
  LotFrontage VARCHAR(100), 
  LotArea INT, 
  GarageArea INT, 
  GrLivArea INT, 
  TotalBsmtSF INT, 
  SalePrice INT, 
  CONSTRAINT id_pkey PRIMARY KEY (Id)
) 
SELECT 
  * 
FROM 
  public.property_sales


/*

===============================================================
	Pulling from CSV file
===============================================================

	Handling Rules:
	'NA' inputs in lotfrontage will be converted to 0

*/

-- **insert data to table named property_sales** --
COPY property_sales (
  Id, MSSubClass, LotShape, LandContour, 
  LandSlope, BldgType, HouseStyle, 
  OverallQual, OverallCond, LotFrontage, 
  LotArea, GarageArea, GrLivArea, TotalBsmtSF, 
  SalePrice
) 
FROM 
  'D:\property_sales.csv' DELIMITER ',' CSV HEADER;


-- **checking possible values for lotfrontage** --
SELECT 
  lotfrontage, 
  COUNT(id) 
FROM 
  public.property_sales 
GROUP BY 
  lotfrontage 
ORDER BY 
  COUNT(id) DESC 
  
 -- **convert 'NA' values to 0** --
 WITH updated_values AS (
    SELECT 
      id, 
      CASE WHEN lotfrontage = 'NA' 
		   THEN '0' ELSE lotfrontage END AS lotfrontage 
    FROM 
      public.property_sales
  ) 
UPDATE 
  public.property_sales 
SET 
  lotfrontage = updated_values.lotfrontage 
FROM 
  updated_values 
WHERE 
  property_sales.id = updated_values.id;


-- **converting lotfrontage to INTEGER** --
ALTER TABLE 
  public.property_sales 

ALTER COLUMN LotFrontage 
TYPE integer USING LotFrontage :: integer;


-- **checking the final table** --
SELECT 
  * 
FROM 
  public.property_sales


/*

===============================================================
	Task 1: One Hot Encoding
===============================================================

*/

-- **checking possibe values for landslope** --
SELECT 
  DISTINCT LandSlope 
FROM 
  public.property_sales 


SELECT 
  id, 
  landslope, 
  CASE WHEN landslope = 'Gentle slope' 
	   THEN 1 ELSE 0 END AS gentle_slope, 
  CASE WHEN landslope = 'Moderate Slope' 
       THEN 1 ELSE 0 END AS moderate_slope, 
  CASE WHEN landslope = 'Severe Slope' 
       THEN 1 ELSE 0 END AS severe_slope 
FROM 
  public.property_sales 
  

-- **adding gentle_slope column** --
ALTER TABLE 
  public.property_sales 
ADD 
  COLUMN gentle_slope INT;
UPDATE 
  public.property_sales 
SET 
  gentle_slope = CASE WHEN landslope = 'Gentle slope' 
					  THEN 1 ELSE 0 END 
SELECT 
  id, 
  landslope, 
  gentle_slope 
FROM 
  public.property_sales 


-- **adding moderate_slope column** --
ALTER TABLE 
  public.property_sales 
ADD 
  COLUMN moderate_slope INT;
UPDATE 
  public.property_sales 
SET 
  moderate_slope = CASE WHEN landslope = 'Moderate Slope' 
						THEN 1 ELSE 0 END 
SELECT 
  id, 
  landslope, 
  moderate_slope 
FROM 
  public.property_sales 
  
  
-- **adding severe_slope column** --
ALTER TABLE 
  public.property_sales 
ADD 
  COLUMN severe_slope INT;
UPDATE 
  public.property_sales 
SET 
  severe_slope = CASE WHEN landslope = 'Severe Slope' 
					  THEN 1 ELSE 0 END 
SELECT 
  id, 
  landslope, 
  severe_slope 
FROM 
  public.property_sales


/*

===============================================================
	Task 2: Ordinal or Label Encoding
===============================================================
	Handling Rules:
	Rank 1 = Excellent
	Rank 2 = Very Good
	Rank 3 = Good
	Rank 4 = Above Average
	Rank 5 = Average
	Rank 6 = Below Average
	Rank 7 = Fair
	Rank 8 = Poor
	Rank 9 = Very Poor
	
	
*/

-- **checking values** --
SELECT 
  DISTINCT OverallCond 
FROM 
  public.property_sales WITH updated_values AS (
    SELECT 
      id, 
      CASE WHEN OverallCond = 'Excellent' THEN '1' 
		   WHEN OverallCond = 'Very Good' THEN '2' 
		   WHEN OverallCond = 'Good' THEN '3' 
		   WHEN OverallCond = 'Above Average' THEN '4' 
		   WHEN OverallCond = 'Average' THEN '5' 
		   WHEN OverallCond = 'Below Average' THEN '6' 
		   WHEN OverallCond = 'Fair' THEN '7' 
		   WHEN OverallCond = 'Poor' THEN '8' 
		   WHEN OverallCond = 'Very Poor' THEN '9' 
		   ELSE NULL END AS OverallCond 
    FROM 
      public.property_sales
  ) 
UPDATE 
  public.property_sales 
SET 
  OverallCond = updated_values.OverallCond 
FROM 
  updated_values 
WHERE 
  property_sales.id = updated_values.id;
  
  
-- **setting OverallCond to integer** --
ALTER TABLE 
  public.property_sales 

ALTER COLUMN OverallCond 
TYPE INTEGER USING OverallCond :: INTEGER;


-- **rechecking distinct entries** --
SELECT 
  DISTINCT OverallCond 
FROM 
  public.property_sales


/*

===============================================================
	Task 3: Mean Encoding
===============================================================

*/

WITH updated_values AS (
  SELECT 
    id, 
    LotShape, 
    LotArea, 
    ROUND(
      AVG(LotArea) OVER(PARTITION BY LotShape), 
      2
    ):: VARCHAR AS mean_lotarea 
  FROM 
    public.property_sales
) 
UPDATE 
  public.property_sales 
SET 
  LotShape = updated_values.mean_lotarea 
FROM 
  updated_values 
WHERE 
  property_sales.id = updated_values.id;


-- **converting to float** --
ALTER TABLE 
  public.property_sales ALTER COLUMN LotShape TYPE FLOAT USING LotShape :: FLOAT;


-- **checking values** --
SELECT 
  id, 
  LotShape, 
  LotArea 
FROM 
  public.property_sales


/*

===============================================================
	Task 4: Mean Normalization
===============================================================

	Handling Rules:
	X' = (X - Mean(X)) / (Max(X) - Min(X))


*/

SELECT
    id,
	
    ROUND(
        (LotFrontage - AVG(LotFrontage) OVER ())
        / (MAX(LotFrontage) OVER () - MIN(LotFrontage) OVER ()),
        2
    ) AS mnorm_lotfrontage,
	
    ROUND(
        (LotArea - AVG(LotArea) OVER ())
        / (MAX(LotArea) OVER () - MIN(LotArea) OVER ()),
        2
    ) AS mnorm_lotarea,
	
    ROUND(
        (GarageArea - AVG(GarageArea) OVER ())
        / (MAX(GarageArea) OVER () - MIN(GarageArea) OVER ()),
        2
    ) AS mnorm_garagearea,
	
    ROUND(
        (TotalBsmtSF - AVG(TotalBsmtSF) OVER ())
        / (MAX(TotalBsmtSF) OVER () - MIN(TotalBsmtSF) OVER ()),
        2
    ) AS mnorm_totalbsmtsf,
	
    ROUND(
        (SalePrice - AVG(SalePrice) OVER ())
        / (MAX(SalePrice) OVER () - MIN(SalePrice) OVER ()),
        2
    ) AS mnorm_saleprice
	
FROM public.property_sales
GROUP BY id;


-- **creating mnorm_ columns** --
ALTER TABLE PUBLIC.property_sales ADD COLUMN mnorm_lotfrontage float;
ALTER TABLE PUBLIC.property_sales ADD COLUMN mnorm_lotarea float;
ALTER TABLE PUBLIC.property_sales ADD COLUMN mnorm_garagearea float;
ALTER TABLE PUBLIC.property_sales ADD COLUMN mnorm_totalbsmtsf float;
ALTER TABLE PUBLIC.property_sales ADD COLUMN mnorm_saleprice float;
ALTER TABLE PUBLIC.property_sales ADD COLUMN mnorm_grlivarea float;


-- **populating the mnorm_ columns** --

-- **mnorm_lotfrontage** --
WITH updated_values AS (
    SELECT
        id,
        ROUND(
            (LotFrontage - AVG(LotFrontage) OVER())
            / (MAX(LotFrontage) OVER() - MIN(LotFrontage) OVER()),
            2
        ) AS mnorm_lotfrontage,
        ROUND(
            (LotArea - AVG(LotArea) OVER())
            / (MAX(LotArea) OVER() - MIN(LotArea) OVER()),
            2
        ) AS mnorm_lotarea,
        ROUND(
            (GarageArea - AVG(GarageArea) OVER())
            / (MAX(GarageArea) OVER() - MIN(GarageArea) OVER()),
            2
        ) AS mnorm_garagearea,
        ROUND(
            (TotalBsmtSF - AVG(TotalBsmtSF) OVER())
            / (MAX(TotalBsmtSF) OVER() - MIN(TotalBsmtSF) OVER()),
            2
        ) AS mnorm_totalbsmtsf,
        ROUND(
            (SalePrice - AVG(SalePrice) OVER())
            / (MAX(SalePrice) OVER() - MIN(SalePrice) OVER()),
            2
        ) AS mnorm_saleprice
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET mnorm_lotfrontage = uv.mnorm_lotfrontage
FROM updated_values uv
WHERE ps.id = uv.id;


-- **mnorm_lotarea** --
WITH updated_values AS (
    SELECT
        id,
        ROUND(
            (LotFrontage - AVG(LotFrontage) OVER())
            / (MAX(LotFrontage) OVER() - MIN(LotFrontage) OVER()),
            2
        ) AS mnorm_lotfrontage,
        ROUND(
            (LotArea - AVG(LotArea) OVER())
            / (MAX(LotArea) OVER() - MIN(LotArea) OVER()),
            2
        ) AS mnorm_lotarea,
        ROUND(
            (GarageArea - AVG(GarageArea) OVER())
            / (MAX(GarageArea) OVER() - MIN(GarageArea) OVER()),
            2
        ) AS mnorm_garagearea,
        ROUND(
            (TotalBsmtSF - AVG(TotalBsmtSF) OVER())
            / (MAX(TotalBsmtSF) OVER() - MIN(TotalBsmtSF) OVER()),
            2
        ) AS mnorm_totalbsmtsf,
        ROUND(
            (SalePrice - AVG(SalePrice) OVER())
            / (MAX(SalePrice) OVER() - MIN(SalePrice) OVER()),
            2
        ) AS mnorm_saleprice
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET mnorm_lotarea = uv.mnorm_lotarea
FROM updated_values uv
WHERE ps.id = uv.id;


-- **mnorm_garagearea** --
WITH updated_values AS (
    SELECT
        id,
        ROUND(
            (LotFrontage - AVG(LotFrontage) OVER())
            / (MAX(LotFrontage) OVER() - MIN(LotFrontage) OVER()),
            2
        ) AS mnorm_lotfrontage,
        ROUND(
            (LotArea - AVG(LotArea) OVER())
            / (MAX(LotArea) OVER() - MIN(LotArea) OVER()),
            2
        ) AS mnorm_lotarea,
        ROUND(
            (GarageArea - AVG(GarageArea) OVER())
            / (MAX(GarageArea) OVER() - MIN(GarageArea) OVER()),
            2
        ) AS mnorm_garagearea,
        ROUND(
            (TotalBsmtSF - AVG(TotalBsmtSF) OVER())
            / (MAX(TotalBsmtSF) OVER() - MIN(TotalBsmtSF) OVER()),
            2
        ) AS mnorm_totalbsmtsf,
        ROUND(
            (SalePrice - AVG(SalePrice) OVER())
            / (MAX(SalePrice) OVER() - MIN(SalePrice) OVER()),
            2
        ) AS mnorm_saleprice
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET mnorm_garagearea = uv.mnorm_garagearea
FROM updated_values uv
WHERE ps.id = uv.id;


-- **mnorm_totalbsmtsf** --
WITH updated_values AS (
    SELECT
        id,
        ROUND(
            (LotFrontage - AVG(LotFrontage) OVER())
            / (MAX(LotFrontage) OVER() - MIN(LotFrontage) OVER()),
            2
        ) AS mnorm_lotfrontage,
        ROUND(
            (LotArea - AVG(LotArea) OVER())
            / (MAX(LotArea) OVER() - MIN(LotArea) OVER()),
            2
        ) AS mnorm_lotarea,
        ROUND(
            (GarageArea - AVG(GarageArea) OVER())
            / (MAX(GarageArea) OVER() - MIN(GarageArea) OVER()),
            2
        ) AS mnorm_garagearea,
        ROUND(
            (TotalBsmtSF - AVG(TotalBsmtSF) OVER())
            / (MAX(TotalBsmtSF) OVER() - MIN(TotalBsmtSF) OVER()),
            2
        ) AS mnorm_totalbsmtsf,
        ROUND(
            (SalePrice - AVG(SalePrice) OVER())
            / (MAX(SalePrice) OVER() - MIN(SalePrice) OVER()),
            2
        ) AS mnorm_saleprice
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET mnorm_totalbsmtsf = uv.mnorm_totalbsmtsf
FROM updated_values uv
WHERE ps.id = uv.id;


-- **mnorm_saleprice** --
WITH updated_values AS (
    SELECT
        id,
        ROUND(
            (LotFrontage - AVG(LotFrontage) OVER())
            / (MAX(LotFrontage) OVER() - MIN(LotFrontage) OVER()),
            2
        ) AS mnorm_lotfrontage,
        ROUND(
            (LotArea - AVG(LotArea) OVER())
            / (MAX(LotArea) OVER() - MIN(LotArea) OVER()),
            2
        ) AS mnorm_lotarea,
        ROUND(
            (GarageArea - AVG(GarageArea) OVER())
            / (MAX(GarageArea) OVER() - MIN(GarageArea) OVER()),
            2
        ) AS mnorm_garagearea,
        ROUND(
            (TotalBsmtSF - AVG(TotalBsmtSF) OVER())
            / (MAX(TotalBsmtSF) OVER() - MIN(TotalBsmtSF) OVER()),
            2
        ) AS mnorm_totalbsmtsf,
        ROUND(
            (SalePrice - AVG(SalePrice) OVER())
            / (MAX(SalePrice) OVER() - MIN(SalePrice) OVER()),
            2
        ) AS mnorm_saleprice
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET mnorm_saleprice = uv.mnorm_saleprice
FROM updated_values uv
WHERE ps.id = uv.id;


-- **mnorm_grlivarea** --
WITH updated_values AS (
    SELECT
        id,
        ROUND(
            (GrLivArea - AVG(GrLivArea) OVER())
            / (MAX(GrLivArea) OVER() - MIN(GrLivArea) OVER()),
            2
        ) AS mnorm_grlivarea
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET mnorm_grlivarea = uv.mnorm_grlivarea
FROM updated_values uv
WHERE ps.id = uv.id;


-- **checking results** --
SELECT
    id,
    mnorm_lotfrontage,
    mnorm_lotarea,
    mnorm_garagearea,
    mnorm_totalbsmtsf,
    mnorm_saleprice,
    mnorm_grlivarea
FROM public.property_sales;


/*

===============================================================
	Task 5: Standardization
===============================================================

	Handling Rules:
	X' = (X - MEAN(X)) / STDV(X)


*/

SELECT
    id,
    ROUND(
        (LotFrontage - AVG(LotFrontage) OVER())
        / STDDEV_SAMP(LotFrontage) OVER(),
        2
    ) AS std_lotfrontage,
    ROUND(
        (LotArea - AVG(LotArea) OVER())
        / STDDEV_SAMP(LotArea) OVER(),
        2
    ) AS std_lotarea,
    ROUND(
        (GarageArea - AVG(GarageArea) OVER())
        / STDDEV_SAMP(GarageArea) OVER(),
        2
    ) AS std_garagearea,
    ROUND(
        (GrLivArea - AVG(GrLivArea) OVER())
        / STDDEV_SAMP(GrLivArea) OVER(),
        2
    ) AS std_grlivarea,
    ROUND(
        (TotalBsmtSF - AVG(TotalBsmtSF) OVER())
        / STDDEV_SAMP(TotalBsmtSF) OVER(),
        2
    ) AS std_totalbsmtsf,
    ROUND(
        (SalePrice - AVG(SalePrice) OVER())
        / STDDEV_SAMP(SalePrice) OVER(),
        2
    ) AS std_saleprice
FROM public.property_sales
GROUP BY id;


-- **adding std_ columns** --
ALTER TABLE public.property_sales ADD COLUMN std_lotfrontage FLOAT;
ALTER TABLE public.property_sales ADD COLUMN std_lotarea FLOAT;
ALTER TABLE public.property_sales ADD COLUMN std_garagearea FLOAT;
ALTER TABLE public.property_sales ADD COLUMN std_grlivarea FLOAT;
ALTER TABLE public.property_sales ADD COLUMN std_totalbsmtsf FLOAT;
ALTER TABLE public.property_sales ADD COLUMN std_saleprice FLOAT;


-- **std_lotfrontage** --
WITH updated_values AS (
    SELECT
        id,
		
        ROUND((LotFrontage - AVG(LotFrontage) OVER()) 
		/ STDDEV_SAMP(LotFrontage) OVER(), 2) AS std_lotfrontage,
		
        ROUND((LotArea - AVG(LotArea) OVER())       
		/ STDDEV_SAMP(LotArea) OVER(), 2) AS std_lotarea,
		
        ROUND((GarageArea - AVG(GarageArea) OVER()) 
		/ STDDEV_SAMP(GarageArea) OVER(), 2) AS std_garagearea,
		
        ROUND((GrLivArea - AVG(GrLivArea) OVER())   
		/ STDDEV_SAMP(GrLivArea) OVER(), 2) AS std_grlivarea,
		
        ROUND((TotalBsmtSF - AVG(TotalBsmtSF) OVER()) 
		/ STDDEV_SAMP(TotalBsmtSF) OVER(), 2) AS std_totalbsmtsf,
		
        ROUND((SalePrice - AVG(SalePrice) OVER())   
		/ STDDEV_SAMP(SalePrice) OVER(), 2) AS std_saleprice
		
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET std_lotfrontage = uv.std_lotfrontage
FROM updated_values uv
WHERE ps.id = uv.id;

-- **std_lotarea** --
WITH updated_values AS (
    SELECT
        id,
		
        ROUND((LotFrontage - AVG(LotFrontage) OVER()) 
		/ STDDEV_SAMP(LotFrontage) OVER(), 2) AS std_lotfrontage,
		
        ROUND((LotArea - AVG(LotArea) OVER())   
		/ STDDEV_SAMP(LotArea) OVER(), 2) AS std_lotarea,
		
        ROUND((GarageArea - AVG(GarageArea) OVER()) 
		/ STDDEV_SAMP(GarageArea) OVER(), 2) AS std_garagearea,
		
        ROUND((GrLivArea - AVG(GrLivArea) OVER())   
		/ STDDEV_SAMP(GrLivArea) OVER(), 2) AS std_grlivarea,
		
        ROUND((TotalBsmtSF - AVG(TotalBsmtSF) OVER()) 
		/ STDDEV_SAMP(TotalBsmtSF) OVER(), 2) AS std_totalbsmtsf,
		
        ROUND((SalePrice - AVG(SalePrice) OVER())   
		/ STDDEV_SAMP(SalePrice) OVER(), 2) AS std_saleprice
		
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET std_lotarea = uv.std_lotarea
FROM updated_values uv
WHERE ps.id = uv.id;


-- **std_garagearea** --
WITH updated_values AS (
    SELECT
        id,
		
        ROUND((LotFrontage - AVG(LotFrontage) OVER()) 
		/ STDDEV_SAMP(LotFrontage) OVER(), 2) AS std_lotfrontage,
		
        ROUND((LotArea - AVG(LotArea) OVER())   
		/ STDDEV_SAMP(LotArea) OVER(), 2) AS std_lotarea,
		
        ROUND((GarageArea - AVG(GarageArea) OVER()) 
		/ STDDEV_SAMP(GarageArea) OVER(), 2) AS std_garagearea,
		
        ROUND((GrLivArea - AVG(GrLivArea) OVER())   
		/ STDDEV_SAMP(GrLivArea) OVER(), 2) AS std_grlivarea,
		
        ROUND((TotalBsmtSF - AVG(TotalBsmtSF) OVER()) 
		/ STDDEV_SAMP(TotalBsmtSF) OVER(), 2) AS std_totalbsmtsf,
		
        ROUND((SalePrice - AVG(SalePrice) OVER())   
		/ STDDEV_SAMP(SalePrice) OVER(), 2) AS std_saleprice
	
    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET std_garagearea = uv.std_garagearea
FROM updated_values uv
WHERE ps.id = uv.id;


-- **std_grlivarea** --
WITH updated_values AS (
    SELECT
        id,
		
        ROUND((LotFrontage - AVG(LotFrontage) OVER()) 
		/ STDDEV_SAMP(LotFrontage) OVER(), 2) AS std_lotfrontage,
		
        ROUND((LotArea - AVG(LotArea) OVER())   
		/ STDDEV_SAMP(LotArea) OVER(), 2) AS std_lotarea,
		
        ROUND((GarageArea - AVG(GarageArea) OVER()) 
		/ STDDEV_SAMP(GarageArea) OVER(), 2) AS std_garagearea,
		
        ROUND((GrLivArea - AVG(GrLivArea) OVER())   
		/ STDDEV_SAMP(GrLivArea) OVER(), 2) AS std_grlivarea,
		
        ROUND((TotalBsmtSF - AVG(TotalBsmtSF) OVER()) 
		/ STDDEV_SAMP(TotalBsmtSF) OVER(), 2) AS std_totalbsmtsf,
		
        ROUND((SalePrice - AVG(SalePrice) OVER())   
		/ STDDEV_SAMP(SalePrice) OVER(), 2) AS std_saleprice

    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET std_grlivarea = uv.std_grlivarea
FROM updated_values uv
WHERE ps.id = uv.id;


-- **std_totalbsmtsf** --
WITH updated_values AS (
    SELECT
        id,
		
        ROUND((LotFrontage - AVG(LotFrontage) OVER()) 
		/ STDDEV_SAMP(LotFrontage) OVER(), 2) AS std_lotfrontage,
		
        ROUND((LotArea - AVG(LotArea) OVER())   
		/ STDDEV_SAMP(LotArea) OVER(), 2) AS std_lotarea,
		
        ROUND((GarageArea - AVG(GarageArea) OVER()) 
		/ STDDEV_SAMP(GarageArea) OVER(), 2) AS std_garagearea,
		
        ROUND((GrLivArea - AVG(GrLivArea) OVER())   
		/ STDDEV_SAMP(GrLivArea) OVER(), 2) AS std_grlivarea,
		
        ROUND((TotalBsmtSF - AVG(TotalBsmtSF) OVER()) 
		/ STDDEV_SAMP(TotalBsmtSF) OVER(), 2) AS std_totalbsmtsf,
		
        ROUND((SalePrice - AVG(SalePrice) OVER())   
		/ STDDEV_SAMP(SalePrice) OVER(), 2) AS std_saleprice

    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET std_totalbsmtsf = uv.std_totalbsmtsf
FROM updated_values uv
WHERE ps.id = uv.id;


-- **std_saleprice** --
WITH updated_values AS (
    SELECT
        id,
		
        ROUND((LotFrontage - AVG(LotFrontage) OVER()) 
		/ STDDEV_SAMP(LotFrontage) OVER(), 2) AS std_lotfrontage,
		
        ROUND((LotArea - AVG(LotArea) OVER())   
		/ STDDEV_SAMP(LotArea) OVER(), 2) AS std_lotarea,
		
        ROUND((GarageArea - AVG(GarageArea) OVER()) 
		/ STDDEV_SAMP(GarageArea) OVER(), 2) AS std_garagearea,
		
        ROUND((GrLivArea - AVG(GrLivArea) OVER())   
		/ STDDEV_SAMP(GrLivArea) OVER(), 2) AS std_grlivarea,
		
        ROUND((TotalBsmtSF - AVG(TotalBsmtSF) OVER()) 
		/ STDDEV_SAMP(TotalBsmtSF) OVER(), 2) AS std_totalbsmtsf,
		
        ROUND((SalePrice - AVG(SalePrice) OVER())   
		/ STDDEV_SAMP(SalePrice) OVER(), 2) AS std_saleprice

    FROM public.property_sales
    GROUP BY id
)
UPDATE public.property_sales ps
SET std_saleprice = uv.std_saleprice
FROM updated_values uv
WHERE ps.id = uv.id;


-- **Checking std_ outputs** --
SELECT
    id,
    std_lotfrontage,
    std_lotarea,
    std_garagearea,
    std_grlivarea,
    std_totalbsmtsf,
    std_saleprice
FROM public.property_sales;


-- **Checking final output** --
SELECT *
FROM public.property_sales
ORDER BY id ASC;
