provider "aws" {
  profile    = "default"
  region     = "us-west-2" # sns text messaging is only available in some regions
  version = "~> 2.0"
}

# The aws iot thing(s)
resource "aws_iot_thing" "beamtest_iot_thing" {
  for_each = toset(var.imsi_ids)

  name = "raspi-${each.key}"
}

# A policy for the iot thing that allowes soracom beam inbound
resource "aws_iot_policy" "beamtest_policy" {
  name = "SoracomBeamTest"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect",
        "iot:Subscribe"
      ],
      "Resource": "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Publish"
      ],
      "Resource": "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/beamtest"
    }
  ]
}
EOF
}

# Create an aws iot certificate
resource "aws_iot_certificate" "beamtest_cert" {
  for_each = toset(var.imsi_ids)

  active = true
}

# Attach policy generated above to the aws iot thing(s)
resource "aws_iot_policy_attachment" "beamtest_policy_att" {
  for_each = toset(var.imsi_ids)

  policy = aws_iot_policy.beamtest_policy.name
  target = aws_iot_certificate.beamtest_cert[each.key].arn
}


# Output certificate to /cert/{IMSI} folder
resource "local_file" "beamtest_cert_pem" {
  for_each = toset(var.imsi_ids)

  content     = aws_iot_certificate.beamtest_cert[each.key].certificate_pem
  filename = "${path.module}/certs/${each.key}/${substr(aws_iot_certificate.beamtest_cert[each.key].id,0,12)}.pem.crt"
}

# Output private key to /cert/{IMSI} folder
resource "local_file" "beamtest_private_key" {
  for_each = toset(var.imsi_ids)

  content     = aws_iot_certificate.beamtest_cert[each.key].private_key
  filename = "${path.module}/certs/${each.key}/${substr(aws_iot_certificate.beamtest_cert[each.key].id,0,12)}.private.key"
}

# Output public key to /cert/{IMSI} folder
resource "local_file" "beamtest_public_key" {
  for_each = toset(var.imsi_ids)

  content     = aws_iot_certificate.beamtest_cert[each.key].public_key
  filename = "${path.module}/certs/${each.key}/${substr(aws_iot_certificate.beamtest_cert[each.key].id,0,12)}.public.key"
}

# Attach AWS iot cert generated above to the aws iot thing(s) 
resource "aws_iot_thing_principal_attachment" "beamtest_principal_att" {
  for_each = toset(var.imsi_ids)

  principal = aws_iot_certificate.beamtest_cert[each.key].arn
  thing     = aws_iot_thing.beamtest_iot_thing[each.key].name
}

# Get the aws iot endpoint to print out for reference
data "aws_iot_endpoint" "endpoint" {
    endpoint_type = "iot:Data-ATS"
}

# Output arn of iot thing(s) 
output "iot_endpoint" {
  value = data.aws_iot_endpoint.endpoint.endpoint_address
}