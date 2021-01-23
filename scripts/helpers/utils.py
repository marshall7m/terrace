import ast
import subprocess
import os
import re

def get_tf_dir() -> str:
    """
    Gets the terragrunt file's relative path to the terraform directory within the .terragrunt cache

    :param rel_tg_path: Relative path to the Terragrunt directory (defaults to cwd)
    :param rel_tg_path: str
    """
    if os.path.isdir(os.environ['TG_PATH']): 
        config = subprocess.check_output(f"cd {os.environ['TG_PATH']}; terragrunt terragrunt-info", shell=True)
        config = ast.literal_eval(config.decode("utf-8"))
        abs_tf_path = f"~{config['WorkingDir']}"
        return abs_tf_path
    else:
        print(f"Invalid relative Terragrunt path: {os.environ['TG_PATH']}")
        

def get_min_required(path) -> str:
    required_versions = []
    for dir_path, _, file_names in os.walk(path):
        for file_name in file_names:
            file_path = os.path.join(dir_path, file_name)
        with open(file_path, 'r') as f:
           required_versions.extend(re.findall("", f.read()))
    return required_versions
