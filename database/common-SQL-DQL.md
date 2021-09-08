# Common SQL DQL

**Content**

- Schema Query
- Table Query
  - [Queries](#queries)
    - [Conditional Query](#Conditional Query)
    - [Deduplicate](#Deduplicate)
  - [Aggregations](#Aggregations)
- Call Procedure or function

## Schema Query

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

### Aggregations

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

**Count by conditions**

```sql
SELECT SUM(if(status=1, 1, 0)) 
FROM {tableName}
```

```sql
SELECT SUM(if(a.acceptor_id=#{userId} AND a.STATUS='accepted', 1, 0))
FROM {tableName}
```

**Nested group by and convert all sub group sum to all average**

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

**GROUP_CONCAT**

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

