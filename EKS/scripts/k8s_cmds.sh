#!/bin/bash

aws eks --region us-east-1 update-kubeconfig --name 312-eks
export KUBECONFIG=~/.kube/config
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

for i in $(kubectl get nodes -o name); 
    do kubectl label node ${i##*/} node-role.kubernetes.io/worker=worker; 
done
