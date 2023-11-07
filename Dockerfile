# Use Ubuntu Jammy as the base image
FROM ubuntu:jammy

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -m -d /opt/glassfish6 -U -s /bin/false glassfish

# Update the package list and install necessary packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y openjdk-8-jdk maven wget unzip
#RUN apt-get update && apt-get upgrade -y && apt-get install -y default-jdk maven wget unzip

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Setup environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV GF_HOME /usr/local/glassfish6
ENV PATH $PATH:$JAVA_HOME/bin:$GF_HOME/bin

# Set the working directory inside the container
WORKDIR /workspace/app
EXPOSE 8080 4848

VOLUME /tmp
#COPY glassfish.service .

# install glassfish
#RUN curl -L -o /tmp/glassfish6.zip https://www.eclipse.org/downloads/download.php?file=/ee4j/glassfish/glassfish-6.2.5.zip
RUN wget https://www.eclipse.org/downloads/download.php?file=/ee4j/glassfish/glassfish-6.2.5.zip -O /tmp/glassfish6.zip && \
    unzip /tmp/glassfish6.zip -d /usr/local  && \
    chmod -R a+x /usr/local/glassfish6  && \
    rm -f /tmp/glassfish6.zip

# Secure GF installation with a password and authorize network access
ADD password_1.txt /tmp/password_1.txt
ADD password_2.txt /tmp/password_2.txt
RUN asadmin --user admin --passwordfile /tmp/password_1.txt change-admin-password --domain_name domain1 ; asadmin start-domain domain1 ; asadmin --user admin --passwordfile /tmp/password_2.txt enable-secure-admin ; asadmin stop-domain domain1
RUN rm /tmp/password_?.txt


# Copy the contents of your project to the container
#COPY mvnw .
#COPY .mvn .mvn
#COPY pom.xml .
#COPY src src

#RUN mvn install -DskipTests
#RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

#VOLUME /tmp
#ARG DEPENDENCY=/workspace/app/target/dependency
#COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
#COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
#COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

EXPOSE 8080 4848

# Add our GF startup script
ADD         glassfish-start.sh /usr/local/bin/glassfish-start.sh
RUN         chmod 755 /usr/local/bin/glassfish-start.sh


CMD        []
ENTRYPOINT ["/usr/local/bin/glassfish-start.sh"]