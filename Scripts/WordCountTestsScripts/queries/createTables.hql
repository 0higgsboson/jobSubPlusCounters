--Assumes data is present on local file system at  /root/TestsData/

drop table if exists docs_large;
CREATE TABLE docs_large (line STRING); 
LOAD DATA LOCAL INPATH '/root/TestsData/large' OVERWRITE INTO TABLE docs_large;

drop table if exists docs_normal;
CREATE TABLE docs_normal (line STRING);
LOAD DATA LOCAL INPATH '/root/TestsData/normal/' OVERWRITE INTO TABLE docs_normal;

drop table if exists docs_small;
CREATE TABLE docs_small (line STRING);
LOAD DATA LOCAL INPATH '/root/TestsData/small/' OVERWRITE INTO TABLE docs_small; 

