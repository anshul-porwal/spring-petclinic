	# To build the image & push to ECR
	# 
	
	dockerfile="Dockerfile"
	imageName="petclinic-dev"
	imageTag="${BUILD_NUMBER}"
	clusterName="Test"
	serviceName="Test"
	IMAGE_VERSION="v_"${BUILD_NUMBER}
	taskDefination="Test"
	
	# aws account details

	awsRegion="us-east-1"
	awsAccount="048187499877"
	imageRepository="${awsAccount}.dkr.ecr.${awsRegion}.amazonaws.com"
	imageURL="${imageRepository}/${imageName}:${imageTag}"
	localImage="${USER}/${imageName}:${imageTag}"
	
	#
	# steps to deploy
	#
	echo "remove any local images ..."
	docker rmi -f ${imageURL} ${USER}/${imageName}:${imageTag}
	
	echo 'build docker image...' \
	&& docker build -t ${USER}/${imageName}:${imageTag} -f ${dockerfile} . \
	&& echo 'tag docker image...' \
	&& docker tag ${localImage} ${imageURL}
	
	echo 'configure aws...' \
	&& ~/.local/bin/aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} \
	&& ~/.local/bin/aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} \
	&& ~/.local/bin/aws configure set region ${awsRegion}
	
	echo 'login to ecr...' \
	&& `~/.local/bin/aws ecr get-login --no-include-email --region ${awsRegion}`
	
	echo 'push docker image...' \
	&& docker push ${imageURL}

	# Create a new task definition for this build
	sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" Test.json > test-v_${BUILD_NUMBER}.json
	aws ecs register-task-definition --family Test --cli-input-json file://test-v_${BUILD_NUMBER}.json

	# Update the service with the new task definition and desired count
	TASK_REVISION=`aws ecs describe-task-definition --task-definition Test | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
	DESIRED_COUNT=`aws ecs describe-services --services ${serviceName} | egrep "desiredCount" | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
	if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
	fi
	aws ecs update-service --cluster ${clusterName} --service ${serviceName} --task-definition ${taskDefination}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}


