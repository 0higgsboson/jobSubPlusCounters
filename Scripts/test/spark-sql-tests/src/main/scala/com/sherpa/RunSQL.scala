package com.sherpa.RunSQL

import org.apache.spark.sql.SparkSession 
import scala.io.Source

object RunSQL {
   def main(args: Array[String]) {

    	if (args.length < 1) {
      	   println("Usage:")
      	   println("spark-submit " +
           				"com.sherpa.RunSQL " +
        				"RunSQL.jar " +
        				"[input-file]")
      	System.exit(0)
    }
    val inputFile = args(0)
    val spark = SparkSession.builder()
    	      	.appName("RunSQL").getOrCreate()
    import spark.implicits._

    for (line <- Source.fromFile(inputFile).getLines) {
    	val line2 = line.replace(';',' ')
    	println(line2)
	val result = spark.sql(line2)
     }
   }
}