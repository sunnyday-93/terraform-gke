variable "google_credentials" {
  default = <<EOF
{
  "type": "service_account",
  "project_id": "cicd-project-438005",
  "private_key_id": "6f4e3862b61c72da3e59654d32051e3272477deb",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCp2Ey9jH8wTQud\nidawjEBeZk1eXHNUld0S3fpJ1ok0JMKKGb5b88xKArvjz3IcnEjE6h0N2kh2h7Ng\nVfGgcmNj1COxvYmOpuVrZ6Kd2P07Rw6R9x8d9kwcFgBfiud6rtGHesPE8lINRgIH\nfoacMTCMBJXtWAkgc+IdHyQBRF/PpBZXmgVBJMKDLQ0ttJFmgG3viM39HlFXRkn7\np+WLM+FPAsU1pmhtJjRhZgbVYcaWLnBE9a7UrJtf4iuX+C8pSX6CLAFWvoRFM9/j\nNAoTIuvauvIcVVL2Hq2kbDlbaVOilk9sMClyhBG+skYCVfFp2l9cplgv4pPOGIA+\nIY8TjZ0TAgMBAAECggEARvZ+qbun8JBgSAQtVTpkMozfyosqDK9I3Pct+efPD6BE\nP9sds+Ga+1lFE5u6+8U4ij2ewgjvucZc5eVCvVzNtgoOl9avQJDuzf9Q7E6bD0dT\nCR2NPMGJbzqqEUFCEfo0xTw/y2vLaIxVkLgGmf/bXsUTt0TPG2YPlUdLjdP5jBE+\nb98YESVVvfVnoN7xFyX58uz9nIoIULMhCAxN1hSq/BiPD6y1oeRNr5yAAbUTNcQy\nuSgRH1YH3DInZc7/Y0+vV5wYynS9ZcRVNi1RjQ/HyzII65z2nagsxdfRbRHkiFe+\nCZhHuJ7wGvKI0KFcB5dgCQMQqS0COjkFUN7fQXE98QKBgQDaLvrMBGKTbZGFmLqp\nxqWYjDq5xKTNquWihGMmQ0P02oBtCnuIBORufzZnTdEAxDLoco7TYzsHR3Uk0e7j\nW+z9+vm1NaoIEWPW8zqxYui0R1MOLeoBTknT1za6fxM4vvri0/hfTvWQNFhPj5tu\nHgTrbVYHh1Bl5tVhkxVnYQiPnwKBgQDHSH0LH/MqXD1LIJxRz9f7K0HOzDudVuTC\nz4gBqCLF/D7GtiLhUV7j7sSwxH5YoeCGhN7qyAs/5PLyxEGaw0EQvKRMQUOua+3Z\niDrxadpS2QC/snRZIRCIOGH8ZL9mR2XjF7gt57v5SUGZ0vLwQv65SJtpNQ4nxwh8\nYrhijphuDQKBgQC/JpOxdFIMydzJh/JZ1eC00n6MzHx6d7Qx+vyGxD3gYiJL5fgu\nReL/79HxFZr7qejT/7Gj/3byvKcj+AzsAliSd3SYTwjFgr7Ozk/oozgu4aIhdRZj\nyHwj7ZRUNgrYF3HkkkMy9RFtIn8QTUemZQR4YlURyXolnOPrVZpV9Qw0DwKBgAXA\nzftYPMjoSMy2cEzcVzvlD81MkBwGuiv1mdOSaw6ULavG7lLa6oZiCkOgKJWedsDr\nbRQSGmEJ1wmzKMGzCVnWWFfrOmz6qK8zA6CckbT6ls7x8/Huxm9oUUvcDLqDLSnV\nMXgBzKdxufca4/CTvo7SzcnHwlTbph8RKomN3FCxAoGAUg6ukh6P57H7hfyPqAXQ\nXr6XJUNHL0RFB3yKUFMnKVNufDjQDzZmS0O2fIw82xd9fJQ20ykck5oY75PkAwNT\nyBOgytgqsLjbeypqKU17RS7JJ6IsLR8JKMt+fI1d1WaiRbwWGZGKj7BjMCj9suzG\nlyU4n4z4zYK4l/XHaOgYOEo=\n-----END PRIVATE KEY-----\n",
  "client_email": "terraform-sa@cicd-project-438005.iam.gserviceaccount.com",
  "client_id": "112155506095874028556",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/terraform-sa@cicd-project-438005.iam.gserviceaccount.com",
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
