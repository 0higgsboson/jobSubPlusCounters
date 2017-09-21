#!/bin/bash

/root/tenzing-analysis/roi-csv-win.py Memory > ~ismail/roi-mem-nh.csv
/root/tenzing-analysis/roi-csv-win.py CPU > ~ismail/roi-cpu-nh.csv
/root/tenzing-analysis/roi-csv-win.py Latency > ~ismail/roi-latency-nh.csv
/root/tenzing-analysis/reports-selected-to-csv-win.py > ~ismail/reports.tsv
