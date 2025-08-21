## Unreleased
- Filtered out deleted data when viewing group analytics

## 0.36.0 - Reworked Student MLIDs and Tags 
- Added the ability to delete Tags
- Added ability to search students by both organization and tag name
- Updated subject analytics performance charts to render each grade score
- Added the ability to export basic student data to csv for a group
- Added `random_alphanumeric_string(length)` DB function to help with MLID generation
- Added `random_student_mlids(org_id, mlid_length, number_of_mlids)` to generate unique available student MLIDs for organization
- Added organization to student model
- Reworked student MLIDs to be up to 8 characters long
- Added autogeneration of student MLIDs when creating students

## 0.35.0 - Enrollment Date Fixes
- Enabled teachers to create and edit groups/students
- Added toggle buttons in group reports
- Added averages for each skill when viewing students
- Added average mark info and mark counts chart in skill view
- Fixed duplicate skills showing in skill index
- Upgraded to Rails 7.2
- Upgraded Ruby to 3.3.6
- Added inline student creating & editing in Group view
- Added database procedure which updates enrollments according to earliest grades
- Modified Student API to return group_id according to Enrollments
- Implemented Enrollments API
- Added Datepicker component and modified forms with dates to use it

## 0.34.0 - Group Reports
- Added Count of Graded/absent/total students and total lesson average mark in lesson view
- Changed Group lesson summaries to show average of students' averages
- Modified enrollments trigger when updating students to properly update active_since and inactive_since fields
- Changed student lesson summaries and related views to include enrollments
- Fixed Migration data with proper active_since and inactive_since values
- Fix for graph in single lesson view to properly highlight current lesson
- Added Reports page for generating printable reports containing group and student summaries
- Added attendance to Group Lesson view and attendance graph for Reports
- Added button in group view that generates report
- Added enrolled students table for group reports
- Show gender when viewing student tables
- Added enrollment chart in group reports
- Group reports are now split according to subject
- Removed old lesson Ids
- Fixed missing data for groups with only one lesson in group analytics

## 0.33.0 - Lesson UUIDs & Graphs
- Added validation for existing tags in an organization
- Blocked users from removing a graded skill from a subject
- Removed absence from student lesson summaries and added lesson date
- Restructured Lessons to go by their UUID
- Disabled decimals for 'No of Assessments' & 'No. of Lessons' in analytics
- Upgraded Rails to 7.1
- Enabled YJIT
- Added analytics for last 30 day grade average for students.
- Added analytics for last 30 day grade average for groups.
- Added canonical and noindex tags to stop search engines from indexing staging site

## 0.32.0 - Deletions & Nonbinary

- Implemented Organization, Chapter & Group deletion
- Upgraded Ruby to 3.3.1
- Added a tooltip when hovering long titles
- Added 'Nonbinary' as a gender option
- Fixed #1770 - students missing in lesson view
- Added policy scoping for Subjects and Assignments
- Fix seeding by making sure MLID is a string
- Make sure all MLIDs are always uppercase by
- Sorted organizations in new group form

## 0.31.1 - Ruby 3.3.0
- Upgraded Ruby to 3.3.0
- Fixed #1805 - made sure to display form validation errors in red
- Fixed #1804 - defaulting student DOB to January 1st

## 0.31.0 - Redesign
- Redesigned the whole application
- Implemented Organization editing
- Student creation will redirect to the previous location
- Validating organizations MLID can be up to 3 characters
- Implemented independent scoping for tables so it's possible to have multiple tables per page with independent sorting
- Made search dynamic; it does not reload the page and triggers automatically 200ms after the last keystroke
- Default table orders are now created_at descending, showing the most recent entries first
- Implemented smaller forms such as student tags, as animated drop forms on the index pages

## 0.30.2 - Rails 7
- Updated Rails to v7
- Removed healthcheck from skylight endpoints

## 0.30.1 - Fix student table ordering
- Fixed the student table bug where table row number started at 2

## 0.30.0 - Homepage
- Removed Sass
- Implemented a marketing landing page
- Fixed crash when navigating to a student tag that is in use by some students
- Upgraded Ruby to 3.0.3

## 0.29.1 - Structured Group Select
- Implemented structured group select in the student form 

## 0.29.0 - Changing Groups
- Enabled students to change groups
- Created Enrollments to track groups the student was enrolled to over time

## 0.28.0 - Datapoints
- Upgraded to Ruby 3
- Upgraded Omniauth to v2
- Analytics filters are now stored in the URL making them shareable
- Added Number of Datapoints to General Analytics

## 0.27.1 - Group/Student MLID fix
- Fixed Student MLID scoping by group instead of by chapter
- Alphabetized Chapters in New Group form

## 0.27.0 - Group MLIDs
- Added MLID to Groups 

## 0.26.0 - Organization and Chapter MLIDs
- Added subjects the skill belongs to in single skill view
- Added MLIDs to Organizations
- Added MLIDs to Chapters
- Scoped Student MLIDs by Chapter and Organization
- Fixed non-global users being unable to see the lessons page
- Upgraded to Rails 6.1.2

## 0.25.1. - Analytics UX Improvements
- Fixed Analytics dropdown defaulting to All Organizations
- Fixed Analytics Subjects not displaying individual organizations
- Alphabetized all Analytics dropdowns

## 0.25.0 - Optimizations, Deployment, Analytics
- Deployment for AWS
- Optimized a few eager database queries
- Fixed clicking Update Role when no role is selected crashing the app on the single user screen
- Organizations in the single user screen are now paged
- Organizations in the single user screen can now be searched
- Added a health endpoint
- Upgraded Ruby to 2.7.2
- Implemented search for chapters
- Added more information in the General Analytics Performance Graph tooltip and the ability to click on point to go to lesson
- Improved performance of Analytics dropdowns
- Defaults Analytics to first organization
- Remove deleted resources from analytics

## 0.24.0 - Student Tags
- Upgraded Rails to 6.0.3.2
- Upgraded Ruby to 2.7.1
- Implement Student Tags
- Use `c.` notation for estimated date

## 0.23.1 - Fix analytics display of individual students
- Fixed displaying group analytics instead of a single student when a student is selected

## 0.23.0 - Country of Nationality for Students
- Upgraded Ruby to 2.6.5
- Hiding creation buttons from users that aren't permitted to use them
- Fixed issue with new MDL fields not being activated in coccoon forms
- Added Country of Nationality field to Students

## 0.22.0 - Lesson Table Improvements
- Not displaying deleted skills when creating subject
- Implemented student ordering in single lesson view
- Default Lessons view order
- Added color indicators for student grading status in single lesson view
- Added a display of graded and total students in group in the lesson table
- Fix Lesson Graph not showing on the first load
- Added Average Grade column to lesson table
- Fix some lessons erroring out because of wrong date format

## 0.21.3 - Logs
- Updated Logging aggregation

## 0.21.2 - Page Titles
- Made snackbar more consistent by removing the in-out animation
- Added autofocus to first field of most forms (student, group, chapter, ...)
- Added page titles

## 0.21.1 - Student & Group Creation Improvements
- Adjusted layout for smaller screens in single lesson view
- Fixed showing Student Lesson for a lesson when student is no longer in the group lesson was in
- Added total average mark and grade count in single lesson view
- Ignoring deleted grades in Students list in single lesson view
- Showing all skills in single lesson view, even if their grades were deleted
- Made Students searchable by MLID
- Added "Create another" prompt after creating a new group
- Added the button to Add a new student directly to the current group
- Made "Create another" student prompt pre-fill the current group
- Made "Create another" group prompt pre-fill the current chapter

## 0.21.0 - Integrated Analytics
- Redesigned Lesson Page
- Added nearby lesson performance visualization to the Lesson Page
- Redesigned Skill Page
- Skill Deletion
- Skill Undeletion
- Integrated Analytics
- Added Lesson date and grade count to Group Analytics graphs tooltips
- Added clicking on data points in Group Analytics to go to individual lessons

## 0.20.0 - Sidebar image and Mobile app link
- Limit user image size to 50px in the sidebar
- Added link to download mobile app

## 0.19.0 - Deletion Policy and navigation improvement
- Improved the performance of student index listing (fix for N+1 query)
- Fixed inconsistencies in UI after clicking back/forward - MDL and Turbolinks were not properly resetting
- Upgraded Ruby to 2.6.4
- Only allow global administrators with a higher global role to delete users

## 0.18.0 - User Deletion and Login Improvements
- Implemented User Deletion
- Upgrade Ruby to 2.6.3
- Fix Google Login for users that have uppercase letters in their emails
- Differentiate between invalid Google id_token and a valid id_token but non-existent MindLeaps user

## 0.17.0 - Policy scoped Grades API
- Policy scoped grade v2 API
- Fix N+1 Query on individual user view
- Implemented search for Skills

## 0.16.0 - Search
- Updated table styles to simplify and unify table margins
- Implemented Search for Students table
- Implemented Search for Groups table
- Implemented Search for Users table
- Handle pagination overflows by displaying the last page

## 0.15.1
- Updated views for new grade structure
- Policy scoping API index responses for V2 of API
- Fix v2 deletion endpoint to properly use lesson UUID instead of the old ID

## 0.15.0
- Added authorization for v2 API
- Added a v2 API for grades that uses skill_id and mark to relate to grade_descriptors
- Added skill_id and mark to Grades
- Added UUIDs for Lessons
- Added a v2 API for Lessons UUIDs for identifiers
- Upgraded Ruby runtime to 2.6.1
- Enable showing deleted students in single group view
- Added paging to first and last pages

## 0.14.1
- Add Material loading bar for Turbolinks
- Fix Highcharts instantiating multiple times because of Turbolinks

## 0.14.0
- Disable Performance tab for students that have no grades
- Improve UX of back/up button in student pages
- Integrated Turbolinks to improve app performance

## 0.13.0
- Require students to belong to a group
- Remove organization association from students

## 0.12.1
- Show Restore deleted group button on group show
- Redirect after group deletion back to referrer

## 0.12.0
- Show Deleted functionality for Students and Groups
- Undelete Students and Groups
- Student header actions now available on the student images view

## 0.11.1
- Added request_id key for logging
- Added meta-request for dev information in Chrome dev tools
- Fixed N+1 query with loading current_user roles

## 0.11.0
- Adds Edit Student button to each row in the student table
- Back button now returns back to the referrer page (like browser back)
- Submitting grades for student now redirects back to the lesson page

## 0.10.0
- Enable users to generate a short lived API token on their profile page
- Preserving Student gender when editing student details
- Exclude empty student lessons, by default, in Student performance view
- Incorporated student images in the student menu, along with details and performance

## 0.9.0
- GET /grades API returns only grades that were updated within the last 4 months 
- Separated student performance and details into separate tabs
- Displaying student performance on student page

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
