node {
  stage('Checkout') {
    checkout scm
  }

  stage('Build') {
    sh "mvn -B -DskipTests clean package"
  }

  stage('Build Docker') {
    //sh "mvn install dockerfile:build"
    docker.build("myspringboot:latest", "--build-arg JAR_FILE=target/myspringboot-0.0.1-SNAPSHOT.jar .")
  }

  stage('Push Docker to ECR') {
    sh("eval \$(aws ecr get-login --no-include-email | sed 's|https://||')")
    sh("docker tag myspringboot 264359801351.dkr.ecr.us-east-1.amazonaws.com/myspringboot:${env.BUILD_ID}")
    sh("docker push 264359801351.dkr.ecr.us-east-1.amazonaws.com/myspringboot:${env.BUILD_ID}")
    sh("docker tag myspringboot 264359801351.dkr.ecr.us-east-1.amazonaws.com/myspringboot:latest")
    sh("docker push 264359801351.dkr.ecr.us-east-1.amazonaws.com/myspringboot:latest")    
  }

  stage('Redeploy to ECS PreProd') {
    sh "aws ecs update-service --cluster jenkins --service myspringboot-pre --desired-count 1 --force-new-deployment --region us-east-1"
    sleep 30
  }

  stage('Load test') {
    FLOOD_TOKEN = sh (
      script: "aws ssm get-parameters --names 'FloodIoToken' --with-decryption | jq -r '.Parameters[0].Value'",
      returnStdout: true
    ).trim()
    //sh "./src/main/test/floodio.sh $FLOOD_TOKEN ./src/main/test/SampleAppSpringBootTest.scala ${env.BUILD_ID}"
    sh "gatling.sh -sf src/main/test -s ok.SampleAppSpringBootTest"
  }

  stage('Redeploy to ECS Prod') {
    sh "aws ecs update-service --cluster jenkins --service myspringboot --desired-count 1 --force-new-deployment --region us-east-1"
  }

}
