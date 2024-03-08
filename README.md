# Atlantis Lab Time
In this Lab we are going to use Terraform to deploy a EC2 instance with Atlantis' Dockerfile already created for us.
We will be connecting into the EC2 instance and install Atlantis via the Docker Image way and get hands on with webhooking Atlantis to our GitLab repository,
follow by creating a pull request to see Atlantis in action.

Follow the step-by-step below to complete this Lab, hope you enjoy and learn something new from this!

## Set up Gitlab
In this section we will be going through Gitlab to create a repo, access token and webhook configuration as a pre-requesit for Atlantis. Token will be used for Atlantis to access the repo and webhook secrets will define what event Atlantis will be listening out for.

Log into your GitLab instance with provided login details

1. Create a new repo within Gitlab
![Gitlab login page](/image/1_gitlab.png)

2. Fill out the name of the repo
![Create a new repo](/image/2_gitlab.png)

3. First we need to create an access token for Atlantis to use
![Create new access token](/image/3_gitlab.png)

4. Give the name of Token atlantis so team members know what the token is used for. Give it Developer Role and select api to give it permissions. Once the Token is created, make note of it and save it for later. Set the environment variable with below command e.g. export ACCESS_TOKEN=glpat-abc123def456
```
export ACCESS_TOKEN=YOUR_TOKEN

To check if you have assigned the value correctly, run 'echo $ACCESS_TOKEN'. This should return the token you just generated
```
![Settings for access token](/image/4_gitlab.png)
![Take note of token secret](/image/4_1_gitlab.png)

5. Create a webhook with EC2 IP. Just like with access token, set the environment variable for webhook secret too.
The secret will be defined by you.
```
export WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET
```
    - URL: http://ec2-public-ip:4000/events 
    - Name: alantis-webhook (It is optional and can be anything you want)
    - Secret Token: atlantis123 (This token will be used for the Docker run command later, so should make a note of it)
    - Trigger:
        - Push Events
        - Comments
        - Merge Request Events
    - Keep SSL enabled
![Gitlab login page](/image/5_gitlab.png)
![Gitlab login page](/image/5_1_gitlab.png)
![Gitlab login page](/image/5_2_gitlab.png)

6. Set repo URL and hostname environment variables. 
Make sure Repo URL DOES NOT contain http.
Make sure hostname DOES contain http.

```
Repo URL:
export REPO_URL=YOUR_REPO_URL 

e.g. export REPO_URL=18.134.152.108/root/atlantis-test

Hostname:
export HOSTNAME=YOUR_HOSTNAME

e.g. export HOSTNAME=http://18.134.152.108
```
![Gitlab repo home](/image/6_gitlab.png)

Reaching here means you have fully set up Alantis to accept connections and events from Gitlab. Next section we will be launching Atlantis with the environment variables we defined earlier. 


## Atlantis Install and Set Up
In this section, we will be installing Atlantis from within the CLI using Docker. There should be a Dockerfile created already which will install the latest version of Atlantis.
Commands below will build a image named atlantis with the Dockerfile supplied and run the atlantis service on port 4000:4141. The environment we been assigning is used here to configure atlantis on where to connect and give atlantis the access to our repo.

```
sudo docker build -t atlantis .

sudo docker run -itd -p 4000:4141 --name atlantis atlantis server --automerge --autoplan-modules --gitlab-user=root --gitlab-token=$ACCESS_TOKEN --repo-allowlist=$REPO_URL --gitlab-webhook-secret=$WEBHOOK_SECRET --gitlab-hostname=$HOSTNAME
```

![Atlantis docker image build](/image/1_atlantis.png)
![Running Atlantis with built image above](/image/2_atlantis.png)


Once Atlantis service is started, you can access it by going to your EC2 IP on port 4000
![Atlantis homepage](/image/3_atlantis.png)

Next we need to provide Atlantis the access to AWS by providing the AWS User Access key and Secret Access Key. A IAM user is provided with minimum required permissions for Atlantis to work here.
```
We first exec into the atlantis:
sudo docker exec -it atlantis /bin/sh

Then with the Vim editor we update the credentials within .aws folder:
vi /home/atlantis/.aws/credentials

Press I within the Vim editor to go into input mode and paste in the block below:
[default]
aws_access_key_id = "AKIA2UT47QJP5U7MGRM4"
aws_secret_access_key = "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"

Once that is done, we press ESC to exit the input mode and press :wq to save the changes (w for write and q for quit)

```
![Adding AWS Creds for Atlantis](/image/4_atlantis.png)