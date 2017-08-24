#!/bin/bash

/root/tenzing-analysis/roi-memory-to-csv-win.py > ~sherpa/roi-mem-nh.csv
/root/tenzing-analysis/roi-cpu-to-csv-win.py > ~sherpa/roi-cpu-nh.csv
/root/tenzing-analysis/roi-latency-to-csv-win.py > ~sherpa/roi-latency-nh.csv
/root/tenzing-analysis/reports-selected-to-csv-win.py > ~sherpa/reports.tsv
