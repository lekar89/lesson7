pipeline {
    agent {
        kubernetes {
            label 'django-kaniko-agent'
            defaultContainer 'git'

            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: django-kaniko-agent
spec:
  serviceAccountName: jenkins
  restartPolicy: Never

  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest-jdk21
      args:
        - $(JENKINS_SECRET)
        - $(JENKINS_NAME)

    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command:
        - /busybox/cat
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker

    - name: git
      image: alpine/git:2.47.2
      command:
        - cat
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker

  volumes:
    - name: docker-config
      emptyDir: {}
'''
        }
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '058862856673'
        ECR_REPOSITORY = 'lesson-8-9-django'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

        HELM_VALUES_FILE = 'charts/django-app/values.yaml'
        GIT_BRANCH = 'lesson-8-9'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Configure ECR authentication') {
            steps {
                container('git') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'aws-credentials',
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        )
                    ]) {
                        sh '''
                            set -eu

                            apk add --no-cache aws-cli

                            mkdir -p /kaniko/.docker

                            ECR_PASSWORD="$(aws ecr get-login-password \
                              --region "${AWS_REGION}")"

                            AUTH="$(printf 'AWS:%s' "${ECR_PASSWORD}" | base64 | tr -d '\\n')"

                            cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "${ECR_REGISTRY}": {
      "auth": "${AUTH}"
    }
  }
}
EOF
                        '''
                    }
                }
            }
        }

        stage('Build and push image') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context "${WORKSPACE}/app" \
                          --dockerfile "${WORKSPACE}/app/Dockerfile" \
                          --destination "${IMAGE_URI}" \
                          --destination "${ECR_REGISTRY}/${ECR_REPOSITORY}:latest" \
                          --cache=true
                    '''
                }
            }
        }

        stage('Update Helm image tag') {
            steps {
                container('git') {
                    sh '''
                        set -eu

                        sed -i "s/^  tag: .*/  tag: ${IMAGE_TAG}/" \
                          "${HELM_VALUES_FILE}"

                        grep -A 3 '^image:' "${HELM_VALUES_FILE}"
                    '''
                }
            }
        }

        stage('Commit and push Helm change') {
            steps {
                container('git') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-credentials',
                            usernameVariable: 'GIT_USERNAME',
                            passwordVariable: 'GIT_TOKEN'
                        )
                    ]) {
                        sh '''
                            set -eu

                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@example.com"

                            git add "${HELM_VALUES_FILE}"

                            if git diff --cached --quiet; then
                              echo "No Helm changes to commit"
                              exit 0
                            fi

                            git commit -m "Update Django image to ${IMAGE_TAG}"

                            REPOSITORY_URL="$(git config --get remote.origin.url)"

                            case "${REPOSITORY_URL}" in
                              https://*)
                                AUTHENTICATED_URL="$(echo "${REPOSITORY_URL}" \
                                  | sed "s#https://#https://${GIT_USERNAME}:${GIT_TOKEN}@#")"
                                ;;
                              *)
                                echo "Remote origin must use HTTPS"
                                exit 1
                                ;;
                            esac

                            git push "${AUTHENTICATED_URL}" \
                              HEAD:"${GIT_BRANCH}"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Image pushed: ${IMAGE_URI}"
        }

        failure {
            echo 'CI/CD pipeline failed'
        }

        always {
            cleanWs()
        }
    }
}