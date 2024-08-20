Here are the steps and commands to deployment of java web application on AWS EKS using fargate.

install kubectl in ubuntu
install eksctl

 1. creation of eks cluster with fargate

 sudo eksctl create cluster \
  --name my-cluster \
  --region us-west-2 \
  --fargate

 2. configure kubectl to our new cluster

  sudo aws eks --region us-east-2 update-kubeconfig --name mukesh-app-cluster

 3. create namespace

  sudo kubectl create -f namespace.yml

 4. create fargate profile in our namespace

  sudo eksctl create fargateprofile \
    --cluster mukesh-app-cluster \
    --region us-east-2 \
    --name mukesh-fargate-profile-app \
    --namespace prod-app

5. create deployment, service and ingress using below commands 

  sudo kubectl create -f deployment.yml
	sudo kubectl create -f service.yml
	sudo kubectl create -f ingress.yml


6. configure OIDC provider to our cluster

sudo eksctl utils associate-iam-oidc-provider --cluster mukesh-app-cluster --region us-east-2 --approve

7. create aws load balancer controller, load balancer controller will create ALB which will distribute traffic to our pods.
To do that we need to create IAM policy and IAM role and these need to attach to service account which need to attach to our cluster

8. Download IAM policy

sudo curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

9. create IAM policy

sudo aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

 10.   create IAM role

    sudo eksctl create iamserviceaccount --cluster=mukesh-app-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::<aws-acc-id>:policy/AWSLoadBalancerControllerIAMPolicy --region=us-east-2 --approve

11. Deploy helm repo
  
  sudo helm repo add eks https://aws.github.io/eks-charts
  
  sudo helm repo update eks

12.  create aws load balancer controller using helm

   sudo helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=mukesh-app-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-2 --set vpcId=<cluster vpc id>

   Check load balancer controller status


   After successfully installed aws load balancer controller, it will create application load balancer and we can access our application using below command.

   http://<ALB DNS Name>/my-web-app-1.0-SNAPSHOT
   
  sudo kubectl get deployment -n kube-system aws-load-balancer-controller
