resource "kubernetes_deployment" "kuard" {

  metadata {
    name = "kuard"
    labels = {
      app = "kuard"
    }
  }

  spec {

    replicas = 3
    selector {
      match_labels = {
        app = "kuard"
      }
    }

    template {


      metadata {
        labels = {
          app = "kuard"
        }
      }
      spec {
        container {
          name  = "kuard"
          image = "gcr.io/kuar-demo/kuard-amd64:3"
          port {
            container_port = 8080
          }
          resources {
            requests = {
              memory = "5Mi"
            }
            limits = {
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kuard_nodeport" {

  metadata {
    name = "kuard"
    labels = {
      name = "kuard"
    }
  }
  spec {
    selector = {
      app = "kuard"
    }

    type = "NodePort"
    port {
      name        = "http"
      port        = 80
      target_port = "8080"

      # optional - hardcode rather than from nodeport range
      node_port = 30000
    }
  }
}