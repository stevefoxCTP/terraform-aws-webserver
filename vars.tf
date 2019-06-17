variable "lab_username"      {
  description = "Lab username, like lab-user-x. Used as an EC2 tag which the networking terraform workspace reads."
}

variable "instance_type"     {
  description = "EC2 instance type, like t2.micro."
}

variable "ami"               {
  description = "An ubuntu AMI ID. Default is Ubuntu 16.04"
  default     = "ami-0565af6e282977273"
}

variable "env_version"       {
  description = "Used by the networking module to identify blue and green infrastructure. Must be Blue or Green"
}

variable "filecontent"       {
  description = "Raw file content which will become the default index.html of the webserver on port 80."
}
