--Далее вам необходимо создать витрину. Напишите запрос с CREATE TABLE и выполните его на предоставленной 
--базе данных в схеме analysis. Помните, что при создании таблицы необходимо учитывать названия полей, 
--типы данных и ограничения.
--Создайте документ datamart_ddl.sql и сохраните в него написанный запрос.
--drop table analysis.dm_rfm_segments;
create table analysis.dm_rfm_segments (
  	user_id int4 NOT NULL,
	recency numeric(1,0) NOT NULL check (recency in (1,2,3,4,5)),
	frequency numeric(1,0) NOT NULL check (recency in (1,2,3,4,5)),
	monetary_value numeric(1,0) NOT NULL check (recency in (1,2,3,4,5))
  );

--Реализуйте расчёт витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте. Для решения 
--предоставьте код запроса.
--Рассчитайте витрину поэтапно. Сначала заведите таблицы под каждый показатель:
--drop table analysis.tmp_rfm_recency;
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
--drop table analysis.tmp_rfm_frequency;
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
--drop table analysis.tmp_rfm_monetary_value;
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);