pipeline {
    agent {
        label "builder"
    }
    environment {
        REPO_NAME = "kehisa/project-1"
        TAG = sh(script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "_"', returnStdout: true).trim()
    }
    stages {
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
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credential', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
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
                    scp -o StrictHostKeyChecking=no ./target/web*.war ec2-user@172.31.36.164:/opt/tomcat/webapps/ROOT.war
                    """
                }
            }
        }
    }
}
// Post actions can be added here if needed
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker rmi ${REPO_NAME}:${TAG} || true'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
