pipeline {
    agent {
       kubernetes {
           yaml """
apiVersion: v1 
kind: Pod 
metadata: 
    name: dind
    annotations:
      container.apparmor.security.beta.kubernetes.io/dind: unconfined
      container.seccomp.security.alpha.kubernetes.io/dind: unconfined
spec: 
    containers: 
      - name: dind
        image: docker:dind
        securityContext:
          privileged: true
        tty: true
        volumeMounts:
        - name: var-run
          mountPath: /var/run
      - name: jnlp
        securityContext:
          runAsUser: 0
          fsGroup: 0
        volumeMounts:
        - name: var-run
          mountPath: /var/run
        
    volumes:
    - emptyDir: {}
      name: var-run
"""
       }
   }

    parameters { 
        string(name: 'DOCKER_REPOSITORY', defaultValue: 'programmerq/vulntest', description: 'Name of the image to be built (e.g.: sysdiglabs/dummy-vuln-app)') 
    }
    
    environment {
        DOCKER = credentials('docker-repository-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                container("dind") {
                    sh "docker pull sysdiglabs/secure-inline-scan:457a94c7 & docker pull anchore/inline-scan:v0.6.1 &" 
                    checkout scm
                }
            }
        }
        stage('Build Image') {
            steps {
                container("dind") {
                    sh "docker build -t ${params.DOCKER_REPOSITORY} ."
                }
            }
        }
        stage('Scanning Image') {
            steps {
                container("dind") {
                    withCredentials([usernamePassword(credentialsId: 'sysdig-secure-api-credentials', passwordVariable: 'TOKEN', usernameVariable: '')]) {
                        sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock  -v \"$WORKSPACE/out:/out\" sysdiglabs/secure-inline-scan:457a94c7 analyze -R /out -k $TOKEN ${params.DOCKER_REPOSITORY};"
                    }
                }
            }
        }
        stage('Push Image') {
            steps {
                container("dind") {
                    sh "docker info && docker image ls && echo docker push ${params.DOCKER_REPOSITORY}"
                }
            }
        }
    }
    post { 
        always { 
            container("dind") {
            echo 'archiving pdfs'
            sh "pwd; echo workspace: $WORKSPACE; ls -lah out; echo"
            archiveArtifacts artifacts: 'out/*.pdf', followSymlinks: false
            }
        }
    }
}
