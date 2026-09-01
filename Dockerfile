ARG USERNAME=nixenv

FROM debian:bookworm-slim
ARG USERNAME

ENV TZ=Asia/Ho_Chi_Minh
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl fish git xz-utils ca-certificates procps locales tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN useradd -m -s /bin/fish -u 1000 $USERNAME

RUN curl -sSfL https://install.lix.systems/lix | sh -s -- install linux --init none --no-confirm && chown -R $USERNAME:$USERNAME /nix

USER $USERNAME
WORKDIR /home/$USERNAME
ENV USER=$USERNAME
ENV HOME=/home/$USERNAME

ENV PATH="/nix/var/nix/profiles/default/bin:/home/$USERNAME/.nix-profile/bin:/home/$USERNAME/.local/bin:${PATH}"

RUN curl -sSf https://raw.githubusercontent.com/infraflakes/kiru/main/install.sh | sh
RUN curl -sSf https://raw.githubusercontent.com/infraflakes/sutils/main/install.sh | sh

RUN git clone --depth=1 https://github.com/infraflakes/devenv ~/.config/kiru

RUN kiru sync

RUN nix-shell -p stow home-manager --run 'kiru run bootstrap'

ENV SHELL=/bin/fish

CMD ["fish"]
