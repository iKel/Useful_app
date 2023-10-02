#------------------------> EKS <---------------------------#
EKS-deploy:
	cd EKS && $(MAKE) deploy
EKS-destroy:
	cd EKS && $(MAKE) destroy

#------------------------> EFK <---------------------------#
EFK-deploy:
	cd EFK && kubectl create -f .
EFK-destroy:
	cd EFK && kubectl delete -f .
#--------------------> Monitoring <------------------------#
Monitoring-deploy:
	cd Monitoring && $(MAKE) deploy
Monitoring-destroy:
	cd Monitoring && $(MAKE) destroy
#----------------------> Jenkins <-------------------------#
Jenkins-deploy:
	cd CI.CD && $(MAKE) deploy
Jenkins-image:
	cd CI.CD && $(MAKE) build
Jenkins-destroy:
	cd CI.CD && $(MAKE) delete-image
	cd CI.CD && $(MAKE) delete-pvc
	cd CI.CD && $(MAKE) mage-repo-delete
	cd CI.CD && $(MAKE) namespace-delete
	cd CI.CD && $(MAKE) delete-aws-secret
	cd CI.CD && $(MAKE) delete-k8s-secret
#----------------------> Web-app <-------------------------#
Web-app-deploy:
	cd web-app && $(MAKE) build
	cd web-app && $(MAKE) push
	cd web-app && $(MAKE) deploy
Web-app-destroy:
	cd web-app && $(MAKE) destroy