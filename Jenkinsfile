pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Repository') {
            steps {
                sh 'pwd'
                sh 'ls -la'
                sh 'tree -L 2 || true'
            }
        }
    }
}
