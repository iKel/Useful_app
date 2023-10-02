cluster = $(shell aws eks list-clusters --query "clusters[0]" --output text)
version = 1.0
namespace = monitoring
include clusters/$(cluster)/config
region = us-east-1

# monitoring should run in one ns
kubectl := kubectl -n $(namespace)

#helps dynamicly change variables in yaml files
replacements="\
s/NAMESPACE/$(namespace)/g;\
s/STORAGESIZE/$(storagesize)/g;\
s/CLUSTER/$(cluster)/g;\
s/RETENTIONPERIOD/$(retentionPeriod)/g\
"

namespace:
	@cat namespace.yaml | sed $(replacements) | kubectl apply -f -

deploy: namespace
	@cat prometheus-server/clusterRole.yaml | sed $(replacements) | kubectl apply -f -
	@cat prometheus-server/pvc.yaml | sed $(replacements) | kubectl apply -f -
	@cat prometheus-server/configmap.yaml | sed $(replacements) | kubectl apply -f -
	@cat prometheus-server/deployment.yaml | sed $(replacements) | kubectl apply -f -
	@cat prometheus-server/service.yaml | sed $(replacements) | kubectl apply -f -
	@###
	@cat kube-state-metrics/clusterRole.yaml | sed $(replacements) | kubectl apply -f -
	@cat kube-state-metrics/deployment.yaml | sed $(replacements) | kubectl apply -f -
	@cat kube-state-metrics/service.yaml | sed $(replacements) | kubectl apply -f -
	@###
	@cat node-exporter/daemonset.yaml | sed $(replacements) | kubectl apply -f -
	@cat node-exporter/service.yaml | sed $(replacements) | kubectl apply -f -

stop:
	@cat prometheus-server/deployment.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat prometheus-server/service.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@###
	@cat kube-state-metrics/deployment.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat kube-state-metrics/service.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@###
	@cat node-exporter/daemonset.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat node-exporter/service.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	

clean: stop
	@cat prometheus-server/clusterRole.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat prometheus-server/configmap.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found
	@cat kube-state-metrics/clusterRole.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found

destroy: clean
	@cat prometheus-server/pvc.yaml | sed $(replacements) | kubectl delete -f - --ignore-not-found

forward:
	@$(kubectl) port-forward $$($(kubectl) get pod \
		-l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}") 9090
