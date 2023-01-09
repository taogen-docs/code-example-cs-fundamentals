# Common SQL Settings

## tx_isolation

```sql
-- global
SET GLOBAL tx_isolation='READ-COMMITTED'
-- session
SET tx_isolation='READ-COMMITTED'
```

```sql
SELECT @@global.tx_isolation, @@tx_isolation;
```

## group_concat_max_len

For 32bit systems, the maximum value is 4294967295

For 64 bit systems, the maximum value is 18446744073709551615.

```sql
-- global
SET GLOBAL group_concat_max_len=4294967295;
-- session
SET SESSION group_concat_max_len=4294967295;
```

```sql
SELECT @@global.group_concat_max_len, @@group_concat_max_len;
```



## Character Set

```sql
set names utf8mb4;
```

After connecting to MySQL, perform `SET NAMES utf8mb4`. That will establish that your client is using the full 4-byte encoding for reading/writing. but keep in mind that when connecting as root (or any `SUPER` user), `init_connect` is ignored.

Also, the tables/columns must be `CHARACTER SET utf8mb4`.

Option File

```sql
[mysqld]
init_connect = 'SET NAMES utf8mb4'
```



