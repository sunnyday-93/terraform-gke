variable "google_credentials" {
  default = <<EOF
{
  "type": "service_account",
  "project_id": "cicd-project-438005",
  "private_key_id": "25666f0bc648f590477ecb94ef608acd9374e818",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC0qMfFoYv7GHdn\n5cZ7UxRukAQtXWs2103oMcoMej46wquH04i4/CKyijSGzieiS/1gTnpaMzOKfh9K\nZMilcVznr/1+AuBKZkkZzt6uI7I33oBmrvXYP9cxcfTkrC+R9Re//QaGb2/K2aTM\n+3PCMHPBhRfTEL6g2do4Wd7iQeIkYgUbeyoqGgQYfz9d9JeQndd4AqSEaZtQIky4\ncYPPmD2XZQ+jmRspL+OESvgaCpLJtC02hUoBl7QP+bZwayvZimdVucUjwWghpbrE\nOYMmc7OBnfspKuZamC38Hx6UlmOwmCIaW5cUgA4xvqbHPKl9PhK+A753UgLJyE1n\nf1cG0AIvAgMBAAECggEAA1OOP7Q4ExrOuNUd8/X1Waaa/q89j6HXcRYlmotpROsb\nsTsMXx38kSppScgjw66MtXuMb8e8kOkkloz6tgBVDeQ+kYjoOOzfakzvhBsewQrL\ndQvCQnj4DRS3krq25eplq9oy7UIoN7INNKo2mSJyQMoJRJCGdtWI2ciR1lTdnv5x\n3LsCzymZoPoV44fzgkZexGfg5lNf/SMmxlWZO29gIDvlWqJXk7yUdumLtPRw44fh\nIh1dWKFQ5cRi7BwusuyOV++hOSvB1jhslwhKLLMQc0kcBIolwlXlnAsa1hkmNPo6\n5C+hSQurn3rgF9xh13JdrIK6cFy/VD67YZrRSgPOMQKBgQDywWJ4Za+aiTRvDXPy\nrnxkEY0ieeV8jqqhA9wKNt1ipcxiEkEFAZOV3i6ym5RKSqo3BNkgClwsZZwaZiMi\nij8UY8SG1am54RH7+CkfgEkNdWg00hWwfWbxoTh0OTgbVC8iZol5rTOnsy9tn3nC\n5gBqK3FE4SZ2SeJluLA4NmYIsQKBgQC+hBYedOvo6uUjWJOvwtJqmeU5cV8Ij/bv\nrk9YfockQqdh6LqglhtWedUykfg3EEhiLdVD9ID7SklvuRdNyj55g/boIUpyPXeB\njxjEhL6yXOuFn9YIYgctpQXVnQgLBejC8IiBWhy3Sop6EK9MNDVLopbFY659KbBl\nPvbmSnFw3wKBgQDLDRrynguudYmYQmZz3aNKiKvG5LMh5quulu3c1VuEgi5c8evU\n5iauuvPQjfYR1jZeYv3CoSfMMwnJwxkscPqmcXUXW2zmf+5tFnw/TyzLxyLs27Us\ntRgAkNwJyzq1EUuDuMTRNCD66xSG21gbwAskw0WxWaq0UsS+VSeBPW9HYQKBgD8q\nii7k80bRgtF6T9UpkhxYFCE8jpbHLMeBEruzj9kc5GRZBm+x9TRxxpcywIp5Mpai\nvZ//VDh9A+YwByL6mEYv09BZIVbJPHNPX5XgsV1v44L1YMB8yAaBPXL60qzc87SW\njZvdpcG7zDf2ijiI4tbF/JlLmJHVHbAj9TabngsfAoGAS55/5i1+c4z2am7dxmjG\ngm2jrGgChb9AVIBYx9XaRvyYu3VjQ6h4A//5VQnbESMurYB/6DYTY9NbEFcG3Rq+\npB3mKuy/8kuqlYT2ijLBKoCmcLBrWYuiM2bdR1lXU4xdO7Krs07b5v6wuNYG0npY\nlpihRULvBeOw6Ah37SSvRxk=\n-----END PRIVATE KEY-----\n",
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
