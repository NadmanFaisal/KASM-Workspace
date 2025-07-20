FROM kasmweb/core-ubuntu-focal:1.14.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt-get update -y && \
    apt-get install -y && \
    apt-get install -y python3 python3-pip wget libcanberra-gtk-module libxslt1.1 libxss1 && \
    apt-get clean

RUN wget https://download.jetbrains.com/python/pycharm-community-2024.1.tar.gz -O /tmp/pycharm.tar.gz && \
    mkdir -p /opt/pycharm && \
    tar -xzf /tmp/pycharm.tar.gz --strip-components=1 -C /opt/pycharm && \
    ln -s /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm && \
    rm /tmp/pycharm.tar.gz && \
    apt-get clean

# Create Desktop Shortcut
RUN printf "[Desktop Entry]\n\
Name=PyCharm\n\
Comment=Python IDE\n\
Exec=pycharm\n\
Icon=python3\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;\n" > $HOME/Desktop/pycharm.desktop && \
    chmod +x $HOME/Desktop/pycharm.desktop && \
    chown 1000:1000 $HOME/Desktop/pycharm.desktop

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000