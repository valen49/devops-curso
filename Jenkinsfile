pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building application...'
                sh 'mkdir -p dist'
                sh 'echo version=1.0.0 > dist/build.txt'
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'echo Test 1: OK'
                sh 'echo Test 2: OK'
                sh 'echo All tests passed'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'echo Deploy completed successfully'
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
