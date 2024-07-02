### Environments ###
# Tags
SPARK_TAG = edts/spark:3.5.1-hadoop-3.4.0

### Commands ###
# Service - Database
database-up:
  ifdef db
		docker compose -f database/docker-compose.yml up -d
  else
		docker compose -f database/docker-compose.yml up -d $(db)
  endif

database-down:
  ifdef clean
    ifdef db
			docker compose -f database/docker-compose.yml down $(db) -v --remove-orphans
    else
			docker compose -f database/docker-compose.yml down -v --remove-orphans
    endif
  else
    ifdef db
			docker compose -f database/docker-compose.yml down $(db) --remove-orphans
    else
			docker compose -f database/docker-compose.yml down --remove-orphans
    endif
  endif

# Service - Spark
spark-build:
	docker build -t $(SPARK_TAG) spark/base

spark-pull:
  docker pull ${SPARK_TAG}

spark-up:
  ifdef mode
    ifeq ($(mode),local)
			docker compose -f spark/infra/spark-local/docker-compose.yml up -d
    endif
  
    ifeq ($(mode),hadoop)
      ifdef scale
				docker compose -f spark/infra/spark-hadoop/docker-compose.yml up -d --scale spark-worker=$(scale)
      else
				@echo "Using default: scale=2"
				docker compose -f spark/infra/spark-hadoop/docker-compose.yml up -d --scale spark-worker=2
      endif
    endif
  else
		@echo "Using default: mode=local"
		docker compose -f spark/infra/spark-local/docker-compose.yml up -d
  endif

spark-down:
  ifdef mode
    ifeq ($(mode),local)
			docker compose -f spark/infra/spark-local/docker-compose.yml down -v --remove-orphans
    endif

    ifeq ($(mode),hadoop)
			docker compose -f spark/infra/spark-hadoop/docker-compose.yml down -v --remove-orphans
    endif
  else
		@echo "Using default: mode=local"
		docker compose -f spark/infra/spark-local/docker-compose.yml down -v --remove-orphans
  endif

spark-submit:
  ifdef script
    ifdef mode
      ifeq ($(mode),local)
				docker compose -f spark/infra/spark-local/docker-compose.yml exec spark-local spark-submit $(script)
      endif

      ifeq ($(mode),hadoop)
				docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master spark-submit $(script)
      endif
    else
			@echo "Using default: mode=local"
			docker compose -f spark/infra/spark-local/docker-compose.yml exec spark-local spark-submit $(script)
    endif
  else
		@echo "Spark Submit need 'script' argument"
  endif

spark-logs:
  ifdef applicationId
		docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-history yarn logs -applicationId $(applicationId)
  else
		@echo "Spark Logs need 'applicationId' argument"
  endif

spark-secret-create:
  ifdef name
		docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master hadoop credential create $(name)
  else
		@echo "Spark Create Secret need 'name' argument"
  endif

spark-secret-delete:
  ifdef name
		docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master hadoop credential delete $(name)
  else
		@echo "Spark Create Secret need 'name' argument"
  endif

spark-secret-list:
	docker compose -f spark/infra/spark-hadoop/docker-compose.yml exec spark-master hadoop credential list

spark-database-connect:
  ifdef db
    ifdef mode
			@for container in $(shell docker network inspect database_internal | grep Name | tail -n+2 | cut -d':' -f2 | tr -d '", ' | grep $(db)); do docker network connect spark-$(mode)_internal $${container} || true; done
    else
			@echo "Using default: mode=local"
			@for container in $(shell docker network inspect database_internal | grep Name | tail -n+2 | cut -d':' -f2 | tr -d '", ' | grep $(db)); do docker network connect spark-local_internal $${container} || true; done
    endif
  else
		@echo "Spark Connect need 'db' argument"
  endif

spark-database-disconnect:
  ifdef db
    ifdef mode
			@for container in $(shell docker network inspect database_internal | grep Name | tail -n+2 | cut -d':' -f2 | tr -d '", ' | grep $(db)); do docker network disconnect spark-$(mode)_internal $${container} || true; done
    else
			@echo "Using default: mode=local"
			@for container in $(shell docker network inspect database_internal | grep Name | tail -n+2 | cut -d':' -f2 | tr -d '", ' | grep $(db)); do docker network disconnect spark-local_internal $${container} || true; done
    endif
  else
		@echo "Spark Disconnect need 'db' argument"
  endif
