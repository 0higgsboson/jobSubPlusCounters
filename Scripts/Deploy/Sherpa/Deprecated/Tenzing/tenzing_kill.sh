#!/bin/bash
kill `jps | grep TenzingService | awk '{print $1}'`