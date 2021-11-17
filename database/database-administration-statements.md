# Database Administration Statements

Content

- Account Management Statements
- Table Maintenance Statements
- Plugin and Loadable Function Statements
- SET Statements
- Show Statements
- Other Administrative Statements

## Account Management Statements

## Table Maintenance Statements

## Plugin and Loadable Function Statements

## SET Statements

### System Variable Assignment

To assign a value to a global system variable

```sql
SET GLOBAL {variable} = {value};
SET @@GLOBAL.{variable} = {value};
```

To assign a value to a session system variable

```sql
SET SESSION {variable} = {value};
SET LOCAL {variable} = {value};
SET @@SESSION.{variable} = {value};
SET @@LOCAL.{variable} = {value};
SET @@{variable} = {value};
SET {variable} = {value};
```

To set a global system variable value to the compiled-in MySQL default value

```sql
SET @@SESSION.{variable} = DEFAULT;
```

To set a session system variable to the current corresponding global value

```sql
SET @@SESSION.{variable} = @@GLOBAL.{variable};
```

### Show Variables

```sql
SHOW VARIABLES;
```

```sql
SHOW [GLOBAL | SESSION] VARIABLES
    [LIKE 'pattern' | WHERE expr]
SHOW VARIABLES LIKE 'max_join_size';
SHOW VARIABLES LIKE '%size%';
SHOW GLOBAL VARIABLES LIKE '%size%';
```

```sql
SELECT @@GLOBAL.{variable};
SELECT @@SESSION.{variable};
```

### Common Variable Settings

group concat max length

```sql
SET SESSION group_concat_max_len = 1000000; // default 1024
```



## Show Statements

## Other Administrative Statements

