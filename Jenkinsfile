pipeline {
    agent any


    tools {
        // This assumes you have configured a JDK tool in Jenkins named “JDK”
        jdk 'JDK'
    }
    environment {
        DOCKERHUB_REPO = "shivshashya"        
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        //IMAGE_TAG = "${env.BUILD_NUMBER}"
        //ACR_NAME = 'wissda.azurecr.io'
     //   Dockerhub_NAME = ''
        DOCKER_IMAGE_NAME = 'admin-beta-aks'
        IMAGE_TAG = "beta-admin-build-${BUILD_NUMBER}"
        JDK_HOME = "${tool 'JDK'}"
        PATH = "${tool 'JDK'}/bin:${env.PATH}"
    //     //BASE_URL_BETA = "https://beta-be.wissda.cloud/admin"
    //     //BASE_URL_GAMMA = "https://gamma-be.wissda.cloud/admin"
     }

    parameters {
        gitParameter branchFilter: '.*',
                     defaultValue: 'main',
                     name: 'BRANCH_NAME',
                     type: 'PT_BRANCH',
                     useRepository: 'https://github.com/shivshashya/backend-pipeline-javaspringboot.git'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {

        stage('Git Check') {
            steps {
                script {
                    try {
                        checkout scmGit(
                            branches: [[name: "${params.BRANCH_NAME}"]],
                            extensions: [],
                            userRemoteConfigs: [[credentialsId: 'jenkine_github_token', url: 'https://github.com/shivshashya/backend-pipeline-javaspringboot.git']]
                        )
                    } catch (Exception e) {
                        error "❌ Git checkout failed: ${e.message}"
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    try {
                        sh 'mvn clean package'
                    } catch (Exception e) {
                        error "❌ Build failed: ${e.message}"
                    }
                }
            }
        }

        stage('Unit Test') {
            steps {
                script {
                    try {
                        sh 'mvn surefire-report:report'
                    } catch (Exception e) {
                        error "❌ Unit tests failed: ${e.message}"
                    }
                }
            }
        }

//         stage('SonarQube Analysis') {
//             steps {
//                 script {
//                     try {
//                         echo "SonarQube Analysis Started!"
//                         def mvn = tool 'Maven 3.6.3'
//                         withSonarQubeEnv() {
//                             sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=admin-beta-be -Dsonar.projectName='admin-beta-be'"
//                         }
//                         echo "SonarQube Analysis Completed!"
//                     } catch (Exception e) {
//                         error "❌ SonarQube analysis failed: ${e.message}"
//                     }
//                 }
//             }
//         }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        // dir('devops-repo') {
                        //     checkout([$class: 'GitSCM',
                        //               branches: [[name: 'main']],
                        //               userRemoteConfigs: [[
                        //                   credentialsId: 'PAT_Jenkins',
                        //                   url: 'https://github.com/shivshashya/backend-pipeline-javaspringboot.git'
                        //               ]]]
                        //     )
                        // }

                        sh "docker build -t ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ."
                        sh 'docker images'
                    } catch (Exception e) {
                        error "❌ Docker build failed: ${e.message}"
                    }
                }
            }
        }

//         stage('Push to ACR') {
//             steps {
//                 script {
//                     try {
//                         withCredentials([usernamePassword(credentialsId:'azure-acr-credentials', passwordVariable: 'ACR_password', usernameVariable: 'ACR_USERNAME')]) {
//                             sh "echo \$ACR_password | docker login $ACR_NAME -u $ACR_USERNAME --password-stdin"
//                             sh "docker push $ACR_NAME/$DOCKER_IMAGE_NAME:${IMAGE_TAG}"
//                         }
//                     } catch (Exception e) {
//                         error "❌ Push to ACR failed: ${e.message}"
//                     }
//                 }
//             }
//         }
        stage('Push to QA Docker Hub') {
        steps {
            script {
                // // Define image name and tag
               // def qaImage = "${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}-qa"

                // Tag the built image for QA
                // sh "docker tag ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${qaImage}"

                // Log into Docker Hub & push the QA tag
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                    sh "docker push ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                    // Optionally push as latest‐qa or similar
                   // sh "docker tag ${qaImage} ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:latest-qa"
                   // sh "docker push ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:latest-qa"
                }

                // You can clean up local QA image if you like
               // sh "docker rmi ${qaImage} ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:latest-qa"
            }
        }
        }
       

        // stage('Deploy to QA/Beta') {
        //     steps {
        //         script {
        //             try {
        //                 sh "sed -i 's|{IMAGE_TAG}|${IMAGE_TAG}|' devops-repo/be-microservices/qa/admin/admin-deployment.yaml"
        //                 withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kube-qa', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
        //                     sh "kubectl apply -f devops-repo/be-microservices/qa/admin/admin-clusterip-service.yaml"
        //                     sh "kubectl apply -f devops-repo/be-microservices/qa/admin/admin-deployment.yaml"
        //                 }
        //             } catch (Exception e) {
        //                 error "❌ Deployment to QA/Beta failed: ${e.message}"
        //             }
        //         }
        //     }
        // }



        stage ('Beta-Deploy docker image'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                    sh "docker pull ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"  
                    sh "docker rm -f \$(docker ps -aq)"
                    sh "docker run -d -p 8082:8082 --name demo-app-container ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"                  
                }
              }
            }  
         }

//    /*     stage('Integration API Tests') {
//             steps {
//                 script {
//                     dir('automation-tests') {
//                         deleteDir()
//                         checkout([
//                             $class: 'GitSCM',
//                             branches: [[name: 'main']],
//                             userRemoteConfigs: [[
//                                 credentialsId: 'PAT_Jenkins',
//                                 url: 'https://github.com/wissda-inc/AdminServiceIntegrationTests.git'
//                             ]]
//                         ])
//                         sh "java -version"
//                         sh "mvn --version"

//                         // Run Maven tests with environment variable
//                         sh "mvn clean test -Dapplication=beta -DBASE_URL_BETA=${env.BASE_URL_BETA}"

//                         // Publish JUnit XML results (will fail the pipeline on test failures)
//                         junit allowEmptyResults: false,
//                               testResults: 'target/surefire-reports/*.xml'

//                         // Publish Surefire HTML Report
//                         publishHTML(target: [
//                             reportDir: 'target/surefire-reports',
//                             reportFiles: 'index.html',
//                             reportName: 'Integration Test Report',
//                             keepAll: true,
//                             alwaysLinkToLastBuild: true,
//                             allowMissing: true
//                         ])

//                         // Add report link to build description
//                         def reportUrl = "${env.BUILD_URL}Integration_Test_Report/"
//                         echo "📊 Integration Test Report: ${reportUrl}"
//                         currentBuild.description = "<a href='${reportUrl}'>Integration Test Report</a>"
//                     }
//                 }
//             }
//         }

        stage('Approval to Proceed') {
            steps {
                script {
                    input message: "✅ Integration API Tests passed. Proceed to Pre-Prod/Gamma deployment?",
                          ok: "Proceed"
                }
            }
        }

//         stage('Deploy to Pre-Prod/Gamma') {
//             steps {
//                 script {
//                     try {
//                         sh "sed -i 's|{IMAGE_TAG}|${IMAGE_TAG}|' devops-repo/be-microservices/pre-prod/admin/admin-deployment.yaml"
//                         withKubeConfig(caCertificate: '', clusterName: 'wdp-prod-cluster-1', contextName: '', credentialsId: 'kube-config', namespace: 'pre-prod', restrictKubeConfigAccess: false, serverUrl: '') {
//                             sh "kubectl apply -f devops-repo/be-microservices/pre-prod/admin/admin-clusterip-service.yaml"
//                             sh "kubectl apply -f devops-repo/be-microservices/pre-prod/admin/admin-deployment.yaml"
//                         }
//                     } catch (Exception e) {
//                         error "❌ Deployment to Pre-Prod failed: ${e.message}"
//                     }
//                 }
//             }
//         }

        stage('Deploy to Pre-Prod/Gamma') {
            steps {
                script {
                    try {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                        sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                        sh "docker pull ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"  
                        sh "docker rm -f \$(docker ps -aq)"
                        sh "docker run -d -p 8083:8083 --name demo-app-container-2 ${DOCKERHUB_REPO}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}" 
                        }
                    } catch (Exception e) {
                        error "❌ Deployment to Pre-Prod failed: ${e.message}"
                    }
                }
            }
        }

//         stage('Clean up ACR') {
//             steps {
//                 script {
//                     try {
//                         withCredentials([azureServicePrincipal(credentialsId: 'azure-service-principal',
//                                                                 clientIdVariable: 'AZURE_SP_CLIENT_ID',
//                                                                 clientSecretVariable: 'AZURE_SP_CLIENT_SECRET',
//                                                                 tenantIdVariable: 'AZURE_SP_TENANT_ID')]) {
//                             sh "az login --service-principal -u ${AZURE_SP_CLIENT_ID} -p ${AZURE_SP_CLIENT_SECRET} --tenant ${AZURE_SP_TENANT_ID}"

//                             def imagesOutput = sh(script: "az acr repository show-tags --name ${ACR_NAME} --repository ${DOCKER_IMAGE_NAME} --orderby time_desc --output tsv", returnStdout: true).trim()
//                             def imageTags = imagesOutput.tokenize('\n')
//                             def buildPrefix = "qa-build-"
//                             def relevantTags = imageTags.findAll { it.startsWith(buildPrefix) }
//                             def sortedTags = relevantTags.collect { it.replace("${buildPrefix}", "").toInteger() }.sort().reverse()
//                             def keepTags = sortedTags.take(3).collect { "${buildPrefix}${it}" }

//                             if (!keepTags.contains(IMAGE_TAG)) {
//                                 keepTags.add(IMAGE_TAG)
//                             }

//                             imageTags.each { imageTag ->
//                                 if (!keepTags.contains(imageTag) && imageTag.startsWith(buildPrefix)) {
//                                     sh "az acr repository delete --name ${ACR_NAME} --image ${DOCKER_IMAGE_NAME}:${imageTag} --yes"
//                                     echo "Deleted image: ${imageTag}"
//                                 }
//                             }

//                             echo "Kept images: ${keepTags.join(', ')}"
//                         }
//                     } catch (Exception e) {
//                         error "❌ Cleanup of ACR images failed: ${e.message}"
//                     }
//                 }
//             }
//         }
//     }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "🚨 Pipeline failed. Please check above logs."
        }
        always {
            cleanWs()
        }
    }
 }
