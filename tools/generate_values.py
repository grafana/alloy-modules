# generate_values.py

import os
import yaml

directory_to_scan = './config-files'  # Directory containing the configuration files
output_values_path = './chart/values.yaml'  # Path to the values.yaml file in your Helm chart

files_list = []
for subdir, dirs, files in os.walk(directory_to_scan):
    for file in files:
        filepath = os.path.join(subdir, file)
        with open(filepath, 'r') as f:
            content = f.read()
            files_list.append({'path': filepath.replace(directory_to_scan + '/', ''), 'content': content})

values = {'configFiles': files_list}

with open(output_values_path, 'w') as outfile:
    yaml.dump(values, outfile, default_flow_style=False)
