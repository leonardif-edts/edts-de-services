build:
	docker build -t avidito/spark:3.5.1-hadoop-3.4.0 base

local-up:
	docker compose -f infra/spark-local/docker-compose.yml up -d

local-down:
	docker compose -f infra/spark-local/docker-compose.yml down -v --remove-orphans

local-submit: 
	docker compose -f infra/spark-local/docker-compose.yml exec spark-local spark-submit $(script)

hadoop-up:
ifdef scale
	docker compose -f infra/spark-hadoop/docker-compose.yml up -d --scale spark-worker=$(scale)
else
	docker compose -f infra/spark-hadoop/docker-compose.yml up -d
endif

hadoop-down:
	docker compose -f infra/spark-hadoop/docker-compose.yml down -v --remove-orphans

hadoop-submit:
	docker compose -f infra/spark-hadoop/docker-compose.yml exec spark-local spark-submit $(script)
