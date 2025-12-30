FROM kasmweb/core-ubuntu-focal:1.16.0
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
WORKDIR $HOME

######### 1. Essential Tools, XAMPP & System Core ###########
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates sudo curl gnupg2 unzip tar software-properties-common \
    build-essential gcc g++ gdb git wireshark tshark obs-studio libfuse2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install XAMPP
RUN wget --no-check-certificate \
    https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run/download -O /tmp/xampp-installer.run && \
    chmod +x /tmp/xampp-installer.run && \
    /tmp/xampp-installer.run --mode unattended && \
    rm /tmp/xampp-installer.run && \
    ln -s /opt/lampp/manager-linux-x64.run /usr/local/bin/xampp-control

RUN groupadd -f wireshark && \
    usermod -aG wireshark kasm-user && \
    chgrp wireshark /usr/bin/dumpcap && \
    chmod 750 /usr/bin/dumpcap && \
    setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap

RUN chmod -R 777 /opt/lampp/var && \
    chown -R 1000:0 /opt/lampp/htdocs && \
    chmod -R 775 /opt/lampp/htdocs

######### 2. Languages & Node.js (Python, Java, Node, Spyder Dependencies) ###########
# Install Node.js LTS and system dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends \
    nodejs openjdk-8-jdk openjdk-11-jdk python3 python3-pip python3-venv \
    libreoffice libreoffice-gtk3 libreoffice-java-common \
    libxinerama1 libgl1-mesa-glx libxslt1.1 \
    gcc g++ gdb build-essential pypy3 composer firefox obs-studio \
    # CRITICAL: Pre-compiled system dependencies for Spyder/PyQt5
    python3-nbconvert python3-qtconsole \
    pandoc texlive-xetex \
    python3-pyqt5 python3-pyqt5.qtwebengine spyder \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    "jupyter_server<2.0.0" \
    "jupyter-events<=0.9.0" \
    "nbconvert>=4.0" \
    "spyder-kernels<1.0" \
    "qtconsole<5.0" \
    "entrypoints" \
    "jupyter"

# RUN pip3 install --no-cache-dir jupyter spyder-kernels nbconvert qtconsole

######### 3. VS Code & Extensions (For All Users) ###########
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && apt-get install -y code && \
    # Pre-install requested packs
    sudo -u kasm-user code --install-extension ms-vscode.cpptools && \
    sudo -u kasm-user code --install-extension vscjava.vscode-java-pack && \
    sudo -u kasm-user code --install-extension ms-python.python

######### 4. GitHub Desktop & MongoDB ###########
RUN mkdir -p /usr/share/keyrings && \
    wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor --batch --yes -o /usr/share/keyrings/mwt-desktop.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list && \
    apt-get update && apt-get install -y github-desktop

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

######### 6. Android Studio & Flutter/Kotlin Setup ###########
RUN apt-get update && apt-get install -y --no-install-recommends \
    libx11-6 libxext6 libxrender1 libice6 libsm6 libxt6 libnss3 libgbm1 \
    libcups2 libpulse0 libasound2 \
    lib32z1 lib32ncurses6 lib32stdc++6 libbz2-1.0:i386 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/android-studio && \
    curl -L https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.20/android-studio-2022.3.1.20-linux.tar.gz | tar xz --strip-components=1 -C /opt/android-studio

ENV ANDROID_HOME=/home/kasm-user/Android/Sdk
ENV PATH="/opt/android-studio/bin:/opt/flutter/bin:${PATH}"

RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter && \
    chown -R 1000:0 /opt/flutter && \
    git config --global --add safe.directory /opt/flutter && \
    sudo -u kasm-user /opt/flutter/bin/flutter precache

RUN ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

######### 7. Local Files (Arduino & DrJava) ###########
COPY ["Arduino IDE/arduino-ide_2.3.2_Linux_64bit.zip", "/tmp/arduino.zip"]
COPY ["Arduino IDE/arduino-start.sh", "/usr/local/bin/arduino-start.sh"]
RUN mkdir -p /opt/arduino-ide && unzip /tmp/arduino.zip -d /opt/arduino-ide && rm /tmp/arduino.zip && \
    chmod -R +x /opt/arduino-ide && chmod +x /usr/local/bin/arduino-start.sh

RUN BIN_PATH=$(find /opt/arduino-ide -name "arduino-ide" -type f -executable | head -n 1) && \
    ln -s "$BIN_PATH" /usr/local/bin/arduino-ide-bin

COPY ["DrJava/drjava.jar", "/opt/drjava.jar"]
RUN echo '#!/bin/bash\njava -jar /opt/drjava.jar' > /usr/local/bin/drjava && chmod +x /usr/local/bin/drjava

COPY ["Arduino IDE/arduino-ide-logo.png", "/usr/share/icons/arduino-ide.png"]
COPY ["DrJava/DrJava-logo.png", "/usr/share/icons/drjava.png"]

######### 8. Postman ###########
RUN wget https://dl.pstmn.io/download/version/9.31.28/linux64 -O /tmp/postman.tar.gz && \
    tar -xzf /tmp/postman.tar.gz -C /opt && \
    ln -s /opt/Postman/Postman /usr/local/bin/postman && \
    rm /tmp/postman.tar.gz

######### 9. Cisco Packet Tracer 8.2.1 (Force-EULA Fix) ###########
COPY ["Cisco/CiscoPacketTracer_821_Ubuntu_64bit.deb", "/tmp/pt.deb"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    libdouble-conversion3 libqt5gui5 libqt5network5 libqt5widgets5 \
    libqt5printsupport5 libqt5xml5 libqt5multimedia5 libqt5multimediawidgets5 \
    libqt5sql5 libqt5svg5 libqt5x11extras5 libqt5serialport5 libqt5websockets5 \
    libqt5core5a libqt5dbus5 libqt5positioning5 libqt5quick5 libqt5webchannel5 \
    libqt5webenginecore5 libqt5webengine5 libqt5webenginewidgets5 \
    libqt5networkauth5 debconf-utils && \
    echo "packettracer packettracer/accept-eula select true" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/pt.deb || DEBIAN_FRONTEND=noninteractive apt-get install -y -f && \
    if [ ! -d "/opt/pt/bin" ]; then \
        mkdir -p /opt/pt && dpkg-deb -x /tmp/pt.deb /; \
    fi && \
    rm /tmp/pt.deb

RUN echo '#!/bin/bash\n/opt/pt/bin/PacketTracer --no-sandbox --appimage-extract-and-run "$@"' > /usr/bin/packettracer && \
    chmod +x /usr/bin/packettracer

######### 10. Desktop Shortcuts & Permissions ###########
RUN mkdir -p $HOME/Desktop && \
    printf "XAMPP TERMINAL COMMANDS\n\nTo START all services:\nsudo /opt/lampp/lampp start\n\nTo STOP all services:\nsudo /opt/lampp/lampp stop\n\nTo RESTART:\nsudo /opt/lampp/lampp restart\n" > $HOME/Desktop/xampp_command.txt && \
    chown 1000:0 $HOME/Desktop/xampp_command.txt && \
    chmod 644 $HOME/Desktop/xampp_command.txt && \
    printf "[Desktop Entry]\nName=VS Code\nExec=code --no-sandbox\nIcon=vscode\nType=Application\n" > $HOME/Desktop/vscode.desktop && \
    printf "[Desktop Entry]\nName=Arduino IDE\nExec=arduino-ide-bin --no-sandbox\nIcon=arduino-ide\nType=Application\n" > $HOME/Desktop/arduino.desktop && \
    printf "[Desktop Entry]\nName=DrJava\nExec=drjava\nIcon=drjava\nType=Application\n" > $HOME/Desktop/drjava.desktop && \
    printf "[Desktop Entry]\nName=GitHub Desktop\nExec=env --unset=LD_PRELOAD github-desktop --no-sandbox\nIcon=github-desktop\nType=Application\n" > $HOME/Desktop/github-desktop.desktop && \
    printf "[Desktop Entry]\nName=IntelliJ IDEA\nExec=idea\nIcon=/opt/intellij/bin/idea.png\nType=Application\n" > $HOME/Desktop/intellij.desktop && \
    printf "[Desktop Entry]\nName=MongoDB Compass\nExec=mongodb-compass --no-sandbox\nIcon=mongodb-compass\nType=Application\n" > $HOME/Desktop/mongodb-compass.desktop && \
    printf "[Desktop Entry]\nName=PyCharm\nExec=pycharm\nIcon=/opt/pycharm/bin/pycharm.png\nType=Application\n" > $HOME/Desktop/pycharm.desktop && \
    printf "[Desktop Entry]\nName=XAMPP\nExec=sudo env --unset=LD_PRELOAD /opt/lampp/manager-linux-x64.run\nIcon=utilities-terminal\nType=Application\n" > $HOME/Desktop/xampp.desktop && \
    printf "[Desktop Entry]\nName=Spyder\nExec=spyder\nIcon=spyder\nType=Application\nCategories=Development;IDE;\n" > $HOME/Desktop/spyder.desktop && \
    printf "[Desktop Entry]\nName=Android Studio\nExec=android-studio\nIcon=/opt/android-studio/bin/studio.png\nType=Application\nCategories=Development;IDE;\n" > $HOME/Desktop/android-studio.desktop && \
    printf "[Desktop Entry]\nName=Postman\nExec=env --unset=LD_PRELOAD postman --no-sandbox\nIcon=/opt/Postman/app/resources/app/assets/icon.png\nType=Application\n" > $HOME/Desktop/postman.desktop && \
    printf "[Desktop Entry]\nName=Cisco Packet Tracer 8.2.1\nExec=/usr/bin/packettracer\nIcon=utilities-terminal\nType=Application\n" > $HOME/Desktop/packettracer.desktop && \
    printf "[Desktop Entry]\nName=Wireshark\nExec=wireshark\nIcon=wireshark\nType=Application\n" > $HOME/Desktop/wireshark.desktop && \
    printf "[Desktop Entry]\nName=Jupyter Notebook\nExec=/usr/local/bin/jupyter-notebook --ip=0.0.0.0 --NotebookApp.token='' --allow-root\nIcon=jupyter\nType=Application\n" > $HOME/Desktop/jupyter.desktop && \
    chmod +x $HOME/Desktop/*.desktop

# Final Permissions
RUN echo "kasm-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R 1000:0 /opt/ /usr/share/icons/ $HOME

RUN $STARTUPDIR/set_user_permission.sh $HOME
ENV HOME=/home/kasm-user
WORKDIR $HOME
USER 1000
