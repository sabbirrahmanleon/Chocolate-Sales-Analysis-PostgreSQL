--1. Find the most popular product in every country:

with productsales as (
  select  
    sales.geoid,  
    geo.geo as country,  
    products.product,  
    sum(sales.boxes) as totalboxessold,  
    row_number() over (partition by sales.geoid order by sum(sales.boxes) desc) as number_  
  from sales  
  inner join products on sales.pid = products.pid  
  inner join geo on sales.geoid = geo.geoid  
  group by sales.geoid, geo.geo, products.product  
)  
select geoid, country, product, totalboxessold  
from productsales  
where number_ = 1;

--------------------------

-- 2. Month with the most sales in every country:

with monthlysales as (
  select  
    geo.geo as country,  
    to_char(sales.saledate, 'fmmonth yyyy') as salemonth,  
    sum(sales.amount) as totalsales,  
    row_number() over (partition by geo.geo order by sum(sales.amount) desc) as number_  
  from sales  
  inner join geo on sales.geoid = geo.geoid  
  group by geo.geo, salemonth  
)  
select country, salemonth, totalsales  
from monthlysales  
where number_ = 1;


--------------------------

-- 3. Which regions have more selling persons?

select 
  geo.region, 
  count(distinct people.spid) as total_sales_persons
from people
inner join sales on people.spid = sales.spid
inner join geo on sales.geoid = geo.geoid
group by geo.region
order by total_sales_persons desc;


--------------------------

-- 4. Top 3 countries considering selling persons:

select 
  geo.geo as country, 
  count(distinct sales.spid) as salespersons_count
from sales
inner join geo on sales.geoid = geo.geoid
group by geo.geo
order by salespersons_count desc
limit 3;


--------------------------

-- 5. Top 3 countries considering selling days in 4 amount categories:

with sales_categories as (
  select 
    geo.geo as country, 
    count(distinct sales.saledate) as total_days,
    case 
      when sum(sales.amount) >= 10000 then '10k or more'
      when sum(sales.amount) < 10000 and sum(sales.amount) >= 5000 then 'under 10k'
      when sum(sales.amount) < 5000 and sum(sales.amount) >= 1000 then 'under 5k'
      else 'under 1k'
    end as sales_category
  from sales
  join geo on sales.geoid = geo.geoid
  group by geo.geo
)
select country, sales_category, total_days
from sales_categories
order by sales_category, total_days desc
limit 3;


--------------------------

-- 6. Salespersons with no shipments in the first 7 days of January 2022:

select people.salesperson, people.spid
from people
where not exists (
  select people.salesperson 
  from sales
  where people.spid = sales.spid 
  and sales.saledate between '2022-01-01' and '2022-01-07'
);
