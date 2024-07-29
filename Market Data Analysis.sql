		-- Project Title: Intermediate Customer Data Management and Analysis using SQL
-- 1. Database Setup:        
--  Create a new database to store the customer data
create database CustomerData;

-- Load the dataset into the database
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\marketing_data.csv"
INTO TABLE marketing_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 2. Data Cleaning and Preparation:
--  Identify and handle missing or null values
select * from marketing_data
where ID is null;

--  Correct data types where necessary (e.g., convert `Income` from string to numeric).
update marketing_data
set Income = replace(Income, "$","");
update marketing_data
set Income = replace(Income, ",","");
alter table marketing_data
modify Income int;

--  Ensure that date fields are in the correct format
-- Replace "/" with "-"
update marketing_data
set Dt_Customer  = Replace(Dt_Customer, "/","-");

-- Set column Dt_Customer to the right data type
update marketing_data
set Dt_Customer = str_to_date(Dt_Customer, '%m-%d-%YYYY');

-- Checking for Duplicates
SELECT id FROM marketing_data
group by ID
HAVING COUNT(*) > 1;

-- Delete Duplicate rows from the table
 create temporary table temp_marketing_data as select distinct * from marketing_data;
-- truncate table marketing_data;
Insert into marketing_data 
 select * from temp_marketing_data;

-- Replace Values on Education Column
-- Replace Graduation to Graduate
update marketing_data
set Education = "Graduate"
where Education = "Graduation";

-- Replace 2n Cycle, Basic to Undergraduate
update marketing_data
set Education = "Undergraduate"
where Education regexp "^(2n|Basic)";

-- Replace PhD, Master to Post Graduate
update marketing_data
set Education = "Post Graduate"
where Education regexp "^(PhD|Master)";

-- Replace Married, Together to Partner
update marketing_data
set Marital_Status = "Partner"
where Marital_Status regexp "^(Married|Together)";

-- Replace Single, Divorced, Widow, Alone, Absurd, YOLO to Alone
update marketing_data
set Marital_Status = "Alone"
where Marital_Status regexp "^(Single|Divorced|Widow|Alone|Absurd|YOLO)";


-- Create New column for Age 
alter table marketing_data
add column Age int;
-- Add values into column age
update marketing_data
set Age = (year(current_date())-Year_Birth);
-- To know the minimum and maximum age
select max(age),min(age) from marketing_data;
-- Add new column Age-group
Alter table marketing_data
add column Age_Group Varchar(20);

-- Add values into Age_Group
Update marketing_data
Set Age_Group = Case
					when Age between 12 and 27 then "Gen Z" 
                    when Age between 28 and 43 then "Millennials"
                    when Age between 44 and 59 then "Gen X"
                    when Age between 60 and 78 then "Baby Boomers"
                    when Age between 79 and 96 then "Silent Generation"
                    Else "Other"
				End;
                
-- Add columns Kidhome and Teenhome together
alter table marketing_data
add column No_of_Children int;
update marketing_data
set No_of_Children = Kidhome+Teenhome;

-- Add columns MntWines,MntFruits,MntMeatProducts,MntFishProducts,MntSweetProducts,MntGoldProds as Monetary
alter table marketing_data
add column Monetary_Value int;
update marketing_data
set Monetary_Value = MntWines+MntFruits+MntMeatProducts+MntFishProducts+MntSweetProducts+MntGoldProds;

-- Add column NumWebPurchases+NumCatalogPurchases+NumStorePurchases as Frequency
Alter table marketing_data
add column Frequency int;
update marketing_data
set Frequency = NumWebPurchases+NumCatalogPurchases+NumStorePurchases;

--  Add column AcceptedCmp3+AcceptedCmp4+AcceptedCmp5+AcceptedCmp1+AcceptedCmp2+Response as Response_Accepted
Alter table marketing_data
add column Response_Accepted int;
update marketing_data
set Response_Accepted =AcceptedCmp3+AcceptedCmp4+AcceptedCmp5+AcceptedCmp1+AcceptedCmp2+Response;


		-- 3. Advanced Querying:
-- Write complex queries to extract meaningful insights from the data.
-- Use aggregate functions (SUM, AVG, COUNT, MAX, MIN) to calculate summary statistics.
-- Implement JOIN operations to combine data from multiple tables if necessary.
-- Utilize subqueries and common table expressions (CTEs) for more advanced data manipulation.

-- 1. Average Income
select concat("$",avg(income))as Avg_Income from marketing_data;

-- 2. Total Number of Customers
select count(id) as No_of_Customers from marketing_data;

-- 3. The Min and Max customer's income
select min(Income) as MIN_Income, max(Income) as Max_Income from marketing_data;

-- 4. Total Spending by each Customer 
select concat("$",sum(Monetary_Value)) as
total_spents from marketing_data;

-- 5. Top 10 Customers by Total Spendings
select ID, concat("$",sum(Monetary_Value)) as 
total_spents from marketing_data
group by ID
order by total_spents desc
limit 10;

-- 6. Customers with above average income
select ID,concat("$",Income) as Income
from marketing_data
where Income > (select concat("$",avg(Income)) from marketing_data)
order by Income desc
limit 5;

-- 7. Customers who made purchases above average in any category
Select ID from marketing_data
where MntWines > (select avg(MntWines) from marketing_data) 
 or MntFruits > (Select avg(MntFruits) from marketing_data)
or
 MntMeatProducts > (select avg(MntMeatProducts) from marketing_data)
or
 MntFishProducts > (select avg(MntFishProducts) from marketing_data)
or
 MntSweetProducts > (select avg(MntSweetProducts) from marketing_data)
or
 MntGoldProds > (select avg(MntGoldProds) from marketing_data); 

	-- 4. Customer Segmentation:
 -- Create segments of customers based on demographics, purchasing behavior, and responses to campaigns.
 -- Write queries to identify top-performing segments based on total spending, frequency of purchases, or campaign responses.

-- 1. Customers from each country
select Country, count(Country) as No_of_Customers from marketing_data
group by Country;

-- 2.Country by Total Spending
select Country, concat("$",sum(Monetary_Value)) as Total_Spending from marketing_data
group by Country;

-- 3.  Aducation Level by Total Spending
select Education, concat("$",sum(Monetary_Value)) as Total_Spending from marketing_data
group by Education;

-- 4.  Marital Status by Total_Spending
select Marital_Status, concat("$",sum(Monetary_Value)) as Total_Spending from marketing_data
group by Marital_Status;

-- 5. Age Group by Total_Spending
select Age_Group, concat("$",sum(Monetary_Value)) as Total_Spending from marketing_data
group by Age_Group;

-- 6. Education Level by Frequency of Purchases
select Education, Sum(Frequency) as Total_Purchases from marketing_data
group by Education;

-- 7. Age Group by Frequency
select Age_Group, Sum(Frequency) as Total_Purchases from marketing_data
group by Age_Group;

-- 8. Age Group by Campaign Responses
Select Age_Group, 
sum(Response_Accepted) as Total_Response
from marketing_data
group by Age_Group
order by Total_Response desc;

-- 9. Age group by Monetary value, Frequency, Response Accepted
select Age_Group, concat("$",sum(Monetary_Value)) Monetary_Value , sum(Frequency) Frequency, sum(Response_Accepted) Response_Accepted
from marketing_data
group by Age_Group;

-- 10. Education by Monetary value, Frequency, Response Accepted
select Education, concat("$",sum(Monetary_Value)) Monetary_Value, sum(Frequency) Frequency, sum(Response_Accepted) Response_Accepted
from marketing_data
group by Education;


 -- 11. Age Group by Amount Segment of food purchases
 select Age_Group, sum(MntWines) Wine,sum(MntFruits) Fruits ,sum(MntMeatProducts) Meat ,
 sum(MntFishProducts) Fish, sum(MntSweetProducts) Sweet, sum(MntGoldProds) Gold,sum(Monetary_Value) Total
 from marketing_data
 group by Age_Group
 order by Total desc;
 
-- 5 Market Campaign Analysis
-- Analyze the effectiveness of different marketing campaigns.
-- Write queries to calculate the response rates for each campaign.
 -- Identify customers who have accepted multiple campaigns and analyze their behavior.
 
-- 1. Response rate for each marketing campaign
select (sum(AcceptedCmp1)/count(*))*100 as Respose_rate1,
		(sum(AcceptedCmp2)/count(*))*100 as Respose_rate2,
		(sum(AcceptedCmp3)/count(*))*100 as Respose_rate3,
        (sum(AcceptedCmp4)/count(*))*100 as Respose_rate4,
        (sum(AcceptedCmp5)/count(*))*100 as Respose_rate5,
        (sum(Response)/count(*))*100 as Response
			from marketing_data;
            
-- 2. Customers who accepted multiple campaigns
select ID from marketing_data
where AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+AcceptedCmp4+AcceptedCmp5+Response > 1
limit 10;

-- 3. Customers who accepted multiple campaigns analyze their behavior
with cte2 as (select ID,No_of_Children,Marital_Status,country,Income from marketing_data
where AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+AcceptedCmp4+AcceptedCmp5 > 1)
select ID, count(No_of_Children) as No_of_Children from cte2
group by ID
limit 10;

-- 6. Recency, Frequency, Monetary (RFM) Analysis:
-- Perform an RFM analysis to identify high-value customers.
 -- Write queries to calculate recency, frequency, and monetary value for each customer.
 -- Segment customers into different RFM categories.
 
-- 1. Perform an RFM analysis to identify high-value customers.
select ID,sum(Monetary_value) as highValueCustomers from marketing_data
group by ID
order by highValueCustomers desc
limit 5;

-- 2.  Write queries to calculate recency, frequency, and monetary value for each customer.        
with RFM as (select *,
ntile(5) over (order by Recency) RecencyScore,
ntile(5) over (order  by Frequency) FrequencyScore,
ntile(5) over (order by Monetary_Value) MonetaryScore
from marketing_data)
select ID, RecencyScore,FrequencyScore,MonetaryScore,
 concat(RecencyScore,FrequencyScore,MonetaryScore) as RFM_Score from RFM;

-- 3. Segment customers into different RFM categories
with SegmentCustomers as (with RFM_SCORE as (with RFM as (select *,
ntile(5) over (order by Recency desc) RecencyScore,
ntile(5) over (order  by Frequency) FrequencyScore,
ntile(5) over (order by Monetary_Value) MonetaryScore
from marketing_data)
select *,
 concat(RecencyScore,FrequencyScore,MonetaryScore) as RFM_Score
 from RFM)
 select * from RFM_SCORE
inner join segment
on
RFM_SCORE.RFM_Score = RFM_Scores)
select ID, RFM_Score,Segment from SegmentCustomers;

-- 7. Optimization and Indexing:
 -- Optimize SQL queries for performance.
 -- Implement indexing strategies to speed up query execution.
 -- Analyze query execution plans to identify and resolve performance bottlenecks.


-- for optimization, select only the columns you need
-- Process of writing sql qyery to improve database performance\
-- Use limit to preview Query results
-- Avoid select distinct if possible
-- Ensure you are using the correct join type
-- use where clauses to limit the data processed
-- Write sargable Query
-- Columns used in where, join, order by, and group by clauses are good candidates for indexing
create index inx_R on marketing_data (Recency);
create index inx_Mone on marketing_data (Monetary_Value);
create index Index_Id on marketing_data (ID);
create index Index_Age on marketing_data (Age);
create index Index_Frequency on marketing_data(Frequency);
create index Index_Income on marketing_data(Income);
create index Index_Date on marketing_data(Dt_Customer);
create index Index_RFM_Score on segment(RFM_Scores);
