resource "aws_key_pair" "ec2_prod" {
  key_name   = "ec2-${var.vpc_name}-${var.service_name}-prod"
  public_key = var.prod_public_key_ssh

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_instance" "ec2_prod" {
  ami                    = var.ami_id
  instance_type          = var.prod_ec2_instance_size
  key_name               = aws_key_pair.ec2_prod.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.priv_subnet_a_id
  availability_zone      = var.availability_zone
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_type           = var.prod_ec2_root_volume_type
    volume_size           = var.prod_ec2_root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "null_resource" "ec2_prod" {
  triggers = {
    subdomain_id = "${aws_route53_record.lb_prod.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.ec2_prod.private_ip
    private_key = var.prod_private_key_ssh
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
      "echo INSTALLING - powershell",
      "sudo apt-get update",
      "sudo apt-get install -y wget apt-transport-https software-properties-common",
      "wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "sudo apt-get update",
      "sudo add-apt-repository universe",
      "sudo apt-get install -y powershell",
      "sudo ln -s /usr/bin/pwsh /usr/bin/powershell",
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
      "sudo sed -i 's/{service_name}/${var.service_name}/g; s/{aws_region}/${var.aws_region}/g;' /var/lib/jenkins/init.groovy.d/basic-security.groovy",
      "echo CHANGING PERMISSIONS - init.groovy.d",
      "sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d",
      "echo DOWNLOADING plugin-installation-manager-tool",
      "wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.9.0/jenkins-plugin-manager-2.9.0.jar",
      "echo EXECUTING - plugin-installation-manager-tool",
      "sudo java -jar jenkins-plugin-manager-*.jar --plugin-file ./plugins.yaml -d /var/lib/jenkins/plugins --verbose",
      "echo MOVING - jenkins.yaml",
      "sudo mv /home/ubuntu/jenkins.yaml /var/lib/jenkins/jenkins.yaml",
      "echo UPDATING - jenkins.yaml",
      "sudo sed -i 's#{hostname}#${var.service_name}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{serviceName}#${var.service_name}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{domain}#${var.domain}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{adminUsername}#${var.admin_username}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{adminEmail}#${var.admin_email}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{gitAccount}#${var.github_account}#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{gitRepo}#${var.github_repo}#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{githubBranch}#${var.github_branch_prod}#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{s3ExportDirectory}#${aws_s3_bucket.main.id}/#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{awsRegion}#${var.aws_region}#g' /var/lib/jenkins/jenkins.yaml",
      "echo CHANGING PERMISSIONS - jenkins.yaml",
      "sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml",
      "echo RESTARTING SERVICE - jenkins",
      "sudo service jenkins restart",
      "echo MOUNTING S3 BUCKET",
      "sudo apt-get install automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config -y",
      "git clone https://github.com/s3fs-fuse/s3fs-fuse.git",
      "cd s3fs-fuse && ./autogen.sh && ./configure --prefix=/usr --with-openssl",
      "make",
      "sudo make install",
      "sudo mkdir -p /${aws_s3_bucket.main.id}",
      "sudo chmod -R 775 /${aws_s3_bucket.main.id}",
      "sudo chown jenkins:jenkins -R /${aws_s3_bucket.main.id}/*",
      "echo \"s3fs#${aws_s3_bucket.main.id} /${aws_s3_bucket.main.id} fuse _netdev,allow_other,nonempty,iam_role=${aws_iam_role.ec2.name},endpoint=${var.aws_region},url=http://s3.${var.aws_region}.amazonaws.com 0 0\" | sudo tee -a /etc/fstab",
      "echo CLEANING UP",
      "rm -rf /home/ubuntu/init.groovy",
      "rm -rf /home/ubuntu/plugins.yaml",
      "rm /home/ubuntu/packages-microsoft-prod.deb",
      "rm /home/ubuntu/jenkins-plugin-manager-2.9.0.jar",
      "rm -rf s3fs-fuse",
      "echo RESTARTING",
      "sudo shutdown -r +0"
    ]
  }
}


resource "aws_key_pair" "ec2_staging" {
  key_name   = "ec2-${var.vpc_name}-${var.service_name}-staging"
  public_key = var.staging_public_key_ssh

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-staging"
    Service     = var.service_name
    Environment = "staging"
    Terraform   = true
  }
}

resource "aws_instance" "ec2_staging" {
  ami                    = var.ami_id
  instance_type          = var.staging_ec2_instance_size
  key_name               = aws_key_pair.ec2_staging.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.priv_subnet_a_id
  availability_zone      = var.availability_zone
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_type           = var.staging_ec2_root_volume_type
    volume_size           = var.staging_ec2_root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-staging"
    Service     = var.service_name
    Environment = "staging"
    Terraform   = true
  }
}

resource "null_resource" "ec2_staging" {
  triggers = {
    subdomain_id = "${aws_route53_record.lb_staging.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.ec2_staging.private_ip
    private_key = var.staging_private_key_ssh
    agent       = false
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
      "echo INSTALLING - powershell",
      "sudo apt-get update",
      "sudo apt-get install -y wget apt-transport-https software-properties-common",
      "wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "sudo apt-get update",
      "sudo add-apt-repository universe",
      "sudo apt-get install -y powershell",
      "sudo ln -s /usr/bin/pwsh /usr/bin/powershell",
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
      "sudo sed -i 's/{service_name}/${var.service_name}/g; s/{aws_region}/${var.aws_region}/g;' /var/lib/jenkins/init.groovy.d/basic-security.groovy",
      "echo CHANGING PERMISSIONS - init.groovy.d",
      "sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d",
      "echo DOWNLOADING plugin-installation-manager-tool",
      "wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.9.0/jenkins-plugin-manager-2.9.0.jar",
      "echo EXECUTING - plugin-installation-manager-tool",
      "sudo java -jar jenkins-plugin-manager-*.jar --plugin-file ./plugins.yaml -d /var/lib/jenkins/plugins --verbose",
      "echo MOVING - jenkins.yaml",
      "sudo mv /home/ubuntu/jenkins.yaml /var/lib/jenkins/jenkins.yaml",
      "echo UPDATING - jenkins.yaml",
      "sudo sed -i 's#{hostname}#${var.service_name}-staging#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{serviceName}#${var.service_name}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{domain}#${var.domain}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{adminUsername}#${var.admin_username}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{adminEmail}#${var.admin_email}#g;' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{gitAccount}#${var.github_account}#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{gitRepo}#${var.github_repo}#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{githubBranch}#${var.github_branch_staging}#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{s3ExportDirectory}#${aws_s3_bucket.main.id}/#g' /var/lib/jenkins/jenkins.yaml",
      "sudo sed -i 's#{awsRegion}#${var.aws_region}#g' /var/lib/jenkins/jenkins.yaml",
      "echo CHANGING PERMISSIONS - jenkins.yaml",
      "sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml",
      "echo RESTARTING SERVICE - jenkins",
      "sudo service jenkins restart",
      "echo MOUNTING S3 BUCKET",
      "sudo apt-get install automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config -y",
      "git clone https://github.com/s3fs-fuse/s3fs-fuse.git",
      "cd s3fs-fuse && ./autogen.sh && ./configure --prefix=/usr --with-openssl",
      "make",
      "sudo make install",
      "sudo mkdir -p /${aws_s3_bucket.main.id}",
      "sudo chmod -R 775 /${aws_s3_bucket.main.id}",
      "sudo chown jenkins:jenkins -R /${aws_s3_bucket.main.id}/*",
      "echo \"s3fs#${aws_s3_bucket.main.id} /${aws_s3_bucket.main.id} fuse _netdev,allow_other,nonempty,iam_role=${aws_iam_role.ec2.name},endpoint=${var.aws_region},url=http://s3.${var.aws_region}.amazonaws.com 0 0\" | sudo tee -a /etc/fstab",
      "echo CLEANING UP",
      "rm -rf /home/ubuntu/init.groovy",
      "rm -rf /home/ubuntu/plugins.yaml",
      "rm /home/ubuntu/packages-microsoft-prod.deb",
      "rm /home/ubuntu/jenkins-plugin-manager-2.9.0.jar",
      "rm -rf s3fs-fuse",
      "echo RESTARTING",
      "sudo shutdown -r +0"
    ]
  }
}