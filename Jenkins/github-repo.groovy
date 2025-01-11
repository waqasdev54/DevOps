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
                    "name": "Areez",
                    "description": "Repository 1",
                    "private": true,
                    "teams": ["team1"]
                },
                {
                    "name": "Shamir",
                    "description": "Repository 2",
                    "private": false,
                    "teams": ["team2"]
                }
            ]'''
        )
    }
    
    stages {
        stage('Validate Configuration') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        // Check organization access using secure shell command
                        def orgAccess = sh(
                            script: 'curl -s -H "Authorization: token $GITHUB_TOKEN" ' + GITHUB_API_URL + '/orgs/' + GITHUB_ORG,
                            returnStdout: true
                        ).trim()
                        
                        def orgData = readJSON text: orgAccess
                        if (orgData.message) {
                            error "Failed to access organization: ${orgData.message}"
                        }
                        
                        echo "Successfully validated organization access"
                    }
                }
            }
        }
        
        stage('Create Repositories') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        def repos = readJSON(text: params.REPOS_CONFIG)
                        def skippedRepos = []
                        def createdRepos = []
                        def failedRepos = []
                        
                        repos.each { repo ->
                            // Check if repo exists using secure shell command
                            def repoExists = sh(
                                script: '''
                                    curl -s -o /dev/null -w "%{http_code}" \
                                    -H "Authorization: token $GITHUB_TOKEN" \
                                    ''' + GITHUB_API_URL + '/repos/' + GITHUB_ORG + '/' + repo.name,
                                returnStdout: true
                            ).trim()
                            
                            if (repoExists == "200") {
                                skippedRepos.add(repo.name)
                                echo "Skipping ${repo.name}: Already exists"
                                return
                            }
                            
                            def payload = groovy.json.JsonOutput.toJson([
                                name: repo.name,
                                description: repo.description,
                                private: repo.private,
                                auto_init: true,
                                default_branch: 'main'
                            ])
                            
                            // Write payload to temporary file
                            writeFile file: 'payload.json', text: payload
                            
                            // Create repository using secure shell command
                            def response = sh(
                                script: '''
                                    curl -s -X POST \
                                    -H "Authorization: token $GITHUB_TOKEN" \
                                    -H "Accept: application/vnd.github.v3+json" \
                                    -d "@payload.json" \
                                    ''' + GITHUB_API_URL + '/orgs/' + GITHUB_ORG + '/repos',
                                returnStdout: true
                            ).trim()
                            
                            // Clean up payload file
                            sh 'rm payload.json'
                            
                            def responseData = readJSON text: response
                            if (responseData.message) {
                                failedRepos.add("${repo.name}: ${responseData.message}")
                                echo "Failed to create ${repo.name}: ${responseData.message}"
                            } else {
                                createdRepos.add(repo.name)
                                echo "Successfully created ${repo.name}"
                            }
                        }
                        
                        echo "Created repositories: ${createdRepos.join(', ')}"
                        if (skippedRepos) {
                            echo "Skipped repositories: ${skippedRepos.join(', ')}"
                        }
                        if (failedRepos) {
                            error "Failed to create some repositories:\n${failedRepos.join('\n')}"
                        }
                    }
                }
            }
        }
    }
}
