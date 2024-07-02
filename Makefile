### Defaults ###
mode = local
scale = 1
logFile = stdout
tag = edts/spark:3.5.1-hadoop-3.4.0


### Commands ###
# Service - Database
database-up:
  ifdef db
		docker compose -f database/docker-compose.yml up -d
  else
		docker compose -f database/docker-compose.yml up -d $(db)
  endif

database-down:
  ifeq ($(clean),true)
		@echo "Tear Down Database with `clean=true`"
    ifdef db
			docker compose -f database/docker-compose.yml down $(db) -v --remove-orphans
    else
			docker compose -f database/docker-compose.yml down -v --remove-orphans
    endif
  else
		@echo "Tear Down Database with `clean=false`"
    ifdef db
			docker compose -f database/docker-compose.yml down $(db) --remove-orphans
    else
			docker compose -f database/docker-compose.yml down --remove-orphans
    endif
  endif

# Service - Spark
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

spark-connect:
  ifdef db
		docker network connect spark-$(mode)_internal database-$(db)-1
  endif

spark-disconnect:
  ifdef db
		docker network disconnect spark-$(mode)_internal database-$(db)-1
  endif
