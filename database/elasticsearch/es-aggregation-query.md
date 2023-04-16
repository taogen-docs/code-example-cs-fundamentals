# Elasticsearch Aggregation Query

## Count

### Approximate distinct count

```json
{
  "size": 0,
  "aggs": {
    "author_count": {
      "cardinality": {
        "field": "author"
      }
    }
  }
}
```



## Group

### Query rows of Top N Group order by a field

Using terms to get groups

Using top-hits to specify items of a group

```json
{
    "size": 0,
    "aggs":{
        "termAggs":{
            "terms":{
                "field":"same_id",
                "order":{
                    "_count":"desc"
                },
                "size":10
            },
            "aggs":{
                "topHitAggs":{
                    "top_hits":{
                        "_source":{
                            "includes":[
                                "id",
                                "title",
                                "senti_keywords",
                                "source_url"
                            ]
                        },
                        "sort":{
                            "pub_time":{
                                "order":"desc"
                            }
                        }
                    }
                }
            }
        }
    }
}
```



### Query the second level nested group names and second level group count greater than 100

- first level group count > 100: "min_doc_count": 100
- second level group count > 100: "min_doc_count": 100

```json
{
  "size": 0,
  "aggs": {
    "sameIdTerms": {
      "terms": {
        "field": "same_id",
        "size": 1000,
        "min_doc_count": 100
      },
      "aggs": {
        "authorTerms": {
          "terms": {
            "field": "author",
            "size": 100,
            "min_doc_count": 100
          }
        }
      }
    }
  },
  "query": {
    "bool": {
      "must": [
        {
          "exists": {
            "field": "author"
          }
        }
      ],
      "must_not": [
        {
          "term": {
            "author": ""
          }
        }
      ]
    }
  }
}
```

