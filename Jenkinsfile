pipeline {
    agent any

    tools {
        git 'Default'
        maven 'Maven 3.6.3'
    }

    environment {
        REPO_NAME = "kehisa/project-1"
        GIT_CREDENTIALS = credentials('your-credentials-id') 
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Olakenny1975/proj-mdp-152-155.git', credentialsId: 'your-credentials-id'
            }
        }

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

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                cd kubernetes
                kubectl apply -f deployment.yaml
                kubectl set image deployment/webapp-deployment webapp=${REPO_NAME}:${TAG}
                kubectl apply -f service.yaml
                """
        }
    }
}