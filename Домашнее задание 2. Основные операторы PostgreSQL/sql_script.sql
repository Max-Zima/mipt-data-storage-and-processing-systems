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
select distinct brand from transaction_20240101
where standard_cost > 1500;

-- Задание 2 --
select * from transaction_20240101 
where order_status = 'Approved' 
and transaction_date::date between '2017-04-01' and '2017-04-09';

-- Задание 3 --
select distinct job_title from customer_20240101
where job_industry_category in ('IT', 'Financial Services') and job_title like 'Senior%';

-- Задание 4 --
select distinct transaction_20240101.brand from transaction_20240101
inner join customer_20240101 on customer_20240101.customer_id = transaction_20240101.customer_id
where customer_20240101.job_industry_category = 'Financial Services' and transaction_20240101.brand like '_%';

-- Задание 5 --
select distinct c.customer_id, c.first_name, c.last_name, c.job_title, t.online_order from customer_20240101 c
inner join transaction_20240101 t on c.customer_id = t.customer_id
where t.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
and t.online_order = 'True'
limit 10;

-- Задание 6 --
-- Вариант решения 1 --
select c.customer_id, c.first_name, c.last_name from customer_20240101 c
where c.customer_id not in (select distinct t.customer_id from transaction_20240101 t);

-- Вариант решения 2 --
select c.customer_id, c.first_name, c.last_name from customer_20240101 c
full outer join transaction_20240101 t on c.customer_id = t.customer_id
where t.customer_id is null;

-- Задание 7 --
-- Версия с максимальной стандратной стоимостью вообще --
select distinct c.* from customer_20240101 c
left join transaction_20240101 t on c.customer_id = t.customer_id
where c.job_industry_category = 'IT' 
and t.standard_cost = (select max(standard_cost) from transaction_20240101);

-- Версия с максимальной стандратной стоимостью относительно IT --
select distinct * from customer_20240101 c
left join transaction_20240101 t on c.customer_id = t.customer_id
where c.job_industry_category = 'IT' 
and t.standard_cost = (select max(t2.standard_cost) from transaction_20240101 t2
					   inner join customer_20240101 c2 on c2.customer_id = t2.customer_id
    				   where c2.job_industry_category = 'IT');

-- Задание 8 --
select distinct c.* from customer_20240101 c
inner join transaction_20240101 t on c.customer_id = t.customer_id
where c.job_industry_category in ('IT', 'Health')
and t.order_status = 'Approved' 
and t.transaction_date::date BETWEEN '2017-07-07' and '2017-07-17';