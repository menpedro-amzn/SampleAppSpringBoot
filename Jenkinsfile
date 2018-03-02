node {
  stage('Checkout') {
    checkout scm
  }

  stage('Build') {
    withMaven(
    // Maven installation declared in the Jenkins "Global Tool Configuration"
    maven: 'M3') {
      // Run the maven build
      sh "mvn -B -DskipTests clean package"
    }
  }

  stage('Build Docker') {
    withMaven(
    // Maven installation declared in the Jenkins "Global Tool Configuration"
    maven: 'M3') {
      // Run the maven build
      sh "mvn install dockerfile:build"
    }
    //def app = docker.build("myspringboot:latest", "--build-arg JAR_FILE=target/myspringboot-0.0.1-SNAPSHOT.jar .")
  }

  stage('Push Docker to ECR') {
    sh("eval \$(aws ecr get-login --no-include-email --profile menpedro| sed 's|https://||')")
    docker.withRegistry("https://264359801351.dkr.ecr.us-east-1.amazonaws.com", "ecr:us-east-1:menpedro") {
      docker.image("myspringboot").push("${env.BUILD_ID}")
      docker.image("myspringboot").push("latest")
    }
  }

  stage('Redeploy to ECS') {
    sh "aws ecs update-service --cluster jenkins --service myspringboot --desired-count 2 --force-new-deployment --profile menpedro --region us-east-1"
    sleep 30
  }

  stage('Load test') {
    sh "gatling.sh -sf src/main/test -s ok.SampleAppSpringBootTest"
  }
}
