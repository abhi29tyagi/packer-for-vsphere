pipeline {
    agent { label "docker" }
    options {
        ansiColor('xterm')
        timestamps ()
    }
    environment {
        // NO TRAILING SLASH
        BRANCH = "${GIT_BRANCH}"
    }
    parameters {
        string(name: 'vm_size', defaultValue: '')
        string(name: 'distro_name', defaultValue: '')
    }
    stages {
        stage("Build Docker Image") {
            steps {
                script {
                     withCredentials([usernamePassword(credentialsId: 'svc-compute-packaging-login-credentials', passwordVariable: 'loginPASS', usernameVariable: 'loginUSER')]) {
                        sh """
                            if [ ${BRANCH} = "origin/master" ]; then
                                docker build -t ${JOB_BASE_NAME}:stable --build-arg username=${loginUSER} --build-arg password=${loginPASS} .
                            else
                                docker build -t ${JOB_BASE_NAME}:latest --build-arg username=${loginUSER} --build-arg password=${loginPASS} .
                            fi
                        """
                     }
                }
            }
        }
        stage("Create VM Template") {
            steps {
                script {
                    sh """
                    if [ ${BRANCH} = "origin/master" ]; then
                        docker run -i --rm ${JOB_BASE_NAME}:stable ${params.distro_name} ${params.vm_size} -force
                        docker rmi -f ${IMAGE_REPO}/${JOB_BASE_NAME}:stable
                    else
                        docker run -i --rm ${JOB_BASE_NAME}:latest ${params.distro_name} ${params.vm_size}
                        docker rmi -f ${IMAGE_REPO}/${JOB_BASE_NAME}:latest
                    fi
                    """
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
