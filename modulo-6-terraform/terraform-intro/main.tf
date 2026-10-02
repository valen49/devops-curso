resource "local_file" "saludo" {
  filename = "${path.module}/saludo.txt"
  content  = "Hola desde Terraform, ${var.nombre}!"
}
