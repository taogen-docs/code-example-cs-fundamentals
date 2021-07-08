# Common SQL DML

- insert
- update
- delete

## insert

insert from select

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