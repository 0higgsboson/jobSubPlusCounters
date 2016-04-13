#!/bin/bash
kill `jps | grep AgentService | awk '{print $1}'`