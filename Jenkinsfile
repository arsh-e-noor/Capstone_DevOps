pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '235130525547'

        AUTH_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/auth-service'
        CHAT_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/chat-service'
        FRONTEND_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/chat-app-client'

        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Repository') {
            steps {
                sh '''
                pwd
                ls -la
                '''
            }
        }

        stage('AWS ECR Login') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
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
                docker build \
                  -t auth-service:${IMAGE_TAG} \
                  ./app/auth-service

                docker tag auth-service:${IMAGE_TAG} \
                  ${AUTH_ECR}:${IMAGE_TAG}

                docker tag auth-service:${IMAGE_TAG} \
                  ${AUTH_ECR}:latest
                '''
            }
        }

        stage('Push Auth Service') {
            steps {
                sh '''
                docker push ${AUTH_ECR}:${IMAGE_TAG}
                docker push ${AUTH_ECR}:latest
                '''
            }
        }

        stage('Build Chat Service') {
            steps {
                sh '''
                docker build \
                  -t chat-service:${IMAGE_TAG} \
                  ./app/chat-service

                docker tag chat-service:${IMAGE_TAG} \
                  ${CHAT_ECR}:${IMAGE_TAG}

                docker tag chat-service:${IMAGE_TAG} \
                  ${CHAT_ECR}:latest
                '''
            }
        }

        stage('Push Chat Service') {
            steps {
                sh '''
                docker push ${CHAT_ECR}:${IMAGE_TAG}
                docker push ${CHAT_ECR}:latest
                '''
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                docker build \
                  -t chat-app-client:${IMAGE_TAG} \
                  ./app/chat-app-client

                docker tag chat-app-client:${IMAGE_TAG} \
                  ${FRONTEND_ECR}:${IMAGE_TAG}

                docker tag chat-app-client:${IMAGE_TAG} \
                  ${FRONTEND_ECR}:latest
                '''
            }
        }

        stage('Push Frontend') {
            steps {
                sh '''
                docker push ${FRONTEND_ECR}:${IMAGE_TAG}
                docker push ${FRONTEND_ECR}:latest
                '''
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Images pushed to ECR with tag ${IMAGE_TAG}"
        }

        failure {
            echo "FAILED: Pipeline execution failed"
        }
    }
}