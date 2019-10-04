pipeline {
  agent any
  stages {
    stage("Notify Slack Channel") {
      steps {
        // send build started notifications
        slackSend (
          channel: "#softwaredev-services-firehose",
          color: "#8B0000",
          message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Started (<${env.RUN_DISPLAY_URL}|open>)\nGit Commit: ${GIT_COMMIT_HASH}",
          tokenCredentialId: "95231ecb-a041-445b-84c0-870db41e2ba8",
          teamDomain: "uclalibrary"
          )
        }
      }
    stage("Build cantaloupe-ucla") {
      parallel {
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
      message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} ${currentBuild.currentResult} after ${currentBuild.durationString.replace(' and counting', '')} (<${env.RUN_DISPLAY_URL}|open>)\nGit Commit: ${GIT_COMMIT_HASH}",
      tokenCredentialId: "95231ecb-a041-445b-84c0-870db41e2ba8",
      teamDomain: "uclalibrary"
      )
    }
  }
}

