pipeline {
    agent any
    
    environment {
        DOCKERHUB_REPO = "hema995"  
        VERSION = "${BUILD_NUMBER}"
        GIT_CREDENTIALS = credentials('git-credentials-budgetapp')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build and Push Images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        sh 'echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
                        sh "docker build -t $DOCKERHUB_REPO/budgetapp:$VERSION -f Dockerfile ."
                        sh "docker push $DOCKERHUB_REPO/budgetapp:$VERSION"
                        sh "docker tag $DOCKERHUB_REPO/budgetapp:$VERSION $DOCKERHUB_REPO/budgetapp:latest"
                        sh "docker push $DOCKERHUB_REPO/budgetapp:latest"
                    }
                }
            }
        }
    }
}