# Common SQL Triggers

Forbid to insert data

```sql
CREATE TRIGGER before_insert_video
BEFORE INSERT ON `video` FOR EACH ROW
BEGIN
  IF (new.source_from = "土豆") THEN
    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Forbid to insert tudou video';
  END IF;
END
```


