provider "aws" {
  region = "${var.region}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "${var.name}-sg"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "port_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "redis_port" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 6379
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_s3_bucket_object" "bucket" {
  bucket = "${var.bucket}"
  key    = "${var.key}"
  source = "../docs/docker-multicontainer-v2.zip"
  etag   = "${md5(file("../docs/docker-multicontainer-v2.zip"))}"
}

module "elastic_beanstalk_application" {
  source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=master"
  namespace   = "${var.namespace}"
  stage       = "${var.stage}"
  name        = "${var.name}"
  description = "Test elastic_beanstalk_application"
}

resource "aws_elastic_beanstalk_application_version" "myjarversion" {
  application = "${module.elastic_beanstalk_application.app_name}"
  name        = "sample"
  bucket      = "${var.bucket}"
  key         = "${var.key}"
}

module "elastic_beanstalk_environment" {
  source    = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=master"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  app       = "${module.elastic_beanstalk_application.app_name}"

  instance_type               = "t2.micro"
  autoscale_min               = 1
  autoscale_max               = 2
  updating_min_in_service     = 0
  updating_max_batch          = 1
  associate_public_ip_address = "true"
  environment_type            = "SingleInstance"
  rolling_update_type         = "Time"
  updating_min_in_service     = 0

  vpc_id              = "${data.aws_vpc.default.id}"
  public_subnets      = "${data.aws_subnet_ids.all.ids}"
  private_subnets     = "${data.aws_subnet_ids.all.ids}"
  security_groups     = ["${aws_security_group.default.id}"]
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.7 running Multi-container Docker 18.06.1-ce (Generic)"
  keypair             = ""

  tier = "WebServer"

  version_label = "sample"

  env_vars = "${
      map(
        "REDIS_HOST", "${aws_elasticache_cluster.redis.cache_nodes.0.address}",
        "REDIS_PORT", "6379",
        "PGUSER", "${var.postgress_username}",
        "PGPASSWORD", "${var.postgress_password}",
        "PGHOST", "${aws_db_instance.postgres.address}",
        "PGDATABASE", "${var.postgress_name}",
        "PGPORT", "5432"
      )
    }"
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "10.6"
  instance_class         = "db.t2.micro"
  port                   = "5423"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  name                   = "${var.postgress_name}"
  username               = "${var.postgress_username}"
  password               = "${var.postgress_password}"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  security_group_ids   = ["${aws_security_group.default.id}"]
}
