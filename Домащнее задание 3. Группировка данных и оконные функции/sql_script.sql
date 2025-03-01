create database customer_transaction

create table customer_20240101(
  customer_id int4
  , first_name varchar(50)
  , last_name varchar(50)
  , gender varchar(30)
  , DOB varchar(50)
  , job_title varchar(50)
  , job_industry_category varchar(50)
  , wealth_segment varchar(50)
  , deceased_indicator varchar(50)
  , owns_car varchar(30)
  , address varchar(50)
  , postcode varchar(30)
  , state varchar(30)
  , country varchar(30)
  , property_valuation int4
)

create table transaction_20240101(
  transaction_id int4
  , product_id int4
  , customer_id int4
  , transaction_date varchar(30)
  , online_order varchar(30)
  , order_status varchar(30)
  , brand varchar(30)
  , product_line varchar(30)
  , product_class varchar(30)
  , product_size varchar(30)
  , list_price float4
  , standard_cost float4
)

-- Задание 1 --
select job_industry_category, count(*) as cnt_customers 
from customer_20240101 c 
group by c.job_industry_category
order by cnt_customers desc;

-- Задание 2 --
select date_trunc('month', t.transaction_date::date) as t_month, c.job_industry_category, sum(t.list_price) as sum_transaction
from customer_20240101 c 
inner join transaction_20240101 t on t.customer_id = c.customer_id
group by t_month, c.job_industry_category
order by t_month, c.job_industry_category;

-- Задание 3 --
select brand, count(*) as cnt_online_orders
from transaction_20240101 t 
inner join customer_20240101 c on c.customer_id = t.customer_id 
where c.job_industry_category = 'IT' 
	and t.order_status = 'Approved'
	and t.online_order = 'True'
group by t.brand
having brand like '_%';

-- Задание 4 --
-- Используем group by --
select t.customer_id
	,sum(t.list_price) as sum_transaction
	,max(t.list_price) as max_transaction
	,min(t.list_price) as min_transaction
	,count(t.list_price) as cnt_transaction
from transaction_20240101 t 
group by t.customer_id
order by sum_transaction desc, cnt_transaction desc;

-- Используем оконную функцию --
select t.customer_id
	,sum(t.list_price) over (partition by t.customer_id) as sum_transaction
	,max(t.list_price) over (partition by t.customer_id) as max_transaction
	,min(t.list_price) over (partition by t.customer_id) as min_transaction
	,count(t.list_price) over (partition by t.customer_id) as cnt_transaction
from transaction_20240101 t 
order by sum_transaction desc, cnt_transaction desc;

-- Используем оконную функцию но чтобы не повторялись строки--
select distinct t.customer_id
	,sum(t.list_price) over (partition by t.customer_id) as sum_transaction
	,max(t.list_price) over (partition by t.customer_id) as max_transaction
	,min(t.list_price) over (partition by t.customer_id) as min_transaction
	,count(t.list_price) over (partition by t.customer_id) as cnt_transaction
from transaction_20240101 t 
order by sum_transaction desc, cnt_transaction desc;

-- Задание 5 --
-- Минимальная сумма --
-- null преобразуется в 0 --
with customer_spending as (
	select 
		c.customer_id
		,c.first_name
		,c.last_name
		,coalesce(sum(t.list_price), 0) as total_spent
	from customer_20240101 c
	left join transaction_20240101 t on c.customer_id = t.customer_id
	group by c.customer_id, c.first_name, c.last_name
)
select first_name, last_name, total_spent 
from customer_spending
where total_spent = (select min(total_spent) from customer_spending);

-- null просто не используем в запросе --
with customer_spending as (
	select 
		c.customer_id
		,c.first_name
		,c.last_name
		,sum(t.list_price) as total_spent
	from customer_20240101 c
	left join transaction_20240101 t on t.customer_id = c.customer_id
	group by c.customer_id, c.first_name, c.last_name
)
select first_name, last_name, total_spent 
from customer_spending
where total_spent = (select min(total_spent) from customer_spending);

-- Максимальная сумма --
-- null преобразуется в 0 --
create view customer_spending_2_1 as 
	select 
		c.customer_id
		,c.first_name
		,c.last_name
		,coalesce(sum(t.list_price), 0) as total_spent
	from customer_20240101 c
	left join transaction_20240101 t on c.customer_id = t.customer_id
	group by c.customer_id, c.first_name, c.last_name


select * from customer_spending_2_1 where total_spent = (select max(total_spent) from customer_spending_2_1);

-- null просто не используем в запросе --
create view customer_spending_2_2 as
	select 
		c.customer_id
		,c.first_name
		,c.last_name
		,sum(t.list_price) as total_spent
	from customer_20240101 c
	left join transaction_20240101 t on t.customer_id = c.customer_id
	group by c.customer_id, c.first_name, c.last_name

	
select * from customer_spending_2_2 where total_spent = (select max(total_spent) from customer_spending_2_2);
	
-- Задание 6 --
select customer_id, transaction_id, transaction_date 
from (select 
		customer_id
		,transaction_id
		,transaction_date
		,row_number() over (partition by customer_id order by transaction_date) as rn
from transaction_20240101
)
where rn = 1


-- Задание 7 --
with transaction_intervals as (
	select
		c.customer_id
        ,c.first_name
        ,c.last_name
        ,c.job_title
        ,lead(t.transaction_date::date) over (partition by c.customer_id order by t.transaction_date::date) - t.transaction_date::date as interval_days
    from transaction_20240101 t
    inner join customer_20240101 c on t.customer_id = c.customer_id 
)
select
	*
from transaction_intervals
where interval_days = (select max(interval_days) from transaction_intervals);
