@rest
Feature: End to End test - install tools

# INSTALL ALL COMPONENTS
  ##################################################
  ## INSTALL KHERMES
  ##################################################
  Scenario: Install Khermes Seed
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/khermes.json' as 'json' with:
      | $.id | UPDATE | khermes |
      | $.env.SEED | UPDATE | true |
      | $.env.PORT0 | UPDATE | 2551 |
      | $.env.VAULT_HOSTS | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT  | UPDATE | ${VAULT_PORT}  |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.KAFKA_BROKER_INSTANCE_NAME | UPDATE | ${KAFKA_BROKER_INSTANCE_NAME} |
      | $.env.KAFKA_BROKER_PRINCIPAL     | UPDATE | ${KAFKA_BROKER_PRINCIPAL}     |
    Then the service response status must be '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w khermes | wc -l' contains '1'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list khermes | awk '{print $5}' | grep khermes' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


#  Scenario: Install Khermes Client
#    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
#    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
#    And I securely send requests to '${DCOS_IP}:443'
#    When I run 'dcos task khermes | grep -w khermes | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'seedIP'
#    And I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/khermes-node.json' as 'json' with:
#      | $.id | UPDATE | khermes-node |
#      | $.env.SEED | UPDATE | true |
#      | $.env.PORT0 | UPDATE | 2552 |
#      | $.env.SEED_IP | UPDATE | !{seedIP} |
#      | $.env.SEED_PORT | UPDATE | 2551 |
#    Then the service response status must be '201'.
#    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w khermes-node | wc -l' contains '1'
#    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
#    And I run 'dcos marathon task list khermes-node | awk '{print $5}' | grep khermes-node' in the ssh connection and save the value in environment variable 'marathonTaskId'
#    #DCOS dcos marathon task show check healtcheck status
#    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'

  ##################################################
  ## INSTALL ZOOKEEPER FRAMEWORK
  ##################################################
  Scenario: Install Zookeeper framework
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/zookeeper-framework.json' as 'json' with:
      | $.id | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.env.ZOOKEEPER_SERVICE_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.env.TENANT_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.ZOOKEEPER_DOCKER_IMAGE | UPDATE | ${ZOOKEEPER_DOCKER_IMAGE} |
      | $.container.docker.image | UPDATE | ${FRAMEWORK_DOCKER_IMAGE} |
    Then the service response status must be '201'

    # We check that installation finished successfully
    Given I wait '10' seconds
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I securely send requests to '${MASTER_NAME}:443'
    When in less than '300' seconds, checking each '10' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains 'RUNNING'
    And I save element '$.status[0].status' in environment variable 'zk01_status'
    And I save element '$.status[1].status' in environment variable 'zk02_status'
    And I save element '$.status[2].status' in environment variable 'zk03_status'
    Then in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains '"zk-0001","role":"zkNode","status":"RUNNING"'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains '"zk-0002","role":"zkNode","status":"RUNNING"'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains '"zk-0003","role":"zkNode","status":"RUNNING"'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list ${ZOOKEEPER_FRAMEWORK_ID} | awk '{print $5}' | grep ${ZOOKEEPER_FRAMEWORK_ID}' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show state RUNNING
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'

    
  ##################################################
  ## INSTALL KAFKA
  ##################################################
  Scenario: Install Kafka
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/confluent-kafka-sec.json' as 'json' with:
      | $.id | UPDATE | confluent-kafka-sec |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
    Then the service response status must be '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w confluent-kafka-sec | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '3'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list confluent-kafka-sec | awk '{print $5}' | grep confluent-kafka-sec' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'


  ##################################################
  ## INSTALL SPARTA
  ##################################################
  Scenario: Install Sparta
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I create file 'SpartaSecurityInstalation.json' based on 'schemas/install_jsons/spartaSecurelywithoutMarathon.json' as 'json' with:
      |   $.container.docker.image                           |  UPDATE     | ${SPARTA_DOCKER_IMAGE}           | n/a    |
      |   $.container.docker.forcePullImage                  |  REPLACE    | ${FORCEPULLIMAGE}                |boolean |
      |   $.env.SPARTA_ZOOKEEPER_CONNECTION_STRING           |  UPDATE     | ${ZK_URL}                        |n/a |
      |   $.env.VAULT_HOST                                   |  UPDATE     | ${VAULT_HOST}                    |n/a |
      |   $.env.VAULT_TOKEN                                  |  UPDATE     | !{vaultToken}                    |n/a |
    # Copy DEPLOY JSON to DCOS-CLI
    When I outbound copy 'target/test-classes/SpartaSecurityInstalation.json' through a ssh connection to '/dcos'
    #Start image from JSON
    And I run 'dcos marathon app add /dcos/SpartaSecurityInstalation.json' in the ssh connection
    # Check Sparta is Running
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep sparta-auto | grep R | wc -l' contains '1'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos marathon task list /sparta/sparta-auto | grep sparta-auto | awk '{print $2}'' contains 'True'


  ##################################################
  ## INSTALL ELASTICSEARCH
  ##################################################
  Scenario: Install Elasticsearch
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    And I create file 'config.json' based on 'schemas/elasticsearchstratio-config.json' as 'json' with:
      | $.service.name            | UPDATE  | ${SERVICE}      | n/a    |
      | $.coordinator_nodes.count | REPLACE | ${COOR_COUNT}   | number |
      | $.data_nodes.count        | REPLACE | ${DATA_COUNT}   | number |
      | $.kibana_nodes.count      | REPLACE | ${KIBANA_COUNT} | number |
      | $.security.vault_hosts    | UPDATE  | ${VAULT_HOST}   | n/a    |
      | $.security.vault_port     | UPDATE  | ${VAULT_PORT}   | n/a    |
      | $.security.vault_token    | UPDATE  | !{vaultToken}   | n/a    |
    And I outbound copy 'target/test-classes/config.json' through a ssh connection to '/tmp'
    When I run 'dcos package install --options=/tmp/config.json ${SERVICE}' in the ssh connection
    Then the command output contains 'DC/OS STRATIO ElasticSearch is being installed!'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w elasticsearchstratio | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep kibana | wc -l' contains '${KIBANA_COUNT}'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep master | wc -l' contains '3'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep coordinator | wc -l' contains '${COOR_COUNT}'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep data | wc -l' contains '${DATA_COUNT}'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list elasticsearchstratio | awk '{print $5}' | grep elasticsearchstratio' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


  ##################################################
  ## INSTALL POSTGRES COMMUNITY
  ##################################################
  Scenario: Install Postgres Community
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'

    # Install according to json with marathon
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/postgres-community.json' as 'json' with:
      | $.id | UPDATE | /${INSTANCE} |
      | $.env.POSTGRES_MESOS_PRINCIPAL | UPDATE | 012345 |
      | $.env.DISABLE_DYNAMIC_RESERVATION | UPDATE | true |
      | $.env.DISABLE_ZOOKEEPER_SEC       | UPDATE | disabled |
      | $.env.POSTGRES_MESOS_ROLE | UPDATE | slave_public |
      | $.env.REALM | UPDATE | DEMO.STRATIO.COM |
      | $.env.POSTGRES_ZOOKEEPER | UPDATE | master.mesos:2181 |
      | $.env.POSTGRES_CPU | UPDATE | 0.5 |
      | $.env.KADMIN_HOST | UPDATE | idp.integration.labs.stratio.com |
      | $.env.VAULT_TOKEN | UPDATE | !{vaulToken} |
      | $.env.POSTGRES_MESOS_MASTER | UPDATE | master.mesos:2181 |
      | $.env.TENANT_NAME | UPDATE | ${INSTANCE} |
      | $.env.VAULT_PORT | UPDATE | 8200 |
      | $.env.ENABLE_MESOS_SEC | UPDATE | true |
      | $.env.VAULT_HOSTS | UPDATE | gosec2.node.default-cluster.labs.stratio.com |
      | $.env.KDC_HOST | UPDATE | idp.integration.labs.stratio.com |
      | $.env.POSTGRES_DOCKER_IMAGE | UPDATE | qa.stratio.com/stratio/postgresql-community:${COMMUNITY_VERSION} |
      | $.env.POSTGRES_SERVICE_NAME | UPDATE | ${INSTANCE} |
      | $.env.ENABLE_MARATHON_SEC | UPDATE | true |
      | $.container.docker.image | UPDATE | qa.stratio.com/stratio/postgres-bigdata-framework:${FRAMEWORK_VERSION} |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | ${INSTANCE} |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | ${INSTANCE} |
    Then the service response status must be '201'

    #  Check the result with dcos-cli
    Given I open a ssh connection to '${DCOS_CLI}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep ${INSTANCE} | grep R | wc -l' contains '1'
    And I wait '200' seconds
    When I send a 'GET' request to '/mesos/frameworks'
    Then the service response status must be '200'
    And I save element '$' in environment variable 'coordinator'
    And 'coordinator' matches the following cases:
      | $.frameworks[?(@.name == "${INSTANCE}")].tasks[?(@.name == "pg_0001")].statuses[*].state           | contains   | TASK_RUNNING          |
    And 'coordinator' matches the following cases:
      | $.frameworks[?(@.name == "${INSTANCE}")].tasks[?(@.name == "pg_0002")].statuses[*].state           | contains   | TASK_RUNNING          |


  ##################################################
  ## INSTALL VALKIRIA
  ##################################################
  #@loop(PRIVATE_AGENTS_LIST,PRIVATE_IP)
  #Scenario: Install Valkiria (PHASE 2)
  #  Given I open a ssh connection to '<PRIVATE_IP>' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
  #  When I run 'mkdir /tmp/valkiria && cd /tmp/valkiria && wget http://sodio.stratio.com/repository/paas/valkiria/0.2.0-SNAPSHOT/valkiria-0.2.0-SNAPSHOT.tar.gz && tar xvzf valkiria-0.2.0-SNAPSHOT.tar.gz' in the ssh connection with exit status '0'
