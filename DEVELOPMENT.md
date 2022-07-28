## Development

Our development setup is docker-based. To install the requirements on debian use: `apt install ruby git docker.io docker-compose gzip`

### Helper Program bin/littlesis

`bin/littlesis` is a helper program that will let you easily interact with the docker containers to do common development tasks such as starting the rails console, running tests, starting sphinx, and viewing logs without having to remember esoteric docker & bash commands. `bin/littlesis` is also used in production.

To see the script's features run: `bin/littlesis help`

You can install the program with a symlink: `sudo ln -s (readlink -f bin/littlesis) /usr/local/bin/littlesis`

### Installation Steps

1) Clone this repo `git clone https://github.com/public-accountability/littlesis-rails`

2) Build the docker image `littlesis build`

3) Start the docker containers: `littlesis up`

4) Create folders:  `littlesis setup-folders`

5) If desired, load a copy of the database.

   You can utilize the littlesis psql shortcuts, for example: `zcat littlesis.sql.gz | littlesis psql`

6) Compile dev and test assets: `littlesis rake assets:precompile` && `littlesis --test rake assets:precompile`

7) Setup the testing database: `littlesis --test rake db:reset`

8) Run the tests: `littlesis test`

9) Create manticore indexes: `littlesis rake ts:rebuild`

This may take a while.

10) Visit port 8080 for Puma and `8081 for nginx

The configurations for nginx and postgres are in the folder config/docker

### Development Scripts

start development services: `docker-compose --profile development up -d`

Create example users: `littlesis script create_development_users.rb`

Start/stop app: `littlesis up/down`

Open rails console: `littlesis console`

*Manticore*

status `littlesis rake ts:status`
start `littlesis rake ts:start`
stop `littlesis rake ts:stop`
index `littlesis rake ts:index`
reconfigure `littlesis rake ts:rebuild`



Clear logs:  `littlesis rake log:clear`

Clear cache: `littlesis runner Rails.cache.clear`

Create new user: `littlesis runner lib/scripts/create_example_user.rb`

Reset user password:  `User.find_by(email: <EMAIL>).send_reset_password_instructions`

Update Network Map Collections: `littlesis rake maps:update_all_entity_map_collections`
