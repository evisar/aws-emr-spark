node {
    stage("Deploy"){
	  checkout scm
    	  docker.image('awscli').inside {
       	     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '${AWS_CRED}']]){
	         sh "chmod +x create-cluster.sh" 
		 sh "./create-cluster.sh"
	     }
	  }
    }
}
