pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '235130525547'

        AUTH_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/auth-service'
        CHAT_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/chat-service'
        FRONTEND_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/chat-app-client'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Verify') {
            steps {
                sh '''
                pwd
                ls -la
                '''
            }
        }
        stage('AWS Login') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login \
                    --username AWS \
                    --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                }
            }
        }
        stage('Build Auth Service') {
            steps {
                sh '''
                docker build -t auth-service:latest ./app/auth-service

                docker tag auth-service:latest \
                ${AUTH_ECR}:latest
                '''
            }
        }
        stage('Push Auth Service') {
            steps {
                sh '''
                docker push ${AUTH_ECR}:latest
                '''
            }
        }
        stage('Build Chat Service') {
            steps {
                sh '''
                docker build -t chat-service:latest ./app/chat-service

                docker tag chat-service:latest \
                ${CHAT_ECR}:latest
                '''
            }
        }
        stage('Push Chat Service') {
            steps {
                sh '''
                docker push ${CHAT_ECR}:latest
                '''
            }
        }
        stage('Build Frontend') {
            steps {
                sh '''
                docker build -t chat-app-client:latest ./app/chat-app-client

                docker tag chat-app-client:latest \
                ${FRONTEND_ECR}:latest
                '''
            }
        }
        stage('Push Frontend') {
            steps {
                sh '''
                docker push ${FRONTEND_ECR}:latest
                '''
            }
        }
    }
    post {
        success {
            echo 'Images pushed to ECR successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}