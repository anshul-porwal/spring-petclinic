#
# To build the image & push to ECR
# 

dockerfile="Dockerfile"
imageName="petclinic-dev"
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
