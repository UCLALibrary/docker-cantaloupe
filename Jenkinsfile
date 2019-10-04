// Variables used in this Jenkinsfile
//
// env.JOB_NAME: Jenkins Project Name
// env.BUILD_NUMBER: Jenkins project build number
// env.RUN_DISPLAY_URL: Obtains a Jenkins Blue Ocean URL that'll point to created build in this given project
// GIT_COMMIT_HASH: This is set in the Jenkins project configurations. If the job is triggered after TravisCI completes, you can pass the env TRAVIS_COMMIT and override the default value specified in the project configuration. The goal is to keep tracking of who triggered the job
// DOCKER_CANTALOUPE_GIT_BRANCH: The default is set to master in the Jenkins project configuration. For the most part, this variable can be left alone. If you want to have the CodeBuild jobs build on a different branch, you can adjust this value
// BUILD_VERSION: Relates to docker-cantaloupe's rake build. Current set to either dev or stable

pipeline {
  agent any
  stages {
    stage("Build cantaloupe-ucla") {
      parallel {
        stage("Notify Slack Channel") {
          steps {
            slackSend(
            channel: "#softwaredev-services-firehose",
            color: "#8B0000",
            tokenCredentialId: "95231ecb-a041-445b-84c0-870db41e2ba8",
            teamDomain: "uclalibrary",
            message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Started (<${env.RUN_DISPLAY_URL}|open>)\nGit Commit: ${GIT_COMMIT_HASH}"
            )
          }
        }
        stage("Building stable") {
          steps {
            awsCodeBuild(
            projectName: "docker-cantaloupe",
            credentialsId: "services-team-jenkins-codebuild-trigger ",
            region: "us-east-1",
            credentialsType: "jenkins",
            sourceControlType: "project",
            sourceVersion: "${DOCKER_CANTALOUPE_GIT_BRANCH}",
            envVariables: "[ { BUILD_VERSION, stable } ]"
          )
          }
        }
        stage("Building dev") {
          steps {
            awsCodeBuild(
            projectName: "docker-cantaloupe",
            credentialsId: "services-team-jenkins-codebuild-trigger ",
            region: "us-east-1",
            credentialsType: "jenkins",
            sourceControlType: "project",
            sourceVersion: "${DOCKER_CANTALOUPE_GIT_BRANCH}",
            envVariables: "[ { BUILD_VERSION, dev } ]"
          )
          }
        }
      }
    }
  }
  post {
    always {
      // send build result notifications
      slackSend (
      channel: "#softwaredev-services-firehose",
      color: "#8B0000",
      replyBroadcast: true,
      message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} ${currentBuild.currentResult} after ${currentBuild.durationString.replace(' and counting', '')} (<${env.RUN_DISPLAY_URL}|open>)\nGit Commit: ${GIT_COMMIT_HASH}",
      tokenCredentialId: "95231ecb-a041-445b-84c0-870db41e2ba8",
      teamDomain: "uclalibrary"
      )
    }
  }
}

