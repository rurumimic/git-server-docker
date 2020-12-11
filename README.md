# git-server-docker

A lightweight Git Server Docker image built with Alpine Linux. Available on [GitHub](https://github.com/rurumimic/git-server-docker) and [Docker Hub](https://hub.docker.com/r/rurumimic/git-server-docker/)

!["image git server docker" "git server docker"](git-server-docker.jpg)

1. [git-server-docker](#git-server-docker)
	1. [Basic Usage](#basic-usage)
		1. [How to use a public key](#how-to-use-a-public-key)
		1. [How to check that container works (you must to have a key)](#how-to-check-that-container-works-you-must-to-have-a-key)
		1. [How to create a new repo](#how-to-create-a-new-repo)
		1. [How to upload a repo](#how-to-upload-a-repo)
		1. [How clone a repository](#how-clone-a-repository)
	1. [Arguments](#arguments)
	1. [SSH Keys](#ssh-keys)
	1. [Build Image](#build-image)
	1. [Docker-Compose](#docker-compose)
	1. [Kubernetes](#kubernetes)

---

## Basic Usage

How to run the container in port 2222 with two volumes: keys volume for public keys and repos volume for git repositories:

```bash
docker run -d -p 2222:22 -v ~/git/keys:/git/keys -v ~/git/repos:/git/repos rurumimic/git-server-docker
```

### How to use a public key

Copy them to keys folder: 
- From host: `cp ~/.ssh/id_ed25519.pub ~/git/keys`
- From remote: `scp ~/.ssh/id_ed25519.pub user@host:~/git/keys`

You need restart the container when keys are updated:

```bash
docker restart <container-id>
```
	
### How to check that container works (you must to have a key)

```bash
ssh -T git@<server-ip> -p 2222

Welcome to git-server-docker!
You've successfully authenticated, but I do not
provide interactive shell access.
```

### How to create a new repo

```bash
cd myrepo
git init --shared=true
git add .
git commit -m "my first commit"
cd ..
git clone --bare myrepo myrepo.git
```

### How to upload a repo

From host:
```bash
mv myrepo.git ~/git/repos
```
From remote:
```bash
scp -r myrepo.git user@host:~/git/repos
```

### How clone a repository

```bash
git clone ssh://git@<server-ip>:2222/git/repos/myrepo.git
```

---

## Arguments

- **Expose ports**: 22
- **Volumes**:
	- `/git/keys`: Volume to store the users public keys
 	- `/git/repos`: Volume to store the repositories

---

## SSH Keys

How generate a pair keys in client machine:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

How upload quickly a public key to host volume:

```bash
scp ~/.ssh/id_ed25519.pub user@host:~/git/keys
```

---

## Build Image

How to make the image:

```bash
docker build -t git-server-docker .
```

---

## Docker-Compose

You can edit docker-compose.yml and run this container with docker-compose:

```bash
docker-compose up -d
```

Clone:

```bash
git clone ssh://git@<server-ip>:32222/git/repos/myrepo.git
```

--- 

## Kubernetes

- port: 2222
- nodePort: 32222

Edit `volumes`:

```yaml
volumes:
  - name: repos
    hostPath: 
      path: <path-to-dir>/git/repos
  - name: keys
    hostPath:
      path: <path-to-dir>/git/keys
```

Apply yaml file:

```bash
kubectl apply -f deployment.yaml
```

Clone:

```bash
git clone ssh://git@<server-ip>:32222/git/repos/myrepo.git
```
