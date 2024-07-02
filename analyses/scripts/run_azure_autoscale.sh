#!/bin/bash

az login

az batch account login -g EcDc-WLS-rg -n ecdcwlsbatch

poolName=test_pool_json_cli

mkdir cloud_config/task_jsons

for rowi in {1..5}
do
 sed 's,<taskid>,'$rowi',g' cloud_config/template_task_hello_mult.json > \
 cloud_config/task_jsons/task_to_use_$rowi.json
done

# We create the pool which will start with 1 target dedicated node
az batch pool create --json-file cloud_config/template_pool_cli.json
az batch job create --pool-id test_pool_json_cli --id "test_job"


az batch pool list \
--query "[].{name:id, vmSize:vmSize,  curNodes: currentDedicatedNodes, \
tarNodes: targetDedicatedNodes, allocState:allocationState}" --output table

for rowi in {1..5}
do
az batch task create --json-file cloud_config/task_jsons/task_to_use_$rowi.json --job-id test_job
done

az batch job task-counts show --job-id test_job

az batch pool autoscale enable --pool-id test_pool_json_cli --auto-scale-evaluation-interval "PT5M"\
 --auto-scale-formula 'percentage = 70;
 maxNumberofVMs = 25;
 span = TimeInterval_Minute * 2;
 $samples = $ActiveTasks.GetSamplePercent(span);
 $tasks = $samples < percentage ? max(0,$ActiveTasks.GetSample(1)) : max( $ActiveTasks.GetSample(1), avg($ActiveTasks.GetSample(span)));
 multiplier = 1;
 $cores = $TargetDedicatedNodes;
 $extraVMs = (($tasks - $cores) + 0) * multiplier;
 $targetVMs = ($CurrentDedicatedNodes + $extraVMs);
 $TargetDedicatedNodes = max(0, min($targetVMs, maxNumberofVMs));
 $NodeDeallocationOption = taskcompletion;'

# modified a little but still not really working. Need to figure out 
# a better way to set starting number of tasks

az batch node list --pool-id $poolName --query "{nodes: [].[id, state][]}" --output json
