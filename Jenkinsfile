pipeline {
    agent {
        label "builder"
    }

    stages {
        stage('Build and Test') {
            steps {
                sh"""
                mvn clean package
                """
            }    
        }
        stage('Deploy') {
           steps {
               sshagent(credentials: ['deloy-server-credential']) {
               sh '''
                   scp -o StrictHostKeyChecking=no ./target/web*.war ec2-user@172.31.36.164:/opt/tomcat/webapps/ROOT.war 
                   '''
    }
           }
        }
    }