import ast
import subprocess
import os
import re
from distutils.version import StrictVersion
import argparse

def get_parser():
    parser = argparse.ArgumentParser(description='Terraform version crawler')
    parser.add_argument('--binary', '-b', type=str,
                        help='Binary to use --command with (terraform|terragrunt)')
    parser.add_argument('--path', '-p', type=str,
                        help='path to Terraform or Terragrunt directory')
    parser.add_argument('--shallow', '-s', type=bool, default=False, 
                        help='Determines if child terragrunt directories versions should be inferred')
    parser.add_argument('--append_hook', '-a', type=bool, default=False,
                        help='Determines if Terraform version hook should be appended to the Terragrunt file within --path')
    return parser

# scope:
# tg hook yes
# 

def main(args=None):
    parser = get_parser()
    args = parser.parse_args(args)
    # if terragrunt with -all then get_tg_dirs()
    if not args.shallow and args.binary == 'terragrunt':
        tg_dirs = get_tg_dirs(args.path)
        tf_dirs = [get_tf_dir(tg_dir) for tg_dir in tg_dirs]
    elif args.shallow and args.binary == 'terragrunt':
        tf_dirs = get_tf_dir(args.path)
    else:
        tf_dirs = args.path

    for dir in tf_dirs:
        version = get_min_required(dir)
        if args.append_hook:
            write_tg_version_hook(tg_dir, min_required_version, tg_file_name)

def get_min_required(dir)
        
        required_versions = []
        for dir_path, _, file_names in os.walk(tf_dir):
            for file_name in file_names: 
                if file_name.endswith('.tf'):
                    file_path = os.path.join(dir_path, file_name)
                    with open(file_path, 'r') as f:
                        version = get_tf_version(f.read())
                        if version != None:
                            print(f'File: {file_path} - version: {version}')
                            required_versions.append(version)   
                            break
        if required_versions == []:
            print(f'Version constraint not found in: {tf_dir}')
        else:
            min_required_version = min(required_versions)
            print(f'Directory: {tf_dir} Terraform Version Constraint: {min_required_version}')
            if args.append_hook:
                write_tg_version_hook(tg_dir, min_required_version, tg_file_name)

def write_tg_version_hook(tg_file_path, version, tg_file_name):
    version_hook = """
terraform {
  before_hook "before_hook" {
    commands     = ["validate", "plan", "apply"]
    execute      = ["terraenv", "terraform use {}"]
  }
}
""".format(version)
    print('tg_filep: ', tg_file_path)
    with open(f'{tg_file_path}/{tg_file_name}', 'a') as f:
        f.write(version_hook)

def get_tf_dir(path) -> str:
    """
    Gets the terragrunt file's relative path to the associated terraform directory within the .terragrunt cache

    :param rel_tg_path: Relative path to the Terragrunt directory (defaults to cwd)
    :param rel_tg_path: str
    """
    if os.path.isdir(path): 
        config = subprocess.check_output(f"cd {path}; terragrunt terragrunt-info", shell=True)
        config = ast.literal_eval(config.decode("utf-8"))
        abs_tf_path = config['WorkingDir']
        rel_tf_path = os.path.relpath(abs_tf_path, os.getcwd())
        return rel_tf_path
    else:
        print(f"Invalid relative Terragrunt path: {path}")
        
def get_tg_dirs(path) -> list:
    std_out = subprocess.check_output(f"cd {path}; terragrunt graph-dependencies", shell=True)
    #TODO: get distinct tg dirs
    tg_dirs = re.findall("""(?:(?<=;\n\s")|(?<=digraph\s\{\n\s"))(?:.+)(?="\s;)""", std_out.decode("utf-8"))
    return tg_dirs

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

if __name__ == '__main__':
    main()