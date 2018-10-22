NAME = "`jq -r .name values.yaml`"
build:
	docker build -t $(NAME) .
push:
	docker tag $(NAME) gerald1248/$(NAME):latest
	docker push gerald1248/$(NAME):latest
install:
	helm install --name=$(NAME) .
delete:
	helm delete --purge $(NAME)
test:
	./Dockerfile_test
