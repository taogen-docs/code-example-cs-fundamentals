# Common SQL DQL

## Table Query

### Select Values

#### Select Values

Query insert row primary key 'id'

```sql
SELECT @userId := LAST_INSERT_ID();
```

Select domain from URL

```sql
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(link, '://', -1), '/', 1) AS domain
FROM {tableName}
```

Select row number

```sql
SELECT  *, ROW_NUMBER() OVER(ORDER BY id) AS row_num
FROM crm_account
```

#### Conditional Query

If else

```sql
select 
id, name,
(select if(count(*)>0, true, false)) as flag
from {tableName}
```

case when {condition} then {val1} else {val1} 

```sql
select (case when column_key = 'PRI' then '1' else '0' end) as is_pk
from information_schema.columns
```

if null then 0

```sql
IFNULL(expr1, 0)
IFNULL(`field`,0)
```

if match a special value set value to null

```sql
nullif(field, 'empty')
```

### Select Rows

#### Select random id with gaps

```sql
select id from recovery_data 
where id >= (SELECT CEIL(RAND() * (SELECT MAX(id) FROM recovery_data)))
order by id asc 
limit 1;
```

```sql
SELECT id FROM recovery_data ORDER BY RAND() LIMIT 10;
```

#### Select random rows no gap (rarely use)

```sql
SELECT name 
FROM tableName JOIN
(SELECT CEIL(RAND() *
             (SELECT MAX(id)
              FROM tableName)) AS id
) AS r2
USING (id)
```

#### Select random rows with gaps

Solution 1: for small data tables (less than few million rows)

```sql
-- This is fast because the sort phase only uses the indexed ID column.
SELECT t1.* FROM tbl AS t1 JOIN (SELECT id FROM tbl ORDER BY RAND() LIMIT 10) as t2 ON t1.id=t2.id
```

```sql
-- Not the efficient solution but works. Sort all rows, but only retrieve few rows.
SELECT * FROM table
ORDER BY RAND()
LIMIT 10
```

Solution 2: for large data tables

```sql
SELECT name
FROM random AS r1 JOIN
       (SELECT (RAND() *
                (SELECT MAX(id)
                 FROM random)) AS id)
        AS r2
 WHERE r1.id >= r2.id
 ORDER BY r1.id ASC
 LIMIT 1;
```

As soon as the distribution of the IDs is not equal anymore our selection of rows isn't really random either. For select a real random row, we can add a ID mapping table `holes_map`

```
row_id | random_id |
+--------+-----------+
|      1 |         1 |
|      2 |         2 |
|      3 |         4 |
|      4 |         8 |
|      5 |        16
```

```sql
SELECT name FROM random
  JOIN (SELECT r1.random_id
        FROM holes_map AS r1
        JOIN (SELECT (RAND() *
                      (SELECT MAX(row_id)
                       FROM holes_map)) AS row_id)
        AS r2
        WHERE r1.row_id >= r2.row_id
        ORDER BY r1.row_id ASC
        LIMIT 1) as rows ON (id = random_id);
```

### Filter Values

#### Filter Values

query to fetch only odd rows from the table

```sql
SELECT * 
FROM {tableName} 
WHERE MOD (userId, 2) <> 0;
```

#### String Contains

 INSTR, LOCATE, POSITION, LIKE

- INSTR (*str*,*substr*)
- LOCATE (*substr*,*str*), LOCATE (*substr*,*str*,*POS*)
- POSITION (*substr* in *str*)  POSITION (substr in str) is a synonym for LOCATE (substr,str)
- column LIKE "%substr%"

```sql
select name
from (select 'abc' as name) as temp
where INSTR(name, 'a') > 0;
```

```sql
select name
from (select 'abc' as name) as temp
where locate('a', name) > 0;

select name
from (select 'abc' as name) as temp
where POSITION("a" in name) > 0;
```

```sql
select name
from (select 'abc' as name) as temp
where name like '%a%';
```

#### Part of Datetime

Using between

```sql
`date` between '2022-07-01' and '2022-07-31'
```

Using function can't use index on MySQL

```sql
DATE_FORMAT(`date`, "%Y-%m") = "2022-07"
YEAR(`date`) = "2022" and MONTH(`date`) = "7"
```

#### Deduplicate

**Select distinct columns**

by `distinct`

```sql
SELECT DISTINCT {distinct_column_1} {distinct_column_2}
FROM {tableName}
```

by `group`

```sql
SELECT {grouped_column_1}, {grouped_column_2}
FROM {tableName}
GROUP BY {grouped_column_1}, {grouped_column_2}
```

**Select all columns deduplicate by part of columns**

```sql
SELECT *
FROM {tableName}
GROUP BY {grouped_column_1}, {grouped_column_2}
```



### Union

#### Select from union

```sql
select * 
from 
(
    select tf.id, tf.file_name as fileName, ti.name as `fileSource`, tf.create_time as createTime 
    from transform_file tf 
    left join transform_info ti on tf.file_transform_type = ti.`type` 
    where file_name like "%xxx%"
    union all
    select id, file_name  as fileName, "文档审核" as `fileSource`, create_time as createTime
    from examine_file ef 
    where file_name like "%xxx%"
) as temp
order by createTime desc
limit 0, 10
```

#### order by in union using subqueries

```sql
select val
from (
    select * from (
        select values1 as val
        from table1 
        order by orderby1
        limit 3
    ) as a
    union all
    select * from (
        select values2 as val
        from table2 
        order by orderby2
        limit 3
    ) as b
) as temp
order by val asc
```

### Join

#### Select Children

select children

```sql
SELECT * FROM {my_table} AS a
INNER JOIN {my_table} AS b ON a.parent_id = b.id
WHERE 
-- second level
a.parent_id = 349 OR 
-- third level
b.parent_id = 349
```

select children and self

```sql
SELECT * FROM {my_table} AS a
LEFT JOIN {my_table} AS b ON a.parent_id = b.id
WHERE 
-- first level(myself)
a.id=349 OR 
-- second level
a.parent_id = 349 OR 
-- third level
b.parent_id = 349
```

#### Join on Find in String Values

```sql
select ga.id, ga.account, max(gt.create_time)
from examine.guide_account ga 
left join examine.guide_task gt on find_in_set(ga.id, gt.account_ids)
group by ga.id
order by ga.id asc
```

### Aggregations

#### Common Usage

Remove null value of group field

1. having count(your_group_field)>0
2. where your_group_field is not null

#### N highest value

query to find the Second highest salary from table

```sql
SELECT MAX(salary)
FROM employees
WHERE salary NOT IN ( SELECT Max(salary) FROM employees);
```

```sql
SELECT MAX(salary) 
FROM employees
WHERE salary < ( SELECT Max(salary) FROM employees);
```

```sql
SELECT DISTINCT salary 
FROM employee 
ORDER BY salary DESC LIMIT 1, 1;
```

#### Top N

top 3 employees for learning course hours in every company

> tip: the max number of "top 3 values of a group less than all values of a group" is 2, also 0, or 1 (because the number of values of a group may less than 3)

```sql
select a.employee_id, a.company_id, a.hours 
from my_table a 
WHERE 
(
    SELECT COUNT(*)    
    from my_table b 
    where b.company_id = a.company_id AND a.hours < b.hours
) < 3
order by a.company_id, a.hours desc;
```

```sql
SELECT a.employee_id, a.company_id, a.hours 
FROM my_table a
LEFT JOIN my_table b ON a.company_id = b.company_id AND a.hours < b.hours
GROUP BY a.employee_id
HAVING COUNT(*) < 3
ORDER BY a.company_id, a.hours DESC;
```

#### Query duplicate data

```sql
select * 
from tableName as a
Inner join (
    select distinct colName
    from tableName
    group by distinct colName
    having count(*) > 1
) as b on a.colName = b.colName
```

or

```sql
select id, title, pubtime
from recovery_data as a 
inner join 
(
    select SUBSTRING_INDEX(url, '#', 1) as url 
    from recovery_data
    where pubtime between '2022-11-01 00:00:00' and '2022-11-01 23:59:59'
    group by SUBSTRING_INDEX(url, '#', 1)
    having count(*) > 1
) as b on a.url like CONCAT(b.url, '%')
where a.pubtime between '2022-11-01 00:00:00' and '2022-11-01 23:59:59'
limit 0, 50
```

#### Query duplicate count

Repeat count

```sql
select sum(*)
from (
    select count(*)
    from tableName
    group by distinct colName
    having count(*) > 1
) As temp
```

column substring repeat count

```sql
SELECT count(*) - count(DISTINCT SUBSTRING_INDEX(url, '#', 1)) FROM table_name;
```

#### Query redundant count

```sql
Select count(*) - count (distinct colName) from tableName
```

or

```sql
Select sum(*)
From (
Select count(*)-1
From tableName
Group by distinct colName
Having count(*) > 1
) As temp
```

distinct with substring

```sql
-- str.subtring(0, str.indexOf("#ocr"))
select count(*) - count(DISTINCT SUBSTRING_INDEX(url, '#ocr', 1)) 
from tableName

-- if (str.endWiths("#orc")) { str.subtring(0, str.indexOf("#ocr")) } else { str }
select count(*) - count(DISTINCT if(LOCATE('#ocr', url) + 3 =  CHAR_LENGTH(url), SUBSTRING_INDEX(url, '#ocr', 1), url)) 
from tableName
```

concat "#ocr" string number

```sql
select count(*)
from (
select distinct a.url
from tableName as a 
where a.pubtime BETWEEN '2022-11-21 09:00:00' and '2022-11-21 09:10:00'
) as t1
inner join 
(
select b.url
from tableName as b
where b.url like "%#ocr" and b.pubtime BETWEEN '2022-11-21 09:00:00' and '2022-11-21 09:10:00'
) as t2 on concat(t1.url, "#ocr") = t2.url
```



#### Aggregation by conditions

Aggregation with conditions

```sql
SELECT SUM(if(status=1, 1, 0)) 
FROM {tableName}
```

```sql
SELECT SUM(if(a.acceptor_id=#{userId} AND a.STATUS='accepted', 1, 0))
FROM {tableName}
```

Query count percent

```sql
SELECT SUM(if(status=1, 1, 0)) / COUNT(*)
FROM {tableName}
GROUP BY type
```

#### Nested group

Nested group by and convert all sub group sum to all average

```sql
SELECT 
biz as user_id, 
#发布篇数
SUM(publish_num_per_hour) as publish_num, 
#发布次数（一个小时内发布的文章算1次发布）
COUNT(*) AS publish_times,
#平均阅读
SUM(total_read_per_hour) / SUM(publish_num_per_hour) AS avg_read,
#平均在看
SUM(total_watch_per_hour) / SUM(publish_num_per_hour) AS avg_watch,
#平均点赞
SUM(total_like_per_hour) / SUM(publish_num_per_hour) AS avg_like,
#阅读峰值
MAX(max_read_during_hour) AS max_read,
#在看峰值
MAX(max_watch_during_hour) AS max_watch,
#点赞峰值
MAX(max_like_during_hour) AS max_like
FROM 
(
    SELECT 
    biz, 
    DATE_FORMAT(data.pubtime, '%Y-%m-%d %H'), 
    COUNT(*) AS publish_num_per_hour,
    SUM(read_num) AS total_read_per_hour,
    SUM(like_num) AS total_watch_per_hour,
    SUM(thumb_num) AS total_like_per_hour,
    MAX(read_num) AS max_read_during_hour,
    MAX(like_num) AS max_watch_during_hour,
    MAX(thumb_num) AS max_like_during_hour
    from data_weixin_account as account
    left join data_weixin as data
    on account.weixin_biz_id = data.biz
    WHERE data.biz IS NOT NULL AND account.weixin_biz_id IS NOT NULL 
    GROUP BY  data.biz, DATE_FORMAT( data.pubtime, '%Y-%m-%d %H' )
) AS temp1
GROUP BY temp1.biz
```

#### GROUP_CONCAT

concat column values of a group to a string

```sql
SELECT name, GROUP_CONCAT(content SEPARATOR "|") AS content
FROM keyword 
GROUP BY name 
ORDER BY id DESC
```

table data

```
name     content
name1    value1
name1    value2
```

result

```
name1    value1|value2
```

#### Group by Date

**Group by Date**

```sql
group by DATE_FORMAT(pubtime, '%Y-%m-%d')
```

```sql
group by DATE(pubtime)
```

**Group by month**

```sql
select site_id,DATE_FORMAT(pubtime, '%Y%m'), count(*) as '文章数', sum(LENGTH(CONTENT)) as "字数"
from my_data
GROUP By site_id, DATE_FORMAT(pubtime, '%Y%m')
ORDER by sum(LENGTH(CONTENT)) desc
```

```sql
select site_id, year(pubtime), month(pubtime), count(*) as '文章数', sum(LENGTH(CONTENT)) as "字数"
from my_data
GROUP By site_id, year(pubtime), month(pubtime)
ORDER by sum(LENGTH(CONTENT)) desc
```

#### Find groups that all rows have the same column value

**Find users with all tasks completed**

```sql
select user_id
from user_task
group by user_id
HAVING sum(if(finish_status=2, 1, 0)) = count(*)
```

finish_status: 0 wait, 1 in_progress, 2 success, 3 fail

## Complex Query Examples

### Query word frequency

Query top 100 words. The max number of words in content is 50.

```sql
SELECT word, COUNT(*) AS frequency
FROM (
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(content, ' ', numbers.n), ' ', -1) AS word
FROM mytable 
inner JOIN 
(SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40 UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45 UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50) numbers 
WHERE n <= 1 + (LENGTH(content) - LENGTH(REPLACE(content, ' ', '')))
) words
GROUP BY word
ORDER BY frequency DESC
limit 100;
```



## Call Procedure or function

## Schema Query

### Database Schema

Databases

```sql
SHOW databases;
```

Tables

```sql
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM information_schema.TABLES 
WHERE TABLE_NAME = '{table_name}';
```

```sql
DESC `table_name`;
```

```sql
SHOW CREATE TABLE `table_name`;
```

Columns

```sql
SHOW COLUMNS FROM `table_name` LIKE 'column_name';
```

```sql
SELECT * 
FROM information_schema.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'db_name' 
AND TABLE_NAME = 'table_name' 
AND COLUMN_NAME = 'column_name'
```

### Database Size

List Database Size

```sql
SELECT table_schema "DB Name",
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" 
FROM information_schema.tables 
GROUP BY table_schema; 
```

```sql
SELECT table_schema AS "Database", SUM(data_length + index_length) / 1024 / 1024 AS "Size (MB)" 
FROM information_schema.TABLES 
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) desc;
```

```sql
SELECT table_schema AS "Database", SUM(data_length + index_length) / 1024 / 1024 / 1024 AS "Size (GB)" 
FROM information_schema.TABLES 
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) desc;
```

List Table Sizes From a Single Database

```sql
SELECT
  TABLE_NAME AS `Table`,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
  information_schema.TABLES
WHERE
  TABLE_SCHEMA = "{database_name}"
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH)
DESC;
```

List All Table Sizes From ALL Databases

```sql
SELECT
  TABLE_SCHEMA AS `Database`,
  TABLE_NAME AS `Table`,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
  information_schema.TABLES
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH)
DESC;
```

## Throw Exception

Throw Exception if not found

```sql
DROP FUNCTION IF EXISTS checkit_2022_01_26;
DELIMITER //

CREATE FUNCTION checkit_2022_01_26()
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE my_count INT;
    SELECT COUNT(*) INTO my_count FROM sys_menu WHERE menu_name = "联系人";
    IF my_count= 0 THEN
        SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = "父菜单名称（联系人）不存在";
    END IF;
    RETURN my_count;
END;
//

DELIMITER ;
select checkit_2022_01_26() AS "父菜单数量";
DROP FUNCTION IF EXISTS checkit_2022_01_26;
```

## Built-In Functions

Reference [Chapter 12 Functions and Operators](https://dev.mysql.com/doc/refman/8.0/en/functions.html)

### Date and time functions

Get Date Time

- date
  - `CURDATE()`, `CURRENT_DATE()`, `CURRENT_DATE`
- datetime
  - `NOW()`, `CURRENT_TIMESTAMP()`, `CURRENT_TIMESTAMP`, `LOCALTIME()`, `LOCALTIME`, `LOCALTIMESTAMP`, `LOCALTIMESTAMP()`
- time
  - `CURTIME()`, `CURRENT_TIME()`, `CURRENT_TIME`

Date Conversion

- `CONVERT_TZ()`
- `FROM_UNIXTIME(1447430881)`
- `MAKEDATE()`
- `MAKETIME()`
- `STR_TO_DATE()`
- `SEC_TO_TIME()`
- `TIME_TO_SEC()`

Date Extraction

- `EXTRACT()`
- `YEAR()`
- `QUARTER()`
- `MONTH()`, `MONTHNAME()`
- `WEEK()`, `WEEKDAY()`, `WEEKOFYEAR()`
- Date
  - `DATE()`
  - `DAY()`, `DAYOFMONTH()`
  - `DAYNAME()`, `DAYOFWEEK()`
  - `DAYOFYEAR()`
  - `LAST_DAY`
- Time
  - TIME()
  - `HOUR()`
  - `MINUTE()`
  - `SECOND()`
  - `MICROSECOND()`

Date Computation

- Date
  - `ADDDATE()`, `DATE_ADD()`
  - `DATE_SUB(NOW(), INTERVAL 10 MINUTE)`, `SUBDATE()`
  - `DATEDIFF()`
- Time
  - `ADDTIME()`
  - `SUBTIME()`
  - `TIMEDIFF()`
  - `TIMESTAMPADD()`
  - `TIMESTAMPDIFF()`
- Other
  - Get start of the day:
    - `DATE_FORMAT(now(), '%Y-%m-%d 00:00:00')` 
    - or `DATE_FORMAT(CONCAT(CURDATE(), ' 00:00:00'), '%m/%d/%Y %H:%i:%s')`

  - Get end of the day: 
    - `DATE_FORMAT(now(), '%Y-%m-%d 23:59:59')` 
    - or `DATE_FORMAT(CONCAT(CURDATE(), ' 23:59:59'), '%m/%d/%Y %H:%i:%s')`


Date Format

- `DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s")`
- `TIME_FORMAT(CURTIME(), "%H:%i:%s")`

Date Time Build

- `concat(date(yourcolumn), ' 21:00:00')`

### String Functions

String Info

- `CHAR_LENGTH(str)`, `CHARACTER_LENGTH(str)`: the length of a string (in characters)
- `LENGTH(str)`:  the *length* of a string (in bytes)

Conversion

- `UPPER()`
- `LOWER()`
- `REVERSE(str)`

Handling

- get substring
  - `SUBSTR(str,pos)`, `SUBSTR(str,pos,len)`, `SUBSTRING(str,pos)`, `SUBSTRING(str,pos,len)`

    ```sql
    SELECT SUBSTRING("Hello World", 7, 3) -- Wor
    ```

  - `LEFT(str,len)`

  - `RIGHT(str,len)`

  - `SUBSTRING_INDEX(str, delim, count)`

    ```sql
    -- left
    SELECT SUBSTRING_INDEX("www.google.com", ".", 1); -- www
    -- right
    SELECT SUBSTRING_INDEX("www.google.com", ".", -1); -- com
    -- middle
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX("www.google.com", ".", 2), ".", -1); -- google
    ```

- get substring index

  - `LOCATE(substr, str)`, `POSITION(substr in str)`

- concat

  - `CONCAT(str1, str2, ...)`

- contains

  - `FIND_IN_SET(str, strList) > 0`

- Match
  - `expression LIKE pattern`
  - `expression REGEX pattern`

- Encode/Decode
  - `TO_BASE64(str)`, `FROM_BASE64(str)`
  - `HEX(str)`, `UNHEX(str)`

- Others
  - `CONCAT(str1, str2,...)`, `CONCAT_WS(seperator, str1, str2,...)`
  - `REPLACE(str, from_str, to_str)`

### Number Functions

- Computation
  - `ABS(x)`
  - `LN(x)`, `LOG(B,X)`, `LOG10(x)`, `LOG2(x)`
- float to integer
  - `CEIL(x)`, `CEILING(x)`
  - `FLOOR(x)`
  - `ROUND(x)`
- Others
  - `RAND()`. Returns a random floating-point value v in the range `0 <= v < 1.0`. To obtain a random integer R in the range `i <= R < j`, use the expression `FLOOR(i + RAND() * (j − i))`.

## Common Usage

### Recent Date Time

Recent 7 days (contains today)

```sql
select DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 6 DAY), '%Y-%m-%d 00:00:00')
```

Recent 30 days (contains today)

```sql
select DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 29 DAY), '%Y-%m-%d 00:00:00')
```

Recent 1 month

```sql
select DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 1 MONTH), '%Y-%m-%d 00:00:00')
```

### String

Find in set

```sql
where FIND_IN_SET("a", "a,b,c") > 0
```

remove from set

```sql
REPLACE(CONCAT(',', 'a,b,c', ','), CONCAT(',', 'a', ','), ',')
```

```sql
update {your_table}
set {your_column} = 
    TRIM(BOTH ',' FROM
         REPLACE(CONCAT(',', {your_column}, ','), CONCAT(',', #{remove_val}, ','), ',')
    )
where ....
```

## References

- [String Functions and Operators](https://dev.mysql.com/doc/refman/8.0/en/string-functions.html)
- [MySQL select 10 random rows from 600K rows fast](https://stackoverflow.com/questions/4329396/mysql-select-10-random-rows-from-600k-rows-fast)
- [ORDER BY RAND()](http://jan.kneschke.de/projects/mysql/order-by-rand/)
