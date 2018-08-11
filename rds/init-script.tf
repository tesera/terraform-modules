data "template_file" "pgsql" {
  template = "${file("${path.module}/pgsql_template.sh")}"

  vars {
    SSH_KEY_FILE_NAME = "${var.bastion_ssh_key_filename}"
    BASTION_USERNAME  = "${var.bastion_username}"
    BASTION_IP        = "${var.bastion_ip}"
    DB_HOST           = "${aws_db_instance.main.address}"
    DB_PORT           = "${aws_db_instance.main.port}"
    DATABASE_NAME     = "${local.db_name}"
    DB_INITFILENAME   = "${var.db_init_filename}"
  }
}

resource "local_file" "pgsql" {
  content  = "${data.template_file.pgsql.rendered}"
  filename = "${path.cwd}/pgsql.sh"
}

resource "null_resource" "docker" {
  # Changes to db_init_filename will execute the script
  triggers {
    files = "${md5(file("${path.cwd}/${var.db_init_filename}"))}"
  }

  provisioner "local-exec" {
    command = "docker run --rm -v ${path.cwd}:/data -e PGPASSWORD=${var.password} -e PGUSER=${var.username} -e USE_BASTION=${var.bastion_ip == "" ? "false" : "true"} kkirov/psql-ssh:latest /bin/bash /data/pgsql.sh"
  }
}
