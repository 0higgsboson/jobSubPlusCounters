add2configs.py

This script inserts manual configs into the ClientAgent's queue of
pending configs.

It reads one or more configs defined in "manualconfigs.json" file in
the local directory, and adds those configs to
/opt/sherpa/ClientAgent/configs.json.

In order to use it, create the manualconfigs.json file.  A good starting point
is to copy our standard tunedconfigs.json file. Edit the "value"
field to the value you wnt to set for each config.  You can also add
new configs, and set the value.  The script ignores the "type",
"minVal", "maxVal", and "stepSize" fields.

For any config that you want to keep at the system-level default
value, delete the entire line for that config.

The steps to follow:

1. Start with a clean /opt/sherpa/ClientAgent/configs.json file.
2. Run the workload you wish to run in a sherpa-tuned setting once (use a single iteration by editing runWorkload.sh and setting iterations=1), so that an entry with the workloadID is generated in the /opt/sherpa/ClientAgent/configs.json file.  The add2configs.py script uses that entry as its template.
3. Edit the manualconfigs.json file with the values you wish to set.
4. run add2configs.py.  This will generate a local copy of configs.json with the added config(s).
5. copy the local configs.json file back to /opt/sherpa/configs.json
6. Run the same workload, sherpa tuned, using runWorkload.sh

 
