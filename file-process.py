import re

def extract_failed_and_unreachable_servers(file_path):
    failed_servers = []
    unreachable_servers = []
    
    with open(file_path, 'r') as file:
        for line in file:
            match_failed = re.search(r"fatal: \[(.*?)\]: FAILED!", line)
            match_unreachable = re.search(r"fatal: \[(.*?)\]: UNREACHABLE!", line)
            
            if match_failed:
                failed_servers.append(match_failed.group(1))
            if match_unreachable:
                unreachable_servers.append(match_unreachable.group(1))
    
    return failed_servers, unreachable_servers

if __name__ == "__main__":
    file_path = input("Enter the Ansible Tower output file path: ")
    failed, unreachable = extract_failed_and_unreachable_servers(file_path)
    
    print("Failed Servers:", failed)
    print("Unreachable Servers:", unreachable)
