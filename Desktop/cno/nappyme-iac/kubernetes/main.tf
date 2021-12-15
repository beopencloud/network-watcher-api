
provider "aws" {
    region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_caller_identity" "current" {
  
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}
/*
data "aws_wafv2_web_acl" "waf" {
  name = "waf_nappyme"
  scope = "REGIONAL"
}
*/
data "aws_vpc" "nappyme_vpc" { 
    tags              = {
     Name           = "${var.vpc_name}-${var.environment}"
  }
}

data "aws_eks_cluster" "nappyme_cluster" {
   name = "${var.cluster_name}-${var.environment}"
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}


#-----------------------
# ALB Ingress Controller
#-----------------------

resource "kubernetes_namespace" "alb_ingress" {
  metadata {
    name = "alb-ingress"
  }
} 

resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name   = "ALBIngressControllerIAMPolicy"
  policy =  jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources",
	      "tag:getTagKeys",
	      "tag:getTagValues",
	      "tag:UntagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name        = "eks-alb-ingress-controller"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."

  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:alb-ingress:alb-ingress-controller"
        }
      }
    }
  ]
}
ROLE
}

resource "aws_iam_role_policy_attachment" "ALBIngressControllerIAMPolicy_attachment" {
  policy_arn = aws_iam_policy.ALBIngressControllerIAMPolicy.arn
  role = aws_iam_role.eks_alb_ingress_controller.name
}


resource "kubernetes_service_account" "alb_ingress_controller" {
  automount_service_account_token = true
  metadata {
    name      = "alb-ingress-controller"
    namespace = "alb-ingress"
    labels    = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_alb_ingress_controller.arn
  //    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubernetes/aws-alb-ingress-controller"
    }
}
}

resource "kubernetes_cluster_role" "alb_ingress_controller" {
   metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
    verbs      = ["create", "get", "list", "update", "watch", "patch"]
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["nodes", "pods", "secrets", "services", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "alb_ingress_controller" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.alb_ingress_controller.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.alb_ingress_controller.metadata[0].name
    namespace = kubernetes_service_account.alb_ingress_controller.metadata[0].namespace
  }

  depends_on = [kubernetes_cluster_role.alb_ingress_controller]
}


resource "kubernetes_deployment" "alb_ingress_controller" {
  metadata {
    name      = "alb-ingress-controller"
    namespace = "alb-ingress"
    labels    = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
    }
  
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "alb-ingress-controller"
        }
      }

      spec {
        restart_policy                   = "Always"
        service_account_name             = kubernetes_service_account.alb_ingress_controller.metadata[0].name
        termination_grace_period_seconds = 60

        container {
          name              = "alb-ingress-controller"
          image             = "docker.io/amazon/aws-alb-ingress-controller:v1.1.6"
          image_pull_policy = "Always"
          
          args = [
          //  "--alb.ingress.kubernetes.io/waf-acl-id=${data.aws_wafv2_web_acl.waf.id}",
            "--ingress-class=alb",
            "--cluster-name=${var.cluster_name}",
            "--aws-vpc-id=${data.aws_vpc.nappyme_vpc.id}",
            "--aws-region=${var.region}",
            "--aws-max-retries=20"
          ] 
        }
      }
    }
  }
}


#-----------------------
# EFS CSI DRIVER
#-----------------------

resource "aws_iam_policy" "AmazonEKS_EFS_CSI_Driver_Policy" {
  name   = "AmazonEKS_EFS_CSI_Driver_Policy"
  policy =  jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
})
}

resource "aws_iam_role" "AmazonEKS_EFS_CSI_Driver_IAMRole" {
  name        = "AmazonEKS_EFS_CSI_Driver_IAMRole"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."

  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:efs-csi-node-sa"
        }
      }
    }
  ]
}
ROLE
}


resource "aws_iam_role_policy_attachment" "AmazonEKS_EFS_CSI_Driver_Policy_attachment" {
  policy_arn = aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy.arn
  role = aws_iam_role.AmazonEKS_EFS_CSI_Driver_IAMRole.name
}

// Install the Amazon EFS Driver
resource "kubernetes_service_account" "efs_csi_sa" {
  automount_service_account_token = true
  metadata {
    name      = "efs-csi-node-sa"
    namespace = "kube-system"
    labels    = {
      "app.kubernetes.io/name"       = "aws-efs-csi-driver"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.AmazonEKS_EFS_CSI_Driver_IAMRole.arn
  //    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubernetes/aws-alb-ingress-controller"
    }
}
}

# Controller CSI, allow to provisionning automatically a PV when a PVC and Pod are created
resource "kubernetes_cluster_role" "efs_csi_clusterRole" {
   metadata {
    name = "efs-csi-external-provisioner-role"
    labels = {
      "app.kubernetes.io/name"       = "aws-efs-csi-driver"
    }
  }

  rule {
    api_groups = ["", "coordination.k8s.io", "storage.k8s.io"]
    resources  = ["persistentvolumes", "persistentvolumeclaims", "storageclasses", "events", "csinodes", "nodes", "leases", "secrets"]
    verbs      = ["create", "get", "list", "delete", "watch", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "efs_csi_cluserRoleBinding" {
  metadata {
    name = "efs-csi-provisioner-binding"
    labels = {
      "app.kubernetes.io/name"       = "aws-efs-csi-driver"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.efs_csi_clusterRole.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.efs_csi_sa.metadata[0].name
    namespace = kubernetes_service_account.efs_csi_sa.metadata[0].namespace
  }

  depends_on = [kubernetes_cluster_role.efs_csi_clusterRole]
}



resource "kubernetes_deployment" "efs-csi-deployment" {
  metadata {
    name      = "efs-csi-controller"
    namespace = "kube-system"
    labels    = {
      "app.kubernetes.io/name"       = "aws-efs-csi-driver"
    }
  
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "aws-efs-csi-driver"
        "app" = "efs-csi-controller"
        "app.kubernetes.io/instance" = "kustomize"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "aws-efs-csi-driver"
          "app.kubernetes.io/instance" = "kustomize"
          "app" = "efs-csi-controller"
        }
      }

      spec {
        container {
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=2",
            "--delete-access-point-root-dir=false"
          ] 
          env {
            name = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          image             = "602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-efs-csi-driver:v1.3.4"
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            failure_threshold = 5
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            period_seconds = 10
            timeout_seconds = 3
          }
          name              = "efs-plugin"
          port {
            container_port = 9909
            name = "healthz"
            protocol = "TCP"
          } 
          security_context {
            privileged = true
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }
        container {
          args = [
            "--csi-address=$(ADDRESS)",
            "--feature-gates=Topology=true",
            "--v=2",
            "--extra-create-metadata",
            "--leader-election"
          ] 
          env {
            name = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/csi-provisioner:v2.1.1"
          image_pull_policy = "IfNotPresent"
          name = "csi-provisioner"
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name = "socket-dir"
          }
        }
        container {
          args = [
            "--csi-address=/csi/csi.sock",
            "--health-port=9909"
          ] 
          image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/livenessprobe:v2.2.0"
          image_pull_policy = "IfNotPresent"
          name = "liveness-probe"
          volume_mount {
            mount_path = "/csi"
            name = "socket-dir"
          }
        }
        host_network = true
        node_selector = {
          "kubernetes.io/os"  = "linux"
        }
        priority_class_name = "system-cluster-critical"
        service_account_name = kubernetes_service_account.efs_csi_sa.metadata[0].name
        volume {
          empty_dir {
            
          }
          name = "socket-dir"
        }
      }
    }
  }
}

# Agent CSI responsable to mount volume on the Pod

resource "kubernetes_daemonset" "efs-csi-daemonset" {
  metadata {
    name      = "efs-csi-node"
    namespace = "kube-system"
    labels    = {
      "app.kubernetes.io/name"       = "aws-efs-csi-driver"
    }
  
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "aws-efs-csi-driver"
        "app" = "efs-csi-node"
        "app.kubernetes.io/instance" = "kustomize"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "aws-efs-csi-driver"
          "app.kubernetes.io/instance" = "kustomize"
          "app" = "efs-csi-node"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values = ["fargate"]
                }
              }
            }
          }
        }
        container {
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=2"
          ] 
          env {
            name = "CSI_ENDPOINT"
            value = "unix:/csi/csi.sock"
          }
          image             = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/aws-efs-csi-driver:v1.3.4"
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            failure_threshold = 5
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            period_seconds = 2
            timeout_seconds = 3
          }
          name              = "efs-plugin"
          port {
            container_port = 9809
            name = "healthz"
            protocol = "TCP"
          } 
          security_context {
            privileged = true
          }
          volume_mount {
            mount_path = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
            name       = "kubelet-dir"
          }
          volume_mount {
            mount_path = "/csi"
            name = "plugin-dir"
          }
          /*
          volume_mount {
            mount_path = "/var/run/efs"
            name = "efs-state-dir"
          }*/
          volume_mount {
            mount_path = "/var/amazon/efs"
            name = "efs-utils-config"
          }
          volume_mount {
            mount_path = "/etc/amazon/efs-legacy"
            name = "efs-utils-config-legacy"
          }
        }
        container {
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=2",
            "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)"
          ] 
          env {
            name = "ADDRESS"
            value = "/csi/csi.sock"
          }
          env {
            name = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/efs.csi.aws.com/csi.sock"
          }
          env {
            name = "KUBE_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/csi-node-driver-registrar:v2.1.0"
          image_pull_policy = "IfNotPresent"
          name = "csi-driver-registrar"
          volume_mount {
            mount_path = "/csi"
            name = "plugin-dir"
          }
          volume_mount {
            mount_path = "/registration"
            name = "registration-dir"
          }
        }
        container {
          args = [
            "--csi-address=/csi/csi.sock",
            "--health-port=9809",
            "--v=2"
          ] 
          image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/livenessprobe:v2.2.0"
          image_pull_policy = "IfNotPresent"
          name = "liveness-probe"
          volume_mount {
            mount_path = "/csi"
            name = "plugin-dir"
          }
        }
        dns_policy = "ClusterFirst"
        host_network = true
        node_selector = {
          "beta.kubernetes.io/os"  = "linux"
        }
        priority_class_name = "system-node-critical"
        service_account_name = "efs-csi-node-sa"
        toleration {
          operator = "Exists"
        }
        volume {
          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
          name = "kubelet-dir"
        }
        volume {
          host_path {
            path = "/var/lib/kubelet/plugins/efs.csi.aws.com/"
            type = "DirectoryOrCreate"
          }
          name = "plugin-dir"
        }
        volume {
          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
          name = "registration-dir"
        }
        volume {
          host_path {
            path = "/var/amazon/efs"
            type = "DirectoryOrCreate"
          }
          name = "efs-utils-config"
        }
        volume {
          host_path {
            path = "/etc/amazon/efs"
            type = "DirectoryOrCreate"
          }
          name = "efs-utils-config-legacy"
        }
      }
    }
  }
}

/*
resource "kubernetes_csi_driver" "efs-csi-driver" {
  metadata {
    annotations = {
      "helm.sh/hook" = "pre-install, pre-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation"
      "helm.sh/resource-policy" = "keep"
    }
    name = "efs.csi.aws.com"
  }
  spec {
    attach_required = false
  }
}
*/
# storage class
/*
data "aws_efs_file_system" "efs" {
  
}

resource "kubernetes_storage_class" "efs-sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    file_system_id = data.aws_efs_file_system.efs.file_system_id 
    type = "efs-ap"
  }
  mount_options = [ "directoryPerms=700","file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none" ]
}
*/