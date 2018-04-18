pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    ECR_REPO = '264359801351.dkr.ecr.us-east-1.amazonaws.com'
  }

  triggers {
    pollSCM('* * * * *')
  }

  stages {
    stage('Build') {
      steps {
        sh "mvn -B -DskipTests clean package"
      }
    }

    stage('Security test') {
      steps {
        sh "mv target/myspringboot-0.0.1-SNAPSHOT.jar target/myspringboot-0.0.1-SNAPSHOT.jar.withdeps"
        sh "mv target/myspringboot-0.0.1-SNAPSHOT.jar.original target/myspringboot-0.0.1-SNAPSHOT.jar"
        sh 'docker run --rm -v $PWD:/target stono/hawkeye'
        sh "mv target/myspringboot-0.0.1-SNAPSHOT.jar target/myspringboot-0.0.1-SNAPSHOT.jar.original"
        sh "mv target/myspringboot-0.0.1-SNAPSHOT.jar.withdeps target/myspringboot-0.0.1-SNAPSHOT.jar"
      }
    }

    stage('Build Docker') {
      steps {
        sh "docker build --build-arg JAR_FILE=target/myspringboot-0.0.1-SNAPSHOT.jar -t myspringboot:latest ."
      }
    }

    stage('Push Docker to ECR') {
      steps {
        sh "eval \$(aws ecr get-login --no-include-email --region ${env.AWS_REGION} | sed 's|https://||')"
        sh "docker tag myspringboot ${env.ECR_REPO}/myspringboot:${env.GIT_COMMIT}"
        sh "docker push ${env.ECR_REPO}/myspringboot:${env.GIT_COMMIT}"
        sh "docker tag myspringboot ${env.ECR_REPO}/myspringboot:latest"
        sh "docker push ${env.ECR_REPO}/myspringboot:latest"
      }
    }

    stage('Redeploy to ECS PreProd') {
      steps {
        sh "aws ecs update-service --cluster jenkins --service myspringboot-pre --desired-count 1 --force-new-deployment --region ${env.AWS_REGION}"
        sleep 30
      }
    }

/*
    stage('Load test - FloodIO') {
      steps {
        script {
          FLOOD_TOKEN = sh (
            script: "aws ssm get-parameters --names 'FloodIoToken' --with-decryption --region ${env.AWS_REGION} | jq -r '.Parameters[0].Value'",
            returnStdout: true
          ).trim()
        }
        sh "./src/main/test/floodio.sh $FLOOD_TOKEN ./src/main/test/SampleAppSpringBootTest.scala ${env.GIT_COMMIT}"
      }
    }
*/

    stage('Load test - Gatling') {
      steps {
        sh 'docker run --rm -v $PWD:/my-app denvazh/gatling -sf /my-app/src/main/test -s ok.SampleAppSpringBootTest'
      }
    }

    stage('Redeploy to ECS Prod') {
      options {
          timeout(time: 5, unit: 'MINUTES')
      }
      input {
        message "Approve deployment?"
        ok "Yes, we should."
        submitter "admin"
      }
      steps {
        sh "aws ecs update-service --cluster jenkins --service myspringboot --desired-count 1 --force-new-deployment --region ${env.AWS_REGION}"
      }
    }
  }
}
