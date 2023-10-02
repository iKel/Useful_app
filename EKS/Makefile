init: 
	terraform init
deploy: init
	terraform apply --auto-approve
destroy:
	terraform destroy --auto-approve
test: 
	kubectl create -f x_ingress.yaml
	sleep 5
	kubectl exec -it nginx -- bash -c "echo '<h1><center>Wowzers! Apparently it works\!</center></h1>' > /usr/share/nginx/html/index.html" 
	kubectl exec -it nginx -- bash -c "echo '<center><iframe src="https://giphy.com/embed/MQ4bWOjn8C9tT2dzIb" width="480" height="400" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/theoffice-MQ4bWOjn8C9tT2dzIb">via GIPHY</a></p></center>' >> /usr/share/nginx/html/index.html"