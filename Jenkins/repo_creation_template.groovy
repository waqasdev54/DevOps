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
        stage('Create Repositories from Templates') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        def repos = readJSON(text: params.REPOS_CONFIG)
                        def createdRepos = []
                        def skippedRepos = []
                        def failedRepos = []
                        
                        repos.each { repo ->
                            // Check if repository already exists
                            def repoCheckResponse = sh(
                                script: """
                                    curl -s -o /dev/null -w "%{http_code}" \
                                    -H "Authorization: Bearer $GITHUB_TOKEN" \
                                    -H "Accept: application/vnd.github+json" \
                                    https://api.github.com/repos/${GITHUB_ORG}/${repo.name}
                                """,
                                returnStdout: true
                            ).trim()
                            
                            if (repoCheckResponse == "200") {
                                skippedRepos.add(repo.name)
                                echo "Repository ${repo.name} already exists. Skipping creation."
                                return
                            }
                            
                            // Validate template repository configuration
                            if (!repo.template_repository || !repo.template_repository.owner || !repo.template_repository.repository) {
                                failedRepos.add("${repo.name}: Missing template repository configuration")
                                return
                            }
                            
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
                                createdRepos.add(repo.name)
                                echo "Successfully created repository ${responseData.full_name}"
                            } else {
                                failedRepos.add("${repo.name}: ${responseData.message}")
                                echo "Failed to create repository ${repo.name}: ${responseData.message}"
                            }
                        }
                        
                        // Report results
                        if (createdRepos) {
                            echo "Successfully created repositories: ${createdRepos.join(', ')}"
                        }
                        
                        if (skippedRepos) {
                            echo "Skipped repositories (already exist): ${skippedRepos.join(', ')}"
                        }
                        
                        if (failedRepos) {
                            error "Failed to create repositories:\n${failedRepos.join('\n')}"
                        }
                    }
                }
            }
        }
    }
}
