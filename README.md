# My Django-Vue Schematic
Deploying projects in a clean way is one of the most difficult tasks I have ever encountered as a developer... I truly hope that this may save your life (or at least your time).

This repo is specifically designed to be able to build and deploy vue-django projects as quickly and efficiently as possible through docker containers and many hours of painful tests to get https to work on the first deployment.

- Simply clone the git repo and then run rm -rf .git to unlink from the repository.
- Install the dependencies in the base server/requirements.txt to ensure deployment succeeds

### Hosts and Headers
NOTE - This project was designed for personal use, make sure to update hosts and headers:
- In /server/server/settings.py -> ALLOWED_HOSTS, CORS_ALLOW_HEADERS
 

## Testing
1. Using a pipenv in the server directory run python manage.py runserver
2. In the client directory run either vue serve or npm run serve


## Deploying
Deploying will automatically set up an SSL certificate with autorenewal for https! 

1. Place any necessary environment variables into the .env file
2. freeze python requirements into server/requirements.txt
3. Create a type A dns link from subdomain and www.subdomain to node ip address
    - This may also be a CNAME dns link depending on your infrastructure.
4. Go grab a coffee to make sure dns links are activated!
5. run init.sh and enter your desired subdomain when prompted
    - NOTE: I reccomend running 'sudo ./init.sh' to ensure crontab has less difficulties
    - NOTE: In order to change domain run with the "-d my-domain.com" flag
    - WARNING: Leaving the subdomain blank will break everything currently


## Even More Batteries Included!
This is just a list of things I've included in the default project:
- django rest framework
- django corsheaders
- celery
- celery beat
- redis (incomplete, needs configuration)
- postgres (incomplete, needs configuration)
