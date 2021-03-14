# hello-eks
basic example of AWS EKS

# Quick start

```
$ terraform apply

$ aws eks update-kubeconfig --name hello-eks

$ kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=$(terraform output aws_iam_role_aws_k8s_serviceaccount_aws_node_arn | tr -d '"')
```

## Dashboard

```
$ kubectl apply -f k8s/dashboard

$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

$ kubectl proxy
```

<http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default>

## kuard

```
$ kubectl apply -f k8s/kuard

$ kubectl port-forward service/kuard 8080:http
```

<http://localhost:8080>

## aws-load-balancer-controller

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
    
