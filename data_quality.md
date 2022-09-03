# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.
Дубли в данных. Фокусируемся на таблицах users, orders, orderstatuses, так как именно они нужны для разработки витрины данных.
1. В таблице users дублирующиеся записи отсутствуют

- select 
	- count(u.*) as unique_rows, --1000
	- count(u2.*) as total_rows  --1000
- from (select distinct * from users u) u
- join (select * from users u2) u2 on u.id = u2.id;

важно проверить отсуствуие дубликатов в колонке login, так как она не имеет ограничения уникальности

- select 
	- count(distinct login) as unique_rows, --1000
	- count(login) as total_rows  --1000
- from users u; -- дублирующиеся записи отсутствуют

2. В таблице orders дублирующиеся записи отсутствуют

- select 
	- count(o.*) as unique_rows, --10000
	- count(o2.*) as total_rows  --10000
- from (select distinct * from orders o) o
- join (select * from orders o2) o2 on o.order_id = o2.order_id;

3. В таблице orderstatuslog дублирующиеся записи отсутствуют

- select 
	- count(o.*) as unique_rows, --29982
	- count(o2.*) as total_rows  --29982
- from (select distinct * from orderstatuslog o) o
- join (select * from orderstatuslog o2) o2 on o.id = o2.id;

4. В таблице orderstatuses дублирующиеся записи отсутствуют

- select 
	- count(o.*) as unique_rows, --5
	- count(o2.*) as total_rows  --5
- from (select distinct * from orderstatuses o) o
- join (select * from orderstatuses o2) o2 on o.id = o2.id;

важно проверить отсуствуие дубликатов в колонке key, так как она не имеет ограничения уникальности

- select 
	- count(distinct key) as unique_rows, --5
	- count(key) as total_rows  --5
- from orderstatuses o; -- дублирующиеся записи отсутствуют

Пропущенные значения в важных полях. Аналогично, фокусируемся на таблицах users, orders, orderstatuses
1. Таблица users. Важной является колонка id, которая является первичным ключом и не может принимать значение null. В проверке нет необходимости.
   
2. Таблица orders. Важными являются колонки order_id, user_id, status, payment, order_ts.
- order_id является первичным ключом и не может принимать значение null. В проверке нет необходимости.
- user_id не имеет внешнего ключа к таблице users(id), соответственно может содержать id несуществующих пользователей. не может принимать значение null
  - select * from orders o
  - left join users u on u.id = o.user_id
  - where u.id is null; --значение null отсутствуют --> user_id соответствуют значениям users(id)
- status не имеет внешнего ключа к таблице orderstatuses(id), соответственно может содержать id несуществующих статусов. не может принимать значение null
  - select * from orders o
  - left join orderstatuses o2 on o2.id = o.status
  - where o2.id is null;--значение null отсутствуют --> status соответствуют значениям orderstatuses(id)
- payment не может принимать значение null и не должен ссылкаться на другие таблицы. В проверке нет необходимости.
- order_ts не может принимать значение null и не должен ссылкаться на другие таблицы. В проверке нет необходимости.
  
3. Таблица orderstatuses. Важными являются колонки id, key. Не могут принимать значение null. В проверке нет необходимости.

`Вывод` Данные не имеют дубликатов и не содержат null в важных сущностях, соответственно имеют достаточный уровень качества и могут использоваться для разработки витрины данных.

## Укажите, какие инструменты обеспечивают качество данных в источнике.
Ответ запишите в формате таблицы со следующими столбцами:
- `Наименование таблицы` - наименование таблицы, объект которой рассматриваете.
- `Объект` - Здесь укажите название объекта в таблице, на который применён инструмент. Например, здесь стоит перечислить поля таблицы, индексы и т.д.
- `Инструмент` - тип инструмента: первичный ключ, ограничение или что-то ещё.
- `Для чего используется` - здесь в свободной форме опишите, что инструмент делает.

Поиск ограничений:
- SELECT
	- "ns"."nspname" AS "table_schema",
	- "t"."relname" AS "table_name",
	- "a"."attname" AS "column_name",
    - "cnst"."conname" AS "constraint_name", pg_get_constraintdef ( "cnst"."oid" ) AS "expression",
- CASE
      - "cnst"."contype" 
      - WHEN 'p' THEN
      - 'PRIMARY' 
      - WHEN 'u' THEN
      - 'UNIQUE' 
      - WHEN 'c' THEN
      - 'CHECK' 
      - WHEN 'x' THEN
      - 'EXCLUDE' 
    - END AS "constraint_type"
- FROM
    - "pg_constraint" "cnst" 
    - INNER JOIN "pg_class" "t" ON "t"."oid" = "cnst"."conrelid"
    - INNER JOIN "pg_namespace" "ns" ON "ns"."oid" = "cnst"."connamespace"
    - LEFT JOIN "pg_attribute" "a" ON "a"."attrelid" = "cnst"."conrelid" 
    - AND "a"."attnum" = ANY ( "cnst"."conkey" );

Поиск not null ограничений:
- SELECT table_schema, table_name, column_name FROM information_schema.columns
- WHERE is_nullable = 'NO' and table_schema = 'production';

Пример ответа:

| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.Products | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.Products | price CHECK ((price >= (0)::numeric)) | Ограниечние-проверка  | Корректность значения цены |
| production.Products | price NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.Products | name NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderstatuses | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderstatuses| key NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.users | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.users | login NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orders | bonus_payment, payment, cost CHECK ((cost = (payment + bonus_payment))) | Ограниечние-проверка  | Проверка денежного платежа и платежа бонусами = стоимости заказа |
| production.orders | order_ts NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | user_id NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | status NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | bonus_payment NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | payment NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | cost NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orders | bonus_grant NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderitems | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderitems | price CHECK ((price >= (0)::numeric)) | Ограниечние-проверка  | Корректность значения цены |
| production.orderitems | price, discount CHECK (((discount >= (0)::numeric) AND (discount <= price))) | Ограниечние-проверка  | Корректность значения скидки и цены |
| production.orderitems | quantity CHECK ((quantity > 0)) | Ограниечние-проверка  | Корректность значения количества товаров |
| production.orderitems | order_id, product_id UNIQUE (order_id, product_id) | Ограниечние-уникальности  | Обеспечивает уникальность комбинации order_id, product_id |
| production.orderitems | product_id FOREIGN KEY (product_id) REFERENCES products(id) | Внешний ключ  | Обеспечивает соответствие используемых значений справочнику |
| production.orderitems | order_id FOREIGN KEY (order_id) REFERENCES orders(order_id) | Внешний ключ  | Обеспечивает соответствие используемых значений справочнику |
| production.orderitems | product_id NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderitems | order_id NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderitems | name NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderitems | quantity NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderitems | price NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderitems | discount NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderstatuslog | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderstatuslog | order_id, status_id UNIQUE (order_id, status_id) | Ограниечние-уникальности  | Обеспечивает уникальность комбинации order_id, status_id |
| production.orderstatuslog | order_id FOREIGN KEY (order_id) REFERENCES orders(order_id) | Внешний ключ  | Обеспечивает соответствие используемых значений справочнику |
| production.orderstatuslog | status_id FOREIGN KEY (status_id) REFERENCES orderstatuses(id) | Внешний ключ  | Обеспечивает соответствие используемых значений справочнику |
| production.orderstatuslog | order_id NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderstatuslog | status_id NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
| production.orderstatuslog | dttm NOT NULL | Ограниечние-проверка  | Поле обязательно для заполнения и не содержит пустых значений |
