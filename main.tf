provider "google" {
  project = "cicd-project-438005"
  region  = "asia-northeast1"
  credentials = file({
  "type": "service_account",
  "project_id": "cicd-project-438005",
  "private_key_id": "ba31122fa03e6530f984e0b03688ae2b3c04f768",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCIyIRdCEjmqWpA\neCuSwClbOBaE3wXTnpr4KlljprogTG9yUU4/X1+5YWyWnuN3eA09mTUO/dY75IfJ\nTC3mf56cmGd2CIIOaM/cHc72Hd4NSaHHMl9YE7c8FAHjO0T+itFDqeqLfUuse5oJ\nzdIo7pKdDTk9gRRTkOHynKRlM5L2xcBKQvmy4LSGFC1rVu9hIiC++vFPyCcqZ2wR\nN9C88a8G0Y5gkm1QdbFP1T42+mGu3Kt5M4LwRtfIUV2nkADvFQSEUz6HL35YX3Wc\nbnwVWk6PPIbjOcQKcKVJPGpZ4yIqu3Y61wqo2yO/bXMjPRKOmc9ZUcD482c0g1dH\nYEdmqpXXAgMBAAECggEAFO5rru7fH7O/fNkcKzX5E3/xlj3+CW8FHkJ2G7U+WJtJ\nwfp7g7VyaQ8QYRDfFH+htbzrAn3JRFte2hOBwfriiJUb3qiY+l/YpcGb/kv+GGty\n9GVwHgLPsJkL3DwhfTrnS2Lw740/a3LIqi+9tXd4pnbeZ7EygpfdCQAmeg7FMmTs\nQW0+7KS84ttgEY5/jsOiHp/DhDkmrywjHMYMgFDZFg0w6EwJt0LsngYtV/IT46Xm\nzDVxm6BTUcRzjyl+hD5tMnEH5yaM8lamBe9mKJ+8MNlYi9msYqj4xxnfX8L/OFmK\nB8o2wNFzXYtaTsVS/pKJnRhPl6VVmd7rFFkS4PByHQKBgQC9sJL/Zof6phIxvG45\nX41swp15Tx0gavBfRY0ebq8/JaBov+NHeq5WwHrzaNpxf9RfAI5MQgk1RFP23K1e\nBynUegw2uo0ORxfqUQfqPQIzuc0eHddxSov0IEF8xtEz+kZZ2LHLOkuwt+kGndpb\nFb7n/599VZ+F2hGdrf3c3llItQKBgQC4mVE2+0dz1AMd4KmbVk+VtYyiOlUJ7jIX\ndrCFs6d7RXCZIF1GmnOo+EnZG4KSeqNw6Eqq6c3WzuyXsr1+wSVDAElckWFjx4S9\nGlhco5RdVzKcwCMVhkZ/fgsG/bj+HyXwhl6mu22KlPQXyYmosNEQEwl1JcYP5CVZ\n7YywyhC32wKBgQC9eb4rvYgAV5h+88CKMKb8x50yylLGyesWz0t55YfJpNUJLPti\nr+mrIBLwRoFEtDI3Pz/kbmXyPjE8ugu2i6M96TeAB3HUnDEITi6AzLYBYwu/lIFa\nWeNYVEv1zka0C7/wCSL3ZGCswdfTUyQErcEGznDKahexRTUpct3MnJFErQKBgBPs\nMBCwA+EjU4bI9WUXZpVwt5HWm9DrjSptG9YCMqQiNWnBTW/OQYdN7KJqzqfCZptL\n5qsVeqqhQHWKy9q/O6dEg6Zi5lDfepryGfE9kkiUnZi/P8oV6MvfrY7+mRWMBQs1\nZUe3WLYpJ0Ld9GZpVtbWRyIGhp62b7WJ5rI5zJ4bAoGAaGqz8aRhGEyaXgKs8IRs\ngnqxyOvwfv8QRs7Rd1yw8XVck5Aa2qGZ8GWZ94JdZDhlEq3Jy8uxooeGGBz7CeWh\nmAO9fF6xhkzvTSkbj0+emCN8j6eoVsFN+xifKjjmlA+/ddr27zBFDSABusN3P8AD\nSQ5wGOoTJUNNz5pZAoR/kNU=\n-----END PRIVATE KEY-----\n",
  "client_email": "terraform-sa@cicd-project-438005.iam.gserviceaccount.com",
  "client_id": "112155506095874028556",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/terraform-sa%40cicd-project-438005.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
})
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
