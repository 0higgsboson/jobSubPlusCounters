#!/bin/bash
kill `jps | grep TzCtCommon | awk '{print $1}'`