FROM kasmweb/core-ubuntu-focal:1.14.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# Install prerequisites
RUN apt-get update && \
    apt-get install -y wget gdebi-core libasound2 libgtk-3-0 libxss1 libgconf-2-4 libnss3 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libappindicator3-1 libxrandr2

# Download and install GitHub Desktop
RUN apt-get update \
    && apt-get install -y wget apt-transport-https gnupg \
    && wget -qO - https://apt.packages.shiftkey.dev/gpg.key \
        | gpg --dearmor \
        > /usr/share/keyrings/shiftkey-packages.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" \
        > /etc/apt/sources.list.d/shiftkey-desktop.list \
    && apt-get update \
    && apt-get install -y github-desktop \
    && rm -rf /var/lib/apt/lists/*

RUN which github-desktop || find / -name github-desktop

# Create Desktop shortcut with sandbox disabled
RUN mkdir -p $HOME/Desktop && \
    printf "[Desktop Entry]\n\
Name=GitHub Desktop\n\
Comment=Git GUI\n\
Exec=env --unset=LD_PRELOAD github-desktop --no-sandbox\n\
Icon=github-desktop\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;\n" > $HOME/Desktop/github-desktop.desktop && \
    chmod +x $HOME/Desktop/github-desktop.desktop && \
    chown 1000:1000 $HOME/Desktop/github-desktop.desktop

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000