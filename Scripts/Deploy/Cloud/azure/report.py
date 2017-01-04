#!/usr/bin/python

import subprocess
import time
import smtplib
from email.mime.text import MIMEText
import datetime as dt


def sendEmail(contents):
    msg = MIMEText(contents)
    msg['Subject'] = 'Azure usage report'
    msg['From'] = me = 'ismail@theperformancesherpa.com'
#    msg['To'] = 'ismail@theperformancesherpa.com'
#    you =  ['ismail@theperformancesherpa.com']
    msg['To'] = 'ismail@theperformancesherpa.com, sid@theperformancesherpa.com'
    you = ['ismail@theperformancesherpa.com', 'sid@theperformancesherpa.com']
    s = smtplib.SMTP('localhost')
    s.sendmail(me, you, msg.as_string())
    s.quit()

def setPrices(c):
    c['Standard_A1'] = 0.035
    c['Standard_D1_v2'] = 0.064
    c['Standard_DS1_v2'] = 0.066
    c['Standard_DS2_v2'] = 0.131
    c['Standard_D4_v2'] = 0.559
    c['Standard_D3_v2'] = 0.279
    
def getTable(proc):
    myTable = []
    realdata = False
    for line in iter(proc.stdout.readline,''):
        tokens = line.split()
        if 'data' in tokens[0]:
            if realdata:
                tokens.pop(0)
                myTable.append(tokens)
            if '---' in tokens[1]:
                realdata = True
    return myTable

m = ""

#proc = subprocess.Popen(['azure','group','list'],stdout=subprocess.PIPE)

history = "/root/azure/history.txt"
last = "/root/azure/last.txt"

hf = open(history,'a')

m += " ====================================================\n"

try:
    lf = open(last, 'r')
    oldVMcost = float(lf.readline())
    oldPIPcost = float(lf.readline())
    lf.close()
except:
    oldVMcost = 0
    oldPIPcost = 0
    m += " No prior data point found!\n"

m += " " + time.strftime("%m/%d/%Y %H:%M") + "\n"
m += " -----------------\n"
deallocatedVMs = 0
runningVMs = 0
VMTypes = dict()
DVMTypes = dict()
price = dict()
setPrices(price)
proc = subprocess.Popen(['azure','vm','list'],stdout=subprocess.PIPE)
vms = getTable(proc)
for vm in vms:
    if vm[4] == 'deallocated':
        deallocatedVMs += 1
        if vm[6] in DVMTypes:
            DVMTypes[vm[6]] = DVMTypes[vm[6]] + 1
        else:
            DVMTypes[vm[6]] = 1
    else:
        runningVMs += 1
        if vm[6] in VMTypes:
            VMTypes[vm[6]] = VMTypes[vm[6]] + 1
        else:
            VMTypes[vm[6]] = 1
m += " Running VMs: " + str(runningVMs) + "\n"
cost = 0
for type in VMTypes:
    s = " \t" + type + ":\t " + str(VMTypes[type]) + " = $"
    if type in price:
        thiscost = price[type] * VMTypes[type] 
        s += " " + str(thiscost)
        cost += thiscost
    else:
        s += " Unknown"
    m += s + "\n"
m +=  " Deallocated VMs: " + str(deallocatedVMs) + "\n"
for type in DVMTypes:
    m +=  " \t" + str(type) + ":\t " + str(DVMTypes[type]) + " (no cost)" + "\n"
m += " Total VM cost per hour: $" + str(cost) + " [was " + str(oldVMcost) + " previous time]\n"
m += " Monthly projected VM cost: $" + str(cost*24*30) + "\n"
m += " -----------------\n"
proc = subprocess.Popen(['azure','network','nic','list'],stdout=subprocess.PIPE)
nics = getTable(proc)
m += " " + str(len(nics)) + " NICs" + "\n"
proc = subprocess.Popen(['azure','network','public-ip','list'],stdout=subprocess.PIPE)
pips = getTable(proc)
pipCost = (len(pips) - 5)*0.004
m += " " + str(len(pips)) + " Public IPs = $" + str(pipCost) + " [was " + str(oldPIPcost) + " previous time]\n"
m += " Monthly projected PIP cost = $" + str(pipCost*24*30) + "\n"

m += " -----------------\n"
proc = subprocess.Popen(['azure','storage','account','list'],stdout=subprocess.PIPE)
sas = getTable(proc)
m += " " + str(len(sas)) + " Storage accounts\n"
m += " ====================================================\n"
hf.write(m)
hf.close()

lf = open(last, 'w')
lf.write(str(cost) + "\n")
lf.write(str(pipCost) + "\n")
lf.close()

h = dt.datetime.now().hour
epsilon = 1e-4
if (h % 6 == 0) or \
   (abs(cost - oldVMcost) > epsilon) or \
   (abs(pipCost - oldPIPcost) > epsilon) :
#    print cost - oldVMcost, " ", pipCost - oldPIPcost
    sendEmail(m)
#else:
#    sendEmail(" Nothing to report...\n")

#print m
#sendEmail(m)



