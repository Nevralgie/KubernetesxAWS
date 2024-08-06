import yaml
import subprocess

# Load vars.yml
with open('vars.yml', 'r') as file:
    vars_data = yaml.safe_load(file)

# Extract values from the YAML file
db_name = vars_data.get('database_name', {}).get('value')
db_user = vars_data.get('database_username', {}).get('value')
db_password = vars_data.get('database_password', {}).get('value')
rds_address = vars_data.get('rds_address', {}).get('value')

# Create the Kubernetes secret
secret_command = [
    'kubectl', 'create', 'secret', 'generic', 'db-credentials',
    '--from-literal=db_name=' + db_name,
    '--from-literal=db_user=' + db_user,
    '--from-literal=db_password=' + db_password,
    '--from-literal=rds_address=' + rds_address
]

subprocess.run(secret_command, check=True)
