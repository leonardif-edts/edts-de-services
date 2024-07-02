### Defaults ###
mode = local
scale = 1
logFile = stdout
tag = edts/spark:3.5.1-hadoop-3.4.0

# Placeholder
help:
	@echo "Please specify any command"

### Commands ###
# Spark
spark-build:
	docker build -t $(tag) spark/base

spark-up:
	docker compose -f spark/infra/spark-$(mode)/docker-compose.yml up -d $(if $(filter hadoop, $(mode)),--scale spark-worker=$(scale),)

spark-down:
	docker compose -f spark/infra/spark-$(mode)/docker-compose.yml down -v --remove-orphans

spark-submit:
  ifdef script
		docker compose -f spark/infra/spark-$(mode)/docker-compose.yml exec spark-$(if $(filter local, $(mode)),local,master) spark-submit $(script)
  else
		@echo "Spark Submit need 'script' argument"
  endif

spark-logs:
  ifdef applicationId
		docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-history yarn logs -applicationId $(applicationId) -log_files $(logFile)
  else
		@echo "Spark Logs need 'applicationId' argument"
  endif

spark-cred-create:
  ifdef name
		docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master hadoop credential create $(name)
  else
		@echo "Spark Create Secret need 'name' argument"
  endif

spark-cred-delete:
  ifdef name
		docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master hadoop credential delete $(name)
  else
		@echo "Spark Create Secret need 'name' argument"
  endif

spark-cred-list:
	docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master hadoop credential list

spark-cred-connect-local:
	docker network connect spark-hadoop_internal spark-local-spark-local-1

# Resource
resource-up:
  ifdef resources
		@for resource in $(shell echo $(resources) | sed 's/,/ /g'); do docker compose -f resource/docker-compose.yml up -d $$resource; done
  else
		docker compose -f resource/docker-compose.yml up -d
  endif

resource-down:
  ifdef resources
		@for resource in $(shell echo $(resources) | sed 's/,/ /g'); do docker compose -f resource/docker-compose.yml down --remove-orphans $(if $(filter true, $(clean)),-v,) $$resource; done
  else
		docker compose -f resource/docker-compose.yml down --remove-orphans $(if $(filter true, $(clean)),-v,)
  endif

resource-connect:
  ifdef service
    ifdef resources
			@for resource in $(shell echo $(resources) | sed 's/,/ /g'); do docker network connect $(service)_internal resource-$$resource-1 || true; done
    else
			@for resource in $(shell docker compose -f resource/docker-compose.yml ps | tail -n+2 | cut -d' ' -f1 | tr '\n' ' '); do docker network connect $(service)_internal $$resource || true; done
    endif
  else
		@echo "Resource Connect need 'service' argument"
  endif
