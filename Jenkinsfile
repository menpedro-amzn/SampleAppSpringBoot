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
}
