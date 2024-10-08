#!/usr/bin/env bash

## Job to run daily
cd "{{ .Values.analytics_home }}"
source model-config.sh
today=$(date "+%Y-%m-%d")

while :; do
    case $1 in
        -j|--job)   shift
                    job="$1"         
        ;;
        -m|--mode)  shift
                    mode="$1"            
        ;;
        -p|--parallelisation)   shift
                                parallelisation=$1            
        ;;
        -pa|--partitions)   shift
                            partitions=$1       
        ;;
        -sd|--startDate)    shift
                            start_date=$1            
        ;;
        -ed|--endDate)  shift
                        end_date=$1            
        ;;
        -h|--sparkMaster)   shift
                            sparkMaster=$1
        ;;
        -sp|--selectedPartitions)   shift 
                                    selected_partitions=$1
        ;;
        *) break
    esac
    shift
done

get_report_job_model_name(){
    case "$1" in
        "assessment-dashboard-metrics") echo 'org.sunbird.analytics.job.report.AssessmentMetricsJobV2'
        ;;
        "course-dashboard-metrics") echo 'org.sunbird.analytics.job.report.CourseMetricsJobV2'
        ;;
        "userinfo-exhaust") echo 'org.sunbird.analytics.exhaust.collection.UserInfoExhaustJob'
        ;;
        "response-exhaust") echo 'org.sunbird.analytics.exhaust.collection.ResponseExhaustJob'
        ;;
        "response-exhaust-v2") echo 'org.sunbird.analytics.exhaust.collection.ResponseExhaustJobV2'
        ;;
        "progress-exhaust") echo 'org.sunbird.analytics.exhaust.collection.ProgressExhaustJob'
        ;;
        "progress-exhaust-v2") echo 'org.sunbird.analytics.exhaust.collection.ProgressExhaustJobV2'
        ;;
        "cassandra-migration") echo 'org.sunbird.analytics.updater.CassandraMigratorJob'
        ;;
        "uci-private-exhaust") echo 'org.sunbird.analytics.exhaust.uci.UCIPrivateExhaustJob'
        ;;
        "uci-response-exhaust") echo 'org.sunbird.analytics.exhaust.uci.UCIResponseExhaustJob'
        ;;
        *) echo $1
        ;;
    esac        
}

submit_cluster_job() {
   # add batch number to config
   echo "Running for below batch number $i"
   batchNumberString="\\\"modelParams\\\":{\\\"batchNumber\\\":$i,"
   job_config=$(config $job)
   cluster_job_config=${job_config//'"'/'\"'}
   finalConfig=${cluster_job_config/'\"modelParams\":{'/$batchNumberString}
   echo $finalConfig
   echo "Running $job as parallel jobs"
   classVariable="org.ekstep.analytics.job.JobExecutor"
   argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$finalConfig\"]"
   argsStr="\"className\": \"org.ekstep.analytics.job.JobExecutor\", $argsList"
   clusterConfig=`cat cluster-config.json`
   requestBody=${clusterConfig/'"className": "org.ekstep.analytics.job.JobExecutor"'/$argsStr}
   finalRequestBody=${requestBody/'org.ekstep.analytics.job.JobExecutor'/$classVariable}
   echo $finalRequestBody
   response=$(curl -k --user "{{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}:{{ include "common.tplvalues.render" ( dict "value" .Values.admin_password "context" $ ) }}" -v -H "Content-Type: application/json" -X POST -d "$finalRequestBody" 'https://{{ include "common.tplvalues.render" ( dict "value" .Values.spark_cluster_name "context" $ ) }}.azurehdinsight.net/livy/batches' -H "X-Requested-By: {{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}")
   echo "Submitted job for batchNumer $i below is the response"
   echo $response
}

job_id=$(get_report_job_model_name $job)

if [ -z "$sparkMaster" ]; then sparkMaster="local[*]"; else sparkMaster="$sparkMaster"; fi

if [ "$mode" = "via-partition" ]; then
    endPartitions=`expr $partitions - 1`
    if [ -z "$parallelisation" ]; then parallelisation=1; else parallelisation=$parallelisation; fi
    # add partitions to config and start jobs
    for i in $(seq 0 $parallelisation $endPartitions)
        do 
            # add partitions to config
            partitionString="\\\"delta\\\":0,\\\"partitions\\\":[$(seq -s , $i `expr $i + $parallelisation - 1`)]"
            if [ -z "$start_date" ]; then
                job_config=$(config $job)
                cluster_job_config=${job_config//'"'/'\"'}
                finalConfig=${cluster_job_config/'\"delta\":0'/$partitionString}
                echo $finalConfig
                echo "Running $job by partitions."
                classVariable="org.ekstep.analytics.job.JobExecutor"
                argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$finalConfig\"]"
            else 
                job_config=$(config $job '__endDate__')
                cluster_job_config=${job_config//'"'/'\"'}
                finalConfig=${cluster_job_config/'\"delta\":0'/$partitionString}
                echo $finalConfig
                echo "Running $job by partitions via Replay-Supervisor."
                classVariable="org.ekstep.analytics.job.ReplaySupervisor"
                argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$finalConfig\", \"--fromDate\", \"$start_date\", \"--toDate\", \"$end_date\"]"
            fi
            argsStr="\"className\": \"org.ekstep.analytics.job.JobExecutor\", $argsList"
            clusterConfig=`cat cluster-config.json`
            requestBody=${clusterConfig/'"className": "org.ekstep.analytics.job.JobExecutor"'/$argsStr}
            finalRequestBody=${requestBody/'org.ekstep.analytics.job.JobExecutor'/$classVariable}
            echo $finalRequestBody
            curl -k --user "{{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}:{{ include "common.tplvalues.render" ( dict "value" .Values.admin_password "context" $ ) }}" -v -H "Content-Type: application/json" -X POST -d "$finalRequestBody" 'https://{{ include "common.tplvalues.render" ( dict "value" .Values.spark_cluster_name "context" $ ) }}.azurehdinsight.net/livy/batches' -H "X-Requested-By: {{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}"
        done

elif [ "$mode" = "parallel-jobs" ]; then
     # add batch number to config and submit jobs
    echo "inside parallel-jobs block" 
    echo $parallelisation
    if [ $parallelisation -ge 1 ]; then
        for i in $(seq 1 $parallelisation)
            do 
            submit_cluster_job $i &
            done
    else echo "No requests found in table"; fi       

elif [ "$mode" = "selected-partition" ]; then
     # add partitions to config
     partitionString="\\\"delta\\\":0,\\\"partitions\\\":[$selected_partitions]"
     if [ -z "$start_date" ]; then
         job_config=$(config $job)
         cluster_job_config=${job_config//'"'/'\"'}
         finalConfig=${cluster_job_config/'\"delta\":0'/$partitionString}
         echo $finalConfig
         echo "Running $job by partitions."
         classVariable="org.ekstep.analytics.job.JobExecutor"
         argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$finalConfig\"]"
     else 
         job_config=$(config $job '__endDate__')
         cluster_job_config=${job_config//'"'/'\"'}
         finalConfig=${cluster_job_config/'\"delta\":0'/$partitionString}
         echo $finalConfig
         echo "Running $job by partitions via Replay-Supervisor."
         classVariable="org.ekstep.analytics.job.ReplaySupervisor"
         argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$finalConfig\", \"--fromDate\", \"$start_date\", \"--toDate\", \"$end_date\"]"
     fi
     argsStr="\"className\": \"org.ekstep.analytics.job.JobExecutor\", $argsList"
     clusterConfig=`cat cluster-config.json`
     requestBody=${clusterConfig/'"className": "org.ekstep.analytics.job.JobExecutor"'/$argsStr}
     finalRequestBody=${requestBody/'org.ekstep.analytics.job.JobExecutor'/$classVariable}
     echo $finalRequestBody
     curl -k --user "{{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}:{{ include "common.tplvalues.render" ( dict "value" .Values.admin_password "context" $ ) }}" -v -H "Content-Type: application/json" -X POST -d "$finalRequestBody" 'https://{{ include "common.tplvalues.render" ( dict "value" .Values.spark_cluster_name "context" $ ) }}.azurehdinsight.net/livy/batches' -H "X-Requested-By: {{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}"

else
    if [ -z "$start_date" ]; then
        echo "Running $job without partition via run-job."
        job_config=$(config $job)
        cluster_job_config=${job_config//'"'/'\"'}
        classVariable="org.ekstep.analytics.job.JobExecutor"
        argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$cluster_job_config\"]"
    else   
        job_config=$(config $job '__endDate__')
        cluster_job_config=${job_config//'"'/'\"'}
        echo "Running $job without partition via Replay-Supervisor." 
        classVariable="org.ekstep.analytics.job.ReplaySupervisor"
        argsList="\"args\": [\"--model\", \"$job_id\", \"--config\", \"$cluster_job_config\", \"--fromDate\", \"$start_date\", \"--toDate\", \"$end_date\"]"
    fi  
    argsStr="\"className\": \"org.ekstep.analytics.job.JobExecutor\", $argsList"
    echo $argsStr
    clusterConfig=`cat cluster-config.json`
    requestBody=${clusterConfig/'"className": "org.ekstep.analytics.job.JobExecutor"'/$argsStr}
    finalRequestBody=${requestBody/'org.ekstep.analytics.job.JobExecutor'/$classVariable}
    echo $finalRequestBody
    curl -k --user "{{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}:{{ include "common.tplvalues.render" ( dict "value" .Values.admin_password "context" $ ) }}" -v -H "Content-Type: application/json" -X POST -d "$finalRequestBody" 'https://{{ include "common.tplvalues.render" ( dict "value" .Values.spark_cluster_name "context" $ ) }}.azurehdinsight.net/livy/batches' -H "X-Requested-By: {{ include "common.tplvalues.render" ( dict "value" .Values.admin_name "context" $ ) }}"    
fi
