echo "Task 1. Create the networks"

echo "Create the first network"
echo "Creating the VPC gcp-vpc"
gcloud compute networks create gcp-vpc --subnet-mode custom
echo "Creating the subnet-a"
gcloud compute networks subnets create subnet-a --region us-central1 --range 10.5.4.0/24 --network gcp-vpc

echo "Create the second network"
echo "Creating the on-prem network"
gcloud compute networks create on-prem --subnet-mode custom
echo "Creating the subnet-b"
gcloud compute networks subnets create subnet-b --region europe-west1 --range 10.1.3.0/24 --network on-prem


echo "Task 2. Create the utility VMs"

echo "Create the first instance in gcp-vpc"
gcloud compute instances create gcp-server --zone us-central1-a --machine-type n1-standard-1 --network gcp-vpc --subnet subnet-a
echo "Create the second instance in on-prem"
gcloud compute instances create on-prem-1 --zone europe-west1-b --machine-type n1-standard-1 --network on-prem --subnet subnet-b


echo "Task 3. Create the firewall rules"

echo "Allow traffic to gcp-vpc"
gcloud compute firewall-rules create allow-icmp-ssh-gcp-vpc --network gcp-vpc --source-ranges 0.0.0.0/0 --allow tcp:22,icmp

echo "Allow traffic to on-prem"
gcloud compute firewall-rules create allow-icmp-ssh-on-prem --network on-prem --source-ranges 0.0.0.0/0 --allow tcp:22,icmp

echo "Task 5. Create the Cloud Routers"

echo "Create the gcp-vpc Cloud Router"
gcloud compute routers create gcp-vpc-cr --network gcp-vpc --region us-central1 --asn 65470

echo "Create the on-prem Cloud Router"
gcloud compute routers create on-prem-cr --network on-prem --region europe-west1 --asn 65503

echo "Prepare for VPN Gateways configuration"
echo "Reserve static ip addresses"
gcloud compute addresses create gcp-vpc-ip --region us-central1
gcloud compute addresses create on-prem-ip --region europe-west1

echo "Remaining steps using the console...we could try using Gateways and Tunnels!"
