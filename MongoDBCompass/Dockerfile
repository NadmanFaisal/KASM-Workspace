FROM kasmweb/core-ubuntu-focal:1.14.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt-get update && apt-get install -y \
    wget \
    gconf2 \
    libgtk-3-0 \
    libxss1 \
    libgconf-2-4 \
    libnss3 \
    libasound2 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Download and install MongoDB Compass
RUN wget -O /tmp/mongodb-compass.deb https://downloads.mongodb.com/compass/mongodb-compass_1.42.3_amd64.deb \
    && apt-get update && apt-get install -y /tmp/mongodb-compass.deb \
    && rm /tmp/mongodb-compass.deb

# Create Desktop entry for MongoDB
RUN mkdir -p $HOME/Desktop && \
    printf "[Desktop Entry]\n\
Name=MongoDB Compass\n\
Comment=MongoDB Compass GUI\n\
Exec=mongodb-compass --no-sandbox\n\
Icon=mongodb-compass\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;\n" > $HOME/Desktop/mongodb-compass.desktop && \
    chmod +x $HOME/Desktop/mongodb-compass.desktop && \
    chown 1000:1000 $HOME/Desktop/mongodb-compass.desktop

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
