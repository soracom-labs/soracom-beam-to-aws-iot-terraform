# Purpose
This purpose of this application is to stand up the AWS side of Soracom's getting started guide for [Beam](https://developers.soracom.io/en/start/aws/beam-iotcore/). 

The infrastucture will consist of at least one IoT thing with it's certificates and keys generated under the certs folder. The IoT things will be connected to an SNS topic that sends a text message to a phone number you provide. MQTT messages sent from the IoT thing on the topic will be forwarded to the phone number as an SMS.

# Considerations
Since terraform does not currently support email for SNS we will instead send a text message to a provided phone number. Note that the region is us-west-2 and not us-east-2 in this example because SMS is only supported in certain regions by AWS Simple Notification Service. 

# Prerequisites
1. The [AWS CLI](https://aws.amazon.com/cli/) and [Terraform](https://learn.hashicorp.com/terraform/getting-started/install) must be installed and ready for use on your computer. See the corresponding installation and getting started guides for more information. 

2. Edit the variables.tf file and add a phone number you would like to receive the sms texts on. Also add in at least one SIM IMSI in the imsi_ids variable.  

    - You can take advantage of the Soracom [API](https://developers.soracom.io/en/api/) or [CLI](https://github.com/soracom/soracom-cli/releases) to get your list of IMSIs by listing subscribers, or listing subscribers in a certain group. For example, use this CLI command to list all subscribers:

        `soracom subscribers list | grep -o '"imsi": *"[^"]*"' | grep -o '"[^"]*"$'`

        (The two grep commands filter down the result to return just the list of IMSIs without the extra attributes.)

3. (Optional) If you configured your aws cli with a user profile, add the name of the profile in the iot.tf file in the provider config. 

# Initialize Terraform 
`terraform init`

# Create the Plan
`terraform plan`

# Apply the Plan
`terraform apply`

# Outputs
The https iot endpoint will be output after running the apply command. The certs and keys are located in the certs/ directory. Use these to configure Beam in the Soracom console.

# Teardown
`terraform destroy`