// Jenkinsfile
def GITHUB_API_URL = 'https://api.github.com'
def GITHUB_ORG = 'your-org-name'
def GITHUB_TOKEN = 'your-github-token-here'

pipeline {
    agent any
    
    parameters {
        text(
            name: 'REPOS_CONFIG',
            description: 'JSON configuration for repositories',
            defaultValue: '''[
                {
                    "name": "repo1",
                    "description": "Repository 1",
                    "private": true,
                    "teams": ["team1"]
                },
                {
                    "name": "repo2",
                    "description": "Repository 2",
                    "private": false,
                    "teams": ["team2"]
                }
            ]'''
        )
    }
    
    stages {
        stage('Create Repositories') {
            steps {
                script {
                    def repos = readJSON(text: params.REPOS_CONFIG)
                    def skippedRepos = []
                    def createdRepos = []
                    
                    repos.each { repo ->
                        // Check if repo exists
                        def repoExists = sh(
                            script: """
                                curl -s -o /dev/null -w "%{http_code}" \
                                -H "Authorization: token ${GITHUB_TOKEN}" \
                                ${GITHUB_API_URL}/repos/${GITHUB_ORG}/${repo.name}
                            """,
                            returnStdout: true
                        ).trim()
                        
                        if (repoExists == "200") {
                            skippedRepos.add(repo.name)
                            echo "Skipping ${repo.name}: Already exists"
                            return
                        }
                        
                        def payload = [
                            name: repo.name,
                            description: repo.description,
                            private: repo.private,
                            auto_init: true,
                            default_branch: 'main'
                        ]
                        
                        sh """
                            curl -X POST \
                            -H "Authorization: token ${GITHUB_TOKEN}" \
                            -H "Accept: application/vnd.github.v3+json" \
                            -d '${groovy.json.JsonOutput.toJson(payload)}' \
                            ${GITHUB_API_URL}/orgs/${GITHUB_ORG}/repos
                        """
                        
                        createdRepos.add(repo.name)
                    }
                    
                    echo "Created repositories: ${createdRepos.join(', ')}"
                    if (skippedRepos) {
                        echo "Skipped repositories: ${skippedRepos.join(', ')}"
                    }
                }
            }
        }
    }
}