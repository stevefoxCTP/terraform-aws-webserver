provider "aws" {
  region     = "us-east-1"
}

module "webserver" {
  source        = "../"
  instance_type = "t2.micro"
  filecontent   = "${file("index.html")}"
  env_version   = "Green"
  lab_username  = "lab-user-41"
}
