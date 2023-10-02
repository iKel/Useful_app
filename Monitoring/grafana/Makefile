cluster = $(shell aws eks list-clusters --query "clusters[0]" --output text)
version = 1.0
namespace = monitoring

service = grafana
include clusters/$(cluster)/config

# monitoring should run in one namespace
kubectl := kubectl -n $(namespace)
aws := aws --region $(region)


replacements="\
s/NAMESPACE/$(namespace)/g;\
s/SERVICE_NAME/$(service)/g;\
s/HOSTNAME/$(hostname)/g\
"

deploy: 
	@cat namespace.yaml | sed $(replacements) | kubectl apply -f -	
	@cat configmap.yaml | sed $(replacements) | kubectl apply -f -
	@cat deployment.yaml | sed $(replacements) | kubectl apply -f -
	@cat service.yaml | sed $(replacements) | kubectl apply -f -

stop:
	@cat deployment.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat service.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found

destroy: stop
	@cat configmap.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat namespace.yaml | sed $(replacements) | kubectl delete -f -	--ignore-not-found
