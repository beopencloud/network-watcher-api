/*
resource "kubernetes_namespace" "web-app" {
  metadata {
    labels = {
        app = "web-app"
    }
    name = "web-app"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "web-server"
    namespace = "web-app"
    labels = {
        app = "web-app"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
          app = "web-app"
      }
    }
    template {
      metadata {
        labels = {
            app = "web-app"
        }
      }
      spec {
        container {
          image = "nginx:1.7.9"
          name = "web-server"
          port {
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_namespace.web-app
  ]
}

resource "kubernetes_service" "app" {
  metadata {
    name = "web-service"
    namespace = "web-app"
  }
  spec {
    selector = {
        app = "web-app"
    }
    port {
      port = 80
      target_port = 80
      protocol = "TCP"
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_deployment.app]
}

resource "kubernetes_ingress" "web-app" {
  metadata {
    name      = "web-ingress"
    namespace = "web-app"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/load-balancer-name" = "nappyme-alb"
    }
    labels = {
        "app" = "web-app"
    }
  }

  spec {
      backend {
        service_name = "web-service"
        service_port = 80
      }
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "web-service"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}

*/
