# hello-eks
basic example of AWS EKS

# Quick start

```
$ terraform apply

$ aws eks update-kubeconfig --name hello-eks

$ kubectl run nginx --image nginx
```

## AWS Permissions to view k8s resources
permissions to view resources
https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions

note: eksctl not new enough on freebsd
```
$ kubectl apply -f https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml
```


## Dashboard

TODO: figure out how to fix for k8s 1.22+

Docs: https://github.com/kubernetes/dashboard/releases

```
$ kubectl proxy

# enter token from TF output
```

<http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default>

## kuard

```
$ kubectl apply -f k8s/kuard

$ kubectl port-forward service/kuard 8080:http
```

<http://localhost:8080>

## aws-load-balancer-controller

TODO: review and cleanup

See https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

# notes

## elb 

- on each worker, 
    - kube-proxy listens on random port (31596)
    - iptables rule configured to redirect from 31596 to every svc pod IP
        - each has their own random probability
            - but.. evens out based on math (rules execed sequentially)
            
- ELB has targets for each host's kube-proxy random port (31596). e.g., 4 targets
    - requests to ELB distributed mostly evenly
    - ELB request arrives at target, then may be re-routed to another host even
      if the target has svc pod available

## nlb

- each worker,
    - kube-proxy listens on random port (31305)
    - iptables rule similar
 
- NLB health target is port 31612, bound to kube-proxy
    - no iptables rules
    - path /healthz
    - remove /index.html from one pod
        - health check doesn't detect it
    
