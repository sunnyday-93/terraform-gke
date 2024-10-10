variable "google_credentials" {
  default = <<EOF
{
  "type": "service_account",
  "project_id": "cicd-project-438005",
  "private_key_id": "b27c5e398a0531b8f98365fdec8d9b80e57a6097",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCisFBcvQIHGSm4\nzJGt80kz5vQf6b3Jlkkv6TgsSEAXvQaMJ9UXZE0d+JhSiYd8142riP+ME78FgBSa\nhO3B/MJ9LeFTD11Z6cTxxvYIYt2DPY5FWBaCSjocoVg5KOeBg0wQ8QNs1fsmoXl7\n5HwTL+zfy9CojH1FfP4lk4m4/DDRxlJv6mbKeTdzxh5JXj6LFOtOrDhEhTzy0dB9\nght1bQwfdbPf0raZ8c1FBKVuwr9LjM5jCFKUV8LvScvfLxjjWxKV7KL+DvXYYbb6\nhP3nkTcdAe5UYNQZaAnBs3iW5MHJnReI/phBmjzCuLg3jsMr4de+6x2hK9ZpOFUm\nDbTlcaspAgMBAAECggEAHXfHuqCOsTf013EQcxxl1kWfUvd85bp3y7qX7udwWoxl\n1vWxEqFbmZHpj0uzc6C8m8U/GoGKIGYsdTeeNDzDArcQgQG/tDVUc8HI10iHHIpG\nDpfvzc5Bm+V6rDHVSx974/av2uMgcIUfktoWQkh0RK4vf5Qg7bj/9ND2SYA+nIRg\nb4wbxx9cuFOWGpnvUC+s0DRGN25RAUxynxvAboZ9cZJ2UVl2wFgvIwtYPBcVk41q\nY3+eOgrjAA70oQ3S0PdtNtXmH34P9TeCoEOtM7xyviIiBm/+dVtkUBgrvt90aFfD\nXcu363q1lpjrWkO3qGq/VCGuNzUajMrm29V4pEYF3QKBgQDV4onOJsljyFHxuWV6\nvYNIX/dg+sDNMLGyQo2rxOyC72qcrDaFVEU7wcOCqvPRl5HdwIRmC4bu1+Tw3Px6\nVpAFFAam6D/CA3/k0OwiPlThxxRsu2wGp3DaBcFu3vLCfp6Gv1dutNspGMn9Gsn2\nigmBSuqTrXRaPOjncS8ZhzsZRQKBgQDCuRcB4qkpO43T7ziH5CB0aaJHsysmSYPx\nD1XxwEduSeLnzfA4gDL8vifqCFThNq8nf+WgpD6n5NLUqEUoZCA/zFRkCKZ+OLXE\nCrgqqcbnVUXPAXfb5xo4tg2R5if1ifOW7V/k4tE+j91s8wFjvVO8ei4yUpO1IU61\nTf6Vdux+lQKBgGAwy80dAIGRu9i8inkS9hH8puLEoyUk+yWybMiNfdi9F/NyN+rq\npWBkmisP+yuNwRo71M+X641LJzl0CVBz0b2W7g7ucI4uyLv9gdU8tyv7PqJQABtV\n/pju8bmNJxx1mZH8R7QQPmhTL7RW8fGgzvmI2cqkvak/r3c3HfmbKecJAoGANmcL\n3IT9Cf4Pg/TD8IN15dBVfH68QXgsmr7UHjTAQDn4YRcSVFbM5/wgnqwxOrLSgNCk\n0RrSPooZtTxGBiDjOa/WrBQWoBEsB1ePWKwSXDNgy5L3b8LDerCyXd7Vry4ZlkM/\nlW0hVL9Q9810x+7vZCsmmPylM+fYW6Msy4lsTXkCgYEAvQKWo+9N2/gBKCrdFYRH\n8inyOCAe47teFY6NNuBwKs4s8/t0SydkkE7JlDjJ2vOWNVzOwjQHJ5FiIlzVBh1N\n8hHyjLWEkeITDTeerciMPW8AzaoPSWzFzQc8MKrm+Aj9nSK+Iop4Vmg9EF4N6ToF\nFojg8jlJDbJ6CqA4irnS3yE=\n-----END PRIVATE KEY-----\n",
  "client_email": "terraform-sa@cicd-project-438005.iam.gserviceaccount.com",
  "client_id": "112155506095874028556",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/terraform-sa%40cicd-project-438005.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
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
