ARG USERNAME=nixenv

FROM debian:bookworm-slim
ARG USERNAME

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl fish git xz-utils ca-certificates procps locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN useradd -m -s /bin/fish -u 1000 $USERNAME && \
    mkdir -m 0755 /nix && chown $USERNAME:$USERNAME /nix

USER $USERNAME
WORKDIR /home/$USERNAME
ENV USER=$USERNAME
ENV HOME=/home/$USERNAME
ENV PATH="/home/$USERNAME/.nix-profile/bin:/home/$USERNAME/.local/bin:${PATH}"

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# explicit hardware tuning & flake configuration
RUN mkdir -p ~/.config/nix && \
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf && \
    echo "cores = 0" >> ~/.config/nix/nix.conf && \
    echo "auto-optimise-store = true" >> ~/.config/nix/nix.conf && \
    echo "max-jobs = auto" >> ~/.config/nix/nix.conf

RUN git clone --depth=1 https://github.com/infraflakes/nixenv

RUN nix run nixpkgs#home-manager -- switch --flake ./nixenv#${USERNAME}@container

RUN rm -r ~/nixenv

RUN curl -sSf https://raw.githubusercontent.com/infraflakes/kiru/main/install.sh | sh

RUN curl -sSf https://raw.githubusercontent.com/infraflakes/sutils/main/install.sh | sh

RUN git clone --depth=1 https://github.com/infraflakes/deploy

RUN kiru -c ~/deploy/nixenv.kiru sync

RUN kiru -c ~/deploy/nixenv.kiru fn init dots

ENV SHELL=/bin/fish

CMD ["fish"]
