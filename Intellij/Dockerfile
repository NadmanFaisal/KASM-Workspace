FROM kasmweb/core-ubuntu-focal:1.14.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# Install Java and dependencies
RUN apt-get update && \
    apt-get install -y curl wget unzip libxext6 libxrender1 libxtst6 libfreetype6 openjdk-8-jdk && \
    apt-get clean

# Download and install IntelliJ IDEA Community Edition
ENV IDEA_VERSION 2021.3.3
ENV IDEA_URL https://download.jetbrains.com/idea/ideaIC-${IDEA_VERSION}.tar.gz

RUN mkdir -p /opt/intellij && \
    curl -L $IDEA_URL | tar xz --strip-components=1 -C /opt/intellij && \
    ln -s /opt/intellij/bin/idea.sh /usr/local/bin/idea

# Create IntelliJ Desktop Shortcut
RUN mkdir -p /home/kasm-user/Desktop && \
    printf "[Desktop Entry]\n\
    Name=IntelliJ IDEA\n\
    Comment=JetBrains IntelliJ IDEA Community Edition\n\
    Exec=/opt/intellij/bin/idea.sh\n\
    Icon=/opt/intellij/bin/idea.png\n\
    Terminal=false\n\
    Type=Application\n\
    Categories=Development;\n" > /home/kasm-user/Desktop/intellij.desktop && \
        chmod +x /home/kasm-user/Desktop/intellij.desktop && \
        chown 1000:1000 /home/kasm-user/Desktop/intellij.desktop

######### End Customizations ###########

RUN chown -R 1000:0 /opt/intellij
RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000