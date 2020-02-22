{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "SnsEmailTopic": {
      "Type": "AWS::SNS::Topic",
      "Properties": {
        "DisplayName": "${display_name}",
        "Subscription": [
          {
            "Endpoint": "${email_address}",
            "Protocol": "email"
          }
        ]
      }
    }
  },
  "Outputs": {
    "ARN": {
      "Description": "SNS Email Topic ARN",
      "Value": {
        "Ref": "SnsEmailTopic"
      }
    }
  }
}
