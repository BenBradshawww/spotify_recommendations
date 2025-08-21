import boto3

def stop_instance_if_running(instance_id):
    ec2 = boto3.client('ec2')

    try:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        state = response['Reservations'][0]['Instances'][0]['State']['Name']

        print(f"Instance {instance_id} is currently in state: {state}")

        if state == 'running':
            ec2.stop_instances(InstanceIds=[instance_id])
            print(f"Stopping instance {instance_id}...")
        else:
            print(f"No action taken. Instance is in '{state}' state.")
    
    except Exception as e:
        print(f"Error checking/stopping instance: {e}")

# Lambda entrypoint
def lambda_handler(event, context):
    instance_id = event.get("instance_id")
    stop_instance_if_running(instance_id)