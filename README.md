# ThoughtWorks Demo

## Introduction
This document will lead you to containerize MediaWiki with help of Kubernetes and Helm chart.
 
### Tech Stack
1. AWS
2. Kubernetes
3. Helm Chart
4. Terraform
5. Shell
## Provision Infrastructure
 Here, I have used AWS & Terraform to provision 3 node private Kubernetes cluster, Bastion server and few roles to enable access from the cluster.

### Steps
1. we have a server with role attached. the role or keys should have access for EC2 and EKS.
2. make sure the role eks-admin should be available with full eks access and a keypair called a101 already should be there or you can name it anything you want. don't forget to change it in variable file.
3. make sure Terraform installed on the server, then navigate into terraform_templates path and then execute the **terraform init and terraform apply**.
4. once everything provisioned, goahead and check aws cli, kubectl and helm has been installed. those are configured in the user data.
5. then run a command to update k8s cluster config **aws eks update-kubeconfig --name <clustername>**
6. once updated test the nodes details to verify

## Containerization
1. I have used official mediawiki docker image and mysql 5.6 image
2. for mediawiki, have created deployment, service, storage class and persistent volume claim.
3. for mysql, deployment, servcie and persistent volume claim.
4. once you execute the helm install(there are 3 charts here, mysql, storage and wiki), it will create all the above resources and check mediawiki service to get loadbalancer URL.
5. once all pods up and running hit the URL and you can see the mediawiki setup page.
6. goahead and do all the installation setup. use **mysql.mediawiki-ns.svc.cluster.local** for DB host and root/password for DB credentials.
7. once setup completed, you will get **LocalSettings.php**. download it and move it to bastion server.
8. from bastion server copy it to mediawiki pod by running **kubectl cp LocalSettings.php mediawiki-ns/<podname>:/var/www/html/**
9. now we got the mediawiki up and running.


Planned well to make this. due to low time I couldn't acheive all thoughts. I can explain in discussion if it's possible.

** Thanks for reading! **