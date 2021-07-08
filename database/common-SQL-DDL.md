# Common SQL DDL

- CREATE
  - Databases
  - Tables
  - Indexes
- ALTER
  - Databases
  - Tables
- DROP

## CREATE

### Databases

```sql
CREATE DATABASE `db_name`
    [[DEFAULT] CHARACTER SET charset_name]
    [[DEFAULT] COLLATE collation_name]
```

For example:

```sql
CREATE DATABASE `mydatabase` 
	CHARACTER SET utf8mb4 
	COLLATE utf8mb4_unicode_ci;
```

### Tables

```sql
DROP TABLE IF EXISTS `customer_manage`.`crm_task_type`;

CREATE TABLE `customer_manage`.`crm_task_type` (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    category ENUM('development','support') NOT NULL COMMENT '类别（研发/支撑）',
    name VARCHAR(64) NOT NULL COMMENT '类型名称',
    parent_id INT NULL COMMENT '父类型id',
    delete_flag BOOL NOT NULL DEFAULT FALSE COMMENT '删除标识',
    create_by INT NOT NULL COMMENT '创建人',
    create_time TIMESTAMP NOT NULL DEFAULT NOW() COMMENT '创建时间',
    modify_by INT NULL COMMENT '修改人',
    modify_time TIMESTAMP NULL ON UPDATE NOW() COMMENT '修改时间')
ENGINE='InnoDB'
COMMENT='任务类型';
```

### Indexes

```sql
CREATE INDEX `title` USING BTREE 
ON `crm_knowledge_file` (title(64));

CREATE INDEX `parent_id` USING BTREE 
ON `crm_knowledge_file_history` (parent_id);
```



## ALTER

### Databases

```sql
ALTER DATABASE db_name
    [[DEFAULT] CHARACTER SET charset_name]
    [[DEFAULT] COLLATE collation_name]
```

```sql
ALTER DATABASE mydatabase 
	CHARACTER SET utf8mb4 
	COLLATE utf8mb4_unicode_ci;
```

### Tables

Update Table

```mysql
ALTER TABLE t1 RENAME t2;
```



Add Columns

```sql
ALTER TABLE `examine`.`sys_user`
	ADD COLUMN `type` TINYINT NULL COMMENT '账号类型（0正常，1舆情系统插入)'
	AFTER `status`;
```

Drop Columns

```sql
ALTER TABLE `db_name`.`table_name`
	DROP COLUMN `column_name`;
```

Update Column Properties

```mysql
# update data type
ALTER TABLE [tablename] MODIFY [columnName] [data_type] [is_null];
```

```mysql
# update data type range
ALTER TABLE [tablename] CHANGE [columnName] [columnName] DECIMAL (10,2)
```



## DROP



## References

- [13.1.9.3 ALTER TABLE Examples - MySQL Documentation](https://dev.mysql.com/doc/refman/8.0/en/alter-table-examples.html)