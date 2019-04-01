#
# To build the image & push to ECR
# 

dockerfile="Dockerfile"
imageName="Petclinic-Dev"
imageTag="${BUILD_NUMBER}"

#
# aws account details
#
awsRegion="us-east-1"
awsAccount="048187499877"
imageRepository="${awsAccount}.dkr.ecr.${awsRegion}.amazonaws.com"
imageURL="${imageRepository}/${imageName}:${imageTag}"
localImage="${USER}/${imageName}:${imageTag}"

#
# deployment steps
#
echo "remove any local images ..."
docker rmi -f ${imageURL} ${USER}/${imageName}:${imageTag}

echo 'build docker image...' \
 && docker build -t ${USER}/${imageName}:${imageTag} -f ${dockerfile} . \
 && echo 'tag docker image...' \
 && docker tag ${localImage} ${imageURL}
 
echo 'configure aws...' \
 && aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} \
 && aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} \
 && aws configure set region ${awsRegion}

echo 'login to ecr...' \
 && `aws ecr get-login --no-include-email --region ${awsRegion}`
 
echo 'push docker image...' \
 && docker push ${imageURL}