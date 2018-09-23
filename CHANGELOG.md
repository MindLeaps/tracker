## 0.8.1
- Fix Scoping for GroupSummary

## 0.8.0
- Caching drawer navigation based on request path
- Using "Unknown" instead of "Unactive User"
- Improved Lesson View with average mark and graded skills
- Sorting/Ordering by column values in resource tables
- Counting only undeleted students in group and chapter student count

## 0.7.1
- Paging in resource tables

## 0.7.0
- POSTing to /grades to create a new grade will update the existing grade and return 200 instead of returning 409 conflict
- Upgraded Rails from 5.2.0 to 5.2.1
- Upgraded pg from 1.0.0 to 1.1.2
- Upgraded slim from 3.0.9 to 4.0.0
- Upgraded Pundit from 1.1.0 to 2.0.0

## 0.6.0
- Upgraded Skylight from 1.6.1 to 2.0.1
- Upgraded Fog Core from 1.45.0 to 2.1.0
- Upgraded Fog AWS from 2.0.1 to 3.0.0
- Removed sdoc

## 0.5.0
- Setup log format to JSON
- Sending logs to Datadog
- Upgraded pg from 0.21.0 to 1.0.0
- Upgraded Ruby from 2.4.3 to 2.5.1
- Upgraded Rails from 5.1.6 to 5.2
- Upgraded Skylight from 1.6.0 to 1.6.1

## 0.4.2
- Upgraded Tiddle from 1.1.0 to 1.2.0
- Upgraded Rails from 5.1.5 to 5.1.6
- Upgraded New Relic agent from 4.8 to 5.0
- Upgraded Skylight from 1.5.1 to 1.6.0

## 0.4.1
- Fixed Datadog DB connect address

## 0.4.0
- Upgraded Rails from 5.1.4 to 5.1.5
- Upgraded Puma from 3.11.2 to 3.11.3 
- Upgraded Simple Form from 3.5.0 to 3.5.1
- Upgraded Bullet from 5.7.2 to 5.7.5
- Upgraded Selenium-webdriver from 3.9.0 to 3.11.0
- Upgraded Rubocop from 0.52.1 to 0.53.0
- Upgraded Devise from 4.3.0 to 4.4.3
- Upgraded Tiddle from 1.0.2 to 1.1.0
- Integrated with Datadog (base, nginx, and Postgres) 

## 0.3.0
- Revert Policy scoping on Organizations API (The Mobile is not ready)
- Revert removing `after_timestamp` parameter from Organizations API

## ~~0.2.0~~
- Upgraded capybara from 2.17.0 to 2.18.0
- Upgraded i18n from 0.9.4 to 0.9.5
- ~~Applying Policy scope to Organizations API~~
- ~~ignoring after_timestamp parameter for Organizations API~~

## 0.1.0
- Base Release
