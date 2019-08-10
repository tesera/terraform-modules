data "template_file" "indices_script" {
  count    = var.bootstrap_file == "" ? 0 : 1
  template = file("${path.module}/create_indices_template.sh")

  vars = {
    SSH_IDENTITY_FILE      = var.ssh_identity_file
    SSH_USERNAME           = var.ssh_username
    BASTION_IP             = var.bastion_ip
    ELASTICSEARCH_ENDPOINT = aws_elasticsearch_domain.main.endpoint
    INDICES_CONFIG_FILE    = var.bootstrap_file
  }
}

resource "local_file" "indices_script" {
  count      = var.bootstrap_file == "" ? 0 : 1
  content    = data.template_file.indices_script[0].rendered
  filename   = "${path.cwd}/create_indices.sh"
  depends_on = [aws_elasticsearch_domain.main]
}

data "local_file" "indices_config" {
  count    = var.bootstrap_file == "" ? 0 : 1
  filename = "${path.cwd}/${var.bootstrap_file}"
}

data "local_file" "init_script" {
  filename = "${path.module}/indices.js"
}

resource "null_resource" "init" {
  count      = var.bootstrap_file == "" ? 0 : 1
  depends_on = [local_file.indices_script]

  triggers = {
    mappings    = md5(data.local_file.indices_config[0].content)
    init_script = md5(data.local_file.init_script.content)
  }

  provisioner "local-exec" {
    command = "docker run --rm -v ${path.cwd}:/data -v ${path.module}/indices.js:/data/indices.js -e USE_BASTION=${var.bastion_ip == "" ? "false" : "true"} tesera/node10-ssh:latest /bin/bash /data/create_indices.sh"
  }
}

