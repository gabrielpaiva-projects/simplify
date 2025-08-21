#!/usr/bin/env python3
import re

def update_file(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Pattern to find _nextStep method
    next_step_pattern = r'(  void _nextStep\(\) \{)\n(    bool isValid = false;)'
    next_step_replacement = r'\1\n    // Close keyboard before changing step\n    FocusScope.of(context).unfocus();\n    \n\2'
    
    # Pattern to find _previousStep method
    prev_step_pattern = r'(  void _previousStep\(\) \{)\n(    if \(_currentStep > 0\) \{)'
    prev_step_replacement = r'\1\n    // Close keyboard before changing step\n    FocusScope.of(context).unfocus();\n    \n\2'
    
    # Apply replacements
    content = re.sub(next_step_pattern, next_step_replacement, content)
    content = re.sub(prev_step_pattern, prev_step_replacement, content)
    
    # Write back to file
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"Updated {file_path}")

# Update client registration screen
update_file('/workspace/lib/features/auth/presentation/screens/client_registration_screen.dart')

# Update professional registration screen  
update_file('/workspace/lib/features/auth/presentation/screens/professional_registration_screen.dart')

print("All files updated successfully!")