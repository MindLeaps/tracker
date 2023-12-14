# MindLeaps Tracker
![CI](https://github.com/MindLeaps/tracker/workflows/CI/badge.svg) [![security](https://hakiri.io/github/MindLeaps/tracker/master.svg)](https://hakiri.io/github/MindLeaps/tracker/master)
[![Coverage Status](https://coveralls.io/repos/github/MindLeaps/tracker/badge.svg?branch=master)](https://coveralls.io/github/MindLeaps/tracker?branch=master)

This software is responsible for keeping track of Students in the field and their progress in MindLeaps programs.

## Getting started

### Without Docker

1. Install the Ruby version that's listed in the .ruby-version file. You can also use version managers such as RVM or rbenv.
2. Install Postgres
3. In the tracker directory run `bundle install` to install all the dependencies
4. Create an empty `.env` file. You can leave it empty and refer to the `skipping auth` section below
5. Seed the database by running `rake db:seed`
6. Run the app by running `./bin/dev`
7. Test with `rake test`

### Using Docker

You can use docker as well but it can be fiddly. There is a docker-compose file that sets up the web container and the database but you will have to figure out the environments on your own. 
This workflow should be improved.

1. Install Docker on your machine

2. Run `docker-compose up`
    
3. To seed the database, ssh into the web container and run `rake db:seed`

Finally, point your browser to http://localhost:3000

You can test the application by running the following inside the Docker container:
```sh
rake test
```

### Skipping auth

To enable login without auth, uncomment the following in `application_controller.rb`. This will skip auth in development

    ```
    /app/controllers/base_controller.rb
    
      # Uncomment this to skip authentication in development
      # def authenticate_user!
      #   return true if Rails.env.development?
      #
      #   raise SecurityError
      # end
      #
      # def current_user
      #   raise SecurityError unless Rails.env.development?
      #
      #   user = User.find_or_create_by!(email: 'test@example.com')
      #   user.add_role :super_admin
      #   user
      # end
    ```
