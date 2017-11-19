#!/bin/bash

cat > ./workloads-demo.sh <<EOF
#!/bin/bash

workloads=("terasort")
input_sizes=("10MB")
cost_objectives=("Memory")
DATE=`date '+%Y-%m-%d-%H-%M-%S'`
tag_base="demo_\${DATE}"

nontuned_iterations=10
tuned_iterations=0
EOF

./run.sh ./workloads-demo.sh
rm -f ./workloads-demo.sh
