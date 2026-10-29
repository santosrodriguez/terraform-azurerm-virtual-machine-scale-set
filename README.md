## Example usage

```hcl
module "zscaler_cc_vmss" {
  source = "../../modules/vmss-linux"

  name                = "vmss-zscaler-cc-prd-01"
  resource_group_name = "rg-sec-prd-01"
  location            = "eastus2"
  sku                 = "Standard_D2s_v3"
  instances           = 2
  zones               = ["1", "2"]

  admin_username = "azureadmin"
  ssh_public_key = file("~/.ssh/id_rsa.pub")

  subnet_id = azurerm_subnet.cc.id

  source_image_reference = {
    publisher = "zscaler1579058425289"
    offer     = "zia_cloud_connector"
    sku       = "zs_ser_gen1_cc_01"
    version   = "latest"
  }

  marketplace_plan = {
    publisher = "zscaler1579058425289"
    product   = "zia_cloud_connector"
    name      = "zs_ser_gen1_cc_01"
  }

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.cc.id,
  ]

  identity_type = "SystemAssigned"

  tags = {
    environment = "prd"
    workload    = "zscaler-cloud-connector"
    managed_by  = "terraform"
  }
}
```
