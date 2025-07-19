FROM kasmweb/core-ubuntu-focal:1.16.0
USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/home/kasm-user
WORKDIR $HOME

# Install dependencies required by Arduino IDE
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libx11-6 libxext-dev libxrender-dev libxtst-dev \
        libcanberra-gtk-module libcanberra-gtk3-module \
        libxshmfence1 libglu1 libnss3-dev \
        libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev libsecret-1-dev \
        x11-apps && \
    rm -rf /var/lib/apt/lists/*

# Copy Arduino IDE from local context
COPY ./arduino-ide /opt/arduino-ide

# Copy startup script to user's home
COPY ./arduino-start.sh /home/kasm-user/arduino-start.sh
RUN chmod +x /home/kasm-user/arduino-start.sh

# Configure Kasm to launch Arduino IDE at session start
RUN mkdir -p /home/kasm-user/.config && \
    echo "/home/kasm-user/arduino-start.sh" > /home/kasm-user/.config/autostart-kasm-app

# Create Desktop Shortcut for Arduino IDE
RUN mkdir -p /home/kasm-user/Desktop && \
    printf "[Desktop Entry]\n\
Name=Arduino IDE\n\
Comment=Arduino Pro IDE\n\
Exec=/opt/arduino-ide/arduino-ide --no-sandbox\n\
Icon=/opt/arduino-ide/resources/app/resources/icons/256x256.png\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;\n" > /home/kasm-user/Desktop/arduino.desktop && \
    chmod +x /home/kasm-user/Desktop/arduino.desktop && \
    chown 1000:1000 /home/kasm-user/Desktop/arduino.desktop

# Set permissions
RUN chown -R 1000:0 /opt/arduino-ide /home/kasm-user

# Configure Kasm to launch Arduino IDE at session start
RUN echo "/home/kasm-user/arduino-start.sh" > /home/kasm-user/.config/autostart-kasm-app


USER 1000
