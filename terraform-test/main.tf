terraform {
  required_version = "0.12.20"
}

// How to work with JSON
// https://discuss.hashicorp.com/t/how-to-work-with-json/2345
locals {
  json_data = jsondecode(file("elasticache-redis-cluster-endpoints.json"))
}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = format("echo %s", length(local.json_data.ReplicationGroups[0].NodeGroups))
    interpreter = ["bash.exe", "-c"]
  }
}
