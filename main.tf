variable "google_credentials" {
  default = <<EOF
{
  "type": "service_account",
  "project_id": "cicd-project-438005",
  "private_key_id": "34800a521c31e3139f3131f79e65833b5672a387",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDMeBsthfKDNrfU\n9aDJVyymo/cX2RkfJck+aHA1dpM5hXEHUdsyv4nCIZpKeJ6opCO1GO1ad25ieXR0\nnkdyBJogEFpdNC3zExqSGNnGIUmMpW8J7H3CTeOJm4RCmLeIc+hFWFCQnDy+qia7\ngba0lJS9p7YuYd2AfkxNb8wtlQKkrzowHhMB4KxZvDFIf8laFHoZSQtuT4L+k4xV\nXloPhPFi2kyy4TG657h6+qRo8SbYWfre0PDYRIm/ckulESt1D4FYunK6E51P8juv\nS4vPztfkk17Y/tA9PEtxE7GVjw6ryn9bglk1cl0WLZ/Hb+7VDZLKrEsD48FKLYhh\n1Bnn5dGtAgMBAAECggEALdw5gkwjEO2WrVf7XHVmQSkRDIMHyK3ttYbwtfkWu+XT\nbGgecUM3J3jodZAYy+vmy2FgKTSU6Fbj+R0gGrFwDUWFsxZ3QOgVw1N6Et+X8skP\nPutRaKGWKaDdOR+uOJeArv8IMOsuD7izr8Y//8A8nU4uxTfzmbSaMhsjcUzU9zEk\nX8yTIVYrN39oMU2Xm1oqWicaXL+oiZ9fxRoQldGqZ67Ee8VbrXVKUTiWhZyCw6tt\nb2PxeOclCI1SxzMVdhwgclCPfl0BIM86xbBvn8gcnITm1BOR4KIKae+gcUzEvRxK\nq9BpcPswNI99SmHwfu+abyMV2Dv0dwM/GZZAd71hyQKBgQDyT4N5YrTB4O5VwAQY\n+bqi3nfBX5zckzeNLzJvoBVw2D8yDOF8dPKIW0i3H0f2PVp9I1wnEMa304hpbzfj\nJwpeEc/YXdq9Bvdbz8HyKU8MjgS1U9DApQoewdn2kzw8vXw2EI3PrC019g6OrN1r\nVaRf/W+468EktnN9XIQRVSrBKQKBgQDYBUzM4wpPoz+vK9obMo45XNBmm+NIgPuR\nJGyT29csv2hhwtRHOKlMRr42wwJ4VXh38vH66F/7wEEqiJx+c56OtBDY4DMV4rdw\nW0YFbu4HoShpeUudzfOSi71wpQglAJQwSl2xr5vfMHZ2UFyNgVnf7+7ZMF5V+Ud9\nAY2q0KfI5QKBgQC1fHSesB1usUgRldX71t/BKRtNDI3yb5lF97mw/ZfRg0Yh+J/S\nlc0p8CUQcy908RMbcyaMY/ZSrO8Y+SJE0nLjbjfceL9ioRsX+w3qkKISZzSDk5lh\nELv5uXvFQRX28H1eCRwOFYlvRzI0DqlwwR5yfuH1AS8Sjk0F8gtA6CczsQKBgDOy\ncQLHgvw0EVWWpQfFPYw0zhsAS5Babdn6YZGxFvm6hPyAZ9TzlnCOrY7ldH3f1oi+\nN3LYkb/p7q6DKxCIEvYL2cxNO2yNaWEWNteuCIEC7GzxfksxsozrrFZ86EoSrWQx\nJ+MSJ7duHauK59tljWCuRvbrQGhK0/Tynji23rCRAoGBAKmKvTr5k+vEstxZw0yk\nr+VI4OhZjOZ3nQFtqPGNdX3TjwRWZC8qSxitKG+4o/O8Ljp6WJWfRw0X6KMjz9Hx\n74OMpVscVLnbOy4XhztTfXmEUF/A81UGAxZoJUuJoW1Nz6xL0lKQmhFdgepAWh4s\nkafRkmgOIAD+ZXEpxe03q5ZC\n-----END PRIVATE KEY-----\n",
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
