ARG BASE_IMAGE="scottyhardy/docker-remote-desktop"
#ARG BASE_IMAGE="amd64/ubuntu"
#ARG TAG="18.04"
ARG TAG="ubuntu-18.04"

FROM ${BASE_IMAGE}:${TAG}
# Install prerequisites
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt update && apt install -y --no-install-recommends \
	apt-transport-https \
	ca-certificates \
	gosu \
	gnupg \
	p7zip \
	aptitude \
	tzdata \
	unzip \
	wget \
	winbind \
	xvfb \
	zenity \
	sudo \
	software-properties-common \
	gvfs-backends gvfs-common gvfs-fuse \
    && rm -rf /var/lib/apt/lists/*
	#gpg-agent \
	#cabextract \
	#git \
	#ssh \
	#pulseaudio \
	#pulseaudio-utils \

RUN wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key \
	&& apt-key add Release.key \
	&& apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'
# Install wine , winetricks, mono , gecko
ARG WINE_BRANCH="devel"
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key && apt-key add winehq.key \
	&& apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    && dpkg --add-architecture i386 \
	&& apt update \
	&& aptitude install winehq-${WINE_BRANCH} -y \
	&& apt install winetricks -y \
    && rm -rf /var/lib/apt/lists/* \
	&& apt autoremove

	#&& apt install winetricks wine-gecko\* mono-complete -y \
# Install winetricks
#RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
#    && chmod +x /usr/bin/winetricks
RUN apt update && apt install build-essential zlib1g-dev pkg-config \
	libglib2.0-dev binutils-dev libboost-all-dev autoconf libtool \
	libssl-dev libpixman-1-dev libpython-dev python-pip python-capstone \
	virtualenv ninja-build virt-manager libvirt-daemon-system \
	libvirt-clients libsdl2-dev -y

# Download gecko and mono installers
COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(dpkg -s wine-${WINE_BRANCH} | grep "^Version:\s" | awk '{print $2}' | sed -E 's/~.*$//')"

#COPY pulse-client.conf /root/pulse/client.conf
COPY entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
