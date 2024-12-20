#!/bin/bash

az login

az batch account login -g EcDc-WLS-rg -n ecdcwlsbatch

poolName=test_pool_json_cli

# Get Azure storage container token so we can access it from the task
end=`date -u -d "1 day" '+%Y-%m-%dT%H:%MZ'`

sastoken=`az storage container generate-sas --account-name ecdcwls --expiry $end --name sendicott --permissions racwdli -o tsv --auth-mode login --as-user`

sasurl=https://ecdcwls.blob.core.windows.net/sendicott/?$sastoken

# copy the whole analyses folder to storage so scripts and data are available
az storage copy -d $sasurl -s analyses --recursive

# show files in container. All these files will be copied to each node
az storage blob list -c sendicott --account-name ecdcwls --sas-token $sastoken --query "[].{name:name}"

# folder for temporary task jsons containing token
mkdir cloud_config/task_jsons

# fill in taskid to make mulitple tasks from a template
for rowi in {1..10}
do
 sed 's,<taskid>,'$rowi',g' cloud_config/template_task_hello_mult.json \
  | sed 's,<sastoken>,'${sastoken//&/\\&}',g' > cloud_config/task_jsons/task_to_use_$rowi.json
done

# We create the pool which will start with 1 target dedicated node
az batch pool create --json-file cloud_config/template_pool_cli.json
az batch job create --pool-id test_pool_json_cli --id "test_job"


az batch pool list \
--query "[].{name:id, vmSize:vmSize,  curNodes: currentDedicatedNodes,
tarNodes: targetDedicatedNodes, taskSlotsPerNode:taskSlotsPerNode,
state:state, enableAutoScale:enableAutoScale,
allocState:allocationState, lastModified:lastModified}" \
--output table

for rowi in {1..10}
do
az batch task create --json-file cloud_config/task_jsons/task_to_use_$rowi.json --job-id test_job
done

az batch job task-counts show --job-id test_job

# setup autoscaling to create new nodes so that all tasks will run at the same
# time up to a max of 25 nodes and nodes will be deleted when tasks are complete
az batch pool autoscale enable --pool-id $poolName --auto-scale-evaluation-interval "PT6M"\
 --auto-scale-formula 'maxNumberofVMs = 25;
 $atasks = $ActiveTasks.GetSample(TimeInterval_Minute * 2, 1);
 $rtasks = $RunningTasks.GetSample(TimeInterval_Minute * 2, 1);
 $tasks = max($atasks) + max($rtasks);
 $nodes = max($CurrentDedicatedNodes, $TargetDedicatedNodes);
 $cores = $nodes*$TaskSlotsPerNode;
 $extraVMs = ceil((($tasks - $cores) + 0) / $TaskSlotsPerNode);
 $targetVMs = ($nodes + $extraVMs);
 $TargetDedicatedNodes = max(0, min($targetVMs, maxNumberofVMs));
 $NodeDeallocationOption = taskcompletion;' 

# This will show what the formula would return if autoscaling ran now.  
az batch pool autoscale evaluate --pool-id $poolName \
--auto-scale-formula 'maxNumberofVMs = 25;
 $atasks = $ActiveTasks.GetSample(TimeInterval_Minute * 2, 1);
 $rtasks = $RunningTasks.GetSample(TimeInterval_Minute * 2, 1);
 $tasks = max($atasks) + max($rtasks);
 $nodes = max($CurrentDedicatedNodes, $TargetDedicatedNodes);
 $cores = $nodes*$TaskSlotsPerNode;
 $extraVMs = ceil((($tasks - $cores) + 0) / $TaskSlotsPerNode);
 $targetVMs = ($nodes + $extraVMs);
 $TargetDedicatedNodes = max(0, min($targetVMs, maxNumberofVMs));
 $NodeDeallocationOption = taskcompletion;' 

az batch pool autoscale evaluate --pool-id $poolName \
--auto-scale-formula '$test=$ActiveTasks.GetSample(TimeInterval_Minute * 2, 1)'

# if autoscaling is not working as expected you can disable it
# az batch pool autoscale disable --pool-id $poolName

# check if new nodes are starting up
az batch node list --pool-id $poolName --query "{nodes: [].[id, state][]}" --output json

# Download results from storage
az storage blob list -c sendicott --account-name ecdcwls --sas-token $sastoken --query "[].{name:name}"

# Gets all files in folder
az storage copy -s https://ecdcwls.blob.core.windows.net/sendicott/*?$sastoken -d analyses/data/derived-data 


az batch pool delete --pool-id $poolName -y
az batch job delete --job-id test_job -y

# delete directory and files with task specific jsons that contain token
rm -r cloud_config/task_jsons
