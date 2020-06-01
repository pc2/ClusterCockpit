import json
import requests
import time
import argparse
import sys
import os
from dotenv import load_dotenv
import pandas as pd
from influxdb import DataFrameClient

load_dotenv(verbose=True)

baseurl=os.getenv("BASEURL")
apikey=os.getenv("APIKEY")

influxdbhost=os.getenv("INFLUXDBHOST")
influxdbport=os.getenv("INFLUXDBPORT")
influxdbuser=os.getenv("INFLUXDBUSER")
influxdbpassword=os.getenv("INFLUXDBPASSWORD")
influxdbname=os.getenv("INFLUXDBDBNAME")
influxdbprotocol=os.getenv("INFLUXDBPROTOCOL")
cluster=os.getenv("CLUSTER")

def startjob(cluster,jobid,user,start,nodes):
    task={"action": "startjob","job_id":jobid,"user_id":user,"cluster_id":cluster,"start_time":start,"nodes":nodes.split(",")}
    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json())
    else:
            print('Error status code: ', status)
            raise

def stopjob(cluster,jobid,stop):
    task={"action": "stopjob","job_id":jobid,"stop_time":stop}
    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json())
    else:
            print('Error status code: ', status)
            raise

def setnodes(cluster,jobid,nodes):
    task={"action": "setnodes","job_id":jobid,"nodes":nodes.split(",")}
    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json())
    else:
            print('Error status code: ', status)
            raise

def setlastupdate(cluster,jobid,lastupdate):
    task={"action": "setlastupdate","job_id":jobid,"lastupdate":lastupdate}
    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json())
    else:
            print('Error status code: ', status)
            raise

def getlastupdate(cluster,jobid):
    task={"action": "getlastupdate","job_id":jobid}
    #print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print("lastupdate=",resp.json())
    else:
            print('Error status code: ', status)
            raise

def getjobs(cluster):
    task={"action": "getjobs"}
#    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json().replace("\",\"","\n").replace("\"]","").replace("[\"",""))
    else:
            print('Error status code: ', status)
            raise

def getjobswithoutupdate(cluster):
    task={"action": "getjobswithoutupdate"}
#    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json().replace("\",\"","\n").replace("\"]","").replace("[\"",""))
    else:
            print('Error status code: ', status)
            raise

def getstoppedjobs(cluster):
    task={"action": "getstoppedjobs"}
#    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json().replace("\",\"","\n").replace("\"]","").replace("[\"",""))
    else:
            print('Error status code: ', status)
            raise

def gettags(cluster,jobid,tagtype):
    task={"action": "gettags","job_id":jobid,"tagtype":tagtype}
#    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json()) #.replace("\",\"","\n").replace("\"]","").replace("[\"",""))
    else:
            print('Error status code: ', status)
            raise

def addtag(addtag,jobid,tagname,tagtype):
    task={"action": "addtag","job_id":jobid,"tagname":tagname,"tagtype":tagtype}
    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json())
    else:
            print('Error status code: ', status)
            raise

def removetagsoftype(cluster,jobid,tagtype):
    task={"action": "removetagsoftype","job_id":jobid,"tagtype":tagtype}
    print(task)
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task),verify=False)
    status = resp.status_code
    if status == 200 or status == 304:
            print(resp.json())
    else:
            print('Error status code: ', status)
            raise

def addproblem(cluster,jobid,problem):
    task={"action": "addproblem","job_id":jobid,"problem":problem}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
        print(resp.json())
    else:
        print ('Error status code: ', status)
        raise

def getproblems(cluster,jobid):
    task={"action": "getproblems","job_id":jobid}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
        print(resp.json())
    else:
        print ('Error status code: ', status)
        raise

def clearproblems(cluster,jobid):
    task={"action": "clearproblems","job_id":jobid}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
        print(resp.json())
    else:
        print ('Error status code: ', status)
        raise

def getstarttime(cluster,jobid):
    task={"action": "getstarttime","job_id":jobid}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
            return resp.json()
    else:
            print('Error status code: ', status)
            raise

def getstoptime(cluster,jobid):
    task={"action": "getstoptime","job_id":jobid}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
            return resp.json()
    else:
            print ('Error status code: ', status)
            raise

def getnodes(cluster,jobid):
    task={"action": "getnodes","job_id":jobid}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    nodes=[]
    if status == 200 or status == 304:
            j=resp.json()
            for n in j:
                nodes.append(j[n]["nodeId"])
            return nodes
    else:
            print('Error status code: ', status)
            raise


def checkproblems(cluster,jobid):
  client = DataFrameClient(influxdbhost, influxdbport, influxdbuser, influxdbpassword, influxdbname)
  start=getstarttime(cluster,jobid)
  stop=getstoptime(cluster,jobid)
  if stop==-1:
    stop=int(time.time())
  nodes=getnodes(cluster,jobid)

  print(jobid," ",start," ",stop," ",nodes)

  problems=[]
  with open('rules') as json_file:
      rules = json.load(json_file)
  removetagsoftype(cluster,jobid,"automatically detected problems")

  for r in (rules):
      #print(r)
      condtot=True
      reasons=[]
      for m in r["attrs"]:
          #print(m)
          alerts=[]
          scale=m["scale"]
          if m["granularity"]=="node":
              condsec=False
              for node in nodes:
                  req="SELECT mean(\"" + m["measurement"]+"\") as \"mean_"+ m["measurement"]+"\" FROM " + influxdbname + ".\""+ m["measurement"]+"\" WHERE time > "+str(start)+"s AND time <"+str(stop)+"s AND \"host\"=\'"+node+"\' GROUP BY time(10s) FILL(linear)"
                  print(req)
                  results=client.query(req)
#                print("return=",results)
                  df=results[m["measurement"]].dropna(0)
                  if m["type"]=="mean":
                      val=scale*df["mean_"+m["measurement"]].mean()
                  elif m["type"]=="min":
                      val=scale*df["mean_"+m["measurement"]].min()
                  elif m["type"]=="max":
                      val=scale*df["mean_"+m["measurement"]].max()
                  else:
                      raise "unknown type "+m["type"]

                  print("val=",val)
                  cond=True
                  if m["condition"]=="greater than":
                      if val>float(m["conditionvalue"]):
                          cond=True
                      else:
                          cond=False
                  elif m["condition"]=="lower than":
                      if val<float(m["conditionvalue"]):
                          cond=True
                      else:
                          cond=False
                  else:
                      raise "unknown condition "+m["condition"]
                  if cond:
                      alerts.append([{"node":node,"value":val}])
                      s="The "+m["type"]+" "+m["measurementname"]+" on node " +node+" is "+str(val)+" "+m["unit"]+" and is "+m["condition"]+" the alert value of "+str(m["conditionvalue"])+" "+m["unit"]+"."
                      reasons.append(s)
                  condsec=condsec or cond

          elif m["granularity"]=="job":
              raise "not implemented"
          else:
              raise "unknown granularity "+m["granularity"]
          condtot=condtot and condsec
      if condtot:
          problems.append({"tag":r["tag"],"msg":r["msg"],"url":r["url"],"reasons":reasons,"severity":r["severity"]})
          addtag(cluster,jobid,r["tag"],"automatically detected problems")

  clearproblems(cluster,jobid)
  print("Found "+str(len(problems))+" potential problems with this job:")
  if len(problems)==0:
      phtml="none"
      addproblem(cluster,jobid,phtml)
      addtag(cluster,jobid,"no problem detected","automatically detected problems")
  else:
      phtml="<tr> <td scope=\"col\">"+"severity"+"</td> <td scope=\"col\">"+"tag"+"</td> <td scope=\"col\">"+"description"+"</td> <td scope=\"col\">link</td></tr>"
      addproblem(cluster,jobid,phtml)
      for p in problems:
          phtml="<tr> <td scope=\"col\">"+p["severity"]+"</td> <td scope=\"col\">"+p["tag"]+"</td> <td scope=\"col\">"+p["msg"]+"</td> <td scope=\"col\"><a href=\""+p["url"]+"\">More Information</a></td></tr>"
          phtml=phtml+"<tr> <td scope=\"col\">"+"</td> <td scope=\"col\">"+"</td> <td scope=\"col\">"+"reasons:"+"</td> <td scope=\"col\"></td></tr>"
          for r in p["reasons"]:
              phtml=phtml+"<tr> <td scope=\"col\">"+"</td> <td scope=\"col\">"+"</td> <td scope=\"col\">"+r+"</td> <td scope=\"col\"></td></tr>"
          addproblem(cluster,jobid,phtml)
          print("Problem description:")
          print("   "+p["msg"])
          print("Problem tag:")
          print("   "+p["tag"])
          print("Problem severity:")
          print("   "+p["severity"])
          print("For details and for help to speed up your calculation please visit:")
          print("   "+p["url"])
          print("This problem has been detected because:")
          for r in p["reasons"]:
              print("   "+r)
          print()
def getOutputRecommendations(cluster,jobid):
    task={"action": "getOutputRecommendations","job_id":jobid}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
            print("OutputRecommendations=",resp.json())
    else:
            print('Error status code: ', status)
            raise

def setOutputRecommendations(cluster,jobid,opt):
    task={"action": "setOutputRecommendations","job_id":jobid,"OutputRecommendations":opt}
    resp = requests.post(baseurl+"api/jobs",headers={'content-type':'application/json', 'accept':'application/json','apikey':apikey},data=json.dumps(task))
    status = resp.status_code
    if status == 200 or status == 304:
            return resp.json()
    else:
            print('Error status code: ', status)
            raise


action=sys.argv[1]

if action=="start":
	jobid=sys.argv[2]
	user=sys.argv[3]
	start=sys.argv[4]
	nodes=sys.argv[5]
	startjob(cluster,jobid,user,start,nodes)
elif action=="stop":
	jobid=sys.argv[2]
	stop=sys.argv[3]
	stopjob(cluster,jobid,stop)
elif action=="setnodes":
	jobid=sys.argv[2]
	nodes=sys.argv[3]
	setnodes(cluster,jobid,nodes)
elif action=="getjobs":
	getjobs(cluster)
elif action=="getjobswithoutupdate":
	getjobswithoutupdate(cluster)
elif action=="getstoppedjobs":
	getstoppedjobs(cluster)
elif action=="gettags":
	jobid=sys.argv[2]
	tagtype=sys.argv[3]
	gettags(cluster,jobid,tagtype)
elif action=="addtag":
	jobid=sys.argv[2]
	tagname=sys.argv[3]
	tagtype=sys.argv[4]
	addtag(cluster,jobid,tagname,tagtype)
elif action=="removetagsoftype":
	jobid=sys.argv[2]
	tagtype=sys.argv[3]
	removetagsoftype(cluster,jobid,tagtype)
elif action=="checkproblems":
	jobid=sys.argv[2]
	checkproblems(cluster,jobid)
elif action=="getproblems":
	jobid=sys.argv[2]
	getproblems(cluster,jobid)
elif action=="setOutputRecommendations":
	jobid=sys.argv[2]
	opt=sys.argv[3]
	setOutputRecommendations(cluster,jobid,opt)
elif action=="getOutputRecommendations":
	jobid=sys.argv[2]
	getOutputRecommendations(cluster,jobid)
elif action=="setlastupdate":
	jobid=sys.argv[2]
	opt=sys.argv[3]
	setlastupdate(cluster,jobid,opt)
elif action=="getlastupdate":
	jobid=sys.argv[2]
	getlastupdate(cluster,jobid)

else:
	print("not implemented")




