#!/bin/bash

# Monitor CPU usage and available memory on Azure

az login

az batch account login -g EcDc-WLS-rg -n ecdcwlsbatch

# Get files on Azure
end=`date -u -d "1 day" '+%Y-%m-%dT%H:%MZ'`

sastoken=`az storage container generate-sas --account-name ecdcwls --expiry $end --name sendicott --permissions racwdli -o tsv --auth-mode login --as-user`

sasurl=https://ecdcwls.blob.core.windows.net/sendicott/?$sastoken

az storage copy -d $sasurl -s analyses --recursive

az storage blob list -c sendicott --account-name ecdcwls --sas-token $sastoken --query "[].{name:name}"

sed 's,<sastoken>,'${sastoken//&/\\&}',g' cloud_config/template_task_monitor.json > cloud_config/task_to_use.json


poolName=test_pool_json_cli
jobName=test_job

# Create the pool with 2 task slots per node
az batch pool create --json-file cloud_config/template_pool_cli.json
az batch job create --pool-id test_pool_json_cli --id $jobName

az batch pool list \
--query "[].{name:id, vmSize:vmSize,  curNodes: currentDedicatedNodes,
tarNodes: targetDedicatedNodes, taskSlotsPerNode:taskSlotsPerNode,
state:state, enableAutoScale:enableAutoScale,
allocState:allocationState, lastModified:lastModified}" \
--output table

# Run a task that does something memory intensive
az batch task create --json-file cloud_config/task_test_monitor.json --job-id test_job
# And in the other slot on the same node run a task that monitors usage
az batch task create --json-file cloud_config/task_to_use.json --job-id test_job

az batch job task-counts show --job-id test_job


fileName=stdout.txt

rm "cloud_config/$fileName"

az batch task file download --task-id test_outFile --job-id $jobName \
--file-path $fileName --destination "cloud_config/$fileName"

# print the file to console
cat "cloud_config/$fileName"

Rscript -e 'library(tidyverse);read.table("cloud_config/stdout.txt", sep = ":", col.names = c("var", "value")) %>% mutate(var = str_remove(var, "^\\\\r"), value = str_remove_all(value, "\\\\") %>% str_remove("bb|GB  bb")) %>% filter(var == "MEM") %>% ggplot(aes(1:nrow(.), as.numeric(value)))+geom_point()+labs(y = "Available memory (GB)");ggsave("test.png")'

open test.png

rm test.png
rm cloud_config/task_to_use.json

az batch pool delete --pool-id $poolName -y
az batch job delete --job-id test_job -y

