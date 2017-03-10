import csv
import json

tags = {"aggregation_CPU_1GB":[],"aggregation_Latency_1GB":[],"aggregation_Memory_1GB":[],"aggregation_CPU_10GB":[],"aggregation_Latency_10GB":[],"aggregation_Memory_10GB":[],"join_CPU_1GB":[],"join_Latency_1GB":[],"join_Memory_1GB":[],"join_CPU_10GB":[],"join_Latency_10GB":[],"join_Memory_10GB":[],"scan_CPU_1GB":[],"scan_Latency_1GB":[],"scan_Memory_1GB":[],"scan_CPU_10GB":[],"scan_Latency_10GB":[],"scan_Memory_10GB":[]}

def merge_data():
  #print("Calling...")
  final_file = open("merge_results.csv","w")
  with open("merge_before_results.csv", "r") as ins:
    for line in ins:
        line = line.rstrip('\n').replace("\"","")
        if line.find("Tag") != -1:
            #print line
            final_file.write(line)
            final_file.write('\n')
            cols_len = len(line.rstrip('\n').split(','))
	elif line.find("aggregation_CPU_1GB") != -1:
            tags["aggregation_CPU_1GB"].append(line)
        elif line.find("aggregation_Latency_1GB") != -1:
            tags["aggregation_Latency_1GB"].append(line)
	elif line.find("aggregation_Memory_1GB") != -1:
            tags["aggregation_Memory_1GB"].append(line)
        elif line.find("aggregation_CPU_10GB") != -1:
            tags["aggregation_CPU_10GB"].append(line)
        elif line.find("aggregation_Latency_10GB") != -1:
            tags["aggregation_Latency_10GB"].append(line)
	elif line.find("aggregation_Memory_10GB") != -1:
            tags["aggregation_Memory_10GB"].append(line)
        elif line.find("join_CPU_1GB") != -1:
            tags["join_CPU_1GB"].append(line)
        elif line.find("join_Latency_1GB") != -1:
            tags["join_Latency_1GB"].append(line)
	elif line.find("join_Memory_1GB") != -1:
            tags["join_Memory_1GB"].append(line)
        elif line.find("join_CPU_10GB") != -1:
            tags["join_CPU_10GB"].append(line)
        elif line.find("join_Latency_10GB") != -1:
            tags["join_Latency_10GB"].append(line)
	elif line.find("join_Memory_10GB") != -1:
            tags["join_Memory_10GB"].append(line)
        elif line.find("scan_CPU_1GB") != -1:
            tags["scan_CPU_1GB"].append(line)
        elif line.find("scan_Latency_1GB") != -1:
            tags["scan_Latency_1GB"].append(line)
	elif line.find("scan_Memory_1GB") != -1:
            tags["scan_Memory_1GB"].append(line)
        elif line.find("scan_CPU_10GB") != -1:
            tags["scan_CPU_10GB"].append(line)
        elif line.find("scan_Latency_10GB") != -1:
            tags["scan_Latency_10GB"].append(line)
	elif line.find("scan_Memory_10GB") != -1:
            tags["scan_Memory_10GB"].append(line)
            
  with open('/opt/sherpa/Tenzing/tunedparams.json') as data_file:    
    data = json.load(data_file)

  def getRange(tunedParam):
    if data[tunedParam]['type'] == "DOUBLE" :
       return float(data[tunedParam]['maxVal']) - float(data[tunedParam]['minVal'])
    elif data[tunedParam]['type'] == "INT" :
       return int(data[tunedParam]['maxVal']) - int(data[tunedParam]['minVal'])

  rowRange = "Range,,"+str(getRange('tez.runtime.io.sort.mb'))+","+str(getRange('hive.auto.convert.join.noconditionaltask.size'))+","+str(getRange('tez.shuffle-vertex-manager.max-src-fraction'))+","+str(getRange('tez.grouping.max-size'))+","+str(getRange('hive.tez.container.size'))+","+str(getRange('tez.container.max.java.heap.fraction'))+","+str(getRange('tez.runtime.sort.spill.percent'))+","+str(getRange('tez.runtime.io.sort.factor'))+","+str(getRange('tez.runtime.unordered.output. buffer.size-mb'))

  final_file.write(rowRange)
  final_file.write('\n')

  start_index = 3
  end_index = 2
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
       if col == 'K':
           break
       else:
           col = chr(ord(col)+1)
   #print rowstr
   final_file.write(rowstr)
   final_file.write('\n')
   end_index += 3
   start_index = end_index + 1




