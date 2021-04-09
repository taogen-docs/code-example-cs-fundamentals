# Common SQL DQL

- select
  - Queries
  - Aggregations
- call

## select

### Queries

Query insert row primary key 'id'

```sql
SELECT @userId := LAST_INSERT_ID();
```

Select distinct columns

```sql
SELECT DISTINCT user_id 
FROM {tableName}
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



### Aggregations

Count by conditions

```sql
SELECT SUM(if(status=1, 1, 0)) 
FROM {tableName}
```

```sql
SELECT SUM(if(a.acceptor_id=#{userId} AND a.STATUS='accepted', 1, 0))
FROM {tableName}
```

