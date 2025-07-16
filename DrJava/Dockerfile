FROM kasmweb/core-ubuntu-focal:1.14.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# Install Java
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk

# Copy DrJava jar
COPY drjava.jar /opt/drjava.jar

# Create DrJava launcher
RUN echo '#!/bin/bash\njava -jar /opt/drjava.jar' > /usr/local/bin/drjava && \
    chmod +x /usr/local/bin/drjava

# Create Desktop Shortcut
RUN printf "[Desktop Entry]\n\
Name=DrJava\n\
Comment=Lightweight Java IDE\n\
Exec=drjava\n\
Icon=java\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;\n" > $HOME/Desktop/drjava.desktop && \
    chmod +x $HOME/Desktop/drjava.desktop && \
    chown 1000:1000 $HOME/Desktop/drjava.desktop

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
