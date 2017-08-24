#!/bin/bash

/root/tenzing-analysis/roi-csv-win.py Memory > ~sherpa/roi-mem-nh.csv
/root/tenzing-analysis/roi-csv-win.py CPU > ~sherpa/roi-cpu-nh.csv
/root/tenzing-analysis/roi-csv-win.py Latency > ~sherpa/roi-latency-nh.csv
/root/tenzing-analysis/reports-selected-to-csv-win.py > ~sherpa/reports.tsv
