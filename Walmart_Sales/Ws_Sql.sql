create database if not exists walmart_sales;
use walmart_sales;
select * from ws;

select count(distinct(Payment)) from ws;


-- --- Data Cleaning and changing --- --

-- 1) time_of_day
select time,
(case 
      when time between "00:00:00" and "12:00:00" then "Morning"
      when time between "12:01:00" and "16:00:00" then "Afternoon"
      else "Evening"
      end
      ) as time_of_date
from ws;

alter table ws
add column time_of_date varchar(20);
select * from ws;

alter table ws
change column time_of_date time_of_day varchar(20);
set sql_safe_updates=0;
update ws
set time_of_date = (
case 
      when time between "00:00:00" and "12:00:00" then "Morning"
      when time between "12:01:00" and "16:00:00" then "Afternoon"
      else "Evening"
end
); 
select * from ws; 


-- 2) day_name --

select date,dayname(date) from ws;

alter table ws
add column day_name varchar(20);

update ws
set day_name=dayname(date);
select * from  ws;

-- 3)Month_name
# add a column for month_Name
alter table ws
add column Month varchar(20);

# update Month names in table
set sql_safe_updates=0;
update ws
set month=(select monthname(Date));

alter table ws
change column Month month_name varchar(20);

select * from ws;


-- --- Exploratory Data Analysis --- --

-- Basic Questions --
-- 1) How many unique cities does the data have?
select distinct(City) from ws;

-- 2) How many braches are there in each city?

select distinct(branch) from ws;

select distinct(city) ,branch from ws;

-- Product ---

alter table ws 
rename column `Invoice ID` to invoice_id;

-- 1) how many unique product lines does the data have?
select * from ws;
select count(distinct(`Product line`)) from ws;
select distinct(`Product line`) from ws;

-- 2) what is the most common payment method?
select Payment,count(Payment) as count from ws
group by Payment
order by count desc;

-- 3) what is the most selling product line?
select `Product line` ,count(`Product line`) as count 
from ws
group by `Product line`
order by count desc;

-- 4) what is the total revenue by month?
select distinct(month_name) from ws;
select month_name,sum(total) as revenue from ws
group by month_name
order by revenue desc;

-- 5) what month had the largest COGS?

select month_name,sum(cogs) as cogs from ws
group by month_name
order by cogs desc;

-- 6) What product line had the largest revenue?
select `product line`,sum(total) as revenue from ws
group by `Product line`
order by revenue desc;

-- 7) What is the city with the largest revenue?
select city,branch,sum(total) as revenue from ws
group by city, branch
order by revenue desc;

-- 8) What product line had the largest VAT?
select `Product line` ,sum(`tax 5%`) as Vat from ws
group by `Product line`
order by vat desc;

-- 9) Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select avg(Quantity) from ws;
select `Product line`,( 
case
    when avg(Quantity) > 6 then "Good"
    else "Bad"
end
) from ws
group by `Product line`;

-- 10) Which branch sold more products than average product sold?
select branch,sum(Quantity) as qunt from ws
group by branch
having sum(Quantity)>(select avg(Quantity) from ws);

-- 11) What is the most common product line by gender?
select `Product line`,gender, count(gender) as count from ws
group by gender, `Product line`
order by count desc;

-- 12) What is the average rating of each product line?
select `Product line`,avg(Rating) as rating from ws
group by `Product line`
order by rating desc;


-- Sales --


-- 1)Number of sales made in each time of the day per weekday
select day_name,time_of_day, count(*) as count from ws
group by day_name,time_of_day
order by count desc;

-- 2)Which of the customer types brings the most revenue?
select `Customer type`,sum(total) as revenue from ws
group by `Customer type`
order by revenue desc;

-- 3)Which city has the largest tax percent/ VAT (Value Added Tax)?
select city,round(avg(`Tax 5%`),2)as vat from ws
group by city
order by vat desc;

-- 4)Which customer type pays the most in VAT?
select `Customer type`,avg(`Tax 5%`) as vat from ws
group by `Customer type`
order by vat desc;




-- ----- Customer ------- ----

-- 1)How many unique customer types does the data have?
select * from ws;
select distinct(`Customer type`) from ws;

-- 2)How many unique payment methods does the data have?
select distinct(Payment) from ws;

-- 3)What is the most common customer type?
select `Customer type`,count(*) as count from ws
group by `Customer type`
order by count desc;

-- 4)Which customer type buys the most?
select `Customer type`,count(*) as count from ws
group by `Customer type`;

-- 5)What is the gender of most of the customers?
select Gender,count(*) from ws
group by Gender;

-- 6)What is the gender distribution per branch?
select Gender,branch,count(Gender) as count from ws
group by Gender, branch
order by count desc;

-- 7)Which time of the day do customers give most ratings?
select time_of_day , count(rating) as count from ws
group by time_of_day
order by count desc;

-- 8)Which time of the day do customers give most ratings per branch?
select time_of_day ,branch,count(Rating) as count from ws
group by time_of_day,branch
order by count desc;

-- 9)Which day of the week has the best avg ratings?
select day_name ,avg(Rating) as rating from ws
group by day_name
order by rating desc;

-- 10)Which day of the week has the best average ratings per branch?
select day_name,branch ,avg(Rating) as rating from ws
group by day_name, branch
order by rating desc;





















