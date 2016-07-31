#!/bin/bash
es_host_ip=${1:-"127.0.0.1"}
node_zone=$(awk -F= '{print $2}' /etc/sys.serial.txt)

#db_mysql
 curl -XPUT 'http://'$es_host_ip:9200'/db_mysql' -d '{
	 "settings" : {
		"routing": {
	    	"allocation": {
	        "include": {
	          "zone": "'$node_zone'"
	        }
	      }
	    },
	 	"analyzer" : "ik"
	 } 
 }'
  curl -XPUT 'http://'$es_host_ip:9200'/_river' -d '{
	 "settings" : {
		"routing": {
	    	"allocation": {
	        "include": {
	          "zone": "'$node_zone'"
	        }
	      }
	    },
	 	"analyzer" : "ik"
	 } 
 }'
 #t_sys_user
 curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_sys_user?pretty' -d '{
  "t_sys_user": {
  		"_all": {
        "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "userID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "userGroupID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "roleID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "loginName": {"type": "string","index": "not_analyzed"},
      "userName": {"type": "string","index": "not_analyzed"},
      "jobNum": {"type": "string","index": "not_analyzed"},
      "email": {"type": "String","analyzer": "ik","include_in_all": "true","store": "no"},
      "telephone": {"type": "string","index": "not_analyzed"},
      "mobilePhone": {"type": "string","index": "not_analyzed"},
      "ipAddress": {"type": "String","index": "not_analyzed"},
      "policyID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "password": {"type": "string","index": "not_analyzed","include_in_all": "false"},
      "description": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "status": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "isSysDefault": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "createTime": {"type": "date","index": "not_analyzed"},
      "lastLoginTime": {"type": "date","index": "not_analyzed"},
      "themeType": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "preFix": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "startStandardIP": {"type": "string", "index": "not_analyzed"},
      "endStandardIP": {"type": "string","index": "not_analyzed"},
      "verifyIPAddr": {"type": "long","index": "not_analyzed"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false"}
    }
  }
}'


#t_pol_common_policy
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_pol_common_policy?pretty' -d '{
  "t_pol_common_policy": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
    "properties": {
     "commonPolicyID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "groupID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "commonPolicyName": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "commonPolicyNameEN": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "descritption": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "descriptionEN": {"type": "String","analyzer": "ik","include_in_all": "true","store": "no"},
      "commonPolicyCategory": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "policyContent": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "isSysDefault": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "isEnabled": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "reserved1": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved2": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved3": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved4": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved5": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all":"false" }
    }
  }
}'

#t_pol_filter
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_pol_filter?pretty' -d '{
  "t_pol_filter": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
    "properties": {
     "filterID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "groupID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "filterName": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "status": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "description": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "filterType": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "updatetime": {"type": "date","index": "not_analyzed","include_in_all":"false"},
      "userID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "reserved1": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved2": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved3": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all":"false" }
    }
  }
}'



#t_pol_group
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_pol_group?pretty' -d '{
  "t_pol_group": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
    "properties": {
     "policyGroupID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "policyCategoryID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "upperPolicyGroupID": {"type":  "long","index": "not_analyzed","include_in_all":"false"},
      "policyGroupName": {"type":  "string","analyzer": "ik","include_in_all":"true","store": "no"},
      "policyGroupNameEN": {"type": "string","analyzer": "ik","include_in_all":"true","store": "no"},
      "description": {"type": "String","analyzer": "ik","include_in_all": "true","store": "no"},
      "descriptionEN": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "reserved1": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved2": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved3": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all":"false" }
    }
  }
}'


#t_pol_inc_policy
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_pol_inc_policy?pretty' -d '{
  "t_pol_inc_policy": {
       "_all": {
       "indexAnalyzer": "ik",
       "searchAnalyzer": "ik",
       "store": "false"
      },
      "properties": {
      "incPolicyID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "groupID": {"type": "long","index": "not_analyzed","include_in_all":"false"},
      "incPolicyName": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "incPolicyNameEN": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "incPolicyType": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "incPolicyCategory": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "knowledgeID": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "priority": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "originType": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "creatorID": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "mergFields": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "description": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "descriptionEN": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "status": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "enableStatus": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "isSysDefault": {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "actionID": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved1": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved2": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved3": {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all":"false" }
    }
  }
}'

#t_pol_statistics_rule
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_pol_statistics_rule?pretty' -d '{
  "t_pol_statistics_rule": {
         "_all": {
         "indexAnalyzer": "ik",
         "searchAnalyzer": "ik",
         "store": "false"
      },
      "properties": {
      "statisticsID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "groupID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "statisticsName": {"type": "string","analyzer": "ik" , "include_in_all": "true","store": "no"},
      "statisticsNameEN": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "description": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "descriptionEN": {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "filterRuleID": {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "mergeFields": {"type": "string","analyzer": "ik","include_in_all": "false"},
      "statisticsSource": {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "statisticsInterval": {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "statisticsField1Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField2Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField3Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField4Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField5Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField6Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField7Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField8Name": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField1Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField2Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField3Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField4Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField5Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField6Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField7Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "statisticsField8Expr": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "baselineType": {"type":  "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "reserved1": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved2": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved3": {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all":"false" }
    }
  }
}'


#t_evt_event
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_evt_event?pretty' -d '{
  "t_evt_event": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "eventID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "sessionID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "securityObjectID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "securityObjectIP" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "eventName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "internalCode" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "message" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "severity" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "category" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "subcategory" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "originSeverity" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "deviceType" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "deviceAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "deviceName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "productName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "productVersion" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "receiveTime" :  {"type": "date","index": "not_analyzed","include_in_all": "false","store": "no"},
      "originTime" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "reliability" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "sourceAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "sourceHostName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "sourcePort" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "sourceMask" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "sourceUser" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "sourceMAC" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "sourceZone" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationHostName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationPort" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationMask" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationUser" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationMAC" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "destinationZone" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "collectorID" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "collectorName" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "collectorAddress" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "networkID" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "networkName" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "sendFlow" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "sendFlowUnit" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "receiveFlow" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "receiveFlowUnit" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "totalFlow" :  {"type": "long","index": "not_analyzed" ,"include_in_all": "false","store": "no"},
      "totalFlowUnit" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "sendPacket" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "receivePacket" :  {"type": "long","index": "not_analyzed" ,"include_in_all": "false","store": "no"},
      "totalPacket" :  {"type": "long","index": "not_analyzed","include_in_all": "false","store": "no"},
      "objectCategory" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "objectSubcategory" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "objectName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "objectAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "objectAccount" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "executionAccount" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "executionAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "actionCategory" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "actionName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "actionAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "actionDetail" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "actionDuration" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "domainName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "groupName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "serviceName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "otherAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "otherPort" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "protocol" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "appProtocol" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "appSubprotocol" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "action" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "result" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "fileName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "duration" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "count" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "ruleType" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "stringUserData1" : {"type": "string","include_in_all": "false" },
      "stringUserData2" : {"type": "string","include_in_all": "false" },
      "stringUserData3" : {"type": "string","include_in_all": "false" },
      "stringUserData4" : {"type": "string","include_in_all": "false" },
      "stringUserData5" : {"type": "string","include_in_all": "false" },
      "stringUserData6" : {"type": "string","include_in_all": "false" },
      "stringUserData7" : {"type": "string","include_in_all": "false" },
      "stringUserData8" : {"type": "string","include_in_all": "false" },
      "stringUserData9" : {"type": "string","include_in_all": "false" },
      "stringUserData10" : {"type": "string","include_in_all": "false" },
      "stringUserData11" : {"type": "string","include_in_all": "false" },
      "stringUserData12" : {"type": "string","include_in_all": "false" },
      "stringUserData13" : {"type": "string","include_in_all": "false" },
      "stringUserData14" : {"type": "string","include_in_all": "false" },
      "stringUserData15" : {"type": "string","include_in_all": "false" },
      "stringUserData16" : {"type": "string","include_in_all": "false" },
      "stringUserData17" : {"type": "string","include_in_all": "false" },
      "stringUserData18" : {"type": "string","include_in_all": "false" },
      "stringUserData19" : {"type": "string","include_in_all": "false" },
      "stringUserData20" : {"type": "string","include_in_all": "false" },
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false"  }
    }
  }
}'



#t_rpt_malware_detection
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_rpt_malware_detection?pretty' -d '{
  "t_rpt_malware_detection": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
       "rptID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "sessionID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "fileName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "category" : {"type": "string","index": "not_analyzed","include_in_all": "false" },
      "fileSize" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "beginTime" :  {"type": "date","index": "not_analyzed","include_in_all": "false" },
      "endTime" :  {"type": "date","index": "not_analyzed","include_in_all": "false" },
      "duration" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "reserved1" : {"type": "string","index": "not_analyzed","include_in_all": "false" },
      "reserved2" : {"type": "string","index": "not_analyzed","include_in_all": "false" },
      "reserved3" : {"type": "string","index": "not_analyzed","include_in_all": "false" },
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false" }
    }
  }
}'


#t_inc_incident
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_inc_incident?pretty' -d '{
  "t_inc_incident": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "incidentID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "incidentName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "incPolicyName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "incCategoryID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "incSubCategoryID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "incCategory" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "incSubCategory" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "severity" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "objectID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "objectIP" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "objectType" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "systemTypeID" :  {"type": "long","index": "not_analyzed" },
      "systemTypeName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "createTime" :  {"type": "date","index": "not_analyzed","include_in_all": "true","store": "no"},
      "updateTime" :  {"type": "date","index": "not_analyzed","include_in_all": "true","store": "no"},
      "currentCount" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "incStatus" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "ackReason" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "ackUserID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "ticketID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "ticketStartTime" :  {"type": "date","index": "not_analyzed","include_in_all": "false" },
      "ticketEndTime" :  {"type": "date","index": "not_analyzed","include_in_all": "false" },
      "actorUser" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved1" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved2" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved3" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved4" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved5" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved6" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved7" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved8" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved9" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved10" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "description" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false" }
    }
  }
}'


#t_obj_instance
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_obj_instance?pretty' -d '{
  "t_obj_instance": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "instanceID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "instanceGroupID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "upperInstanceID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "categoryID" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "instanceName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "instanceNameEN" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "description" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "descirptionEN" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "isSysdefault" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "isEnable" :  {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "reserved1" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved2" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved3" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved4" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved5" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved6" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved7" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved8" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "reserved9" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "reserved10" : {"type": "string","analyzer": "ik","include_in_all": "false","store": "no"},
      "status" : {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "issuer" : {"type": "long","index": "not_analyzed","include_in_all": "false" },
      "updatetime" : {"type": "date","index": "not_analyzed","include_in_all": "false" },
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false" }
    }
  }
}'


#t_obj_instance_group
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_obj_instance_group?pretty' -d '{
  "t_obj_instance_group": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "instanceGroupID" :  {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "upperInstanceGroupID" :  {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "instanceGroupName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "instanceGroupNameEN" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "categoryID" :  {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "description" :  {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "isSysdefault" :  {"type": "long","index": "not_analyzed" },
      "reserved1" : {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved2" : {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "reserved3" : {"type": "string","analyzer": "ik","include_in_all":"false","store": "no"},
      "status" : {"type": "long","index": "not_analyzed","include_in_all":"false" },
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all":"false" }
    }
  }
}'


#t_sys_backuplog
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_sys_backuplog?pretty' -d '{
  "t_sys_backuplog": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "backupID" :  {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "backupName" :  {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "backupTime" : {"type": "date","index": "not_analyzed" },
      "backupFilePath" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false"}
    }
  }
}'


#t_sys_log
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_sys_log?pretty' -d '{
  "t_sys_log": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "logID" :  {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "componentName" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "ipAddress" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "logLevel" :  {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "logContent" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "createTime" :  {"type": "date","index": "not_analyzed"},
      "operatorUser" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "logType" :  {"type": "long","index": "not_analyzed"},
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false"}
    }
  }
}'


#t_sys_upgradelog
curl -XPUT 'http://'$es_host_ip:9200'/db_mysql/_mapping/t_sys_upgradelog?pretty' -d '{
  "t_sys_upgradelog": {
  		"_all": {
         "indexAnalyzer": "ik",
        "searchAnalyzer": "ik",
        "store": "false"
      },
      "properties": {
      "upgradeID" :  {"type": "long","index": "not_analyzed","include_in_all": "false"},
      "version" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "oldVersion" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "content" : {"type": "string","analyzer": "ik","include_in_all": "true","store": "no"},
      "upgradeTime" :  {"type": "date","index": "not_analyzed" },
      "upgradeResult" :  {"type": "long","index": "not_analyzed" },
      "cdate" : {"type": "date","index": "not_analyzed","include_in_all": "false"}
    }
  }
}'

########################################################
######################数据表同步策略配置######################
########################################################

#t_sys_user
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_sys_user_river/_meta?pretty' -d '{ 
  "type": "jdbc",
  "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.userID AS _id,a.createTime AS cdate, a.* FROM t_sys_user a WHERE a.createTime IS  NOT NULL",
    "index": "db_mysql",
    "type": "t_sys_user",
    "schedule": "0 0 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'


#system_t_pol_common_policy
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_pol_common_policy_river_sysinit/_meta?pretty' -d '{ 
  "type": "jdbc",
  "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.commonPolicyID AS _id, NOW() AS cdate, a.* FROM t_pol_common_policy a WHERE a.updatetime IS  NULL",
    "index": "db_mysql",
    "type": "t_pol_common_policy",
    "schedule": "0 0 03 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#user_t_pol_common_policy
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_pol_common_policy_river/_meta?pretty' -d '{ 
  "type": "jdbc",
  "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": [
      {
        "statement": "SELECT a.commonPolicyID AS _id, NOW() AS cdate, a.* FROM t_pol_common_policy a WHERE a.updatetime >?",
        "parameter": ["$river.state.last_active_begin"]
      }
    ],
    "index": "db_mysql",
    "type": "t_pol_common_policy",
    "schedule": "0 5 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_pol_filter
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_pol_filter_river/_meta?pretty' -d '{ 
  "type": "jdbc",
  "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT filterID AS _id, NOW() AS cdate, filterID, groupID, filterName, STATUS, description, filterType, updatetime, userID, reserved1, reserved2, reserved3 FROM t_pol_filter ",
    "index": "db_mysql",
    "type": "t_pol_filter",
    "schedule": "0 10 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_pol_group
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_pol_group_river/_meta?pretty' -d '{ 
  "type": "jdbc",
  "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.policyGroupID AS _id, NOW() AS cdate, a.* FROM t_pol_group a",
    "index": "db_mysql",
    "type": "t_pol_group",
    "schedule": "0 15 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'


#t_pol_inc_policy
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_pol_inc_policy_river/_meta?pretty' -d '{ 
  "type": "jdbc",
  "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.incPolicyID AS _id, NOW() AS cdate, a.* FROM t_pol_inc_policy a",
    "index": "db_mysql",
    "type": "t_pol_inc_policy",
    "schedule": "0 20 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_pol_statistics_rule
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_pol_statistics_rule_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.statisticsID AS _id, NOW() AS cdate, a.* FROM t_pol_statistics_rule a",
    "index": "db_mysql",
    "type": "t_pol_statistics_rule",
    "schedule": "0 25 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'


#######按天分表，这里是动态的表名(t_evt_eventYYYYMMDD)，后面需要调整###########
#安全事件基础表，需按天分表:t_evt_event
#####################################################################
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_evt_event_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": [
      {
        "callable": true,
        "statement": "{CALL sync_t_evt_event()}"
      }
    ],
    "index": "db_mysql",
    "type": "t_evt_event",
    "schedule": "0 0/2 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_rpt_malware_detection
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_rpt_malware_detection_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": [
      {
        "statement": "SELECT a.rptID AS _id, a.endTime AS cdate, a.* FROM t_rpt_malware_detection a WHERE a.beginTime >?",
        "parameter": ["$river.state.last_active_begin"]
      }
    ],
    "index": "db_mysql",
    "type": "t_rpt_malware_detection",
    "schedule": "0 0-59 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'


#t_inc_incident
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_inc_incident_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": [
      {
        "statement": "SELECT a.incidentID AS _id, a.updatetime AS cdate, a.* FROM t_inc_incident a WHERE a.createTime >?",
        "parameter": ["$river.state.last_active_begin"]
      }
    ],
    "index": "db_mysql",
    "type": "t_inc_incident",
    "schedule": "0 0-59 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'


#system_t_obj_instance
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_obj_instance_river_sysinit/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": [
      {
        "statement": "SELECT a.instanceID AS _id,a.updatetime AS cdate, a.* FROM t_obj_instance a WHERE categoryid  BETWEEN 5 AND 15  AND a.updatetime >?",
        "parameter": ["$river.state.last_active_begin"]
      }
    ],
    "index": "db_mysql",
    "type": "t_obj_instance",
    "schedule": "0 30 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#user_t_obj_instance
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_obj_instance_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.instanceID AS _id,a.updatetime AS cdate, a.* FROM t_obj_instance a WHERE categoryid  BETWEEN 5 AND 15  AND a.updatetime is null",
    "index": "db_mysql",
    "type": "t_obj_instance",
    "schedule": "0 30 4 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_obj_instance_group
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_obj_instance_group_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.instanceGroupID AS _id, NOW() AS cdate, a.* FROM t_obj_instance_group a",
    "index": "db_mysql",
    "type": "t_obj_instance_group",
    "schedule": "0 35 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_sys_backuplog
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_sys_backuplog_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.backupID AS _id, a.backupTime AS cdate, a.* FROM t_sys_backuplog a",
    "index": "db_mysql",
    "type": "t_sys_backuplog",
    "schedule": "0 40 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'

#t_sys_log
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_sys_log_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": [
      {
        "statement": "SELECT a.logID AS _id, a.createTime AS cdate, a.* FROM t_sys_log a WHERE a.createTime >?",
        "parameter": ["$river.state.last_active_begin"]
      }
    ],
    "index": "db_mysql",
    "type": "t_sys_log",
    "schedule": "0 0-59 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'


#t_sys_upgradelog
curl -XPUT 'http://'$es_host_ip:9200'/_river/t_sys_upgradelog_river/_meta?pretty' -d '{ 
  "type": "jdbc",
    "jdbc": {
    "driver": "com.mysql.jdbc.Driver",
    "url": "jdbc:mysql://'$es_host_ip':3306/polydata",
    "user": "polydata",
    "password": "70kNdHrAQWhm6fujsOPong==",
    "sql": "SELECT a.upgradeID AS _id, a.upgradeTime AS cdate, a.* FROM t_sys_upgradelog a",
    "index": "db_mysql",
    "type": "t_sys_upgradelog",
    "schedule": "0 45 0-23 ? * * *",
	"elasticsearch.cluster":"polydata",
	"elasticsearch.host":"'$es_host_ip':9300",
    "elasticsearch.autodiscover": "false"
  }
}'
