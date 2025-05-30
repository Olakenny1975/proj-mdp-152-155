pipeline {
    agent {
        label "builder"
    }

    environment {
        REPO_NAME = "kehisa/project-1"
    }

    stages {
        stage('Set Tag Version') {
            steps {
                script {
                    env.TAG = sh(script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "_"', returnStdout: true).trim()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                echo ${REPO_NAME}:${TAG}
                docker build -t ${REPO_NAME}:${TAG} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credential',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh """
                    echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USER}" --password-stdin docker.io
                    docker push ${REPO_NAME}:${TAG}
                    docker logout
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(credentials: ['deploy-server-credential']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@172.31.36.164 << 'EOF
                        set -e # Fall on error
                        docker rm -f project-1 || true
                        docker pull ${REPO_NAME}:${TAG}
                        docker run -d --name project-1 -p 8080:8080 $REPO_NAME:${TAG}
                    EOF
                """
                }
            }
        }
    }
}
pipeline {
    agent any

    tools {
        git 'Default' // Match the name configured in Global Tool Configuration
    }

    environment {
        GIT_CREDENTIALS = credentials('your-credentials-id') // Replace with your credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Olakenny1975/proj-mdp-152-155.git', credentialsId: 'your-credentials-id'
            }
        }
    }
}
