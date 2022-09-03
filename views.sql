--view for users
create or replace view users as 
select * from production.users;
--view for orders
create or replace view orders as 
select * from production.orders;
--view for products
create or replace view products as 
select * from production.products;
--view for orderstatuses
create or replace view orderstatuses as 
select * from production.orderstatuses;
--view for orderstatuslog
create or replace view orderstatuslog as 
select * from production.orderstatuslog;
--view for orderitems
create or replace view orderitems as 
select * from production.orderitems;