INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=ValheimServer" --query "Reservations[*].Instances[*].InstanceId" --output text)
aws ec2 start-instances --instance-ids $INSTANCE_ID