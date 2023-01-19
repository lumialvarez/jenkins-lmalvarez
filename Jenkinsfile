def APP_VERSION
pipeline {
   agent any
   environment {
      DOCKERHUB_CREDENTIALS=credentials('dockerhub-lmalvarez')
   }
   stages {
      stage('Get Version') {
         steps {
            script {
               APP_VERSION = sh (
                  script: "grep -m 1 -Po '[0-9]+[.][0-9]+[.][0-9]+' CHANGELOG.md",
                  returnStdout: true
               ).trim()
            }
            script {
               currentBuild.displayName = "#" + currentBuild.number + " - v" + APP_VERSION
            }
            script{
                if(currentBuild.previousSuccessfulBuild) {
                    lastBuild = currentBuild.previousSuccessfulBuild.displayName.replaceFirst(/^#[0-9]+ - v/, "")
                    echo "Last success version: ${lastBuild} \nNew version to deploy: ${APP_VERSION}"
                    if(lastBuild == APP_VERSION)  {
                         currentBuild.result = 'ABORTED'
                         error("Aborted: A version that already exists cannot be deployed a second time")
                    }
                }
            }
         }
      }
      stage('Build') {
            steps {
                sh "docker build . -t lmalvarez/jenkins:${APP_VERSION}"
            }
        }
      stage('Deploy') {
           steps {
               //script_internal_ip.sh -> ip route | awk '/docker0 /{print $9}'
              script {
                  INTERNAL_IP = sh (
                      script: '''ssh ${SSH_MAIN_SERVER} 'sudo bash script_internal_ip.sh' ''',
                      returnStdout: true
                  ).trim()
              }
  
              sh "docker rm -f jenkins-lmalvarez &>/dev/null && echo \'Removed old container\' "
  
              sh "sleep 5s"
  
              sh "docker run --name jenkins-lmalvarez --net=backend-services --add-host=lmalvarez.com:${INTERNAL_IP}  -p 8080:8080 -p 50000:50000 -d -v /var/lib/jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --cpus=0.7 --restart unless-stopped lmalvarez/jenkins:${APP_VERSION}"
           }
        }
      stage('Push') {
            steps {
                sh '''echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin '''

                sh "docker push lmalvarez/jenkins:${APP_VERSION}"
            }
        }
   }
}