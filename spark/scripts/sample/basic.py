# Create New Session
from pyspark.sql import SparkSession
spark = SparkSession.Builder()\
    .appName("Sample - Basic")\
    .getOrCreate()

# Generate Dummy Data
data = [
    ('Leonardi', 'Fabianto', '1998-02-23', 'M', 2000),
    ('Agustinus', 'Vincentius', '2004-06-10', 'M', 500),
    ('Jesslyn', 'Jesslyn', '2000-11-13', 'F', 2000),
]
columns = ["firstname", "lastname", "birthdate", "gender", "salary"]
df = spark.createDataFrame(data, columns)

# Print Dummy Data
df.show()

# Stop Instance
spark.stop()