pipeline {
  def app

  agent {
    docker {
      image 'maven:3-alpine'
      args '-v /Users/menpedro/.m2:/root/.m2'
    }
  }
  stages {
    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }
    stage('Build container') {
      steps {
        app = docker.build("menpedro/myspringboot")
      }
    }
  }
}
