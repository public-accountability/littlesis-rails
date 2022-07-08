## Development

Our development setup is docker-based. To install the requirements on debian use: `apt install bash git docker.io docker-compose gzip`

### Helper Program bin/littlesis

`bin/littlesis` is a helper program that will let you easily interact with the docker containers to do common development tasks such as starting the rails console, running tests, starting sphinx, and viewing logs without having to remember esoteric docker & bash commands.

To see the script's features run: `bin/littlesis help`

Although not necessary, it is suggested to create symlink for `bin/littlesis`: `sudo ln -s (readlink -f bin/littlesis) /usr/local/bin/littlesis`

### Installation Steps

1) Clone this repo. `git clone https://github.com/public-accountability/littlesis-rails`

2) Build the docker image  `littlesis build`

3) Start the docker containers: `littlesis up`

4) Create folders:  `littlesis setup-folders`

5) Load a copy of the database `zcat littlesis.sql.gz | littlesis psql`.
   Afterwards, if needed, run `littlesis psql < lib/sql/clean_users.sql`

6) Compile assets: `littlesis rake assets:precompile`

7) Create manticore indexes `littlesis rake ts:rebuild`

The app is accessible at `localhost:8080` and `localhost:8081`. 8080 goes to directly to puma. 8081 is nginx.

8) Setup the testing database: `littlesis --test rake db:reset`

9) Compile test assets: `littlesis --test rake assets:precompile`

10) Run the tests: ` littlesis test `

The configurations for nginx and postgres are in the folder config/docker

### Subsequent runs

Start/stop app: `littlesis up/down`

Open rails console: `littlesis console`

*Manticore*
    - status: `littlesis rake ts:status`
    - start: `littlesis rake ts:start`
    - index: `littlesis rake ts:index`
    - reconfigure: `littlesis rake ts:rebuild`

Start title extractor service: `docker-compose --profile title-extractor up -d`

Clear logs:  `littlesis rake log:clear`

Clear cache: `littlesis runner Rails.cache.clear`

Login as system user:

* username: `user1@email.com`
* password: `password`

Create new user: `littlesis runner lib/scripts/create_example_user.rb`

Reset user password:  `User.find_by(email: <EMAIL>).send_reset_password_instructions`

Update Network Map Collections: `littlesis rake maps:update_all_entity_map_collections`

To give yourself easy database access:

``` sql
create role <your-name> login;
grant all privileges on database littlesis to <your-name>;
```
