# MySQL Stored Procedures

## Create Stored Procedures

```sql
DROP PROCEDURE IF EXISTS procedure_name;

DELIMITER //
CREATE PROCEDURE procedure_name(p1 INT)
COMMENT '....'
BEGIN
	...;
	...;
END //

DELIMITER ;

CALL update_account_proxy();
```



## Variables

### Declaration and Assignment

#### Local Variable in Procedures

Declaration

```sql
DECLARE var_name [, var_name] ... type [DEFAULT value]
```

This statement declares local variables within stored programs. To provide a default value for a variable, include a `DEFAULT` clause. The value can be specified as an expression; it need not be a constant. If the `DEFAULT` clause is missing, the initial value is `NULL`.

Variable declarations must appear before cursor or handler declarations.

Local variable names are not case-sensitive. 

```sql
DECLARE i INT DEFAULT 0; -- same with DEFAULT false
DECLARE xname VARCHAR(5) DEFAULT 'bob';
```

```sql
DECLARE i INT;
DECLARE NAME VARCHAR(64);
```

```sql
DECLARE b, c INT;
```

If the `DEFAULT` clause is missing, the initial value is `NULL`.

Assignment

```sql
SET i = 1;
SET i = i + 1;
```

View

```sql
select variable_name;
select ... from table where id = variable_name;
```

#### User-defined variables 

User-defined variables are created locally within a session and exist only within the context of that session;

You can access any user-defined variable without declaring it or initializing it. If you refer to a variable that has not been initialized, it has a value of `NULL` and a type of string.

Declaration

```sql
SET @var_name = expr;
```

Assignment

```sql
set @username = 'abc';
SET @total_tax = (SELECT SUM(tax) FROM user);
select @username := 'aaa';
SELECT username INTO @username FROM user;
```

View

```sql
select @username;
```



### SELECT INTO

```sql
DECLARE typeCount INT DEFAULT 0;
select count(distinct type) INTO typeCount from account;
```

### Different types of variables

1. local variables (which are not prefixed by @) are strongly typed and scoped to the stored program block in which they are declared. Note that, as documented under DECLARE Syntax:
   DECLARE is permitted only inside a BEGIN ... END compound statement and must be at its start, before any other statements.

2. User variables (which are prefixed by @) are loosely typed and scoped to the session. Note that they neither need nor can be declared—just use them directly.
   Therefore, if you are defining a stored program and actually do want a "local variable", you will need to drop the @ character and ensure that your DECLARE statement is at the start of your program block. Otherwise, to use a "user variable", drop the DECLARE statement.

## Statements

- Flow Control: IF, CASE, ITERATE, LEAVE LOOP, WHILE, and REPEAT
- RETURN
### Flow Control

#### Choice

##### If

```sql
IF search_condition THEN statement_list
    [ELSEIF search_condition THEN statement_list] ...
    [ELSE statement_list]
END IF
```

```sql
BEGIN
    DECLARE s VARCHAR(20);

    IF n > m THEN SET s = '>';
    ELSEIF n = m THEN SET s = '=';
    ELSE SET s = '<';
    END IF;

    SET s = CONCAT(n, ' ', s, ' ', m);

    RETURN s;
  END //
```

##### Case

```sql
CASE variable_name
    WHEN when_value THEN statement_list
    [WHEN when_value THEN statement_list] ...
    [ELSE statement_list]
END CASE
```

```sql
CASE
    WHEN search_condition THEN statement_list
    [WHEN search_condition THEN statement_list] ...
    [ELSE statement_list]
END CASE
```

```sql
BEGIN
    DECLARE v INT DEFAULT 1;

    CASE v
      WHEN 2 THEN SELECT v;
      WHEN 3 THEN SELECT 0;
      ELSE
        BEGIN
        END;
    END CASE;
  END;
```



#### For Loop

##### LOOP

```sql
[begin_label:] LOOP
    statement_list
END LOOP [end_label]
```



##### WHILE

```sql
DECLARE i INT DEFAULT 0;
WHILE i < 10 DO
	...
END WHILE;
```

##### REPEAT (DO...WHILE)

```sql
[begin_label:] REPEAT
    statement_list
UNTIL search_condition
END REPEAT [end_label]
```

```sql
SET @x = 0;
REPEAT 
SET @x = @x + 1; 
UNTIL @x > p1 END REPEAT;
```

##### ITERATE

```sql
ITERATE label
```

ITERATE can appear only within LOOP, REPEAT, and WHILE statements. ITERATE means “start the loop again.”

```sql
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
COMMENT '....'
BEGIN
	declare i int default 0;
	set @my_count = 1;
	myloop: LOOP
	    if i = 1 then 
	        set i = i + 1;
	    	iterate myloop;
	    end if;
   		set @my_count = @my_count + 1;
	    set i = i + 1;
	    if i = 9 then 
	   		leave myloop;
	   	end if;
	END LOOP myloop;
END //

DELIMITER ;

CALL test();
select @my_count; // loop 10 times, skip 1 times. result is 9;
```



##### LEAVE

```sql
LEAVE label
```

This statement is used to exit the flow control construct that has the given label. If the label is for the outermost stored program block, LEAVE exits the program.

LEAVE can be used within BEGIN ... END or loop constructs (LOOP, REPEAT, WHILE).


## Function

### Input

### Output

### Call

```sql
call procedure_name();
call db_name.procedure_name();
```

## Exception Handling



## Collections

Traversal column values

```sql
DROP PROCEDURE IF EXISTS traverse_column;

DELIMITER //
CREATE PROCEDURE traverse_column(OUT columnValues VARCHAR(1000))
COMMENT 'traverse column values'
begin
	DECLARE col_count int default 0;
	DECLARE i int default 0;
	DECLARE curr varchar(64);
	DECLARE exe_sql VARCHAR(512);
    
    select count(distinct name) into col_count from t_user;
	while i < col_count DO
		select name into curr from t_user order by id asc limit i, 1;
        if columnValues is NULL then 
            set columnValues = curr;
        ELSE 
            set columnValues = CONCAT(columnValues, ',', curr);
        END if; 
		set i = i + 1;
	end while;
END //
DELIMITER ;

CALL traverse_column(@result);
SELECT @result;
```

Traverse string joined by comma

```sql
```



## Work with Random Data

## Examples

```sql
CREATE DEFINER=`js_data`@`%` PROCEDURE `examine`.`update_account_proxy`()
    COMMENT 'update account proxy. The same type of accounts have unique proxy_id'
begin
    declare typeCount int;
    declare currType int;
    declare j INT;
    DECLARE accountCount INT;
    DECLARE i INT;
    declare currAccountId INT;
    declare currProxyId varchar(512);
    update examine.guide_account set proxy_info = null;
    select count(distinct type) into typeCount from guide_account;
    set j = 0;
    WHILE j < typeCount DO
        select distinct type into currType from guide_account limit j, 1;
        select count(*) into accountCount from guide_account ga where ga.`type` = currType;
        SET i = 0;
        WHILE i < accountCount DO
            select id into currAccountId from guide_account ga where type = currType order by id asc  limit i, 1;
            select ip_information into currProxyId from guide_proxy gp where status = 1 order by id asc limit i, 1;
            update guide_account as ga set proxy_info = currProxyId where id = currAccountId;
            SET i = i + 1;
        END WHILE;
        set j = j + 1;
    END WHILE;
END
```



## References

[1] [13.6 SQL Statement - Compound Statement Syntax](https://dev.mysql.com/doc/refman/8.0/en/sql-compound-statements.html)

[2] [25 Stored Objects](https://dev.mysql.com/doc/refman/8.0/en/stored-objects.html)