resource "shoreline_notebook" "cassandra_compaction_executor_blocked_tasks" {
  name       = "cassandra_compaction_executor_blocked_tasks"
  data       = file("${path.module}/data/cassandra_compaction_executor_blocked_tasks.json")
  depends_on = [shoreline_action.invoke_cassandra_config_check,shoreline_action.invoke_cassandra_compaction_executor]
}

resource "shoreline_file" "cassandra_config_check" {
  name             = "cassandra_config_check"
  input_file       = "${path.module}/data/cassandra_config_check.sh"
  md5              = filemd5("${path.module}/data/cassandra_config_check.sh")
  description      = "Configuration issues: Incorrect configuration of the Cassandra cluster or executor can cause tasks to block."
  destination_path = "/agent/scripts/cassandra_config_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cassandra_compaction_executor" {
  name             = "cassandra_compaction_executor"
  input_file       = "${path.module}/data/cassandra_compaction_executor.sh"
  md5              = filemd5("${path.module}/data/cassandra_compaction_executor.sh")
  description      = "Restarting the Cassandra compaction executor can help resolve the issue, as it can clear any stuck tasks and ensure the smooth functioning of the system."
  destination_path = "/agent/scripts/cassandra_compaction_executor.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cassandra_config_check" {
  name        = "invoke_cassandra_config_check"
  description = "Configuration issues: Incorrect configuration of the Cassandra cluster or executor can cause tasks to block."
  command     = "`chmod +x /agent/scripts/cassandra_config_check.sh && /agent/scripts/cassandra_config_check.sh`"
  params      = ["PATH_TO_CASSANDRA_LOG","PATH_TO_CASSANDRA_CONFIG"]
  file_deps   = ["cassandra_config_check"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_config_check]
}

resource "shoreline_action" "invoke_cassandra_compaction_executor" {
  name        = "invoke_cassandra_compaction_executor"
  description = "Restarting the Cassandra compaction executor can help resolve the issue, as it can clear any stuck tasks and ensure the smooth functioning of the system."
  command     = "`chmod +x /agent/scripts/cassandra_compaction_executor.sh && /agent/scripts/cassandra_compaction_executor.sh`"
  params      = []
  file_deps   = ["cassandra_compaction_executor"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_compaction_executor]
}

