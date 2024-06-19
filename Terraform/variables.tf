variable "service" {
  description = "The name of the service"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "The location (e.g., uksouth, ukwest)"
  type        = string
}

variable "instance" {
  description = "The instance identifier (e.g., 01, 02)"
  type        = string
}

variable "acr_sku" {
  type        = string
  description = "ACR SKU: Standard/Premium"
  default     = "Standard"
}

variable "cosmosdb_sqldb_name" {
  type        = string
  description = "Cosmos DB SQL DB name"
  default     = "todoapp"
}

variable "cosmosdb_container_name" {
  type        = string
  description = "Cosmos DB container name"
  default     = "tasks"
}

variable "throughput" {
  type        = number
  description = "Cosmos DB RU throughput"
  default     = 400
}

variable "uai_name" {
  type        = string
  description = "Managed Identity Name"
  default     = "aks-msi"
}

variable "address_space" {
  type        = list(string)
  description = "VNET Address Space"
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "Subnet prefixes"
  default     = ["10.0.0.0/24"]
}

variable "vm_size" {
  type        = string
  description = "AKS Node Size"
  default     = "Standard_B2s"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the Node Pool"
  default     = 2
}

variable "metric_labels_allowlist" {
  description = "A list of metric labels that are allowed to be collected and displayed in Grafana. If null, all metric labels will be collected."
  default     = null
}

variable "metric_annotations_allowlist" {
  description = "A list of metric annotations that are allowed to be collected and displayed in Grafana. If null, all metric annotations will be collected."
  default     = null
}

variable "grafana_version" {
  description = "The version of Grafana to deploy"
  type        = number
  default     = 9
}

variable "grafana_sku" {
  description = "The SKU (pricing tier) of the Azure managed Grafana instance. Common values are 'Standard' or 'Essential'."
  type        = string
  default     = "Essential"
}
