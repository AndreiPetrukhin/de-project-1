insert into analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
select
	trr.user_id,
	trr.recency,
	trf.frequency,
	trmv.monetary_value
from tmp_rfm_recency trr
join tmp_rfm_frequency trf on trf.user_id = trr.user_id
join tmp_rfm_monetary_value trmv on trmv.user_id = trr.user_id;

--the first 10 rows request
select * from dm_rfm_segments drs
order by user_id
limit 10;

--the first 10 rows
0	1	3	4
1	4	3	3
2	2	3	5
3	2	3	3
4	4	3	3
5	5	5	5
6	1	3	5
7	4	2	2
8	1	2	3
9	1	2	2