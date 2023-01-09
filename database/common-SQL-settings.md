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

