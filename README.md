# My-Vue-Django-App
Deploying projects in a clean way is one of the most difficult tasks I have ever encountered as a developer... While I don't know how common vue-django stack apps are this may prove to be your life saver.

This repo is specifically designed to be able to build and deploy vue-django projects as quickly and efficiently as possible through docker containers and many hours of painful tests to get https to work on the first deployment.

Simply clone the git repo and then run rm -rf .git to unlink from the repository.

NOTE - This project was designed for personal use, make sure to update these values:
1. In default.conf -> server name, location /, and ssl certificates
2. In /server/server/settings.py -> ALLOWED_HOSTS, CORS_ALLOW_HEADERS
 

### Testing
1. Using a pipenv in the server directory run python manage.py runserver
2. In the client directory run either vue serve or npm run serve


### Deploying
1. Place any necessary environment variables into the .env file
2. freeze python requirements into /server/requirements.txt

In order to correctly deploy with a correct ssl certificate you must do the following:
1. Create a type A dns link from subdomain and www.subdomain to node ip address
2. Run init-letsencrypt.sh to create dummy ssl keys
3. docker-compose build and docker-compose up
4. Ensure environment variables have been declared correctly