#!/usr/bin/env python3

import os
import re

def renumber_modules(modules_path):
    """Renumber shell scripts in a modules directory by increments of 10"""
    # List all files in the modules directory
    files = [f for f in os.listdir(modules_path) if os.path.isfile(os.path.join(modules_path, f))]
    
    # Filter out non-shell script files and sort them
    shell_scripts = sorted([f for f in files if f.endswith('.sh')])
    
    # Create mapping of old to new names
    renames = {}
    
    # Renumber files sequentially
    for index, filename in enumerate(shell_scripts):
        new_index = (index + 1) * 10  # Increment by 10
        # Extract the name part after the first underscore
        name_part = filename.split('_', 1)[1] if '_' in filename else filename
        new_filename = f"{new_index:02d}_{name_part}"
        
        old_path = os.path.join(modules_path, filename)
        new_path = os.path.join(modules_path, new_filename)
        
        # Rename the file
        os.rename(old_path, new_path)
        renames[filename] = new_filename
        print(f"Renamed: {filename} -> {new_filename}")
    
    return renames

def update_main_script(main_script_path, renames):
    """Update main script references to use new filenames"""
    with open(main_script_path, 'r') as f:
        content = f.read()
    
    # Replace old module names with new ones
    for old_name, new_name in renames.items():
        content = content.replace(f'run_module "{old_name}"', f'run_module "{new_name}"')
    
    with open(main_script_path, 'w') as f:
        f.write(content)
    
    print(f"Updated: {main_script_path}")

def main():
    # Get the script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(script_dir)
    
    # Process pre-install modules
    pre_install_modules = os.path.join(base_dir, 'pre-install', 'modules')
    pre_install_script = os.path.join(base_dir, 'pre-install', 'install_deps.sh')
    
    # Process install-resources modules
    install_modules = os.path.join(base_dir, 'install-resources', 'modules')
    install_script = os.path.join(base_dir, 'install-resources', 'install_guest.sh')
    
    print("Processing pre-install modules...")
    pre_renames = renumber_modules(pre_install_modules)
    update_main_script(pre_install_script, pre_renames)
    
    print("\nProcessing install-resources modules...")
    install_renames = renumber_modules(install_modules)
    update_main_script(install_script, install_renames)
    
    print("\nDone!")

if __name__ == '__main__':
    main()