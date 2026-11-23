Deployment of a Java Web Application on AWS EKS Using Fargate

This document explains the steps and commands required to deploy a Java web application on Amazon Elastic Kubernetes Service (EKS) using AWS Fargate.

1. Install kubectl and eksctl on Ubuntu

Install the following tools on your Ubuntu machine:

kubectl – Kubernetes command-line tool.
eksctl – CLI tool for managing Amazon EKS clusters.
2. Create an EKS Cluster with Fargate

Run the following command to create an EKS cluster with Fargate:

bash
sudo eksctl create cluster \
  --name my-cluster \
  --region us-west-2 \
  --fargate

3. Configure kubectl to Connect to the New Cluster

Configure kubectl to communicate with the newly created EKS cluster:

bash
sudo aws eks --region us-east-2 update-kubeconfig \
  --name mukesh-app-cluster

4. Create a Kubernetes Namespace

Create a namespace using the namespace.yml file:

bash
sudo kubectl create -f namespace.yml

5. Create a Fargate Profile for the Namespace

Create a Fargate profile for the application namespace:

bash
sudo eksctl create fargateprofile \
  --cluster mukesh-app-cluster \
  --region us-east-2 \
  --name mukesh-fargate-profile-app \
  --namespace prod-app

6. Create Deployment, Service, and Ingress

Create the Kubernetes deployment, service, and ingress resources using the following commands:

bash
sudo kubectl create -f deployment.yml

sudo kubectl create -f service.yml

sudo kubectl create -f ingress.yml

7. Configure the OIDC Provider for the EKS Cluster

Associate an IAM OIDC provider with the EKS cluster:

bash
sudo eksctl utils associate-iam-oidc-provider \
  --cluster mukesh-app-cluster \
  --region us-east-2 \
  --approve

8. Install AWS Load Balancer Controller

The AWS Load Balancer Controller manages AWS Elastic Load Balancers for Kubernetes applications.

It creates an Application Load Balancer (ALB) that distributes incoming traffic to the application pods.

To install the controller, we need to:

Download the IAM policy.
Create an IAM policy.
Create an IAM role.
Attach the IAM role to a Kubernetes service account.
Install the controller using Helm.
8.1 Download the IAM Policy

Download the AWS Load Balancer Controller IAM policy:

bash
sudo curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

8.2 Create an IAM Policy

Create an IAM policy using the downloaded JSON file:

bash
sudo aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

8.3 Create an IAM Role and Service Account

Create an IAM service account and attach the IAM policy to it:

bash
sudo eksctl create iamserviceaccount \
  --cluster=mukesh-app-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<aws-acc-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --region=us-east-2 \
  --approve


Note: Replace <aws-acc-id> with your actual AWS account ID.

8.4 Add the AWS EKS Helm Repository

Add the AWS EKS Helm repository:

bash
sudo helm repo add eks https://aws.github.io/eks-charts


Update the Helm repository:

bash
sudo helm repo update eks

8.5 Install AWS Load Balancer Controller Using Helm

Install the AWS Load Balancer Controller using the following command:

bash
sudo helm install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=mukesh-app-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-2 \
  --set vpcId=<your-vpc-id>


Note: Replace <your-vpc-id> with your actual AWS VPC ID.

9. Verify AWS Load Balancer Controller Status

Check whether the AWS Load Balancer Controller deployment is running successfully:

bash
sudo kubectl get deployment \
  -n kube-system \
  aws-load-balancer-controller

10. Access the Java Web Application

After successfully installing the AWS Load Balancer Controller and configuring the Ingress resource, an Application Load Balancer (ALB) will be created.

The ALB distributes incoming traffic to the application pods.

You can access your Java web application using the following URL:

text
http://<your-alb-dns-name>/my-web-app-1.0-SNAPSHOT


Replace <your-alb-dns-name> with the DNS name of your Application Load Balancer.

Conclusion

By following these steps, we can deploy a Java web application on AWS EKS using Fargate.

The AWS Load Balancer Controller manages the Application Load Balancer, which routes external traffic to the application running inside Kubernetes pods.
