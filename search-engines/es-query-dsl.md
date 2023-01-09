# Elasticsearch Query DSL

## Index Name

wildcard for index name, for example, 2022*

## Query

### Basic query

In the query context, a query clause answers the question “*How well does this document match this query clause?*” Besides deciding whether or not the document matches, the query clause also calculates a relevance score in the `_score` metadata field.

- term, terms, range
- match, match_phrase, wildcard

```json
GET /alias-meta-202107*/_search
{
    "from": 0,
    "size": 50,
    "sort": [
        {
            "pub_time": "desc"
        }
    ],
    "query":{
        "bool": {
            "must": [
                {
                    "term": {
                        "status": "0"
                    }
                },
                {
                    "terms": {
                        "tag": ["278"]
                    }
                },
                {
                    "range": {
                        "pub_time": {
                            "gte": "2021-08-22 17:14:00",
                            "lte": "2021-08-23 17:14:00"
                        }
                    }
                },
                {
                    "wildcard": {
                        "host": "*.ttylives.com"
                    }
                }
            ],
            "should": [
                {
                    "match_phrase": {
                        "title": "疫情"
                    }
                },
                {
                    "match_phrase": {
                        "content": "疫情"
                    }
                }
            ]
        }
    }
}
```

### Filter context

In a filter context, a query clause answers the question “*Does this document match this query clause?*” The answer is a simple Yes or No — no scores are calculated. Filter context is mostly used for filtering structured data

```json
GET /alias-meta-20230106/_search
{
    "from": 0,
    "size": 50,
    "sort": [
        {
            "pub_time": "desc"
        }
    ],
    "query":{
        "bool": {
            "filter": [
                {
                    "term": {
                        "status": "0"
                    }
                }
            ]
        }
    }
}
```



### Bool query

must_not, must, should

```json
GET /{index_name}/_search
{
    "query": {
        "bool": {
            "must_not": [
                {
                    "term": {
                        "user_tag": "t_3643"
                    }
                }
            ],
            "must": [],
            "should": []
            "minimum_should_match": 1
        }
    }
}
```

### Select by ids

```json
GET /{index_name}/_search
{
    "query": {
        "ids" : {
            "values" : ["202212020fcf47a7b8d4a41ae445c573", "20221202b5484966b9700ca56c9c3e64"]
        }
    }
}
```

## Aggregation Query

### Term aggregation

```json
GET /{index_name}/_search
{
    "aggs": {
        "termAggs": {
            "terms": {
                "field": "source_id",
                "order": {
                    "_key": "asc"
                }
            }
        }
    }
}
```

### Date aggregation

```json
GET /{index_name}/_search
{
    "aggs": {
        "dateAggs": {
            "date_histogram": {
                "field": "pub_time",
                "format": "M月d日",
                "interval": "day",
                "order": {
                    "_key": "asc"
                },
                "size": 7,
                "min_doc_count": "0"
            }
        }
    }
}
```

### Nested aggregation

```json
GET /{index_name}/_search
{
    "aggs": {
        "dateAggs": {
            "date_histogram": {
                "field": "pub_time",
                "format": "M月d日",
                "interval": "day",
                "order": {
                    "_key": "asc"
                },
                "size": 7,
                "min_doc_count": "0"
            }
        },
        "aggs": {
            "source": {
                "terms": {
                    "field": "level_id"
                }
            }
        }
    }
}
```

