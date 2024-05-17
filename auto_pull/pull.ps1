# Set the execution policy to allow scripts (replace 'CurrentUser' with your username if needed)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

# Perform a regular 'git pull origin main'
git pull origin main

# If an error occurs, perform a forced pull 'git pull -f origin main'
if ($?) -ne 0) {
  git pull -f origin main
}
