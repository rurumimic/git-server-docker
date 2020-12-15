FROM alpine:3.12

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
# openssh=8.3_p1-r0 \
  openssh \
# git=2.26.2-r0
  git

# Key generation on the server
# ssh-keygen: generating new host keys: RSA DSA ECDSA ED25519
RUN ssh-keygen -A

# SSH autorun
# RUN rc-update add sshd

WORKDIR /git

# -D flag avoids password generation
# -s flag changes user's shell
# git:x:1000:1000:Linux User,,,:/home/git:/usr/bin/git-shell
# and unlock user by setting a password
RUN adduser -D -s /usr/bin/git-shell git \
  && echo git:12345 | chpasswd \
  && mkdir /git/keys /git/repos \
  && mkdir /home/git/.ssh

# This is a login shell for SSH accounts to provide restricted Git access.
# It permits execution only of server-side Git commands implementing the
# pull/push functionality, plus custom commands present in a subdirectory
# named git-shell-commands in the user’s home directory.
# More info: https://git-scm.com/docs/git-shell
COPY --chown=git:git git-shell-commands /home/git/git-shell-commands

# sshd_config file is edited for enable access key and disable access password
COPY sshd_config /etc/ssh/sshd_config
COPY start.sh start.sh

EXPOSE 22

CMD ["sh", "start.sh"]
