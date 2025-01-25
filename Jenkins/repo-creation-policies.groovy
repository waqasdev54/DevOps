def GITHUB_API_URL = 'https://api.github.com'
def GITHUB_ORG = 'Xoftlabs'

pipeline {
    agent any
    
    stages {
        stage('Fetch Organization Members') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        // Fetch all organization members
                        def membersResponse = sh(
                            script: """
                                curl -L \
                                -H "Accept: application/vnd.github+json" \
                                -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                                -H "X-GitHub-Api-Version: 2022-11-28" \
                                ${GITHUB_API_URL}/orgs/${GITHUB_ORG}/members
                            """,
                            returnStdout: true
                        ).trim()
                        
                        def members = readJSON(text: membersResponse)
                        
                        // Print member details
                        echo "Total Members: ${members.size()}"
                        members.each { member ->
                            echo "Member: ${member.login} (ID: ${member.id})"
                        }
                    }
                }
            }
        }
        
        stage('Disable Repository Creation Privileges') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        // Update organization members repository creation settings
                        def payload = groovy.json.JsonOutput.toJson([
                            members_can_create_public_repositories: false,
                            members_can_create_private_repositories: false
                        ])
                        def response = sh(
                            script: """
                                curl -L \
                                -X PATCH \
                                -H "Accept: application/vnd.github+json" \
                                -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                                -H "X-GitHub-Api-Version: 2022-11-28" \
                                -H "Content-Type: application/json" \
                                ${GITHUB_API_URL}/orgs/${GITHUB_ORG} \
                                -d '${payload}'
                            """,
                            returnStdout: true
                        ).trim()
                        
                        def responseData = readJSON(text: response)
                        
                        // Validate settings were updated
                        if (responseData.members_can_create_public_repositories == false && 
                            responseData.members_can_create_private_repositories == false) {
                            echo "Successfully disabled repository creation for all organization members"
                        } else {
                            error "Failed to disable repository creation privileges: ${response}"
                        }
                    }
                }
            }
        }
    }
}
