resource "aws_efs_file_system_policy" "efs_policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy = jsonencode({
     Version: "2012-10-17",
     Id: "efs_policy",
     Statement: [
        {
            Sid: "policy01",
            Effect: "Allow",
            Principal: {
                "AWS": "*"
            },
            Resource: "${aws_efs_file_system.efs.arn}",
            Action: [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            Condition: {
                Bool: {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
  })
}