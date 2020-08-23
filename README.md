# dkatalis_task
Deploying Working ElasticSearch Instance

## Inclusions
1. **infra_creation** directory which contains python and terraform configuration scripts for spinning up an ec2 instance.
2. **configuration** directory which contains ansible yamls to install and configure the Elasticsearch node.

## Prequisites:
1. Python on Bastion host.
2. Configured aws cli.

### Note: 
1. Have used t2.xlarge ec2 instance type. The Service is accessible on the localhost itself.
2. Error handling pieces in code are missing.

## Steps
```1. Clone the git repo.```

```2. Navigate to infra_creation directory, make the **trigger.py** script **executable** and execute the script.```

```3. On successfull execution of the script suite, Login to elasticsearch node (ssh -i mykeypair.pem ubuntu@<ES node IP>) and try to execute few curl commands, which demonstrates the access to ElasticSearch service. Username is **elastic** and password is **admin123**.```

  - curl -u "elastic:admin123" --insecure -X GET "https://localhost:9200/_xpack?pretty" # API call to confirm access to elasticsearch over https.
  - curl -u "elastic:admin123" --insecure -X PUT "https://localhost:9200/test-index?pretty" # API call for creating a test index.
  - curl -u "elastic:admin123" --insecure -X GET "https://localhost:9200/_cat/indices/test-index?v&s=index&pretty" # Listing the created index.
  - curl -u "elastic:admin123" --insecure -X GET "https://localhost:9200/_cat/health" # Check health of the service.

```4. Execute **terraform destroy** command from infra_creation directory.```

### Sample Output:

#### ```ubuntu@ip-10-0-1-10:~$ curl -u "elastic:admin123" --insecure -X PUT "https://localhost:9200/test-index?pretty"```

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-index"
}

## Please find the answers inline.

1. What did you choose to automate the provisioning and bootstrapping of the instance? Why?

Ans. I have used Python script to create a aws keypair, so that we get a downloadable file. This same trigger terraform configuration to spin up the vpc resources and ec2 cluster node. Then we trigger the Ansible playbook to configure and setup the elasticsearch configuration.


2. How did you choose to secure ElasticSearch? Why?

Ans. There are two ways which I have followed.
- Just Opened the ssh and 9200 port to access the elasticsearch node.
- Provisioned an openssl certificate for elasticsearch configuration. Access to elasticsearch service is tied with username/password.

3. How would you monitor this instance? What metrics would you monitor?

Ans. I can monitor the elasticsearch cluster node with Prometheus tool on the hostname:9200 of elasticsearch node.

4. Could you extend your solution to launch a secure cluster of ElasticSearch nodes? What would need to change to support this use case?

Ans. Yes we can secure the cluster with organization specific ssl certificates, validated by a CA.

5. Could you extend your solution to replace a running ElasticSearch instance with little or no downtime? How?

Ans. We can create a rolling update mechanism with terraform or ansible.

6. Was it a priority to make your code well structured, extensible, and reusable?

Ans. Currently this code doesn't contain idempotent properties. It's written to suffice the basic level requiremnt. Ansible checks are unavailable. The code is structured but not extensible/reusable.

7. What sacrifices did you make due to time?

Ans. Code Designing is weak, didn't create a multinode Elasticsearch cluster.
