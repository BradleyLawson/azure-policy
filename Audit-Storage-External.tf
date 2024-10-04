variable "namePolicy" {}
variable "displayNamePolicy" {}
variable "descriptionPolicy" {}
variable "mgmtGroupID" {}
variable "IPAddresses" {}
resource "azurerm_policy_definition" "policy" {
  name                = var.namePolicy
  policy_type         = "Custom"
  mode                = "All"
  display_name        = var.displayNamePolicy
  description         = var.descriptionPolicy
  management_group_id = var.mgmtGroupID
  metadata = jsonencode({
    category = "Storage"
  })
parameters = jsonencode({
            IPAddresses = {
              type = "Array"
              metadata = {
                displayName = "List of allowed IP addresses"
              },
              defaultValue = "${var.IPAddresses}"
            }
          })
 policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
          equals = "Enabled"
        },
        {
          not = {
            field = "Microsoft.Storage/storageAccounts/networkAcls.ipRules[*].value"
            in    = "[parameters('IPAddresses')]"
          }
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}