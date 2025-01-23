def GITHUB_API_URL = 'https://api.github.com'
def GITHUB_ORG = 'Xoftlabs'

pipeline {
    agent any
    
    parameters {
        text(
            name: 'REPOS_CONFIG',
            description: 'JSON configuration for repositories',
            defaultValue: '''[
                {
                    "name": "new-project",
                    "description": "Project created from template",
                    "private": true,
                    "template_repository": {
                        "owner": "Xoftlabs",
                        "repository": "project-template"
                    }
                }
            ]'''
        )
    }
    
    stages {
        stage('Create Repositories') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        def repos = readJSON(text: params.REPOS_CONFIG)
                        
                        repos.each { repo ->
                            // Prepare payload for repository creation
                            def payload = [
                                name: repo.name,
                                description: repo.description,
                                private: repo.private
                            ]
                            
                            if (repo.template_repository) {
                                // Create repository from template
                                def response = sh(
                                    script: """
                                        curl -L \
                                        -X POST \
                                        -H "Accept: application/vnd.github+json" \
                                        -H "Authorization: Bearer $GITHUB_TOKEN" \
                                        -H "X-GitHub-Api-Version: 2022-11-28" \
                                        https://api.github.com/repos/${repo.template_repository.owner}/${repo.template_repository.repository}/generate \
                                        -d '${groovy.json.JsonOutput.toJson([
                                            owner: GITHUB_ORG,
                                            name: repo.name,
                                            description: repo.description,
                                            private: repo.private
                                        ])}' 
                                    """,
                                    returnStdout: true
                                ).trim()
                                
                                def responseData = readJSON(text: response)
                                
                                if (responseData.full_name) {
                                    echo "Successfully created repository ${responseData.full_name} from template"
                                } else {
                                    error "Failed to create repository: ${responseData.message}"
                                }
                            } else {
                                // Create standard repository
                                def response = sh(
                                    script: """
                                        curl -L \
                                        -X POST \
                                        -H "Accept: application/vnd.github+json" \
                                        -H "Authorization: Bearer $GITHUB_TOKEN" \
                                        -H "X-GitHub-Api-Version: 2022-11-28" \
                                        https://api.github.com/orgs/${GITHUB_ORG}/repos \
                                        -d '${groovy.json.JsonOutput.toJson([
                                            name: repo.name,
                                            description: repo.description,
                                            private: repo.private,
                                            auto_init: true
                                        ])}' 
                                    """,
                                    returnStdout: true
                                ).trim()
                                
                                def responseData = readJSON(text: response)
                                
                                if (responseData.full_name) {
                                    echo "Successfully created repository ${responseData.full_name}"
                                } else {
                                    error "Failed to create repository: ${responseData.message}"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
