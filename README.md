# Test Git Repo

This is a simple container whose only job is to server as a git repository accessible through both HTTP and SSH for integration testing purposes.

## Security Implications

⚠️ PLEASE do not use this for anything other than testing purposes, with the idea that the container and all of its data will be destroyed after your tests.  This image was built with ease of testing in mind, at the cost of any semblance of security or other optimizations.

The SSH host key will always be the same on each startup, which will prevent users from needing to deal with known host key violations.  If for some reason you do want to test for it, or run with your own host key for a different reason, add a file-level mount at `/etc/ssh/ssh_host_rsa_key`.

## Running the container

All that's needed is to expose the HTTP and SSH ports.  In this (and subsequent) examples we will use port `8080` locally for HTTP and `2222` for SSH:

```bash
docker run -it --rm -p 8080:80 -p 2222:22 ghcr.io/fred-drake/testgitrepo
```

## HTTP Access

The username is `testuser` and the password is `testing`:

```bash
git clone http://testuser@localhost:8080/test.git
```

## SSH Access

The container comes with a pre-configured private and public key which allows password-less access via SSH.  You can get the private key directly from the code repository, or copy it from the image, stored in the root directory under the name `ssh_user_key`.  If you use your own key, then add a file-level mount at `/home/testuser/.ssh/authorized_keys` when you run your container.

```bash
GIT_SSH_COMMAND='ssh -i /path/to/your/ssh_user_key -p 2222' git clone testuser@localhost:/test.git
```
