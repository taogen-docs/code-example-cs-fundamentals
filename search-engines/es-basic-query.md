# Elasticsearch Query

## Basic Query

### Search Page

```json
GET /alias-meta-20230501/data/_search
{
    "from": 0,
    "size": 10,
    "query": {
        "bool": {
            "must": [
                {
                    "term": {
                        "YOUR_FIELD": "FIELD_VALUE"
                    }
                }   
            ]
        }
    }
}
```

### Get by Ids

get by id

```
GET /{index_name}/{id}
GET /{index_name}/{document_type}/{id}
```

get by ids

```json
GET /{index_name}/{document_type}/_search
{
    "query": {
        "ids": {
            "values": ["id1", "id2"]
        }
    }
}
```



## Bool Query

### Nested bool query

```json
"bool": {
    "must": [
        {
            "term": {
                "YOUR_FIELD": "FIELD_VALUE"
            }
        },
        {
            "bool": {
                "should": [
                    {
                        "term": {
                            "YOUR_FIELD": "FIELD_VALUE"
                        }
                    }
                ],
                "minimum_should_match": 1
            }
        }
    ]
}
```

## Conditions

### Null or Empty

not null

```json
"bool": {
    "must": [
        {
            "exists": {
                "field": "YOUR_FIELD"
            }
        }
    ]
}
```

null

```json
"bool": {
    "must_not": [
        {
            "exists": {
                "field": "YOUR_FIELD"
            }
        }    
    ]
}
```

empty?????

```json
{
    "term": {
        "YOUR_FIELD": {
            "value": ""
        }
    }
}
```

not empty???????????

```json
"bool": {
    "must_not": [
        {
            "term": {
                "YOUR_FIELD": {
                    "value": ""
                }
            }
        }  
    ]
}
```

