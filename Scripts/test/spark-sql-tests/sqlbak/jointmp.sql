DROP TABLE IF EXISTS ruj1;
CREATE EXTERNAL TABLE ruj1 ( sourceIP STRING, avgPageRank DOUBLE, totalRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '/user/root/SQLTest/Output/ruj1';
INSERT OVERWRITE TABLE ruj1 SELECT sourceIP, avg(pageRank), sum(adRevenue) as totalRevenue FROM rankings R JOIN (SELECT sourceIP, destURL, adRevenue FROM uservisits UV WHERE (datediff(UV.visitDate, '1999-01-01')>=0 AND datediff(UV.visitDate, '2000-01-01')<=0)) NUV ON (R.pageURL = NUV.destURL) group by sourceIP order by totalRevenue DESC;
