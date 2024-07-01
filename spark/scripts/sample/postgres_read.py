from pyspark.sql import SparkSession

spark = SparkSession.Builder()\
    .appName("Sample - Postgres Read")\
    .getOrCreate()

df = spark.read\
    .format("jdbc")\
    .option("url", "jdbc:postgresql://database-postgres-1:5432/postgres")\
    .option("driver", "org.postgresql.Driver")\
    .option("user", "postgres")\
    .option("password", "kLbORCO9irO8BGH")\
    .option("dbtable", "products")\
    .load()

df.printSchema()
df.show()

spark.stop()