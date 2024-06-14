# Session Call #2


#create EC2 resource, moved to ec2.tf







#Create s3 bucket

#variable can go before or after it is referenced. Interturpulation. 

#variables now in variables.tf
resource "aws_s3_bucket" "bucket_name" {
  bucket = var.my_bucketname

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


#Create Security Group
resource "aws_security_group" "security_group" {
  name        = "ExampleAppServerSecurityGroup"
  description = "Session 2 talkthrough"
  vpc_id      = var.my_vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleAppServer"
  }

}

