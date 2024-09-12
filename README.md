# Deployment using kamla and traefik configuration for ssl certificate

## steps for deploying using kamal and traefik as a reverse proxy

1. Install kamal gem.
2. Do `kamal init`  which will give us all the required files for deployment.
3. Make sure to add values to the .env variables which are already define in the .env file.
4. Start configuring the `deploy.yml`.
5. After that run kamal setup which will setup the server for deployment and deploy our web app and worker to servers
6. If kamal fails to deploy because of docker permission issue make sure to visit the server and add user to docker group by running `sudo usermod -aG docker <username>` after that logout and login to take effect.


which will deploy our app on server and you will be able to see app online.but your app will be on http and not on https for that we have to configure traefik which is a reverse-proxy

### Traefik setup:
lables to add in web service:
    
    labels:
      traefik.http.routers.kamaldeploy.rule: Host(`kamaldeploy.localhosted.in`)   # make sure its in ``
      traefik.http.routers.kamaldeploy.entryPoints: websecure
      traefik.http.routers.kamaldeploy.tls.certresolver: letsencrypt              

### configuration for traefik container with certificateresolvers:

    traefik:
      options:
        publish:
          - "443:443"
        volume:
          - "/etc/letsencrypt/acme.json:/etc/letsencrypt/acme.json"    # make sure to create this manually befor deploying
      args:
        entryPoints.web.address: ":80"
        entryPoints.websecure.address: ":443"
        entryPoints.web.http.redirections.entryPoint.to: "websecure"
        entryPoints.web.http.redirections.entryPoint.scheme: "https"
        entryPoints.web.http.redirections.entryPoint.permanent: true
        certificatesResolvers.letsencrypt.acme.email: "inglepratik0903@gmail.com"
        certificatesResolvers.letsencrypt.acme.storage: "/etc/letsencrypt/acme.json"
        certificatesResolvers.letsencrypt.acme.httpchallenge: true
        certificatesResolvers.letsencrypt.acme.httpchallenge.entrypoint: "web"

1. go to the server itself create acme.json file on this path `/etc/letsencrypt/`
steps for creating `acme.json`
run cmd `mkdir /etc/letsencrypt`
run cmd `touch /etc/letsencrypt/acme.json`
make sure to give only required permissions
by running cmd `chmod 600 /etc/letsencrypt/acme.json`

2. after that add traefik configuration inside deploy.yml file make sure the path given for acme.json file is correct.

3. Now reboot the traefik instance by running cmd `kamal traefik reboot` then answer yes

4. rebbot the web app container for setup to take effect run cmd `kamal app boot --roles=web`

5. now if you refresh the domain name you can see our app is running on https.

## for one touch deployment.

1. make sure to add the env variable and ssh key for accessing the server on github secrets.

2. make sure to store them in system on github actions please reffer workflow for the example on how to do it.

3. also change the path from the deploy.yml according to the ssh key stored in github action.

4. if facing error while deployment on 
```
  ERROR (Errno::ECONNRESET): Exceptions on 2 hosts:
    Exception while executing on host 15.206.125.202: Connection reset by peer - recvfrom(2)
    Exception while executing on host 3.110.49.102: Connection reset by peer - recvfrom(2)
```
please retry the deployment.

## Should connect to encrypted database (MYSQL)

### set up an SSL connection between your Rails app and MySQL:
1. MySQL supports secure (encrypted) connections between MySQL clients and the server using the Secure Sockets Layer (SSL) protocol. [Reference](https://dev.mysql.com/doc/mysql-secure-deployment-guide/8.0/en/secure-deployment-secure-connections.html)

2. ActiveRecord has options for SSL security (:sslkey and others in database.yml).

3. Mysql2 for the secure connection connection [Reference](https://github.com/brianmario/mysql2?tab=readme-ov-file#ssltls-options)

```
Mysql2::Client.new(
  # ...options as above...,
  :sslkey => '/path/to/client-key.pem',
  :sslcert => '/path/to/client-cert.pem',
  :sslca => '/path/to/ca-cert.pem',
  :sslcapath => '/path/to/cacerts',
  :sslcipher => 'DHE-RSA-AES256-SHA',
  :sslverify => true, # Removed in MySQL 8.0
  :ssl_mode => :disabled / :preferred / :required / :verify_ca / :verify_identity,
  )```

