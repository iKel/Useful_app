deploy:
	cd prometheus && $(MAKE) deploy
	cd grafana && $(MAKE) deploy
destroy:
	cd prometheus && $(MAKE) clean
	cd prometheus && $(MAKE) destroy
	cd grafana && $(MAKE) destroy
