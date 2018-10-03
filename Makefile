build:
	docker build -t k8s-backup .
push:
	docker tag k8s-backup gerald1248/k8s-backup:latest
	docker push gerald1248/k8s-backup:latest
install:
	helm install --name=k8s-backup .
delete:
	helm delete --purge k8s-backup
test:
	./Dockerfile_test
