# MindLeaps Tracker
![CI](https://github.com/MindLeaps/tracker/workflows/CI/badge.svg) [![security](https://hakiri.io/github/MindLeaps/tracker/master.svg)](https://hakiri.io/github/MindLeaps/tracker/master)
[![Coverage Status](https://coveralls.io/repos/github/MindLeaps/tracker/badge.svg?branch=master)](https://coveralls.io/github/MindLeaps/tracker?branch=master)

This software is responsible for keeping track of Students in the field and their progress in MindLeaps programs.

## Getting started

1. Install Docker on your machine

2. Run `docker-compose up`
    
3. To seed the database, ssh into the web container and run `rake db:seed`

4. To enable login without auth, uncomment the following in `application_controller.rb`. This will skip auth in development

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

Finally, point your browser to http://localhost:3000

You can test the application by running the following inside the Docker container:
```sh
rake test
```
