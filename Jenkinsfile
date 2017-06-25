node {
    stage("Deploy"){
	  sh "ls"
    	  docker.image('awscli').inside {
       	     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '${AWS_CRED}']]){
	          sh '''cd /
		  locate create-cluster.sh
		  '''
	     }
	  }
    }
}
