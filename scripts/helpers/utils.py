import ast
import subprocess
import os
import re
from distutils.version import StrictVersion

def get_tf_dirs(path) -> str:
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
        
def get_tg_dirs(path) -> list:
    std_out = subprocess.check_output(f"cd {path}; terragrunt graph-dependencies", shell=True)
    tg_dirs = re.findall("""(?:(?<=;\n\s")|(?<=digraph\s\{\n\s"))(?:.+)(?="\s;)""", std_out.decode("utf-8"))
    return tg_dirs

def get_min_required(path) -> str:
    required_versions = []
    tg_dirs = get_tf_dirs(path)
    for dir in tg_dirs:
        for dir_path, _, file_names in os.walk(dir):
            for file_name in file_names:
                file_path = os.path.join(dir_path, file_name)
                with open(file_path, 'r') as f:
                    version = get_tf_version(f.read())
                    print(f'directory: {dir_path} - version: {version}')
    return required_versions

def get_tf_version(content):
    tf_blocks = re.findall("terraform\s+\{\s+((?:(?:.+)\n)+)\}", content, re.MULTILINE)
    required_version_attr = [re.findall('(?<=required_version\s=\s")((?:<=|>=|!=|~>|[=<>])?\s*\d+\.\d+\.\d+(?:-\w+)?)', block) for block in tf_blocks]
    if len(required_version_attr) > 1:
        raise ValueError('Required version could not be inferred. More than one required_version attribute is specified')     
    elif len(required_version_attr) == 0:
        return None
    else:
        required_version_attr = "".join(required_version_attr[0])
        operator = ''.join(re.findall('^(<=|>=|!=|~>|[=<>])', required_version_attr))
        try:
            required_version = re.findall('\d+\.\d+\.\d+(?:-\w+)?', required_version_attr)[0]
        except IndexError:
            raise ValueError('Required version could not be inferred. see: https://www.terraform.io/docs/language/expressions/version-constraints.html')
    remote_versions = subprocess.check_output('terraenv terraform list remote', shell=True).decode("utf-8").split('\n')
    remote_versions = [version for version in remote_versions if version != '']
    if required_version not in remote_versions:
        raise ValueError(f'{required_version} is not a valid Terraform version') 
    target_version = []
    if operator == "<":
        for version in remote_versions:
            if StrictVersion(version) < StrictVersion(required_version):
                target_version.append(version)
        available_versions = sorted(target_version, key=StrictVersion)
        available_versions.reverse()
        return available_versions[0]
    elif operator == ">":
        for version in remote_versions:            
            if StrictVersion(version) > StrictVersion(required_version):
                target_version.append(version)
        available_versions = sorted(target_version, key=StrictVersion)
        return available_versions[0]
    elif operator == "~>":
        split_version = required_version.split('.')
        max_version = int(split_version[len(split_version)*-1+1])+1
        version = '.'.join(split_version[:len(split_version)*-1+1])
        max_version = f'{version}.{max_version}'
        for version in remote_versions:
            if StrictVersion(version) > StrictVersion(required_version) and StrictVersion(max_version) > StrictVersion(version):
                target_version.append(version)
        available_versions = sorted(target_version, key=StrictVersion)
        available_versions.reverse()
        return available_versions[0]
    else:
        return required_version

print(get_min_required("../../terraform-modules/"))