# Common SQL DML

- INSERT
  - insert from select
  - on duplicate key update
  - generating random data
- UPDATE
- DELTE
- CALL
- LOCK

## insert

### insert from select

```sql
INSERT INTO `my_db`.`menu` 
(`name`, parent_id, level)
SELECT 'name', parent_id, parent_level + 1
FROM 
(
    SELECT id AS parent_id, `level` as parent_level FROM `my_db`.`menu` 
    WHERE NAME='用户管理' AND parent_id = 0
    LIMIT 1
) AS temp;
```

### on duplicate key update

Just update unique key fields for ignore insert this row.

```sql
INSERT INTO recovery_words
(words, type, group_id, user_name, user_id) 
VALUES 
("word 1", 3, -1, "admin", 1),
("word 2", 3, -1, "admin", 1)
ON DUPLICATE KEY UPDATE 
words=words, `type` = `type`, group_id = group_id, `status`=`status`;
```

### Use Procedures to generating random data

- random integer (i <= R < j)
  - `select FLOOR(i + RAND() * (j - i))`
- random string: 
  - `select SUBSTRING(MD5(RAND()) FROM 1 FOR stringLength) `
- random date:
  - `select TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, startDateTime, endDateTime)), startDateTime)`
- random records: 
  - `SELECT user_id FROM sys_user ORDER BY RAND() LIMIT 1`

```sql
DROP PROCEDURE IF EXISTS sp_generate_random_data;

DELIMITER //
CREATE PROCEDURE sp_generate_random_data(IN rowNum INT)
COMMENT 'generate n rows random data'
BEGIN
	DECLARE i INT;
    SET i = 1;
    WHILE i <= rowNum DO
    	INSERT INTO ...
        SET i = i + 1;
	END WHILE;
END //
DELIMITER ;

CALL sp_generate_random_data(100);
```

```sql
DROP FUNCTION IF EXISTS sf_get_random_integer;

DELIMITER //
CREATE FUNCTION sf_get_random_integer (minVal INT, maxVal INT)
RETURNS INT DETERMINISTIC
COMMENT 'return random integer in [minVal, maxVal)'
BEGIN
    declare result INT;
    set result = FLOOR(minVal + RAND() * (maxVal - minVal));
    RETURN result;  
END //
DELIMITER ;

SELECT sf_get_random_integer(1, 10); # return a value from [1, 10)
```

```sql
DROP FUNCTION IF EXISTS sf_get_random_string;

DELIMITER //
CREATE FUNCTION sf_get_random_string (stringLength INT)
RETURNS VARCHAR(32) DETERMINISTIC
COMMENT 'return a random string with n characters'
BEGIN
	RETURN SUBSTRING(MD5(RAND()) FROM 1 FOR stringLength);
END //
DELIMITER ;

SELECT sf_get_random_string(32); # return a string with 32 characters
```

```sql
DROP FUNCTION IF EXISTS sf_get_random_datetime;

DELIMITER //
CREATE FUNCTION sf_get_random_datetime (startDateTime DATETIME, endDateTime DATETIME)
RETURNS DATETIME DETERMINISTIC
COMMENT 'return a random datetime between startDateTime and endDateTime'
BEGIN
	RETURN TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, startDateTime, endDateTime)), startDateTime);
END //
DELIMITER ;

SELECT sf_get_random_datetime('2021-08-01 00:00:00', '2021-10-01 00:00:00');
SELECT date(sf_get_random_datetime('2021-08-01 00:00:00', '2021-10-01 00:00:00'));
```

```sql
-- random time: 9:00 ~ 18:00
select @randomTime := MAKETIME(FLOOR(9 + RAND() * (18 - 9)), FLOOR(0 + RAND() * (59 - 0)), FLOOR(0 + RAND() * (59 - 0)))
insert into {your_table} (create_time,...) values (CONCAT('2021-11-22', @randomTime),...)
```

```sql
DROP FUNCTION IF EXISTS sf_get_random_user_id;

DELIMITER //
CREATE FUNCTION sf_get_random_user_id ()
RETURNS BIGINT DETERMINISTIC
COMMENT 'return a random userId'
BEGIN
	DECLARE userId BIGINT;
	SELECT user_id INTO userId FROM sys_user ORDER BY RAND() LIMIT 1;
	RETURN userId;
END //
DELIMITER ;

SELECT sf_get_random_user_id();
```



## update

### Update Examples

Replacing string from http to https

```sql
UPDATE crm_task
	set file_uri = REPLACE(file_uri, 'http:', 'https:')
	WHERE file_uri LIKE '%http:%';
```

### Update with Conditions

```sql
UPDATE message 
SET chat = if(message_from > message_to, concat(message_to, "-", message_from), concat(message_from, "-", message_to))
WHERE chat IS NULL;
```

### Update with join

```sql
UPDATE TABLE2
       JOIN TABLE1
       ON TABLE2.SERIAL_ID = TABLE1.SUBST_ID
SET TABLE2.BRANCH_ID = TABLE1.CREATED_ID;
```

```sql
UPDATE `examine`.`examine_deposit_record` AS deposit
	LEFT JOIN sys_user AS user ON deposit.create_by = user.user_id
	LEFT JOIN sys_dept AS dept ON user.dept_id = dept.dept_id 
SET deposit.dept_id = dept.dept_id
WHERE deposit.dept_id IS null AND user.type = 1;
```

### Use Procedures to Update

```sql
DROP PROCEDURE IF EXISTS update_account_proxy;

DELIMITER //
CREATE PROCEDURE update_account_proxy()
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
END //
DELIMITER ;

CALL update_account_proxy();
```



## delete