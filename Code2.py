import boto3
import os|
from __future__ import print_function
          
def lambda_handler(event, context):
	print('Hello World!')
	#Create an sns client
	sns = boto3.client('sns')
	#Publish a simple message to the specified SNS topic
	response = sns.publish(
	Topic= os.environ('Topic Arn'),
	Message='Hello World'
	)            	
	print(response)
	return 'Hello World!'
