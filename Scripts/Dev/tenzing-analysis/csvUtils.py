#!/usr/bin/python


def flatten_header(prefix, t) :
     s = ""
     if isinstance(t, dict):
          if prefix != "":
               prefix += "_"
          for key in t.keys():
               s += flatten_header(prefix + key, t[key])
          return s
     elif isinstance(t, list):
          if prefix != "":
               prefix += "_"
          for i in range(0, len(t)):
               s += flatten_header(prefix + str(i), t[i])
          return s
     else:
          return prefix + ", "

def build_header(h, prefix, t) :
     if isinstance(t, dict):
          if prefix != "":
               prefix += "_"
          for key in t.keys():
               build_header(h, prefix + key, t[key])
     elif isinstance(t, list):
          if prefix != "":
               prefix += "_"
          for i in range(0, len(t)):
               build_header(h, prefix + str(i), t[i])
     else:
          add_header(h, prefix)

def add_row(row, pos, prefix, t) :
     if isinstance(t, dict):
          if prefix != "":
               prefix += "_"
          for key in t.keys():
               add_row(row, pos, prefix + key, t[key])
     elif isinstance(t, list):
          if prefix != "":
               prefix += "_"
          for i in range(0, len(t)):
               add_row(row, pos, prefix + str(i), t[i])
     else:
          row[pos[prefix]] = t


def add_header(h, key) :
     if key in h:
          return
#     print "Appending ", key
     h.append(key)


def flatten(t) :
     s = ""
     if isinstance(t, dict):
          for key in t.keys():
               s += flatten(t[key])
          return s
     elif isinstance(t, list):
          for i in range(0, len(t)):
               s += flatten(t[i])
          return s
     else:
          return str(t) + ", "

def set_pos(p, h) :
     i = 0
     for key in h:
          p[key] = i
          i += 1

def print_row(row, separator=", ") :
     sep = ""
     s = ""
     for val in row:
          s += sep + str(val)
          sep = separator
     print s


def print_row_to_file(f, row, separator=", ", newline="\n") :
     sep = ""
     s = ""
     for val in row:
          s += sep + str(val)
          sep = separator
     f.write(s + newline)


def generate_sql_file(sf, table, header, newline="\n") :
     sf.write("DROP TABLE IF EXISTS " + table + ";" + newline)
     sf.write("CREATE TABLE " + table + "(" + newline)
     firstCol = True
     for col in header:
          if not firstCol:
               sf.write("," + newline)
          else:
               firstCol = False
          sf.write("    " + col + " TEXT")
     sf.write(newline + ");" + newline)


def add_result_columns_to_header(header):
     sep = '_'
     co_list = ["Memory", "Latency", "CPU"]
     originator_list = ["Client","Sherpa"]
     result_list = ["Success","Failure"]
     for i in co_list:
          for j in originator_list:
               for k in result_list:
                    s = i + sep + j + sep + k
                    header.append(s)


def add_results_to_row(row,pos):
     mem1 = row[pos["counters_MB_MILLIS_MAPS_TOTAL_value"]]
     if mem1 == "":
          mem1 = 0
     mem2 = row[pos["counters_MB_MILLIS_REDUCES_TOTAL_value"]]
     if mem2 == "":
          mem2 = 0
     mem = mem1 + mem2
     if row[pos["state"]] == "SUCCESS":
          if row[pos["originator"]] == "Tenzing":
               row[pos["Memory_Sherpa_Success"]] = mem
          else:
               row[pos["Memory_Client_Success"]] = mem
     elif row[pos["state"]] == "RECOVERED":
          if row[pos["originator"]] == "Tenzing":
               row[pos["Memory_Sherpa_Recovered"]] = mem
          else:
               row[pos["Memory_Client_Recovered"]] = mem
     else:
          if row[pos["originator"]] == "Tenzing":
               row[pos["Memory_Sherpa_Failure"]] = mem
          else:
               row[pos["Memory_Client_Failure"]] = mem

     cpu1 = row[pos["counters_CPU_MILLISECONDS_MAP_value"]]
     if cpu1 == "":
          cpu1 = 0
     cpu2 = row[pos["counters_CPU_MILLISECONDS_REDUCE_value"]]
     if cpu2 == "":
          cpu2 = 0
     cpu = cpu1 + cpu2
     if row[pos["state"]] == "SUCCESS":
          if row[pos["originator"]] == "Tenzing":
               row[pos["CPU_Sherpa_Success"]] = cpu
          else:
               row[pos["CPU_Client_Success"]] = cpu
     elif row[pos["state"]] == "RECOVERED":
          if row[pos["originator"]] == "Tenzing":
               row[pos["CPU_Sherpa_Recovered"]] = cpu
          else:
               row[pos["CPU_Client_Recovered"]] = cpu
     else:
          if row[pos["originator"]] == "Tenzing":
               row[pos["CPU_Sherpa_Failure"]] = cpu
          else:
               row[pos["CPU_Client_Failure"]] = cpu

     latency = row[pos["jobMetaData_executionTime"]]

     if row[pos["state"]] == "SUCCESS":
          if row[pos["originator"]] == "Tenzing":
               row[pos["Latency_Sherpa_Success"]] = latency
          else:
               row[pos["Latency_Client_Success"]] = latency
     elif row[pos["state"]] == "RECOVERED":
          if row[pos["originator"]] == "Tenzing":
               row[pos["Latency_Sherpa_Recovered"]] = latency
          else:
               row[pos["Latency_Client_Recovered"]] = latency
     else:
          if row[pos["originator"]] == "Tenzing":
               row[pos["Latency_Sherpa_Failure"]] = latency
          else:
               row[pos["Latency_Client_Failure"]] = latency
