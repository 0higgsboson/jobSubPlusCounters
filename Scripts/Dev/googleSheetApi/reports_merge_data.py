import csv

tags = {"aggregation_CPU_1GB":[],"aggregation_Latency_1GB":[],"aggregation_Memory_1GB":[],"aggregation_CPU_10GB":[],"aggregation_Latency_10GB":[],"aggregation_Memory_10GB":[],"join_CPU_1GB":[],"join_Latency_1GB":[],"join_Memory_1GB":[],"join_CPU_10GB":[],"join_Latency_10GB":[],"join_Memory_10GB":[],"scan_CPU_1GB":[],"scan_Latency_1GB":[],"scan_Memory_1GB":[],"scan_CPU_10GB":[],"scan_Latency_10GB":[],"scan_Memory_10GB":[]}

def merge_data():
  #print("Calling...")
  final_file = open("merge_results.csv","w")
  with open("merge_before_results.csv", "r") as ins:
    for line in ins:
        if line.find("Tag") != -1:
            #print line.rstrip('\n').replace("\"","")
            final_file.write(line.rstrip('\n').replace("\"",""))
            final_file.write('\n')
            cols_len = len(line.rstrip('\n').split(','))
	elif line.find("aggregation_CPU_1GB") != -1:
            tags["aggregation_CPU_1GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("aggregation_Latency_1GB") != -1:
            tags["aggregation_Latency_1GB"].append(line.rstrip('\n').replace("\"",""))
	elif line.find("aggregation_Memory_1GB") != -1:
            tags["aggregation_Memory_1GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("aggregation_CPU_10GB") != -1:
            tags["aggregation_CPU_10GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("aggregation_Latency_10GB") != -1:
            tags["aggregation_Latency_10GB"].append(line.rstrip('\n').replace("\"",""))
	elif line.find("aggregation_Memory_10GB") != -1:
            tags["aggregation_Memory_10GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("join_CPU_1GB") != -1:
            tags["join_CPU_1GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("join_Latency_1GB") != -1:
            tags["join_Latency_1GB"].append(line.rstrip('\n').replace("\"",""))
	elif line.find("join_Memory_1GB") != -1:
            tags["join_Memory_1GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("join_CPU_10GB") != -1:
            tags["join_CPU_10GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("join_Latency_10GB") != -1:
            tags["join_Latency_10GB"].append(line.rstrip('\n').replace("\"",""))
	elif line.find("join_Memory_10GB") != -1:
            tags["join_Memory_10GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("scan_CPU_1GB") != -1:
            tags["scan_CPU_1GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("scan_Latency_1GB") != -1:
            tags["scan_Latency_1GB"].append(line.rstrip('\n').replace("\"",""))
	elif line.find("scan_Memory_1GB") != -1:
            tags["scan_Memory_1GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("scan_CPU_10GB") != -1:
            tags["scan_CPU_10GB"].append(line.rstrip('\n').replace("\"",""))
        elif line.find("scan_Latency_10GB") != -1:
            tags["scan_Latency_10GB"].append(line.rstrip('\n').replace("\"",""))
	elif line.find("scan_Memory_10GB") != -1:
            tags["scan_Memory_10GB"].append(line.rstrip('\n').replace("\"",""))
            
  start_index = 1
  end_index = 1
  rangeRow = 2
  for key, values in tags.iteritems():
   #print key
   for row in values:
      #print row
      final_file.write(row)
      final_file.write('\n')
      end_index += 1
   
   cols = cols_len - 1
   #print cols
   col = "C"
   row = end_index + 1
   rowstr = "Average, "
   for i in range(0,cols):
      rowstr += ",=AVERAGE("+col+str(start_index)+":"+col+str(end_index)+")"
      if col == 'S':
          break
      else:
          col = chr(ord(col)+1)
   #print rowstr
   final_file.write(rowstr)
   final_file.write('\n')

   rowstr = "Std Dev / Avg, "
   col = "C"
   for i in range(0,cols):
       rowstr += ",=STDEVP("+col+str(start_index)+":"+col+str(end_index)+")/"+col+str(row)
       if col == 'S':
           break
       else:
           col = chr(ord(col)+1)
   #print rowstr
   final_file.write(rowstr)
   final_file.write('\n')

   rowstr = "Std Dev / Range, "
   col = "C"
   for i in range(0,cols):
       rowstr += ",="+col+str(row)+"*" + col + str(row+1) + "/" + col + str(rangeRow)
       if col == 'S':
           break
       else:
           col = chr(ord(col)+1)
   #print rowstr
   final_file.write(rowstr)
   final_file.write('\n')
   end_index += 3
   start_index = end_index




