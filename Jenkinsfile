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

    stage('Repository Info') {
        steps {
            sh '''
            pwd
            ls -la
            echo "Branch: ${BRANCH_NAME}"
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

    stage('Frontend Build Check') {
        steps {
            sh '''
            cd app/chat-app-client
            npm install
            npm run build
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

    stage('Configure EKS Access') {

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
                '''
            }
        }
    }

    stage('Deploy To Test') {

        when {
            branch 'test'
        }

        steps {
            sh '''
            kubectl create namespace chat-test --dry-run=client -o yaml | kubectl apply -f -

            helm upgrade --install chat-app \
            helm/chat-app \
            -f helm/chat-app/values-test.yaml \
            -n chat-test
            '''
        }
    }

    stage('Approval For Production') {

        when {
            branch 'prod'
        }

        steps {
            input message: 'Deploy to Production?'
        }
    }

    stage('Deploy To Production') {

        when {
            branch 'prod'
        }

        steps {
            sh '''
            kubectl create namespace chat-prod --dry-run=client -o yaml | kubectl apply -f -

            helm upgrade --install chat-app \
            helm/chat-app \
            -f helm/chat-app/values-prod.yaml \
            -n chat-prod
            '''
        }
    }

    stage('Deployment Verification') {

        when {
            anyOf {
                branch 'test'
                branch 'prod'
            }
        }

        steps {
            sh '''
            kubectl get pods -A
            '''
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
