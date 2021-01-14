function usage {
  cat << EOF
Runs Terratest or Pytest"
usage: terrace test [Command] [FLAGS]

[FLAGS]:    
-h, --help                Show this help message 
-f, --files               Relative path to test file
EOF
  exit 0
}