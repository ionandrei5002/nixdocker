FROM ubuntu:18.04

RUN apt update && \
    apt install -y curl

RUN useradd -m andrei

USER root
ENV USER andrei
RUN curl -o /tmp/install-nix-2.1.3 https://nixos.org/nix/install
RUN chmod +x /tmp/install-nix-2.1.3
RUN mkdir -m 0755 /nix && \
    chown andrei /nix

USER andrei
RUN /tmp/install-nix-2.1.3
ENV NIXPKGS_ALLOW_UNFREE 1 
WORKDIR /home/andrei/
RUN . /home/andrei/.nix-profile/etc/profile.d/nix.sh && \
    nix-channel --update && \
    nix-env -f '<nixpkgs>' -i git-2.19.1 vscode-1.28.2 libcanberra-0.30 gtk-engine-murrine-0.98.2

USER root
RUN rm /tmp/install-nix-2.1.3

USER andrei
RUN mkdir ~/project && \
    . /home/andrei/.nix-profile/etc/profile.d/nix.sh && \
    code --install-extension felixfbecker.php-intellisense && \
    code --install-extension pkief.material-icon-theme && \
    echo '{ \
        "workbench.iconTheme": "material-icon-theme", \
        "workbench.colorTheme": "Solarized Dark", \
        "workbench.editor.openPositioning": "last", \
        "workbench.editor.enablePreview": true,  \
        "workbench.editor.enablePreviewFromQuickOpen": true, \
        "window.zoomLevel": 0, \
        "explorer.confirmDelete": false, \
        "vsicons.projectDetection.autoReload": true, \
        "files.autoSave": "afterDelay", \
        "workbench.startupEditor": "newUntitledFile" \
    }' > ~/.config/Code/User/settings.json

COPY php7.0.nix /home/andrei/
COPY fix-paths-php7.patch /home/andrei/
COPY fix-paths-php7.patch /home/andrei/fix-paths.patch

RUN . /home/andrei/.nix-profile/etc/profile.d/nix.sh && \
    nix-build -E 'with import <nixpkgs> {}; callPackage ./php7.0.nix {}'

USER root
RUN apt update \
    && apt install -y libnotify4 \
    libnss3 \
    libxkbfile1 \
    libgconf-2-4 \
    libsecret-1-0 \
    libgtk2.0-0 \
    libxss1 \
    libasound2 \
    libcanberra-gtk-module

RUN apt install -y \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf \
    ubuntu-mate-icon-themes \
    ubuntu-mate-themes
    
RUN echo 'include "/usr/share/themes/Ambiant-MATE/gtk-2.0/gtkrc"' > /home/andrei/.gtkrc-2.0

USER andrei
RUN . /home/andrei/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -f '<nixpkgs>' -i 'apache-httpd-2.4.35'

RUN . /home/andrei/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -i ./result

CMD ["/bin/bash", "--login"]