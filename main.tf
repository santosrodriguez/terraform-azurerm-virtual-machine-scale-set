locals {
  computer_name_prefix = coalesce(var.computer_name_prefix, substr(replace(var.name, "/[^a-zA-Z0-9]/", ""), 0, 9))
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = var.sku
  instances                       = var.instances
  zones                           = length(var.zones) > 0 ? var.zones : null
  admin_username                  = var.admin_username
  computer_name_prefix            = local.computer_name_prefix
  disable_password_authentication = var.disable_password_authentication
  provision_vm_agent              = var.provision_vm_agent
  upgrade_mode                    = var.upgrade_mode
  overprovision                   = var.overprovision
  single_placement_group          = var.single_placement_group
  platform_fault_domain_count     = var.platform_fault_domain_count
  health_probe_id                 = var.health_probe_id
  user_data                       = var.user_data

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.user_assigned_identity_ids : null
    }
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == null && var.source_image_reference != null ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  source_image_id = var.source_image_id

  network_interface {
    name                          = var.network_interface_name
    primary                       = true
    enable_ip_forwarding          = var.enable_ip_forwarding
    enable_accelerated_networking = var.enable_accelerated_networking

    ip_configuration {
      name      = var.ip_configuration_name
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids          = length(var.backend_address_pool_ids) > 0 ? var.backend_address_pool_ids : null
      application_gateway_backend_address_pool_ids    = length(var.application_gateway_backend_address_pool_ids) > 0 ? var.application_gateway_backend_address_pool_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  automatic_os_upgrade_policy {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = var.enable_automatic_updates
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT2M"
    prioritize_unhealthy_instances_enabled  = true
    cross_zone_upgrades_enabled             = true
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = (var.source_image_id == null && var.source_image_reference != null) || (var.source_image_id != null && var.source_image_reference == null)
      error_message = "Specify exactly one of source_image_id or source_image_reference."
    }

    precondition {
      condition     = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? length(var.user_assigned_identity_ids) > 0 : true
      error_message = "user_assigned_identity_ids must be provided when using UserAssigned identity."
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "this" {
  count               = var.autoscale.enabled ? 1 : 0
  name                = "${var.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "default"

    capacity {
      minimum = tostring(var.autoscale.min_capacity)
      maximum = tostring(var.autoscale.max_capacity)
      default = tostring(var.autoscale.default_capacity)
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.autoscale.scale_out_cpu_threshold_percentage
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.autoscale.scale_in_cpu_threshold_percentage
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }

  tags = var.tags
}
