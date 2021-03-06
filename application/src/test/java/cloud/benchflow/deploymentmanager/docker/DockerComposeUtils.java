package cloud.benchflow.deploymentmanager.docker;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import cloud.benchflow.deploymentmanager.configurations.DockerConfiguration;
import cloud.benchflow.deploymentmanager.resources.Projects;

public class DockerComposeUtils {
	
	public static void deployProject(DockerConfiguration configuration, String sourceFolder, String destFolder, String experimentId) {
		
		Projects project = new Projects(destFolder, configuration);
		
		InputStream dockerCompose = DockerComposeUtils.class.getResourceAsStream(sourceFolder + "/docker-compose.yml");

		project.deploymentDescriptor(experimentId, dockerCompose);
	
	}

	public static void configure(DockerConfiguration configuration) {

		Properties prop = new Properties();
		InputStream input = null;

		try {

			input = DockerComposeUtils.class.getResourceAsStream("/configuration.properties");

			// load a properties file
			prop.load(input);
			
			// set properties
			configuration.setCertificatesFolder(prop.getProperty("CertificatesFolder"));
			configuration.setDockerComposeFolder(prop.getProperty("DockerComposeFolder"));
			configuration.setDockerEndpoint(prop.getProperty("DockerEndpoint"));
			configuration.setDockerTLSVerify(prop.getProperty("DockerTLSVerify"));

		} catch (IOException ex) {
			ex.printStackTrace();
		} finally {
			if (input != null) {
				try {
					input.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

	}

}
