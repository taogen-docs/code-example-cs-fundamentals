# Common SQL DML

- insert
- update
- delete

## insert

## update

Replacing string from http to https

```
UPDATE crm_task
	set file_uri = REPLACE(file_uri, 'http:', 'https:')
	WHERE file_uri LIKE '%http:%';
```



## delete