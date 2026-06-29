pipeline {
agent any

environment {
    AWS_REGION = 'ap-south-1'
    AWS_ACCOUNT_ID = '235130525547'

    AUTH_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/auth-service'
    CHAT_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/chat-service'
    FRONTEND_ECR = '235130525547.dkr.ecr.ap-south-1.amazonaws.com/chat-app-client'

    EKS_CLUSTER = 'capstone-eks'

    IMAGE_TAG = "build-${BUILD_NUMBER}"
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Branch Info') {
        steps {
            sh '''
            echo "Branch: ${BRANCH_NAME}"
            pwd
            ls -la
            '''
        }
    }

    stage('Backend Build') {
        steps {
            sh '''
            cd app/auth-service
            mvn clean package -DskipTests

            cd ../chat-service
            mvn clean package -DskipTests
            '''
        }
    }

    stage('Frontend Build') {
        steps {
            sh '''
            cd app/chat-app-client
            npm install
            npm run build
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
                aws sts get-caller-identity

                aws ecr get-login-password \
                --region ${AWS_REGION} | docker login \
                --username AWS \
                --password-stdin \
                ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
            }
        }
    }

    stage('Build & Push Auth') {
        steps {
            sh '''
            docker build -t auth:${IMAGE_TAG} ./app/auth-service

            docker tag auth:${IMAGE_TAG} ${AUTH_ECR}:${IMAGE_TAG}
            docker tag auth:${IMAGE_TAG} ${AUTH_ECR}:latest

            docker push ${AUTH_ECR}:${IMAGE_TAG}
            docker push ${AUTH_ECR}:latest
            '''
        }
    }

    stage('Build & Push Chat') {
        steps {
            sh '''
            docker build -t chat:${IMAGE_TAG} ./app/chat-service

            docker tag chat:${IMAGE_TAG} ${CHAT_ECR}:${IMAGE_TAG}
            docker tag chat:${IMAGE_TAG} ${CHAT_ECR}:latest

            docker push ${CHAT_ECR}:${IMAGE_TAG}
            docker push ${CHAT_ECR}:latest
            '''
        }
    }

    stage('Build & Push Frontend') {
        steps {
            sh '''
            docker build -t frontend:${IMAGE_TAG} ./app/chat-app-client

            docker tag frontend:${IMAGE_TAG} ${FRONTEND_ECR}:${IMAGE_TAG}
            docker tag frontend:${IMAGE_TAG} ${FRONTEND_ECR}:latest

            docker push ${FRONTEND_ECR}:${IMAGE_TAG}
            docker push ${FRONTEND_ECR}:latest
            '''
        }
    }

    stage('Deploy to Test') {
        when {
            branch 'test'
        }

        steps {

            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-creds'
            ]]) {

                sh '''
                aws eks update-kubeconfig \
                --region ${AWS_REGION} \
                --name ${EKS_CLUSTER}

                kubectl create namespace chat-test \
                --dry-run=client -o yaml | kubectl apply -f -

                helm upgrade --install chat-app \
                helm/chat-app \
                -f helm/chat-app/values-test.yaml \
                -n chat-test
                '''
            }
        }
    }

    stage('Approval for Prod') {
        when {
            branch 'prod'
        }

        steps {
            input message: 'Deploy to Production?'
        }
    }

    stage('Deploy to Prod') {
        when {
            branch 'prod'
        }

        steps {

            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-creds'
            ]]) {

                sh '''
                aws eks update-kubeconfig \
                --region ${AWS_REGION} \
                --name ${EKS_CLUSTER}

                kubectl create namespace chat-prod \
                --dry-run=client -o yaml | kubectl apply -f -

                helm upgrade --install chat-app \
                helm/chat-app \
                -f helm/chat-app/values-prod.yaml \
                -n chat-prod
                '''
            }
        }
    }

    stage('Verify Deployment') {
        when {
            anyOf {
                branch 'test'
                branch 'prod'
            }
        }

        steps {

            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-creds'
            ]]) {

                sh '''
                aws eks update-kubeconfig \
                --region ${AWS_REGION} \
                --name ${EKS_CLUSTER}

                kubectl get pods -A
                kubectl get svc -A
                '''
            }
        }
    }
}

post {

    success {
        echo "SUCCESS: ${BRANCH_NAME}"
        echo "IMAGE TAG: ${IMAGE_TAG}"
    }

    failure {
        echo "FAILED: ${BRANCH_NAME}"
    }
}


}
