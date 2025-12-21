FROM kasmweb/core-ubuntu-focal:1.16.0
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
WORKDIR $HOME

######### 1. Essential Tools & XAMPP (Longest Task First) ###########
# Install wget and ca-certificates first to ensure downloads work
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install XAMPP
RUN wget --no-check-certificate \
    https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run/download -O /tmp/xampp-installer.run && \
    chmod +x /tmp/xampp-installer.run && \
    /tmp/xampp-installer.run --mode unattended && \
    rm /tmp/xampp-installer.run && \
    ln -s /opt/lampp/manager-linux-x64.run /usr/local/bin/xampp-control

######### 2. System Dependencies (Firefox, LibreOffice, Java) ###########
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gdebi-core unzip tar gnupg2 apt-transport-https \
    libx11-6 libxext-dev libxrender-dev libxtst-dev libfreetype6 \
    libcanberra-gtk-module libcanberra-gtk3-module libxshmfence1 \
    libglu1 libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev \
    libsecret-1-dev x11-apps libasound2 libgconf-2-4 libx11-xcb1 \
    libxcomposite1 libxcursor1 libxdamage1 libxi6 libappindicator3-1 \
    libxrandr2 libgbm1 libpango-1.0-0 libpangocairo-1.0-0 \
    libatk-bridge2.0-0 libxslt1.1 python3 python3-pip python3-venv \
    firefox libreoffice openjdk-8-jdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

######### 3. GitHub Desktop (Mwt Mirror) ###########
RUN mkdir -p /usr/share/keyrings && \
    wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor --batch --yes -o /usr/share/keyrings/mwt-desktop.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list && \
    apt-get update && apt-get install -y github-desktop

######### 4. MongoDB Compass ###########
RUN wget --no-check-certificate -O /tmp/mongodb-compass.deb \
    https://downloads.mongodb.com/compass/mongodb-compass_1.42.3_amd64.deb && \
    apt-get update && apt-get install -y /tmp/mongodb-compass.deb && \
    rm /tmp/mongodb-compass.deb

######### 5. JetBrains (IntelliJ & PyCharm) ###########
ENV IDEA_VERSION=2021.3.3
RUN mkdir -p /opt/intellij && \
    curl -L https://download.jetbrains.com/idea/ideaIC-${IDEA_VERSION}.tar.gz | tar xz --strip-components=1 -C /opt/intellij && \
    ln -s /opt/intellij/bin/idea.sh /usr/local/bin/idea

RUN wget https://download.jetbrains.com/python/pycharm-community-2024.1.tar.gz -O /tmp/pycharm.tar.gz && \
    mkdir -p /opt/pycharm && \
    tar -xzf /tmp/pycharm.tar.gz --strip-components=1 -C /opt/pycharm && \
    ln -s /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm && \
    rm /tmp/pycharm.tar.gz

######### 6. Local Files (Arduino & DrJava) ###########
RUN apt-get update && apt-get install -y unzip && apt-get clean

COPY ["Arduino IDE/arduino-ide_2.3.2_Linux_64bit.zip", "/tmp/arduino.zip"]
COPY ["Arduino IDE/arduino-start.sh", "/usr/local/bin/arduino-start.sh"]
RUN mkdir -p /opt/arduino-ide && unzip /tmp/arduino.zip -d /opt/arduino-ide && rm /tmp/arduino.zip
RUN chmod -R +x /opt/arduino-ide && chmod +x /usr/local/bin/arduino-start.sh

RUN BIN_PATH=$(find /opt/arduino-ide -name "arduino-ide" -type f -executable | head -n 1) && \
    ln -s "$BIN_PATH" /usr/local/bin/arduino-ide-bin

COPY ["DrJava/drjava.jar", "/opt/drjava.jar"]
RUN echo '#!/bin/bash\njava -jar /opt/drjava.jar' > /usr/local/bin/drjava && chmod +x /usr/local/bin/drjava

COPY ["Arduino IDE/arduino-ide-logo.png", "/usr/share/icons/arduino-ide.png"]
COPY ["DrJava/DrJava-logo.png", "/usr/share/icons/drjava.png"]
######### 7. Desktop Shortcuts & Permissions ###########
RUN mkdir -p $HOME/Desktop && \
    printf "[Desktop Entry]\nName=Arduino IDE\nExec=arduino-ide-bin --no-sandbox\nIcon=arduino-ide\nTerminal=false\nType=Application\n" > $HOME/Desktop/arduino.desktop && \
    printf "[Desktop Entry]\nName=DrJava\nExec=drjava\nIcon=drjava\nTerminal=false\nType=Application\n" > $HOME/Desktop/drjava.desktop && \
    printf "[Desktop Entry]\nName=GitHub Desktop\nExec=env --unset=LD_PRELOAD github-desktop --no-sandbox\nIcon=github-desktop\nTerminal=false\nType=Application\nCategories=Development;\n" > $HOME/Desktop/github-desktop.desktop && \
    printf "[Desktop Entry]\n\Name=IntelliJ IDEA\nExec=/opt/intellij/bin/idea.sh\nIcon=/opt/intellij/bin/idea.png\nTerminal=false\nType=Application\nCategories=Development;\n" > $HOME/Desktop/intellij.desktop && \
    printf "[Desktop Entry]\nName=MongoDB Compass\nExec=mongodb-compass --no-sandbox\nIcon=mongodb-compass\nTerminal=false\nType=Application\nCategories=Development;\n" > $HOME/Desktop/mongodb-compass.desktop && \
    printf "[Desktop Entry]\nName=PyCharm\n\Exec=pycharm\nIcon=/opt/pycharm/bin/pycharm.png\nTerminal=false\nType=Application\nCategories=Development;\n" > $HOME/Desktop/pycharm.desktop && \
    printf "[Desktop Entry]\nName=XAMPP Control Panel\nExec=sudo env --unset=LD_PRELOAD /opt/lampp/manager-linux-x64.run\nIcon=utilities-terminal\nTerminal=false\nType=Application\n" > $HOME/Desktop/xampp.desktop && \
    chmod +x $HOME/Desktop/*.desktop

# Final Permissions
RUN echo "kasm-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R 1000:0 /opt/arduino-ide /opt/intellij /opt/pycharm /opt/lampp /opt/drjava.jar && \
    chown -R 1000:0 $HOME

RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
USER 1000
