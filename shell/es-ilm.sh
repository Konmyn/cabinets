#! /usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# 初始化es的索引生命周期管理策略

# ES的连接信息，要包含用户名密码
# 示例: http://elastic:j91GsSb5pr06rkDroJhf@10.20.125.51:9200
ES_URL=$1
# 索引别名， =索引前缀，logstash输出的目的地
# 示例: network-f5
# prd_<namespace>
# prd_default
ILM_NAME=$2

echo 1
# 创建索引生命周期管理策略
curl -XPUT -H "Content-Type:  application/json" ${ES_URL}/_ilm/policy/${ILM_NAME}_ilm -d'{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "120GB",
            "max_age": "7d"
          }
        }
      },
      "delete": {
        "min_age": "21d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'

echo
echo 2
echo

# Create an index template to apply the policy to each new index.
curl -XPUT -H "Content-Type:  application/json" ${ES_URL}/_index_template/${ILM_NAME}_template -d'{
  "index_patterns": ["'"${ILM_NAME}"'-*"],
  "template": {
    "settings": {
      "number_of_shards": 6,
      "number_of_replicas": 1,
      "index.lifecycle.name": "'"${ILM_NAME}"'_ilm",
      "index.lifecycle.rollover_alias": "'"${ILM_NAME}"'"
    }
  }
}'

echo
echo 3
echo

# Bootstrap an index as the initial write index.
curl -XPUT -H "Content-Type:  application/json" ${ES_URL}/${ILM_NAME}-000001 -d'{
  "aliases": {
    "'"${ILM_NAME}"'": {
      "is_write_index": true
    }
  }
}'

echo done
