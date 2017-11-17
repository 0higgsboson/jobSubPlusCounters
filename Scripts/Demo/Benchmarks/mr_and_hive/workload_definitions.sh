#!/bin/bash

workloads=("join" "aggregation" "scan" "terasort" "wordcount")
input_sizes=(1MB 10MB)
cost_objectives=("Memory" "Latency" "CPU")

tag_base="Test123"

# set these to a value >= 1
nontuned_iterations=1
tuned_iterations=50

