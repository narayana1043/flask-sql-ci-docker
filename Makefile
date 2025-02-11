# import and expose environment variables
cnf ?= .env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

.PHONY: init

help:
	@echo
	@echo "Usage: make TARGET"
	@echo
	@echo "Dockerization of the sloria/cookiecutter-flask template repo"
	@echo
	@echo " init initialize your app code base from the sloria/cookiecutter-flask repo"
	@echo " init-purge clean up generated code"@echo "Targets:"

#Generate project codebase form GitHub using cookiecutter
init:
	envsubst <docker/init/cookiecutter.template.yml >docker/init/cookiecutter.yml
	docker-compose -f docker/init/docker-compose.yml up -d --build
	docker cp flask-sql-ci-initiator:/root/$(APP_NAME) ./$(APP_NAME)
	docker-compose -f docker/init/docker-compose.yml down
	rm docker/init/cookiecutter.yml

#Remove the generated code, use this before re-running the `init` target
init-purge:
	sudo rm -rf ./$(APP_NAME)

#Build the development image
dev-build:
	docker-compose -f docker/dev/docker-compose.yml build

#Start up development environment
dev-up:
	docker-compose -f docker/dev/docker-compose.yml up -d

#Bring down development environment
dev-down:
	docker-compose -f docker/dev/docker-compose.yml down

#List development conatiners
dev-ps:
	docker-compose -f docker/dev/docker-compose.yml ps

#Show development logs
dev-logs:
	docker-compose -f docker/dev/docker-compose.yml logs -f

#Run tests
test-run:
	docker-compose -f docker/dev/docker-compose.yml up -d
	sleep 10
	docker-compose -f docker/dev/docker-compose.yml exec web flask test
	docker-compose -f docker/dev/docker-compose.yml down
