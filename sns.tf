# Create an sns topic
resource "aws_sns_topic" "beamtest_topic" {
  name = "soracom_beamtest_topic"
}

# Subscribe to sns topic with endpoint of our phone number
resource "aws_sns_topic_subscription" "beamtest_notification_target" {
  topic_arn = aws_sns_topic.beamtest_topic.arn
  protocol  = "sms"
  endpoint  = var.phone_number
}

# Create iot topic rule that forwards all iot messages to sns
resource "aws_iot_topic_rule" "beamtest_topic_rule" {
  name = "SoracomBeamTestTopicRule"
  enabled = true
  sql_version =  "2016-03-23"
  sql = "SELECT * FROM 'beamtest'"

  sns {
    message_format = "RAW"
    role_arn       = aws_iam_role.beamtest_role.arn
    target_arn     = aws_sns_topic.beamtest_topic.arn
  }
}

# The role for the sns topic
resource "aws_iam_role" "beamtest_role" {
  name = "SoracomBeamTestRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy that allows our iot thing to access our sns topic
resource "aws_iam_role_policy" "beamtest_role_policy" {
  name = "beamtest_sns_policy"
  role = aws_iam_role.beamtest_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "sns:Publish"
        ],
        "Resource": "${aws_sns_topic.beamtest_topic.arn}"
    }
  ]
}
EOF
}