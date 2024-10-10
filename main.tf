variable "google_credentials" {
  default = <<EOF
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "your-email@your-project-id.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/your-email%40your-project-id.iam.gserviceaccount.com"
}
EOF
}

provider "google" {
  project = "cicd-project-438005"
  region  = "asia-northeast1"
  credentials = var.google_credentials
}


# Define the GKE cluster
resource "google_container_cluster" "primary" {
  name     = "terraform-autoscale-cluster"
  location = "asia-northeast1"
  initial_node_count = 1  # Still needed for the cluster itself, but the node pool is defined separately
  
  # Enable cluster autoscaling
  remove_default_node_pool = true  # Remove the default node pool to define a custom one
}

# Define the node pool with autoscaling enabled
resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 1

  autoscaling {
    min_node_count = 1     # Minimum number of nodes
    max_node_count = 3     # Maximum number of nodes
  }

  node_config {
    machine_type = "e2-micro"     # Define node machine type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  # Define auto-scaling based on CPU utilization
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}
