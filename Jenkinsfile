pipeline {
    environment {
        DOCKER_ID = "satishgoli6011" 
        DOCKER_IMAGE = "Kubernes"
        DOCKER_TAG = "v.${BUILD_ID}.0"
    }
    agent any
    stages {
        stage('Checkout') {
            steps {
                // Check out your project from your Git repository
                checkout scm
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    sh '''
                    docker rm -f jenkins
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG .
                    sleep 6
                    '''
                }
            }
        }

        stage('Docker Run') {
            steps {
                script {
                    sh '''
                    docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                    sleep 10
                    '''
                }
            }
        }

        stage('Test Acceptance') {
            steps {
                script {
                    sh '''
                    curl localhost
                    '''
                }
            }
        }

        stage('Docker Push') {
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS")
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'DOCKER_HUB_PASS', variable: 'DOCKER_PASS')]) {
                        sh '''
                        docker login -u $DOCKER_ID -p $DOCKER_PASS
                        docker push $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                        '''
                    }
                }
            }
        }

        stage('Deployment in dev') {
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
                    cat $KUBECONFIG > .kube/config
                    kubectl apply -f kubernetes/dev/
                    '''
                }
            }
        }

        stage('Deployment in QA') {
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
                    cat $KUBECONFIG > .kube/config
                    kubectl apply -f kubernetes/qa/
                    '''
                }
            }
        }

        stage('Deployment in staging') {
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
                    cat $KUBECONFIG > .kube/config
                    kubectl apply -f kubernetes/staging/
                    '''
                }
            }
        }

        stage('Deployment in prod') {
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to deploy in production?', ok: 'Yes'
                }
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
                    cat $KUBECONFIG > .kube/config
                    kubectl apply -f kubernetes/prod/
                    '''
                }
            }
        }
    }
}
