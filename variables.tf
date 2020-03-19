# Update this variable with a cell phone number 
# that will receive the text messages
# Please include country code: ex. +18885555555
variable "phone_number" {
  type = string
  default = "+<REPLACE_WITH_PHONE_NUMBER>"
} 

# A list of SIM IMSI ids. For each id an aws iot thing will be created.
# Update this list with your SIM IMSI id(s). 
variable "imsi_ids" {
  type    = list(string)
  default = ["<REPLACE_WITH_IMSI_1>", "<REPLACE_WITH_IMSI_2>"]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}