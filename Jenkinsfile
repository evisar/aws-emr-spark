node {
    stage("Deploy"){
	ws {
    	  docker.image('awscli').inside {
       	     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '${AWS_CRED}']]){
	          sh '''cd /
		  locate create-cluster.sh
		  '''
	     }
	  }
	}
    }
}
