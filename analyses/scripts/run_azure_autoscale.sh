#!/bin/bash

az login

az batch account login -g EcDc-WLS-rg -n ecdcwlsbatch

poolName=test_pool_json_cli

mkdir cloud_config/task_jsons

# fill in taskid to make mulitple tasks from a template
for rowi in {1..5}
do
 sed 's,<taskid>,'$rowi',g' cloud_config/template_task_hello_mult.json > \
 cloud_config/task_jsons/task_to_use_$rowi.json
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

for rowi in {6..10}
do
az batch task create --json-file cloud_config/task_jsons/task_to_use_$rowi.json --job-id test_job
done

az batch job task-counts show --job-id test_job


# This worked but it first went down to 0 target nodes and then only changed to
# 3 after the first 5 min interval
# az batch pool autoscale enable --pool-id $poolName --auto-scale-evaluation-interval "PT5M"\
#  --auto-scale-formula 'percentage = 70;
#  maxNumberofVMs = 25;
#  span = TimeInterval_Second * 15;
#  $samples = $ActiveTasks.GetSamplePercent(span);
#  $tasks = $samples < percentage ? max(0,$ActiveTasks.GetSample(1)) : max( $ActiveTasks.GetSample(1), avg($ActiveTasks.GetSample(span)));
#  $cores = $CurrentDedicatedNodes*$TaskSlotsPerNode;
#  $extraVMs = ceil((($tasks - $cores) + 0) / $TaskSlotsPerNode);
#  $targetVMs = ($CurrentDedicatedNodes + $extraVMs);
#  $TargetDedicatedNodes = max(0, min($targetVMs, maxNumberofVMs));
#  $NodeDeallocationOption = taskcompletion;'

az batch pool autoscale enable --pool-id $poolName --auto-scale-evaluation-interval "PT5M"\
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

az batch pool autoscale disable --pool-id $poolName

az batch node list --pool-id $poolName --query "{nodes: [].[id, state][]}" --output json

az batch pool delete --pool-id $poolName -y
az batch job delete --job-id test_job -y

