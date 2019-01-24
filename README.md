# Fibonacci Calculator

[![Build Status](https://travis-ci.org/NFhbar/fib-calculator.svg?branch=master)](https://travis-ci.org/NFhbar/fib-calculator)

Over complicated Fibonacci calculator to illustrate multi-container application.

Stack:

- [nginx](https://www.nginx.com/)
- [redis](https://redis.io/)
- [react](https://reactjs.org/)
- [express](https://expressjs.com/)
- [postgres](https://www.postgresql.org/)
- [docker](https://www.docker.com/)
- [terraform](https://www.terraform.io/)
- [AWS Elastic beanstalk](https://aws.amazon.com/elasticbeanstalk/)

Each service is `dockerized` with development containers -`Dockerfile.dev`- for testing:
![Alt text](docs/fib-calculator.png?raw=true "dev_architecture")

The production environment architecture is hosted in AWS:
![Alt text](docs/fib-calculator-3.png?raw=true "prod_architecture")

Nginx is used to route traffic to proper back end server:
![Alt text](docs/fib-calculator-2.png?raw=true "routing")

AWS resources are managed by [terraform](https://www.terraform.io/). See [terraform folder](/terraform/README.md) for details.

TravisCI builds the containers, pushes them to [DockerHub](https://hub.docker.com/u/nfhbar), and tells EBS to update.

## Usage
### Terraform setup
The first time you deploy you'll provision a sample `beanstalk` app:

- Create an `S3` bucket and upload the sample app file: [docker-multicontainer-v2.zip](/docs/docker-multicontainer-v2.zip)

- In the `/terraform` folder, create a `terraform.tfvars` file and fill your values - refer to [terraform.sample.tfvars](/terraform/terraform.sample.tfvars)

- Still in `/terraform`:
```
$ terraform init
$ terraform plan
$ terraform apply
```

If deploy fails, add the following policy to your generated ECS role:
```
arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker
```

And re run apply:
```
$ terraform apply
```

### Updating the Travis File
Update the `.travis.yml` file with your app and bucket values:
```
provider: elasticbeanstalk
region: us-east-2
app: nf-prod-fib-calculator-t
env: nf-prod-fib-calculator-t
bucket_name: elasticbeanstalk-us-east-2-259280065187
bucket_path: fib-calculator
```

Also add a valid AWS `access key` and `access secret` to Travis environment variables.

### Updating the App
After making modifications, push your changes to master and Travis will
build and push.

EBS multi-container settings in [Dockerrun.aws.json](./Dockerrun.aws.json)

## Local Usage
In root folder:
```
$ docker-compose up --build
```

If first time running fails, might have to start twice.

Then visit `localhost:3050`. Input values and refresh page.

## TODO
- optimize memory usage per container in [Dockerrun.aws.json](./Dockerrun.aws.json)

- fix terraform failing on initialization due to missing `IAM policy`.
