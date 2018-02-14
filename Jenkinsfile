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
    //def app = docker.build("myspringboot:${env.BUILD_ID}")
    def app = docker.build("myspringboot:latest")
  }

  stage('Push Docker to ECR') {
    sh "curl \"https://s3.amazonaws.com/aws-cli/awscli-bundle.zip\" -o \"awscli-bundle.zip\""
    sh "unzip awscli-bundle.zip"
    sh "./awscli-bundle/install -b ~/bin/aws"
    sh("eval \$(aws ecr get-login --no-include-email | sed 's|https://||')")
    docker.withRegistry("https://264359801351.dkr.ecr.us-east-1.amazonaws.com", "ecr:us-east-1:menpedro") {
      //docker.image("myspringboot").push(${env.BUILD_ID})
      docker.image("myspringboot").push("latest")
    }
  }

}
