Node Labels Notes
  Tested Hadoop Node Labeling on Hadoop 2.7.1
    - Applications run on correct nodes when we configure default node label expression for queues
    - Node exclusive/non exclusive labels are available in Hadoop 2.8
      https://issues.apache.org/jira/browse/YARN-3214
    - Hortonwork's documentations refer to set queue and node labels as follows:
       -queue queue_name ResourceRequest.setNodeLabelExpression node_label
      Queue parameter works fine but node label assignment does not work
      Tried setting node labels in code as well, it did not work too
      It may be the case that Hortonwork's examples work with Hadoop 2.8