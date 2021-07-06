/*
 * Create an admin user.
 */
import jenkins.model.*
import hudson.security.*
import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration
import hudson.EnvVars;
import hudson.slaves.EnvironmentVariablesNodeProperty;
import hudson.slaves.NodeProperty;
import hudson.slaves.NodePropertyDescriptor;
import hudson.util.DescribableList;


def instance = Jenkins.getInstance()
//def env = System.getenv()
//def user = env['ADMIN_USERNAME']

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
Jenkins.instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(strategy)
Jenkins.instance.save()

// get Jenkins location configuration
def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
// set Jenkins URL
jenkinsLocationConfiguration.setUrl("http://192.168.33.10:8080/")
// set Jenkins admin email address
jenkinsLocationConfiguration.setAdminAddress("test@gmail.com")
// save current Jenkins state to disk
jenkinsLocationConfiguration.save()


public createGlobalEnvironmentVariables(String key, String value){

       Jenkins instance = Jenkins.getInstance();

       DescribableList<NodeProperty<?>, NodePropertyDescriptor> globalNodeProperties = instance.getGlobalNodeProperties();
       List<EnvironmentVariablesNodeProperty> envVarsNodePropertyList = globalNodeProperties.getAll(EnvironmentVariablesNodeProperty.class);

       EnvironmentVariablesNodeProperty newEnvVarsNodeProperty = null;
       EnvVars envVars = null;

       if ( envVarsNodePropertyList == null || envVarsNodePropertyList.size() == 0 ) {
           newEnvVarsNodeProperty = new hudson.slaves.EnvironmentVariablesNodeProperty();
           globalNodeProperties.add(newEnvVarsNodeProperty);
           envVars = newEnvVarsNodeProperty.getEnvVars();
       } else {
           envVars = envVarsNodePropertyList.get(0).getEnvVars();
       }
       envVars.put(key, value)
       instance.save()
}
createGlobalEnvironmentVariables('DockerHub_ID','dockerhub_inclemenstv')
createGlobalEnvironmentVariables('DEPLOY_HOST','192.168.50.10')
createGlobalEnvironmentVariables('DockerHub_Repository','192.168.20.10:5000')
