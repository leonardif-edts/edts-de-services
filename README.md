# EDTS - DE Services

## Overview

Collection of Data Engineering services for local development or simulation. Designed to enchance development experience for Data Engineering. All of the services are deployed as containerized application.

## Services
List of available services:

|Service|Base Image|Description|Single|Cluster|
|:--|:--|:--|:--:|:--:|
|Spark|spark:3.5.1|[PySpark] ETL Service on Single-Node Machine or Clusters|&check;|&check;|

<b>Notes</b>
- Single: Run as single service container
- Cluster: Run as cluster of service with connected containers

## Resources
List of additional resources:

|Resource|Base Image|Description|
|:--|:--|:--|
|PostgreSQL|postgres:15.3|PostgreSQL database instance|