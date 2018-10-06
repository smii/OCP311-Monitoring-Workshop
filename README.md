 Monitoring on OpenShift
-----------------------

In this workshop we will first deploy a sample nodejs application on OpenShift. Next, we will deploy Prometheus and Grafana on OpenShift to monitor the application and the cluster.
 
###  Log-in to your enviromnent:
Goto this link: https://goo.gl/iqm7xM  
Select one of the demo environments (add your name next to it under the name column).\
Use credentials developer/developer.

### Login using the oc command-line tool
Install the OC command-line tool. Download from here: https://github.com/openshift/origin/releases/tag/v3.10.0
```bash
oc login <demo environment url>
The server uses a certificate signed by an unknown authority.
You can bypass the certificate check, but any data you send to the server could be intercepted by others.
Use insecure connections? (y/n): y

Authentication required for <demo environment url> (openshift)
Username: developer    
Password: 
Login successful.

You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default
    grafana
    kube-dns
    kube-proxy
<snip>

Using project "default".
```

### Commands to verify you are in the right environment
```bash
oc whoami
oc project
```

### Deploy sample application
```bash
# Create project for our appl
oc new-project demoproject
# Deploy the app
oc new-app https://github.com/smii/workshop.git --context-dir=example-prometheus-nodejs -n demoproject
# Expose the port which exposes metrics
oc expose dc/workshop --name=workshop-svc --port=3001 -n demoproject
# Expose app to the outside world (optional)
oc expose svc/workshop-svc -n demoproject
```

### Deploy prometheus and node-exporter
```bash
oc new-app -f prometheus/prometheus.yaml -n kube-system
oc get pods -n kube-system
oc describe pod prometheus-0 -n kube-system
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:prometheus -n kube-system
oc create -f prometheus/node-exporter.yaml -n kube-system
oc adm policy add-scc-to-user -z prometheus-node-exporter hostaccess -n kube-system
oc get routes -n kube-system
 ```

### Deploy grafana 
```bash
oc new-project grafana
oc new-app -f "grafana/grafana.yaml" -n grafana
oc rollout status deployment/grafana -n grafana
oc adm policy add-role-to-user view -z grafana -n kube-system
oc get routes -n grafana
oc sa get-token prometheus -n kube-system
```

### Scraper example
Edit the prometheus configmap in order to configure new scrape target.
```bash
oc edit configmap prometheus -n kube-system
```
Paste the following sample scrape configuration into the configmap and save:
```bash
    - job_name: NodeJS
      scrape_interval: 5s
      scrape_timeout: 5s
      static_configs:
      - targets:
        - workshop-svc.demoproject.svc:3001
        labels:
          app: nodejs
          sandbox: nodejs
```
Reload prometheus to re-read the scrap configuration.
```bash
  $ oc rsh -c prometheus prometheus-0 -n kube-system
  $ curl -X POST http://localhost:9090/-/reload
```

### Query example

Scrape CPU activitiy from a specific pod on a specific namespace
```
container_cpu_usage_seconds_total{namespace=<namespace>, pod_name=<pod name>"}
```

Visualize the same example in Grafana
```
sum (irate (container_cpu_usage_seconds_total{namespace="<namespace>", pod_name="<pod name>"}[2m]))
```

More information regarding Prometheus query language
[here](https://prometheus.io/docs/prometheus/latest/querying/basics/)

More information regarding Grafana query language
[here](http://docs.grafana.org/guides/basic_concepts/)

Grafana community dashboards: 
[here](https://grafana.com/dashboards)

