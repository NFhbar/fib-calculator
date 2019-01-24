variable "region" {
  description = "The region to build in"
  default     = "us-east-2"
}

variable "max_availability_zones" {
  description = "The maximum number of availability zones"
  default     = "2"
}

variable "name" {
  description = "The name for the resources"
  default     = "fib-calculator-t"
}

variable "namespace" {
  description = "Namespace, usually organization name"
  default     = "nf"
}

variable "stage" {
  description = "The stage of the app, eg: dev, prod"
  default     = "prod"
}

variable "bucket" {
  description = "The name of the bucket containing source code"
}

variable "key" {
  description = "The key for source file in the bucket"
}

variable "source" {
  description = "The source for the zip file"
}

variable "postgress_name" {
  description = "The name for the database"
}

variable "postgress_username" {
  description = "Username for the postgres database"
}

variable "postgress_password" {
  description = "Password for the postgres database"
}
