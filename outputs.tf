output "id" {
  description = "The resource ID of the VM Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "name" {
  description = "The name of the VM Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

output "unique_id" {
  description = "The unique ID of the VM Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.this.unique_id
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned identity."
  value       = try(azurerm_linux_virtual_machine_scale_set.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the managed identity."
  value       = try(azurerm_linux_virtual_machine_scale_set.this.identity[0].tenant_id, null)
}

output "autoscale_setting_id" {
  description = "The autoscale setting resource ID."
  value       = try(azurerm_monitor_autoscale_setting.this[0].id, null)
}
