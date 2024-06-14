resource "aws_instance" "myWebsite" {
  ami           = var.ami_id
  instance_type = var.my_instancetype
  user_data     = file("build_apache.sh")

  tags = {
    Name = "HelloWorld"
  }
}
