# Common SQL DQL

**Content**

- Schema Query
- Table Query
  - [Queries](#queries)
    - [Conditional Query](#Conditional Query)
    - [Deduplicate](#Deduplicate)
  - [Aggregations](#Aggregations)
- [Table Schema Query](#Table Schema Query)
- Call Procedure or function
- Built-In Functions

## Schema Query

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



## Table Query

### Queries

Query insert row primary key 'id'

```sql
SELECT @userId := LAST_INSERT_ID();
```

Select domain from URL

```sql
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(link, '://', -1), '/', 1) AS domain
FROM {tableName}
```

query to fetch only odd rows from the table

```sql
SELECT * 
FROM {tableName} 
WHERE MOD (userId, 2) <> 0;
```

Select row number

```sql
SELECT  *, ROW_NUMBER() OVER(ORDER BY id) AS row_num
FROM crm_account
```

### Conditional Query

Select with conditions

```sql
select 
id, name,
(select if(count(*)>0, true, false)) as flag
from {tableName}
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

case when {condition} then {val1} else {val1} 

```sql
select (case when column_key = 'PRI' then '1' else '0' end) as is_pk
from information_schema.columns
```

### Deduplicate

Select distinct columns

```sql
SELECT DISTINCT {distinct_column_1} {distinct_column_2}
FROM {tableName}
```

select distinct columns by group

```sql
SELECT {grouped_column_1}, {grouped_column_2}
FROM {tableName}
GROUP BY {grouped_column_1}, {grouped_column_2}
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

#### Aggregation by conditions

```sql
SELECT SUM(if(status=1, 1, 0)) 
FROM {tableName}
```

```sql
SELECT SUM(if(a.acceptor_id=#{userId} AND a.STATUS='accepted', 1, 0))
FROM {tableName}
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
name 	content
name1	value1
name1	value2
```

result

```
name1	value1|value2
```

#### Group by date

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

## Table Schema Query

Databases

```sql
SHOW databases;
```

Tables

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

Date Format

- `DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s")`
- `TIME_FORMAT(CURTIME(), "%H:%i:%s")`

Date Time Build

- `concat(date(yourcolumn), ' 21:00:00')`

### String Functions

String Info

- `LENGTH(str)`
- `CHAR_LENGTH(str)`, `CHARACTER_LENGTH(str)`

Conversion

- `UPPER()`
- `LOWER()`
- `REVERSE(str)`

Handling

- get substring
  - `SUBSTR(str,pos)`, `SUBSTR(str,pos,len)`, `SUBSTRING(str,pos)`
  - `LEFT(str,len)`
  - `RIGHT(str,len)`
- find
  - `LOCATE(substr, str)`, `POSITION(substr in str)`
  - `FIND_IN_SET(str, strList)`
- Match
  - `expression LIKE pattern`
  - `expression REGEX pattern`
- Encode/Decode
  -  `TO_BASE64(str)`, `FROM_BASE64(str)`
  -  `HEX(str)`, `UNHEX(str)`
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

Substring

Return a substring of a string before a specified number of delimiter occurs

`SUBSTRING_INDEX(string, delimiter, number)`

```sql
SELECT SUBSTRING_INDEX("www.google.com", ".", 1); -- www 
```

Extract a substring from the text in a column

`SUBSTRING(*string*, *start*, *length*)`

```sql
SELECT SUBSTRING("Hello World", 7, 3) -- Wor
```

