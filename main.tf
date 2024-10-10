variable "google_credentials" {
  default = <<EOF
{
  "type": "service_account",
  "project_id": "cicd-project-438005",
  "private_key_id": "1c4e27bc3b3b5d6f1f6d5d56af82d3c124f136de",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCucn6UKlnIp7q2\nRjt6DnOL4DWywe/I4oTe/J0uzDqKf04rk7j/EXzZBgwTS3hCg5y0NpI5mmCWVR32\nD63RiZB1XbptzeMOZH5a1NdfhNbHbd0q2NUS2Em7LYdCAnUUf4XRmSfsDcvVcjIC\nzLePy/OFl4u9NREDZeM7VABN21u+2hJUvRhslfNrapGHmlwsBksKp5f7HM2HDkOG\nVX9A+lb++MHZ8mNzz/zSrxy1cXCWBusxIwsG01/4uU1NGUyFHilwEngEtTFC+5PR\nivS82pWF+8Dnhgs1c7rM+8AJj1JXYv8rn2+6unPblbT+VnrlL6DPgRAKPdy5829F\n+lJs6cUvAgMBAAECggEAAZIjOV8w1BGWlq+ZN4KU8lo3OG3cEjBNtSPCoEyKNmlX\n6m339uwH0erCKoG95epKVxfz2WrwmknzWvlymRqUcbfT64IQHKSjThHMS9UvG6YN\nwe8ofSvz/yh+gpgWNqsuuyjfeUzUyg5Bnwf5v8AqjMhpkUq+nFUUZpo45ehLn+ot\njySkGh//gQYGk4UJ5t4fDaB1OKg0H8J7YWlAK4XVG7E0RgrTo55d8NA/lZXWerbn\nizs+/ClqywqOOuLs8vqd1YOAEhhgPr3gG5cm7qGBNkgSD5hP9pDONMLu4cbnZFAr\noBFY8Y3V9queSkJ9PFYTYZS75XN9HmyBIeQVj72RqQKBgQDVfAHwoO91QCMugU/k\nz3ejXkuo32T2LSajKW27xfO4tVVR7EpABWXyKIPgn0zvvNKOJ4G7lL9RHDeKsFoH\nYGVLx4NPs80+oBLaRLrJOdyh6W6oTZRa6WaMWJr9G9bmSrh0kaoEviyJyg6YgiCc\nA/zatUx07ZTsc93IDxKJhBkoIwKBgQDRMEU+RLJ9el8MF2A4kGqfWsUp7iviBqnX\nz5Y0zIQVKtPZ2lcoQfqP4oq+m0IJAYE3+3fR9uR7+nknD4LL2L+zpd+W7EIXVXSo\nTluvyfHPwumIC582NMn7BWPz4xeoz3F+SjbqcMhgNmVK5FrGqbk/lubvjzNB3WTb\np+hVCemZhQKBgQCRSGspjtxnNta6d1YfqPEKRMnIiv7yaZe5wh/jgbtzIDSII/4D\nw6i1O81DuCVroVzJUSmAtqHcWQ+TWqBqFLfa8lPykbJDxDwQPmW/O5litrGP5/vm\nQqB/Mm2HgsKkxoTxD5Bc2e8FdnSoZSY8Bpq1XFxD1stafx+XXmqHG1bjcQKBgGY5\nan0FYRwEYtIr0i+SEyiQWO0moHcxvmnh3YsrrhgR97jsA89+fo01rYt7n4d7HsRW\ntLT8K6eSPQYjhE1NPFDz7BF6nsl8Tye4MwHyc6KNo0WCOGlq3pE2jyOtg/BQfyux\n5KgoOSMbMeCpOtr+MbKrcWr71ZaINDNLGDQGRgtpAoGBAJjmfQxom/FxqlG/Nxx6\nThVFaV3J+APfIBMmQs+xKWqeaAIhneK1bLi6BUiqTByEB37kTLPRG9wZ3/4/x+lQ\n0dWGsXe+oSQwmZvFIv40aUDQ4EywvNrmkjxJC0ri/yXnEt2neXPoXAyKqqsF5xAp\n+dbS0Qa4j60k+PemnM3mSWdi\n-----END PRIVATE KEY-----\n",
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
