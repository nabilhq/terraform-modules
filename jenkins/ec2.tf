resource "aws_key_pair" "ec2" {
  key_name   = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  public_key = var.public_key_ssh

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = var.ec2_instance_size
  key_name               = aws_key_pair.ec2.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.priv_subnet_a_id
  availability_zone      = var.availability_zone
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_type           = var.ec2_root_volume_type
    volume_size           = var.ec2_root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "null_resource" "ec2" {
  triggers = {
    subdomain_id = "${aws_route53_record.lb.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.ec2.private_ip
    private_key = var.private_key_ssh
  }

  provisioner "file" {
    source      = var.jenkins_yaml_config_path
    destination = "/home/ubuntu/jenkins.yaml"
  }

  provisioner "file" {
    source      = var.jenkins_init_groovy_path
    destination = "/home/ubuntu/init.groovy"
  }

  provisioner "file" {
    source      = var.jenkins_plugins_yaml_path
    destination = "/home/ubuntu/plugins.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo WAITING FOR EC2 INSTANCE TO START UP",
      "sleep 60",
      "echo UPDATING PACKAGES",
      "sudo apt-get update",
      "echo INSTALLING - unzip",
      "sudo apt-get install unzip",
      "echo INSTALLING - jq",
      "sudo apt-get install jq -y",
      "echo INSTALLING - java jdk",
      "sudo apt-get install openjdk-8-jdk -y",
      "echo INSTALLING - aws cli",
      "curl -o /home/ubuntu/awscliv2.zip https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip",
      "unzip /home/ubuntu/awscliv2.zip",
      "sudo /home/ubuntu/aws/install",
      "rm /home/ubuntu/awscliv2.zip",
      "echo ADDING JENKINS REPOS",
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "echo UPDATING PACKAGES",
      "sudo apt update",
      "echo INSTALLING - jenkins",
      "sudo apt install jenkins -y",
      "sudo service jenkins stop",
      "echo UPDATING FIREWALL RULES",
      "sudo ufw allow 8080",
      "echo COPYING - init.groovy.d",
      "sudo mkdir -p /var/lib/jenkins/init.groovy.d",
      "sudo cp /home/ubuntu/init.groovy/* /var/lib/jenkins/init.groovy.d/",
      "echo UPDATING - basic-security.groovy",
      "sudo sed -i 's/{service_name}/${var.service_name}/g; s/{aws_region}/${var.aws_region}/g; s/{environment}/${var.environment}/g;' /var/lib/jenkins/init.groovy.d/basic-security.groovy",
      "echo CHANGING PERMISSIONS - init.groovy.d",
      "sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d",
      "echo DOWNLOADING plugin-installation-manager-tool",
      "wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.9.0/jenkins-plugin-manager-2.9.0.jar",
      "echo EXECUTING - plugin-installation-manager-tool",
      "sudo java -jar jenkins-plugin-manager-*.jar --plugin-file ./plugins.yaml -d /var/lib/jenkins/plugins --verbose",
      "echo MOVING - jenkins.yaml",
      "sudo mv /home/ubuntu/jenkins.yaml /var/lib/jenkins/jenkins.yaml",
      "echo UPDATING - jenkins.yaml",
      "sudo sed -i 's/{serviceName}/${var.service_name}/g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's/{domain}/${var.domain}/g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's/{environment}/${var.environment}/g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's/{adminUsername}/${var.admin_username}/g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's/{adminEmail}/${var.admin_email}/g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's/{gitAccount}/${var.github_account}/g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's/{gitRepo}/${var.github_repo}/g' /var/lib/jenkins/jenkins.yaml",
      "echo CHANGING PERMISSIONS - jenkins.yaml",
      "sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml",
      "echo RESTARTING SERVICE - jenkins",
      "sudo service jenkins stop",
      "sudo service jenkins start",
      "echo CLEANING UP",
      "rm -rf /home/ubuntu/init.groovy",
      "rm -rf /home/ubuntu/plugins.yaml"
    ]
  }
}