# used just for k8s dashboard now

resource "kubernetes_service_account" "eks_admin" {
  metadata {
    namespace = "kube-system"
    name      = "eks-admin"
  }
}

resource "kubernetes_cluster_role_binding" "eks_admin" {
  metadata {
    name = "eks-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

data "kubernetes_secret" "eks_admin" {
  metadata {
    name      = kubernetes_service_account.eks_admin.default_secret_name
    namespace = "kube-system"
  }
}

