# README

## ACCEPTANCE TESTS

Cucumber automated acceptance tests for End to End Demo.
Multiple technologies will be involved in this demo:

* Khermes: For random data generation.
* Kafka: As stream processor. 
* Sparta: To process data.
* Elasticsearch: To store processed info.
* Postgres: To store processed data.
* Valkiria: For chaos generation.

This module depends on a QA library (stratio-test-bdd), where common logic and steps are implemented.

## EXECUTION

These tests will be executed as part of the continuous integration flow as follows:

mvn verify [-D\<ENV_VAR>=\<VALUE>] [-Dit.test=\<TEST_TO_EXECUTE>|-Dgroups=\<GROUP_TO_EXECUTE>]

Example:

* Installation:
mvn verify -Dgroups=installation -DDCOS_IP=10.200.0.21 -DDCOS_USER=admin@demo.stratio.com -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DCLI_USER=root -DCLI_PASSWORD=stratio -DVAULT_HOST=10.200.0.28 -DVAULT_PORT=8200 -DKAFKA_BROKER_INSTANCE_NAME=broker-0-confluent-kafka-sec -DKAFKA_BROKER_PRINCIPAL=broker-0-confluent-kafka-sec -DSERVICE=elasticsearchstratio -DCOOR_COUNT=1 -DDATA_COUNT=3 -DKIBANA_COUNT=0 -DINSTANCE=postgresql -DCOMMUNITY_VERSION=0.9.0 -DFRAMEWORK_VERSION=0.14.0

* Setup:
mvn verify -Dgroups=setup -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DCLI_USER=root -DCLI_PASSWORD=stratio -DKAFKA_BROKER_KEYSTORE_PASSWORD=br0k3r_0_c0nflu3nt_k4fk4_s3c -DKAFKA_BROKER_KEY_PASSWORD=br0k3r_0_c0nflu3nt_k4fk4_s3c -DCA_TRUSTORE_PASSWORD=c4_trust_d3f4ult_k3yst0r3 -DBOOTSTRAP_SERVERS=broker-2.confluent-kafka-sec.mesos:10038,broker-1.confluent-kafka-sec.mesos:10038,broker-0.confluent-kafka-sec.mesos:10038 -DSELENIUM_GRID=jenkins.stratio.com:4444 -DFORCE_BROWSER=chrome_aalfonsotest

* Execution:
mvn verify -Dgroups=execution -DSELENIUM_GRID=jenkins.stratio.com:4444 -DFORCE_BROWSER=chrome_aalfonsotest

* Check:
mvn verify -Dgroups=check -DDCOS_IP=10.200.0.21 -DDCOS_USER=admin@demo.stratio.com -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DCLI_USER=root -DCLI_PASSWORD=stratio


By default, in jenkins we will execute the group endtoend, which could contain a subset of tests, that are key to the functioning of the module and the ones generated for the new feature.

All tests, that are not fully implemented, should be tagged with '@ignore @tillfixed(PAAS-XXX)'
