node {
    stage("Build"){
    	docker.image('awscli').inside {
       	   withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '${AWS_CRED}']]){
	        sh "/var/lib/jenkins/workspace/aws-emr-spark/create-cluster.sh"
	   }
	}
    }
}
