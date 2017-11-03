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



