output "ruta_archivo" {
  description = "Ruta del archivo de saludo creado"
  value       = local_file.saludo.filename
}
