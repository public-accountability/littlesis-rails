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

### LittleSis commands

``` sh
# Run docker commands
littlesis docker pause
littlesis docker unpause

# View rails logs
littlesis logs
# Clear rails logs
littlesis rake log:clear
# Follow docker logs
littlesis docker -- logs -f esbuild

# Build javascript
littlesis rake javascript:build

# Build oligrapher
littlesis rake oligrapher:build
littlesis rake oligrapher:build[1ae3ccc83701c684a8398d08f85758c449056bb8]

# Compile assets
littlesis rake assets:precompile

# Edit secret variables
littlsis rails credentials:edit

# Thinking sphinx
littlesis rake ts:configure
littlesis rake ts:index

# Stats on new entities & relationships
littlesis rake stats:year[2021]

# unitedstates.io data
littlesis rake legislators:import
littlesis rake legislators:import_party_memberships
littlesis rake legislators:import_relationships

# External Data tools
littlesis data list
littlesis data download nycc
littlesis data transform nycc
littlesis data load nycc
littlesis data report nycc
littlesis fec -- --help
littlesis sec -- --help

#  Update public data
littlesis runner "PublicData.run"

# Update Network Map Collections
littlesis rake maps:update_all_entity_map_collections

# Create users for testing
littlesis script create_development_users.rb
littlesis script create_example_user.rb

# Rails console
littlesis console

# Send reset password instructions
littlesis runner "User.find_by(email: <EMAIL>).send_reset_password_instructions"

```

### bin/littlesis in production

``` sh
littlesis git fetch origin
littlesis git -- switch --detach COMMIT
littlesis bundle install
littlesis npm ci
littlesis rake javascript:build
littlesis rake assets:precompile
littlesis script download_oligrapher_assets.rb TAG
systemctl restart littlesis.service littlesis-goodjob.service
littlesis status
```
