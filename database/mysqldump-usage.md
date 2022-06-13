# mysqldump Usage

The [**mysqldump**](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html "4.5.4 mysqldump — A Database Backup Program") client utility performs [logical backups](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_logical_backup "logical backup"), producing a set of SQL statements that can be executed to reproduce the original database object definitions and table data. It dumps one or more MySQL databases for backup or transfer to another SQL server. The [**mysqldump**](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html "4.5.4 mysqldump — A Database Backup Program") command can also generate output in CSV, other delimited text, or XML format.

1

```shell
mysqldump [options] > dump.sql
mysqldump [options] --result-file=dump.sql
```

2

```shell
mysqldump [options] db_name [tbl_name ...]
mysqldump [options] --databases db_name ...
mysqldump [options] --all-databases
```

For example: 

```shell
mysqldump -u username -p database_name > xxx_dump_xxxx.sql
mysqldump -u username -p database_name table1 table2 ... > xxx_dump_xxxx.sql
mysqldump crm crm_customer crm_customer_type crm_user > crm_tables_dump_20220613.sql
mysqldump -u username -p --databases crm --tables crm_customer --where='is_formal=1' > xxx_dump_xxxx.sql
```

CVS

```shell
mysqldump -u root -p -T /path/to/csv/files --fields-terminated-by="\t" --fields-enclosed-by='\"' --lines-terminated-by="\r\n" dbname tablename 
mysqldump -u root -p --tab=/path/to/csv/files --fields-terminated-by="\t" --fields-enclosed-by='\"' --lines-terminated-by="\r\n" dbname tablename 
mysqldump -T /root/test/ --fields-terminated-by="\t" --fields-enclosed-by='\"' --lines-terminated-by="\r\n" crm crm_customer 
```

ERROR 1045

```
mysqldump: Got error: 1045: "Access denied for user 'crm'@'%' (using password: YES)" when executing 'SELECT INTO OUTFILE'
```

ERROR 1290

```
mysqldump: Got error: 1290: The MySQL server is running with the --secure-file-priv option so it cannot execute this statement when executing 'SELECT INTO OUTFILE'
```

```shell
$ mysql
mysql> SHOW VARIABLES LIKE "secure_file_priv";
```

```
 secure_file_priv | C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
```

```shell
.\mysqldump.exe -u root -p --tab="C:\ProgramData\MySQL\MySQL Server 8.0\Uploads" --fields-terminated-by="\t"" crm crm_customer
.\mysqldump.exe -u root -p --tab="C:\ProgramData\MySQL\MySQL Server 8.0\Uploads" --fields-terminated-by="\t" --fields-enclosed-by='\"' --lines-terminated-by="\r\n" crm crm_customer
```

Options

- --databases: specify databases to dump
- --tables: specify tables to dump
- --all-databases: Dump all tables in all databases
- Generate
  - --add-drop-database: Add DROP DATABASE statement before each CREATE DATABASE statement
  - --add-drop-table: Add DROP TABLE statement before each CREATE TABLE statement
  - --add-locks: Surround each table dump with LOCK TABLES and UNLOCK TABLES statements
  - --compatible: Produce output that is more compatible with other database systems or with older MySQL servers
  - --no-data
  - --where
