# Atlantis Lab Time
In this Lab we are going to use Terraform to deploy a EC2 instance with Atlantis' Dockerfile already created for us.
We will be connecting into the EC2 instance and install Atlantis via the Docker Image way and get hands on with webhooking Atlantis to our GitLab repository,
follow by creating a pull request to see Atlantis in action.

Follow the step-by-step below to complete this Lab, hope you enjoy and learn something new from this!

## Creating the infrastructure
In this section we will be creating the infrastructure that is necessary for Atlantis 

```
sudo docker build -t atlantis .

sudo docker run -itd -p 4000:4141 --name atlantis atlantis server --automerge --autoplan-modules --gitlab-user=root --gitlab-token=[YOUR_GITLAB_TOKEN] --repo-allowlist=[YOUR_REPO_URL] --gitlab-webhook-secret=[YOUR_WEBHOOK_SECRET] --gitlab-hostname=http://[GITLAB_IP] 


```
