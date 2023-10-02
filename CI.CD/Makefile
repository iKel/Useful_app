namespace = jenkins
repo = jenkins-master
region = us-east-1
account = $(shell aws sts get-caller-identity --query "Account" --output text)
namespace = jenkins
service = jenkins
#image = jenkins/jenkins:latest

stage = dev
include stages/$(stage)

kubectl := kubectl -n $(namespace)

default: help

help:
	make -qp | awk -F':' '/^[a-z0-9][^$$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

#------------------> Image and repo <---------------------#

repo-create:
	aws ecr create-repository \
	--repository-name $(repo) \
	--region $(region)

build: login repo-create
	docker build -t $(repo):$(version) . --no-cache
#build: login
	docker build --platform linux/amd64 -t $(repo):$(version) . --no-cache

login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 340924313311.dkr.ecr.us-east-1.amazonaws.com
#login:
	aws ecr get-login-password --region $(region) | \
		docker login --username AWS --password-stdin $(account).dkr.ecr.$(region).amazonaws.com

push: login
	docker tag $(repo):$(version) $(account).dkr.ecr.$(region).amazonaws.com/$(repo):$(version)
	docker push $(account).dkr.ecr.$(region).amazonaws.com/$(repo):$(version)

delete-image: login
	aws ecr batch-delete-image \
    --repository-name $(repo) \
    --image-ids imageTag=$(version)

#--------------> Jenkins and K8s resources <--------------#

namespace:
	@cat k8s/namespace.yaml | sed "s|NAMESPACE|$(namespace)|g" | kubectl apply -f -

deploy: namespace #csi-driver
	@cat k8s/jenkins.yaml | sed "s|IMAGEVERSION|$(version)|g;s|NAMESPACE|$(namespace)|g;s|HOSTNAME|$(hostname)|g" | kubectl apply -f -

stop:
	@cat k8s/jenkins.yaml | sed "s|IMAGEVERSION|$(version)|g;s|NAMESPACE|$(namespace)|g;s|HOSTNAME|$(hostname)|g" | kubectl delete -f -

delete-pvc: stop
	$(kubectl) delete pvc jenkins-home-jenkins-0

portal:
	$(kubectl) port-forward jenkins-0 8080:8080

csi-driver:
	helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system \
  --set syncSecret.enabled=true \
  --set enableSecretRotation=true

#-------------------> Additional targets <----------------#

#---> Clean-Up 
image-repo-delete:
	@aws ecr delete-repository \
    --repository-name $(repo) \
	--region $(region) \
    --force

delete-deploy-jenkins:
	@cat jenkins.yaml | sed "s/IMAGEVERSION/$(version)/g;s/ACCOUNT/$(account)/g" | kubectl -n $(namespace) delete -f -

namespace-delete: delete-deploy-jenkins
	@cat namespace.yaml | sed "s/NAMESPACE/$(namespace)/g" | kubectl delete -f -

delete-aws-secret:
	@bin/aws-secretsmanager-delete-secrets-without-recovery $(service) ./aws/secrets

delete-k8s-secret:
	@@bin/k8s-secrets-delete-secrets $(service) $(namespace) ./aws/secrets


#---> Creating private and public keys (optional)
create-key-pair:
	@aws ec2 create-key-pair --key-name $(service)-key-pair \
	--region us-east-1 \
	--query 'KeyMaterial' --output text > ./aws/key-pair/$(service)-key-pair.txt
delete-key-pair:
	@aws ec2 delete-key-pair --key-name $(service)-key-pair --region us-east-1


#---> Inject secrets from AWS to the cluster (in case CSI driver isn't working)
create-secret:
	@bin/aws-secretsmanager-create-secrets $(service) ./aws/secrets

update-secret:
	@bin/aws-secretsmanager-update-secrets $(service) ./aws/secrets

inject-secret: create-secret
	@bin/k8s-secrets-inject-secrets $(service) $(namespace) ./aws/secrets

