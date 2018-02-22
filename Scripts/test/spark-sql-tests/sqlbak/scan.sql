DROP TABLE IF EXISTS uservisits_scan_copy;
CREATE TABLE uservisits_scan_copy (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT );
INSERT OVERWRITE TABLE uservisits_scan_copy SELECT * FROM uservisits;
