# Create New Session
from pyspark.sql import SparkSession
spark = SparkSession.Builder()\
    .appName("Sample - Postgres Read")\
    .getOrCreate()

# Get Hadoop Conf
conf = spark.sparkContext._jsc.hadoopConfiguration()
creds_raw = conf.getPassword("resource.postgres.password")
if creds_raw:
    db_password = "".join([str(creds_raw.__getitem__(i)) for i in range(creds_raw.__len__())])
else:
    raise ValueError("'resource.postgres.password' is not exists")

# Read from PostgreSQL
df = spark.read\
    .format("jdbc")\
    .option("url", "jdbc:postgresql://resource-postgres-1:5432/postgres")\
    .option("driver", "org.postgresql.Driver")\
    .option("user", "postgres")\
    .option("password", db_password)\
    .option("dbtable", "products")\
    .load()

# Print Schema and Data
df.printSchema()
df.show()

# Stop Instance
spark.stop()