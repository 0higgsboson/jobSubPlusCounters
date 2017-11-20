#!/bin/bash

cat > ./workloads-demo.sh <<EOF
#!/bin/bash

workloads=("terasort")
input_sizes=("10GB")
cost_objectives=("CPU")
DATE=`date '+%Y-%m-%d-%H-%M-%S'`
tag_base="demo_\${DATE}"

nontuned_iterations=5
tuned_iterations=50
EOF

./run.sh ./workloads-demo.sh
rm -f ./workloads-demo.sh
