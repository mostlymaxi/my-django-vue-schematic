# My-Vue-Django-App
This repo is specifically designed to be able to build and deploy vue-django projects as quickly and efficiently as possible.

Simply clone the git repo and then run rm -rf .git to unlink from the repository.

### Testing
1. Using a pipenv in the server directory run python manage.py runserver
2. In the client directory run either vue serve or npm run serve


### Deploying

In order to correctly deploy with a correct ssl certificate you must do the following:
1. Create a type A dns link from subdomain and www.subdomain to node ip address
2. Run init-letsencrypt.sh to create dummy ssl keys
3. docker-compose build and docker-compose up
4. Ensure environment variables have been declared correctly