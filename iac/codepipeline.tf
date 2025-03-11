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
          "Action": [
              "iam:PassRole"
          ],
          "Resource": "*",
          "Effect": "Allow",
          "Condition": {
              "StringEqualsIfExists": {
                  "iam:PassedToService": [
                      "cloudformation.amazonaws.com",
                      "elasticbeanstalk.amazonaws.com",
                      "ec2.amazonaws.com",
                      "ecs-tasks.amazonaws.com"
                  ]
              }
          }
      },
      {
          "Action": [
              "codecommit:CancelUploadArchive",
              "codecommit:GetBranch",
              "codecommit:GetCommit",
              "codecommit:GetRepository",
              "codecommit:GetUploadArchiveStatus",
              "codecommit:UploadArchive"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "codedeploy:CreateDeployment",
              "codedeploy:GetApplication",
              "codedeploy:GetApplicationRevision",
              "codedeploy:GetDeployment",
              "codedeploy:GetDeploymentConfig",
              "codedeploy:RegisterApplicationRevision"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "codestar-connections:UseConnection"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "elasticbeanstalk:*",
              "ec2:*",
              "elasticloadbalancing:*",
              "autoscaling:*",
              "cloudwatch:*",
              "s3:*",
              "sns:*",
              "cloudformation:*",
              "rds:*",
              "sqs:*",
              "ecs:*"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "lambda:InvokeFunction",
              "lambda:ListFunctions"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "opsworks:CreateDeployment",
              "opsworks:DescribeApps",
              "opsworks:DescribeCommands",
              "opsworks:DescribeDeployments",
              "opsworks:DescribeInstances",
              "opsworks:DescribeStacks",
              "opsworks:UpdateApp",
              "opsworks:UpdateStack"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "cloudformation:CreateStack",
              "cloudformation:DeleteStack",
              "cloudformation:DescribeStacks",
              "cloudformation:UpdateStack",
              "cloudformation:CreateChangeSet",
              "cloudformation:DeleteChangeSet",
              "cloudformation:DescribeChangeSet",
              "cloudformation:ExecuteChangeSet",
              "cloudformation:SetStackPolicy",
              "cloudformation:ValidateTemplate"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Action": [
              "codebuild:BatchGetBuilds",
              "codebuild:StartBuild",
              "codebuild:BatchGetBuildBatches",
              "codebuild:StartBuildBatch"
          ],
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Effect": "Allow",
          "Action": [
              "devicefarm:ListProjects",
              "devicefarm:ListDevicePools",
              "devicefarm:GetRun",
              "devicefarm:GetUpload",
              "devicefarm:CreateUpload",
              "devicefarm:ScheduleRun"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "servicecatalog:ListProvisioningArtifacts",
              "servicecatalog:CreateProvisioningArtifact",
              "servicecatalog:DescribeProvisioningArtifact",
              "servicecatalog:DeleteProvisioningArtifact",
              "servicecatalog:UpdateProduct"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "cloudformation:ValidateTemplate"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "ecr:DescribeImages"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "states:DescribeExecution",
              "states:DescribeStateMachine",
              "states:StartExecution"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "appconfig:StartDeployment",
              "appconfig:StopDeployment",
              "appconfig:GetDeployment"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:us-east-1:361769602634:log-group:/aws/codepipeline/devops-pipeline",
              "arn:aws:logs:us-east-1:361769602634:log-group:/aws/codepipeline/devops-pipeline:log-stream:*"
          ]
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
        ConnectionArn = "arn:aws:codeconnections:us-east-1:361769602634:connection/14454ac0-cdb6-4178-ac26-119da04561bb"
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