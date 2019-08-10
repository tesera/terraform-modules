data "template_file" "pgsql" {
  count    = var.bootstrap_folder == "" ? 0 : 1
  template = file("${path.module}/pgsql_template.sh")

  vars = {
    SSH_IDENTITY_FILE   = var.ssh_identity_file
    SSH_USERNAME        = var.ssh_username
    BASTION_IP          = var.bastion_ip
    DB_HOST             = local.endpoint
    DB_PORT             = local.port
    DATABASE_NAME       = local.db_name
    INIT_SCRIPTS_FOLDER = var.bootstrap_folder
  }
}

resource "local_file" "pgsql" {
  count      = var.bootstrap_folder == "" ? 0 : 1
  content    = data.template_file.pgsql[0].rendered
  filename   = "${path.cwd}/pgsql.sh"
  depends_on = [aws_rds_cluster_instance.main]
}

data "archive_file" "init_scripts" {
  count       = var.bootstrap_folder == "" ? 0 : 1
  type        = "zip"
  output_path = "${path.cwd}/init_sql_script.zip"
  source_dir  = var.bootstrap_folder
}

resource "null_resource" "docker" {
  count = var.bootstrap_folder == "" ? 0 : 1

  # Changes to the files in init_scripts_folder will execute the script
  triggers = {
    scripts_hash = data.archive_file.init_scripts[0].output_base64sha256
    script       = md5(local_file.pgsql[0].content)
  }

  provisioner "local-exec" {
    command = "docker run --rm -v ${path.cwd}:/data -e PGPASSWORD=${var.password} -e PGUSER=${var.username} -e USE_BASTION=${var.bastion_ip == "" ? "false" : "true"} tesera/psql-ssh:latest /bin/bash /data/pgsql.sh"
  }
}

