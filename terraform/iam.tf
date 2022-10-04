resource "aws_iam_policy" "describe_eks_policy" {
  name = "eks-client"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            #            "eks:UpdateClusterConfig",
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster"
          ],
          "Resource" : "*"
        }
      ]
  })
}

resource "aws_iam_role" "describe_eks_role" {
  name = "eks-user"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy_attachment" "describe_eks_attachment" {
  name       = "describe_eks_attachment"
  policy_arn = aws_iam_policy.describe_eks_policy.arn
  roles      = [aws_iam_role.describe_eks_role.name]
}

resource "aws_iam_instance_profile" "bastion_profile" {
  role = aws_iam_role.describe_eks_role.name
}