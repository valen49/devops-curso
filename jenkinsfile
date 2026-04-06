pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Construyendo la aplicacion...'
                sh 'mkdir -p dist'
                sh 'echo version=1.0.0 > dist/build.txt'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Corriendo tests...'
                sh 'echo Test 1: OK'
                sh 'echo Test 2: OK'
                sh 'echo Todos los tests pasaron'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Desplegando...'
                sh 'echo Deploy completado exitosamente'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completado exitosamente'
        }
        failure {
            echo 'Pipeline fallo'
        }
    }
}