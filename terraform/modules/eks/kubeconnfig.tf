
locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
  name: ${module.eks.cluster_arn}
contexts:
- context:
    cluster: ${module.eks.cluster_arn}
    user: ${module.eks.cluster_arn}
  name: ${module.eks.cluster_id}
current-context: ${module.eks.cluster_id}
kind: Config
preferences: {}
users:
- name: ${module.eks.cluster_id}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - us-east-1
      - eks
      - get-token
      - --cluster-name
      - ${module.eks.cluster_id}
      command: aws
KUBECONFIG
}
