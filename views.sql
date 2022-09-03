SET search_path TO analysis;--ранее было подключено к схеме analysis, но в ручном режиме
--view for users
create or replace view analysis.users as 
select * from production.users;
--view for orders
create or replace view analysis.orders as 
select * from production.orders;
--view for products
create or replace view analysis.products as 
select * from production.products;
--view for orderstatuses
create or replace view analysis.orderstatuses as 
select * from production.orderstatuses;