#create a resource group
resource "azurerm_resource_group" "ficky-group" {
  name     = "ficky-resources"
  location = "East US"
}

#create ACR
resource "azurerm_container_registry" "acr" {
  name                = "fickyacr"
  resource_group_name = azurerm_resource_group.ficky-group.name
  location            = azurerm_resource_group.ficky-group.location
  sku                 = "Standard"
}

#Create AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "ficky-aks1"
  location            = azurerm_resource_group.ficky-group.location
  resource_group_name = azurerm_resource_group.ficky-group.name
  dns_prefix          = "fickyaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

#create role assignment for AKS
resource "azurerm_role_assignment" "acrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

