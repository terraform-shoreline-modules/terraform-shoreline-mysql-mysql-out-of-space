resource "shoreline_notebook" "mysql_service_out_of_space" {
  name       = "mysql_service_out_of_space"
  data       = file("${path.module}/data/mysql_service_out_of_space.json")
  depends_on = [shoreline_action.invoke_database_health_check,shoreline_action.invoke_remove_duplicates_and_optimize_table]
}

resource "shoreline_file" "database_health_check" {
  name             = "database_health_check"
  input_file       = "${path.module}/data/database_health_check.sh"
  md5              = filemd5("${path.module}/data/database_health_check.sh")
  description      = "The database is not being properly optimized, leading to inefficiencies and excessive use of storage space."
  destination_path = "/agent/scripts/database_health_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "remove_duplicates_and_optimize_table" {
  name             = "remove_duplicates_and_optimize_table"
  input_file       = "${path.module}/data/remove_duplicates_and_optimize_table.sh"
  md5              = filemd5("${path.module}/data/remove_duplicates_and_optimize_table.sh")
  description      = "Optimize the database by removing duplicate or unused data, which will reduce storage requirements."
  destination_path = "/agent/scripts/remove_duplicates_and_optimize_table.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_database_health_check" {
  name        = "invoke_database_health_check"
  description = "The database is not being properly optimized, leading to inefficiencies and excessive use of storage space."
  command     = "`chmod +x /agent/scripts/database_health_check.sh && /agent/scripts/database_health_check.sh`"
  params      = ["DATABASE_USERNAME","DATABASE_NAME","DATABASE_PASSWORD"]
  file_deps   = ["database_health_check"]
  enabled     = true
  depends_on  = [shoreline_file.database_health_check]
}

resource "shoreline_action" "invoke_remove_duplicates_and_optimize_table" {
  name        = "invoke_remove_duplicates_and_optimize_table"
  description = "Optimize the database by removing duplicate or unused data, which will reduce storage requirements."
  command     = "`chmod +x /agent/scripts/remove_duplicates_and_optimize_table.sh && /agent/scripts/remove_duplicates_and_optimize_table.sh`"
  params      = ["DATABASE_USERNAME","TABLE_NAME","DATABASE_NAME","DATABASE_PASSWORD"]
  file_deps   = ["remove_duplicates_and_optimize_table"]
  enabled     = true
  depends_on  = [shoreline_file.remove_duplicates_and_optimize_table]
}

