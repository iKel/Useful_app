# Creating a base image for Jenkins Master
# Preinstall required plugins
# Set uJlugin

FROM jenkins/jenkins:latest
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false 
ENV CASC_JENKINS_CONFIG /var/lib/jenkins/casc.yaml
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/lib/jenkins/casc.yaml