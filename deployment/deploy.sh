#!/bin/sh -e

#Usage: CONTAINER_VERSION=docker_container_version [create|update]

# register task-definition acc-acc-default
# echo $1
sed <td-nginx.template -e "s,@VERSION@,$1,">TASKDEF.json
aws ecs register-task-definition --cli-input-json file://TASKDEF.json > REGISTERED_TASKDEF.json
TASKDEFINITION_ARN=$( < REGISTERED_TASKDEF.json jq .taskDefinition.taskDefinitionArn )

# echo $TASKDEFINITION_ARN
aws elbv2 describe-target-groups --name $3 > elb_targets.json

# if ! grep -q  $3  elb_targets.json; then
# 	aws elbv2 create-target-group --name $3 --protocol HTTP --port 80 --vpc-id vpc-1b7e4873 > target.json
# 	TG_ARN=$( < loadbalancer.json jq .TargetGroups[0].TargetGroupArn )
# 	aws elbv2 describe-load-balancers --name $4 > loadbalancer.json
# 	LB_ARN=$( < loadbalancer.json jq .LoadBalancers[0].LoadBalancerArn )
# 	aws elbv2 describe-listeners --load-balancer-arn $LB_ARN > listeners.json
# 	LISTENER_ARN=$( < listeners.json jq .LoadBalancers[0].LoadBalancerArn )
# 	aws elbv2 create-rule --listener-arn $LISTENER_ARN --priority 10 --conditions Field=path-pattern,Values='/1/*' --actions Type=forward,TargetGroupArn=$TG_ARN

# fi
# aws elbv2 describe-target-groups > elb_targets.json
TARGETGROUP_ARN=$( < elb_targets.json jq .TargetGroups[0].TargetGroupArn )
echo $TARGETGROUP_ARN
# create or update service
sed "s,@@TASKDEFINITION_ARN@@,$TASKDEFINITION_ARN," <service-$2-nginx.json >SERVICEDEF.json
sed "s,@@TARGET_GROUP_ARN@@,$TARGETGROUP_ARN," <SERVICEDEF.json >SERVICEDEF1.json
aws ecs $2-service --cli-input-json file://SERVICEDEF1.json | tee SERVICE.json




# aws elbv2 create-target-group --name webservers --protocol HTTP --port 80 --vpc-id vpc-57e5d23f

# aws elbv2 create-listener --load-balancer-arn arn:aws:elasticloadbalancing:eu-central-1:987948519449:loadbalancer/app/acc-acc/5e91f16dc6f3f2c6 --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:eu-central-1:987948519449:targetgroup/webservers/99f774c985efd970

# aws elbv2 describe-listeners --load-balancer-arn arn:aws:elasticloadbalancing:eu-central-1:987948519449:loadbalancer/app/acc-acc/5e91f16dc6f3f2c6

# aws elbv2 create-rule --listener-arn arn:aws:elasticloadbalancing:eu-central-1:987948519449:listener/app/acc-acc/5e91f16dc6f3f2c6/0ab4f960a6a77678 --priority 10 --conditions Field=path-pattern,Values='/1/*' --actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:eu-central-1:987948519449:targetgroup/webservers/99f774c985efd970