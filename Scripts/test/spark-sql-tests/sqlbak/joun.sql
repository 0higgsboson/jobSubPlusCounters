DROP TABLE IF EXISTS RUJ;
CREATE EXTERNAL TABLE RUJ ( sourceIP STRING, avgPageRank DOUBLE, totalRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '/user/root/SQLTest/Output/RUJ';
INSERT OVERWRITE TABLE RUJ SELECT sourceIP, avg(pageRank), sum(adRevenue) as totalRevenue FROM rankings R JOIN (SELECT sourceIP, destURL, adRevenue FROM uservisits UV WHERE (datediff(UV.visitDate, '1999-01-01')>=0 AND datediff(UV.visitDate, '2000-01-01')<=0)) NUV ON (R.pageURL = NUV.destURL) group by sourceIP order by totalRevenue DESC;
hadoop fs rm -r /user/root/SQLTest/Output/RUJ;
DROP TABLE IF EXISTS RUJ;

