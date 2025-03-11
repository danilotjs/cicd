resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-fullstate",
        "arn:aws:s3:::terraform-fullstate/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "ecr:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "ecs_pipeline" {
  name     = "devops-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = "terraform-fullstate"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      namespace        = "SourceVariables"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        BranchName = "main"
        ConnectionArn = "arn:aws:codeconnections:us-east-1:361769602634:connection/7a05139e-1ad4-4e35-be7f-442349d2b576"
        DetectChanges = "false"
        FullRepositoryId = "danilotjs/cicd"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      namespace       = "BuildVariables" 
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      output_artifacts = ["BuildArtifact"]
      input_artifacts = ["SourceArtifact"]

      configuration = {
        ProjectName = "devops-cicd"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      region          = "us-east-1"
      run_order       = "1"
      input_artifacts  = ["BuildArtifact"]

      configuration = {
        ClusterName = aws_ecs_cluster.ecs_cluster.name
        ServiceName = "devops-cicd"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}