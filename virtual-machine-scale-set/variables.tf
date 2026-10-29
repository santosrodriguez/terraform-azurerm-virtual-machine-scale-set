variable "name" {
  description = "Name of the VM Scale Set."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the VMSS will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the VMSS."
  type        = string
}

variable "sku" {
  description = "Azure VM size for the scale set."
  type        = string
}

variable "instances" {
  description = "Initial number of VMSS instances."
  type        = number
  default     = 2

  validation {
    condition     = var.instances >= 0
    error_message = "instances must be greater than or equal to 0."
  }
}

variable "zones" {
  description = "Availability zones for the VMSS."
  type        = list(string)
  default     = []
}

variable "admin_username" {
  description = "Admin username for the VMSS instances."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user."
  type        = string
  sensitive   = true
}

variable "computer_name_prefix" {
  description = "Computer name prefix for VM instances."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID where the VMSS NICs will be attached."
  type        = string
}

variable "network_interface_name" {
  description = "Name of the VMSS NIC configuration."
  type        = string
  default     = "nic-01"
}

variable "ip_configuration_name" {
  description = "Name of the VMSS IP configuration."
  type        = string
  default     = "ipconfig-01"
}

variable "backend_address_pool_ids" {
  description = "Optional list of Load Balancer backend address pool IDs."
  type        = list(string)
  default     = []
}

variable "application_gateway_backend_address_pool_ids" {
  description = "Optional list of Application Gateway backend pool IDs."
  type        = list(string)
  default     = []
}

variable "enable_ip_forwarding" {
  description = "Enable IP forwarding on the VMSS NIC."
  type        = bool
  default     = false
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on the VMSS NIC."
  type        = bool
  default     = false
}

variable "os_disk_caching" {
  description = "Caching type for the OS disk."
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "os_disk_caching must be one of None, ReadOnly, ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk."
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition = contains([
      "Standard_LRS",
      "StandardSSD_LRS",
      "Premium_LRS",
      "Premium_ZRS"
    ], var.os_disk_storage_account_type)
    error_message = "Invalid os_disk_storage_account_type."
  }
}

variable "source_image_reference" {
  description = "Marketplace image reference."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "source_image_id" {
  description = "Custom image ID. Use this instead of source_image_reference."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64-encoded cloud-init or custom data."
  type        = string
  default     = null
  sensitive   = true
}

variable "identity_type" {
  description = "Managed identity type. Valid values: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition = contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity_type)
    error_message = "Invalid identity_type."
  }
}

variable "user_assigned_identity_ids" {
  description = "List of user-assigned identity IDs when using UserAssigned identity."
  type        = list(string)
  default     = []
}

variable "upgrade_mode" {
  description = "VMSS upgrade mode."
  type        = string
  default     = "Rolling"

  validation {
    condition     = contains(["Automatic", "Manual", "Rolling"], var.upgrade_mode)
    error_message = "upgrade_mode must be Automatic, Manual, or Rolling."
  }
}

variable "overprovision" {
  description = "Enable overprovisioning."
  type        = bool
  default     = false
}

variable "single_placement_group" {
  description = "Whether the VMSS uses a single placement group."
  type        = bool
  default     = false
}

variable "platform_fault_domain_count" {
  description = "Fault domain count for the VMSS."
  type        = number
  default     = null
}

variable "provision_vm_agent" {
  description = "Whether the Azure VM agent should be provisioned."
  type        = bool
  default     = true
}

variable "health_probe_id" {
  description = "Optional load balancer health probe ID."
  type        = string
  default     = null
}

variable "boot_diagnostics_storage_account_uri" {
  description = "Storage account blob endpoint URI for boot diagnostics. Leave null to disable."
  type        = string
  default     = null
}

variable "enable_automatic_updates" {
  description = "Whether to enable automatic OS updates."
  type        = bool
  default     = true
}

variable "disable_password_authentication" {
  description = "Disable password authentication."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the VMSS."
  type        = map(string)
  default     = {}
}

variable "autoscale" {
  description = "Optional autoscale configuration."
  type = object({
    enabled                            = bool
    min_capacity                       = number
    max_capacity                       = number
    default_capacity                   = number
    scale_out_cpu_threshold_percentage = number
    scale_in_cpu_threshold_percentage  = number
  })
  default = {
    enabled                            = false
    min_capacity                       = 2
    max_capacity                       = 5
    default_capacity                   = 2
    scale_out_cpu_threshold_percentage = 75
    scale_in_cpu_threshold_percentage  = 25
  }
}
