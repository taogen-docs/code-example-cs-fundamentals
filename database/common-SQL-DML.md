# Common SQL DML

- insert
  - insert from select
  - on duplicate key update
  - generating random data
- update
- delete

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

```sql
INSERT INTO recovery_words
(words, type, group_id, user_name, user_id) 
VALUES 
("word 1", 3, -1, "admin", 1),
("word 2", 3, -1, "admin", 1)
ON DUPLICATE KEY UPDATE 
words=words, `type` = `type`, group_id = group_id, `status`=`status`;
```

### generating random data

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
        START TRANSACTION;
        WHILE i <= rowNum DO
            INSERT INTO ...
            SET i = i + 1;
        END WHILE;
        COMMIT;
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

Replacing string from http to https

```sql
UPDATE crm_task
	set file_uri = REPLACE(file_uri, 'http:', 'https:')
	WHERE file_uri LIKE '%http:%';
```

update with join

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

## delete