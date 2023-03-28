# The AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.name}aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.main_rg.name
  node_resource_group = "${var.name}-node-rg"
  dns_prefix          = "${var.name}dns"
  kubernetes_version  = var.kubernetes_version

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                 = "agentpool"
    node_count           = var.agent_count
    vm_size              = var.vm_size
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.id
    }

    ingress_application_gateway {
      enabled   = var.addons.ingress_application_gateway
      subnet_id = azurerm_subnet.app_gwsubnet.id
    }
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  role_based_access_control {
    enabled = var.kubernetes_cluster_rbac_enabled

    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.aks_admins_group_object_id]
    }
  }

  provisioner "local-exec" {
    command = "az aks get-credentials -g ${self.resource_group_name} -n ${self.name} && kubelogin convert-kubeconfig -l azurecli"
  }
}

# Access the Resource Group created automatically for the AKS nodes
data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
  # depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  # depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = azurerm_resource_group.main_rg.id
  role_definition_name = "acrpull"
  # depends_on = [azurerm_kubernetes_cluster.k8s]

  provisioner "local-exec" {
    command = "kubectl create -f deployment.yml"
  }
}
