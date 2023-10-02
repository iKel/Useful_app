app_name = useful
aws_acc = $(shell aws sts get-caller-identity --query "Account" --output text)
v = 1.0.1
replicas=1
namespace = default 

stage = dev
include configs/$(stage)

auth:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/p8r1z1r3
build: auth
	docker build -t $(app_name):$(v) .
push:
	docker tag $(app_name):$(v) public.ecr.aws/p8r1z1r3/$(app_name):$(v)						
	docker push public.ecr.aws/p8r1z1r3/$(app_name):$(v)
deploy:
	helm upgrade --install $(app_name) helm_chart/ --namespace $(namespace) --create-namespace \
		--set app_name=$(app_name) \
		--set replicas=$(replicas) \
		--set image=public.ecr.aws/p8r1z1r3/$(app_name) \
		--set version=$(v) \
		--set port=80 \
		--set hostname=$(hostname)
destroy:
	helm delete useful -n dev
	kubectl delete ns $(namespace)
