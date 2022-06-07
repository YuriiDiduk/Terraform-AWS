 
variable "subnets_cidr" {
	type = list
	default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zone" {
    description = "Avaialbility Zones"
    default = ["us-east-1a", "us-east-1b"]
}

variable "webservers_ami" {
  #default = "ami-0ff8a91507f77f867"
  default = "ami-0f9fc25dd2506cf6d"
  
}


variable "access_key" { default = "AKIA3Y5FS5AS2WK2DXOT" }

variable "secret_key" { default = "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" }


