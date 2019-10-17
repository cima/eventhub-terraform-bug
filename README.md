# Eventhub Terraform Bug

Every new eventhub of _Standard_ tier has Kafka api enabled. The kafka API flag in terraform is optional and it's default value is false. See in [eventhub_namespace.html](https://www.terraform.io/docs/providers/azurerm/r/eventhub_namespace.html#kafka_enabled). Creation of _Standard_ tier eventhub namespace without this flag specified creates namespace with Kafka API enabled. Subsequent terraform execution detects disparity between desired *kafka_enabled* and actual *kafka_enabled* values and decides to recreate the resource. This kind of recreation forces new resource and thus deleting the current one. This might cause data loss and configuaration invalidation for consumers and producers.

## Steps to reproduce

1. Have azure account
2. Have service principal with rights to create resource group and create/delete eventhub namespace of standard tier
3. Have storage account
4. Populate script *init_credentials.sh* with credentials and login information for above resources
5. Execute script *apply_terraform.sh*
6. Inspect created namespace with _az_
  - `az eventhubs namespace show --name eventhub-terraform-bug --resource-group eventhub-terraform-bug`
7. Execute script *apply_terraform.sh* again
8. Inspect created namespace with _az_
  - `az eventhubs namespace show --name eventhub-terraform-bug --resource-group eventhub-terraform-bug`

### First Run
- Kafka API support is not specified in terraform
  - see [main.tf](main.tf)
- Resource is being initiated with *NO* Kafka support
```
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Creating...
  auto_inflate_enabled:                "" => "false"
  capacity:                            "" => "1"
  default_primary_connection_string:   "<sensitive>" => "<sensitive>"
  default_primary_key:                 "<sensitive>" => "<sensitive>"
  default_secondary_connection_string: "<sensitive>" => "<sensitive>"
  default_secondary_key:               "<sensitive>" => "<sensitive>"
  kafka_enabled:                       "" => "false"
  location:                            "" => "westeurope"
  maximum_throughput_units:            "" => "<computed>"
  name:                                "" => "eventhub-terraform-bug"
  network_rulesets.#:                  "" => "<computed>"
  resource_group_name:                 "" => "eventhub-terraform-bug"
  sku:                                 "" => "Standard"
  tags.%:                              "" => "<computed>"
```
- [first_run.log](doc/first_run.log)
- [first_run_log.png](doc/first_run_log.png)
- Resource is *with* Kafka support
```
{
  "createdAt": "2019-10-17T10:25:23.007000+00:00",
  "id": "/subscriptions/XXXXXXXX/resourceGroups/eventhub-terraform-bug/providers/Microsoft.EventHub/namespaces/eventhub-terraform-bug",
  "isAutoInflateEnabled": false,
  "kafkaEnabled": true,
  "location": "West Europe",
  "maximumThroughputUnits": 0,
  "metricId": "XXXXXXXX:eventhub-terraform-bug",
  "name": "eventhub-terraform-bug",
  "provisioningState": "Succeeded",
  "resourceGroup": "eventhub-terraform-bug",
  "serviceBusEndpoint": "https://eventhub-terraform-bug.servicebus.windows.net:443/",
  "sku": {
    "capacity": 1,
    "name": "Standard",
    "tier": "Standard"
  },
  "type": "Microsoft.EventHub/Namespaces"
}
```

### Second Run
- Kafka API support is not specified in terraform
  - see [main.tf](main.tf)
- Resource is reported as *having* Kafka support
- Resource is desired with *NO* Kafka support
- Terraform plans to recreate the resource to disable Kafka support
```
-/+ azurerm_eventhub_namespace.eventhub_terraform_bug_namespace (new resource required)
      id:                                  "/subscriptions/XXXXXXXX/resourceGroups/eventhub-terraform-bug/providers/Microsoft.EventHub/namespaces/eventhub-terraform-bug" => <computed> (forces new resource)
      auto_inflate_enabled:                "false" => "false"
      capacity:                            "1" => "1"
      default_primary_connection_string:   <sensitive> => <computed> (attribute changed)
      default_primary_key:                 <sensitive> => <computed> (attribute changed)
      default_secondary_connection_string: <sensitive> => <computed> (attribute changed)
      default_secondary_key:               <sensitive> => <computed> (attribute changed)
      kafka_enabled:                       "true" => "false" (forces new resource)
      location:                            "westeurope" => "westeurope"
      maximum_throughput_units:            "0" => <computed>
      name:                                "eventhub-terraform-bug" => "eventhub-terraform-bug"
      network_rulesets.#:                  "1" => <computed>
      resource_group_name:                 "eventhub-terraform-bug" => "eventhub-terraform-bug"
      sku:                                 "Standard" => "Standard"
      tags.%:                              "3" => <computed>
```
- Resource is deleted
```
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Destroying... (ID: /subscriptions/XXXXXXXX-...tHub/namespaces/eventhub-terraform-bug)
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Still destroying... (ID: /subscriptions/XXXXXXXX-...tHub/namespaces/eventhub-terraform-bug, 10s elapsed)
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Still destroying... (ID: /subscriptions/XXXXXXXX-...tHub/namespaces/eventhub-terraform-bug, 20s elapsed)
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Destruction complete after 27s
```
- Resource is being initiated with *NO* Kafka support
```
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Creating...
  auto_inflate_enabled:                "" => "false"
  capacity:                            "" => "1"
  default_primary_connection_string:   "<sensitive>" => "<sensitive>"
  default_primary_key:                 "<sensitive>" => "<sensitive>"
  default_secondary_connection_string: "<sensitive>" => "<sensitive>"
  default_secondary_key:               "<sensitive>" => "<sensitive>"
  kafka_enabled:                       "" => "false"
  location:                            "" => "westeurope"
  maximum_throughput_units:            "" => "<computed>"
  name:                                "" => "eventhub-terraform-bug"
  network_rulesets.#:                  "" => "<computed>"
  resource_group_name:                 "" => "eventhub-terraform-bug"
  sku:                                 "" => "Standard"
  tags.%:                              "" => "<computed>"
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Still creating... (10s elapsed)
azurerm_eventhub_namespace.eventhub_terraform_bug_namespace: Creation complete after 3m25s (ID: /subscriptions/XXXXXXXX-...tHub/namespaces/eventhub-terraform-bug)
```
- [second_run.log](doc/second_run.log)
- [second_run_log.png](doc/second_run_log.png)
- Resource is agin created *with* kafka support
```
{
  "createdAt": "2019-10-17T10:25:23.007000+00:00",
  "id": "/subscriptions/XXXXXXXX/resourceGroups/eventhub-terraform-bug/providers/Microsoft.EventHub/namespaces/eventhub-terraform-bug",
  "isAutoInflateEnabled": false,
  "kafkaEnabled": true,
  "location": "West Europe",
  "maximumThroughputUnits": 0,
  "metricId": "XXXXXXXX:eventhub-terraform-bug",
  "name": "eventhub-terraform-bug",
  "provisioningState": "Succeeded",
  "resourceGroup": "eventhub-terraform-bug",
  "serviceBusEndpoint": "https://eventhub-terraform-bug.servicebus.windows.net:443/",
  "sku": {
    "capacity": 1,
    "name": "Standard",
    "tier": "Standard"
  },
  "type": "Microsoft.EventHub/Namespaces",
  "updatedAt": "2019-10-17T10:28:09.553000+00:00"
}
```

### Environment
- Terraform v0.11.13
- provider.azurerm v1.35.0

## Expected behavior
As an incpomatible change was introduced the missing optional parameter shouldn't cause resource recreation. Eventhub recreation not only causes short outage, but also causes data loss. not speking about necessity to redistribute access keys to consumers and producers.