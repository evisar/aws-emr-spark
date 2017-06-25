node {
    stage("Deploy"){
	  checkout scm
    	  docker.image('awscli').inside {
       	     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '${AWS_CRED}']]){
		 sh "./create-cluster.sh"
	     }
	  }
    }
}
