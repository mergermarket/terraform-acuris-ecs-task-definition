resource "aws_ecs_task_definition" "taskdef" {
  family                = var.family
  container_definitions = "[${join(",", var.container_definitions)}]"
  task_role_arn         = var.task_role_arn
  execution_role_arn    = var.execution_role_arn
  network_mode          = var.network_mode
  tags                  = var.tags

  volume {
    name      = lookup(var.volume, "name", "dummy")
    host_path = lookup(var.volume, "host_path", "/tmp/dummy_volume")
  }

  dynamic "volume" {
    for_each = length(var.volume_configured_at_launch) > 0 ? [var.volume_configured_at_launch] : []
    content {
      name                = volume.value
      configure_at_launch = true
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraint_on_demand_only == true ? [1] : []
    content {
        type       =  "memberOf"
        expression = "attribute:lifecycle == on-demand"
    }
  }
}

