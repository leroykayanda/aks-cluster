#install cert manager

resource "helm_release" "cert-manager" {
  count      = var.cluster_created ? 1 : 0
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = "1.14.5"
  repository = "https://charts.jetstack.io"
  namespace  = "kube-system"
  atomic     = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# set up ClusterIssuer. This is a resource that represents a certificate authority (CA) able to sign certificates in response to certificate signing requests.

resource "kubernetes_manifest" "letsencrypt_issuer" {
  count = var.cluster_created ? 1 : 0
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-issuer"
    }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = var.letsencrypt_environment
        privateKeySecretRef = {
          name = "letsencrypt-issuer"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "azure/application-gateway"
              }
            }
          }
        ]
      }
    }
  }
}

