FROM kasmweb/core-ubuntu-focal:1.16.0
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN echo 'To run xampp, in the terminal type: sudo /opt/lampp/lampp start' > $HOME/Desktop/xampp_instruction.txt

# Download and install XAMPP (corrected URL)
RUN wget https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run/download \
     -O /tmp/xampp-installer.run && \
    chmod +x /tmp/xampp-installer.run && \
    /tmp/xampp-installer.run --mode unattended && \
    rm /tmp/xampp-installer.run

RUN chmod a+rx /opt/lampp/manager-linux-x64.run

# Symlink control panel to PATH for easier launching
RUN ln -s /opt/lampp/manager-linux-x64.run /usr/local/bin/xampp-control

# Desktop Entry
RUN printf "[Desktop Entry]\n\
Name=XAMPP Control Panel\n\
Comment=Manage Apache, MySQL, ProFTPD\n\
Exec=env --unset=LD_PRELOAD /opt/lampp/manager-linux-x64.run\n\
Icon=utilities-terminal\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;\n" \
> $HOME/Desktop/xampp.desktop && \
    chmod +x $HOME/Desktop/xampp.desktop && \
    chown 1000:1000 $HOME/Desktop/xampp.desktop

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME
RUN mkdir -p $HOME/Desktop && chown -R 1000:0 $HOME/Desktop

RUN apt-get update && apt-get install -y sudo && \
    echo "kasm-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER 1000