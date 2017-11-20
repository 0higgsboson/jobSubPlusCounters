#!/bin/bash

cat > ./workloads-demo.sh <<EOF
#!/bin/bash

workloads=("terasort")
input_sizes=("1GB" "5GB" "10GB")
cost_objectives=("Latency")
DATE=`date '+%Y-%m-%d-%H-%M-%S'`
tag_base="demo_\${DATE}"

nontuned_iterations=5
tuned_iterations=50
EOF

./run-vsw.sh ./workloads-demo.sh
rm -f ./workloads-demo.sh
