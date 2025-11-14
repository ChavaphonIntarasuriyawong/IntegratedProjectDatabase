# Smart City DB Data Dictionary

* **Project:** Smart City DB
* **Database:** PostgreSQL with PostGIS
* **Last Updated:** 2025-11-14

---

## Core Infrastructure & Users

This section encompasses foundational tables for user authentication, profiles, roles, departments, specialties, and a centralized address management system.

### Table: `roles`

This table maintains user roles to facilitate permission management across the application.

| Column       | Data Type     | Description                              | Constraints / Notes                  |
|--------------|---------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`     | Unique identifier for the role.         | **Primary Key**                     |
| `role_name` | `VARCHAR(50)`| Unique name of the role (e.g., 'admin', 'citizen'). | `NOT NULL`, `UNIQUE`                |

### Table: `departments`

This table records details of various city departments or organizations.

| Column            | Data Type       | Description                              | Constraints / Notes                  |
|-------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`       | Unique identifier for the department.   | **Primary Key**                     |
| `department_name`| `VARCHAR(255)` | Unique official name of the department. | `NOT NULL`, `UNIQUE`                |
| `created_at`     | `TIMESTAMPTZ(6)`| Timestamp of record creation.           | `NOT NULL`, Default: `now()`        |
| `updated_at`     | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `specialty`

This table catalogs user specialties for purposes such as filtering or identification.

| Column            | Data Type     | Description                              | Constraints / Notes                  |
|-------------------|---------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`     | Unique identifier for the specialty.    | **Primary Key**                     |
| `specialty_name` | `VARCHAR(50)`| Unique name of the specialty.           | `NOT NULL`, `UNIQUE`                |

### Table: `addresses`

This centralized table manages physical addresses and geographic coordinates, reusable across entities such as users, facilities, and events.

| Column         | Data Type       | Description                              | Constraints / Notes                  |
|----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`          | `SERIAL`       | Unique identifier for the address record.| **Primary Key**                     |
| `address_line`| `TEXT`         | Main address line (e.g., street and house number). |                                      |
| `province`    | `VARCHAR(255)` | Province name.                          |                                      |
| `district`    | `VARCHAR(255)` | District name.                          |                                      |
| `subdistrict` | `VARCHAR(255)` | Subdistrict name.                       |                                      |
| `postal_code` | `VARCHAR(20)`  | Postal or zip code.                     |                                      |
| `location`    | `geometry`     | Geographic coordinates (e.g., Point) using PostGIS. | GIST Index (`idx_addresses_location`) |
| `created_at`  | `TIMESTAMPTZ(6)`| Timestamp of record creation.           | `NOT NULL`, Default: `now()`        |
| `updated_at`  | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `users`

This table holds core authentication credentials and essential user details. Personal information is normalized into the `user_profiles` table.

| Column        | Data Type       | Description                              | Constraints / Notes                  |
|---------------|-----------------|------------------------------------------|--------------------------------------|
| `id`         | `SERIAL`       | Unique identifier for the user.         | **Primary Key**                     |
| `username`   | `VARCHAR(50)`  | Unique username for login.              | `NOT NULL`, `UNIQUE`                |
| `email`      | `VARCHAR(255)` | Unique email address.                   | `NOT NULL`, `UNIQUE`, Indexed       |
| `phone`      | `VARCHAR(20)`  | Unique phone number.                    | `UNIQUE`, Indexed                   |
| `password_hash` | `VARCHAR(512)`| Securely hashed password.               | `NOT NULL`                          |
| `role_id`    | `INTEGER`      | User's role.                            | Foreign Key to `roles(id)`          |
| `created_at` | `TIMESTAMPTZ(6)`| Timestamp of account creation.          | `NOT NULL`, Default: `now()`        |
| `updated_at` | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |
| `last_login` | `TIMESTAMPTZ(6)`| Timestamp of the user's last login.     |                                      |

### Table: `user_profiles`

This table contains personal profile details, maintaining a one-to-one relationship with the `users` table.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `user_id`         | `INTEGER`      | Link to the user's authentication record.| **Primary Key**, Foreign Key to `users(id)` |
| `first_name`      | `VARCHAR(255)` | User's first name.                      |                                      |
| `middle_name`     | `VARCHAR(255)` | User's middle name (optional).          |                                      |
| `last_name`       | `VARCHAR(255)` | User's last name.                       |                                      |
| `birth_date`      | `DATE`         | User's date of birth.                   |                                      |
| `gender`          | `gender`       | User's gender (enum: 'male', 'female', 'none'). |                                      |
| `address_id`      | `INTEGER`      | User's primary address.                 | Foreign Key to `addresses(id)`      |
| `more_address_detail` | `TEXT`      | Additional address details.             |                                      |
| `id_card_number`  | `VARCHAR(13)`  | User's ID card number.                  |                                      |
| `blood_type`      | `blood_type`   | User's blood type (enum: 'A', 'B', 'AB', 'O'). |                                      |
| `congenital_disease` | `VARCHAR(255)`| Any congenital diseases.                |                                      |
| `allergy`         | `VARCHAR(255)` | Any known allergies.                    |                                      |
| `height`          | `INTEGER`      | User's height in centimeters.           |                                      |
| `weight`          | `INTEGER`      | User's weight in kilograms.             |                                      |
| `profile_picture` | `VARCHAR(255)` | URL to the user's profile picture.      |                                      |
| `ethnicity`       | `VARCHAR(255)` | User's ethnicity.                       |                                      |
| `nationality`     | `VARCHAR(255)` | User's nationality.                     |                                      |
| `religion`        | `VARCHAR(255)` | User's religion.                        |                                      |

### Table: `users_departments`

This junction table establishes a many-to-many relationship between users and departments.

| Column          | Data Type  | Description                              | Constraints / Notes                  |
|-----------------|------------|------------------------------------------|--------------------------------------|
| `user_id`      | `INTEGER` | Foreign key referencing the user.       | **Composite Primary Key**, Foreign Key to `users(id)` |
| `department_id`| `INTEGER` | Foreign key referencing the department. | **Composite Primary Key**, Foreign Key to `departments(id)` |

### Table: `users_specialty`

This junction table establishes a many-to-many relationship between users and specialties.

| Column          | Data Type  | Description                              | Constraints / Notes                  |
|-----------------|------------|------------------------------------------|--------------------------------------|
| `user_id`      | `INTEGER` | Foreign key referencing the user.       | **Composite Primary Key**, Foreign Key to `users(id)` |
| `specialty_id` | `INTEGER` | Foreign key referencing the specialty.  | **Composite Primary Key**, Foreign Key to `specialty(id)` |

---

## Authentication & Sessions

This section includes tables for handling user sessions, refresh tokens, and notification tokens.

### Table: `sessions`

This table tracks active user login sessions.

| Column         | Data Type       | Description                              | Constraints / Notes                  |
|----------------|-----------------|------------------------------------------|--------------------------------------|
| `session_id`  | `UUID`         | Unique identifier for the session.      | **Primary Key**, Default: `uuid_generate_v4()` |
| `user_id`     | `INTEGER`      | User associated with the session.       | Foreign Key to `users(id)`          |
| `created_at`  | `TIMESTAMPTZ(6)`| Timestamp of session creation.          | `NOT NULL`, Default: `now()`        |
| `expires_at`  | `TIMESTAMPTZ(6)`| Timestamp of session expiration.        |                                      |
| `last_accessed`| `TIMESTAMPTZ(6)`| Timestamp of last session activity.     |                                      |

### Table: `refresh_tokens`

This table stores refresh tokens for obtaining new access tokens.

| Column          | Data Type       | Description                              | Constraints / Notes                  |
|-----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`           | `SERIAL`       | Unique identifier for the token.        | **Primary Key**                     |
| `user_id`      | `INTEGER`      | User associated with the token.         | Foreign Key to `users(id)`          |
| `refresh_token`| `TEXT`         | Secure refresh token string.            | `NOT NULL`                          |
| `created_at`   | `TIMESTAMPTZ(6)`| Timestamp of token creation.            | `NOT NULL`, Default: `now()`        |
| `expires_at`   | `TIMESTAMPTZ(6)`| Timestamp of token expiration.          |                                      |

### Table: `fcm_token`

This table stores Firebase Cloud Messaging tokens for push notifications.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the token record. | **Primary Key**                     |
| `user_id`   | `INTEGER`      | User owning the token.                  | Foreign Key to `users(id)`          |
| `created_at`| `TIMESTAMPTZ(6)`| Timestamp of token creation.            | Default: `now()`                    |
| `updated_at`| `TIMESTAMPTZ(6)`| Timestamp of the last update.           | Default: `now()`                    |
| `tokens`    | `TEXT`         | FCM device token.                       | `NOT NULL`                          |

---

## G1: Courses & Education

This section covers tables for managing online and onsite educational courses.

### Table: `courses`

This table stores primary details about educational courses.

| Column            | Data Type       | Description                              | Constraints / Notes                  |
|-------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`       | Unique identifier for the course.       | **Primary Key**                     |
| `author_id`      | `INTEGER`      | User who created the course.            | Foreign Key to `users(id)`          |
| `course_name`    | `VARCHAR(255)` | Course title.                           | `NOT NULL`                          |
| `course_description` | `TEXT`      | Detailed course content description.    |                                      |
| `course_type`    | `course_type`  | Delivery format (enum: 'online', 'onsite', 'online_and_onsite'). | `NOT NULL`                          |
| `course_status`  | `course_status`| Status (enum: 'pending', 'approve', 'not_approve'). | `NOT NULL`, Default: `'pending'`    |
| `cover_image`    | `TEXT`         | URL to the course cover image.          |                                      |
| `created_at`     | `TIMESTAMPTZ(6)`| Timestamp of course creation.           | `NOT NULL`, Default: `now()`        |
| `updated_at`     | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `course_videos`

This table manages video lessons for online courses.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the video.        | **Primary Key**                     |
| `course_id`       | `INTEGER`      | Course to which the video belongs.      | Foreign Key to `courses(id)`        |
| `video_name`      | `VARCHAR(255)` | Video lesson title.                     | `NOT NULL`                          |
| `video_description` | `TEXT`       | Video content description.              |                                      |
| `duration_minutes`| `INTEGER`      | Video length in minutes.                | `NOT NULL`                          |
| `video_order`     | `INTEGER`      | Sequence number in the course.          | `NOT NULL`, `UNIQUE` with `course_id` |
| `video_file_path` | `TEXT`         | Path or URL to the video file.          |                                      |
| `created_at`      | `TIMESTAMPTZ(6)`| Timestamp of video creation.            | `NOT NULL`, Default: `now()`        |
| `updated_at`      | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `onsite_sessions`

This table handles details for in-person course sessions.

| Column                | Data Type       | Description                              | Constraints / Notes                  |
|-----------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                 | `SERIAL`       | Unique identifier for the session.      | **Primary Key**                     |
| `course_id`          | `INTEGER`      | Course to which the session belongs.    | Foreign Key to `courses(id)`        |
| `address_id`         | `INTEGER`      | Session location.                       | Foreign Key to `addresses(id)`      |
| `duration_hours`     | `NUMERIC(6,2)` | Session duration in hours.              |                                      |
| `event_at`           | `TIMESTAMPTZ(6)`| Date and time of the session.           | `NOT NULL`                          |
| `registration_deadline` | `TIMESTAMPTZ(6)`| Registration deadline.                  | `NOT NULL`                          |
| `total_seats`        | `INTEGER`      | Total available seats.                  | `NOT NULL`, Default: `1`            |
| `created_at`         | `TIMESTAMPTZ(6)`| Timestamp of session creation.          | `NOT NULL`, Default: `now()`        |
| `updated_at`         | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `onsite_enrollments`

This table records user enrollments in onsite sessions.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the enrollment.   | **Primary Key**                     |
| `onsite_id` | `INTEGER`      | Onsite session enrolled in.             | Foreign Key to `onsite_sessions(id)`|
| `user_id`   | `INTEGER`      | Enrolling user.                         | Foreign Key to `users(id)`          |
| `created_at`| `TIMESTAMPTZ(6)`| Timestamp of enrollment.                | `NOT NULL`, Default: `now()`        |

**Note:** Unique constraint on (`onsite_id`, `user_id`).

### Table: `questions`

This table stores questions for exercises and quizzes.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the question.     | **Primary Key**                     |
| `question`  | `TEXT`         | Question text.                          | `NOT NULL`                          |
| `level`     | `INTEGER`      | Difficulty level.                       |                                      |
| `created_at`| `TIMESTAMPTZ(6)`| Timestamp of creation.                  | `NOT NULL`, Default: `now()`        |
| `updated_at`| `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `user_exercises`

This table logs user responses to exercise questions.

| Column        | Data Type       | Description                              | Constraints / Notes                  |
|---------------|-----------------|------------------------------------------|--------------------------------------|
| `id`         | `SERIAL`       | Unique identifier for the attempt.      | **Primary Key**                     |
| `user_id`    | `INTEGER`      | User who answered.                      | Foreign Key to `users(id)`          |
| `question_id`| `INTEGER`      | Question answered.                      | Foreign Key to `questions(id)`      |
| `user_answer`| `TEXT`         | User's provided answer.                 |                                      |
| `is_correct` | `BOOLEAN`      | Indicates if the answer is correct.     |                                      |
| `created_at` | `TIMESTAMPTZ(6)`| Timestamp of submission.                | `NOT NULL`, Default: `now()`        |

### Table: `user_levels`

This table maintains users' current skill levels in the education domain.

| Column          | Data Type  | Description                              | Constraints / Notes                  |
|-----------------|------------|------------------------------------------|--------------------------------------|
| `user_id`      | `INTEGER` | User associated with the level.         | **Primary Key**, Foreign Key to `users(id)` |
| `current_level`| `INTEGER` | User's current level.                   | `NOT NULL`, Default: `1`            |

---

## G3: Events Hub

This section includes tables for public events, organizations, and tags.

### Table: `event_organization`

This table stores details for event-organizing entities, extending the `users` table.

| Column        | Data Type       | Description                              | Constraints / Notes                  |
|---------------|-----------------|------------------------------------------|--------------------------------------|
| `id`         | `INTEGER`      | Link to user's authentication record.   | **Primary Key**, Foreign Key to `users(id)` |
| `name`       | `VARCHAR(255)` | Official organization name.             |                                      |
| `email`      | `VARCHAR(255)` | Contact email.                          |                                      |
| `phone_number`| `VARCHAR(255)` | Contact phone.                          |                                      |

### Table: `event_tag_name`

This table catalogs names for event tags.

| Column  | Data Type       | Description                              | Constraints / Notes                  |
|---------|-----------------|------------------------------------------|--------------------------------------|
| `id`   | `INTEGER`      | Unique identifier for the tag name.     | **Primary Key**                     |
| `name` | `VARCHAR(255)` | Tag name.                               |                                      |

### Table: `event_tag`

This table associates events with tags.

| Column         | Data Type       | Description                              | Constraints / Notes                  |
|----------------|-----------------|------------------------------------------|--------------------------------------|
| `event_id`    | `INTEGER`      | Event being tagged.                     | **Primary Key**, Foreign Key to `events(id)` |
| `event_tag_id`| `INTEGER`      | Tag identifier.                         | Foreign Key to `event_tag_name(id)` |
| `name`        | `VARCHAR(255)` | Denormalized tag name.                  |                                      |

### Table: `events`

This table manages event details created by users or departments.

| Column          | Data Type       | Description                              | Constraints / Notes                  |
|-----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`           | `SERIAL`       | Unique identifier for the event.        | **Primary Key**                     |
| `host_user_id` | `INTEGER`      | Event host user.                        | Foreign Key to `users(id)`          |
| `department_id`| `INTEGER`      | Organizing department.                  | Foreign Key to `departments(id)`    |
| `image_url`    | `TEXT`         | URL to promotional image.               |                                      |
| `title`        | `VARCHAR(255)` | Event title.                            |                                      |
| `description`  | `TEXT`         | Detailed event description.             |                                      |
| `total_seats`  | `INTEGER`      | Total available seats.                  | Default: `0`                        |
| `start_at`     | `TIMESTAMPTZ(6)`| Event start date and time.              | Indexed                             |
| `end_at`       | `TIMESTAMPTZ(6)`| Event end date and time.                |                                      |
| `address_id`   | `INTEGER`      | Event location.                         | Foreign Key to `addresses(id)`      |
| `created_at`   | `TIMESTAMPTZ(6)`| Timestamp of creation.                  | `NOT NULL`, Default: `now()`        |
| `updated_at`   | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |
| `organization_id` | `INTEGER`   | Hosting organization.                   | Foreign Key to `event_organization(id)` |

**Note:** One-to-one relationship with `event_tag`; foreign key on `event_tag(event_id)`.

### Table: `event_bookmarks`

This table enables users to bookmark events.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `user_id`   | `INTEGER`      | User who bookmarked.                    | **Composite Primary Key**, Foreign Key to `users(id)` |
| `event_id`  | `INTEGER`      | Bookmarked event.                       | **Composite Primary Key**, Foreign Key to `events(id)` |
| `created_at`| `TIMESTAMPTZ(6)`| Timestamp of bookmark creation.         | `NOT NULL`, Default: `now()`        |

---

## G4: Freecycle (Donation) Domain

This section supports features for donating and receiving items at no cost.

### Table: `freecycle_categories`

This table defines categories for donated items.

| Column           | Data Type       | Description                              | Constraints / Notes                  |
|------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`            | `SERIAL`       | Unique identifier for the category.     | **Primary Key**                     |
| `category_name` | `VARCHAR(100)` | Unique category name.                   | `NOT NULL`, `UNIQUE`                |
| `created_at`    | `TIMESTAMPTZ(6)`| Timestamp of creation.                  | `NOT NULL`, Default: `now()`        |
| `updated_at`    | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `freecycle_posts`

This table stores donation posts.

| Column                 | Data Type        | Description                              | Constraints / Notes                  |
|------------------------|------------------|------------------------------------------|--------------------------------------|
| `id`                  | `SERIAL`        | Unique identifier for the post.         | **Primary Key**                     |
| `item_name`           | `VARCHAR(255)`  | Name of the donated item.               | `NOT NULL`                          |
| `item_weight`         | `NUMERIC(10,3)` | Approximate item weight.                |                                      |
| `photo_url`           | `TEXT`          | URL to item photo.                      |                                      |
| `description`         | `TEXT`          | Item description and condition.         |                                      |
| `donater_id`          | `INTEGER`       | Donating user.                          | Foreign Key to `users(id)`          |
| `donate_to_department_id` | `INTEGER`   | Optional target department.             | Foreign Key to `departments(id)`    |
| `is_given`            | `BOOLEAN`       | Indicates if item is given away.        | `NOT NULL`, Default: `FALSE`        |
| `created_at`          | `TIMESTAMPTZ(6)` | Timestamp of post creation.             | `NOT NULL`, Default: `now()`        |
| `updated_at`          | `TIMESTAMPTZ(6)` | Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `freecycle_posts_categories`

This junction table links posts to categories.

| Column        | Data Type  | Description                              | Constraints / Notes                  |
|---------------|------------|------------------------------------------|--------------------------------------|
| `post_id`    | `INTEGER` | Foreign key referencing the post.       | **Composite Primary Key**, Foreign Key to `freecycle_posts(id)` |
| `category_id`| `INTEGER` | Foreign key referencing the category.   | **Composite Primary Key**, Foreign Key to `freecycle_categories(id)` |

### Table: `receiver_requests`

This table tracks requests to receive donated items.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the request.      | **Primary Key**                     |
| `post_id`   | `INTEGER`      | Requested post.                         | Foreign Key to `freecycle_posts(id)`|
| `receiver_id`| `INTEGER`      | Requesting user.                        | Foreign Key to `users(id)`          |
| `status`    | `freecycle_request_status` | Status (enum: 'pending', 'accepted', 'rejected'). | `NOT NULL`, Default: `'pending'`    |
| `created_at`| `TIMESTAMPTZ(6)`| Timestamp of request creation.          | `NOT NULL`, Default: `now()`        |
| `updated_at`| `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

---

## G5/G14: Environment (Air & Weather)

This section manages air quality and weather data.

### Table: `air_quality`

This table records air quality metrics for locations.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the reading.      | **Primary Key**                     |
| `location_id`| `INTEGER`      | Reading location.                       | Foreign Key to `addresses(id)`      |
| `aqi`       | `NUMERIC(6,2)` | Air Quality Index value.                |                                      |
| `pm25`      | `NUMERIC(8,3)` | PM2.5 concentration.                    |                                      |
| `category`  | `air_quality_category` | Category (enum: 'good', 'moderate', 'unhealthy', 'hazardous'). |                                      |
| `measured_at`| `TIMESTAMPTZ(6)`| Timestamp of measurement.               | `NOT NULL`, Default: `now()`        |

### Table: `weather_data`

This table stores weather condition details.

| Column               | Data Type       | Description                              | Constraints / Notes                  |
|----------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                | `SERIAL`       | Unique identifier for the record.       | **Primary Key**                     |
| `location_id`       | `INTEGER`      | Weather reading location.               | Foreign Key to `addresses(id)`      |
| `temperature`       | `NUMERIC(6,2)` | Measured temperature in Celsius.        |                                      |
| `feel_temperature`  | `NUMERIC(6,2)` | 'Feels like' temperature.               |                                      |
| `humidity`          | `NUMERIC(6,2)` | Relative humidity percentage.           |                                      |
| `wind_speed`        | `NUMERIC(6,2)` | Wind speed (e.g., km/h).                |                                      |
| `wind_direction`    | `VARCHAR(50)`  | Wind direction.                         |                                      |
| `rainfall_probability` | `NUMERIC(5,2)` | Precipitation probability percentage.   |                                      |
| `created_at`        | `TIMESTAMPTZ(6)`| Timestamp of creation.                  | `NOT NULL`, Default: `now()`        |
| `updated_at`        | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

---

## G6: Volunteer Events

This section handles volunteer events and participation.

### Table: `volunteer_events`

This table stores volunteer event details.

| Column                  | Data Type       | Description                              | Constraints / Notes                  |
|-------------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                   | `SERIAL`       | Unique identifier for the event.        | **Primary Key**                     |
| `created_by_user_id`   | `INTEGER`      | Event creator.                          | Foreign Key to `users(id)`          |
| `department_id`        | `INTEGER`      | Associated department.                  | Foreign Key to `departments(id)`    |
| `image_url`            | `TEXT`         | URL to promotional image.               |                                      |
| `title`                | `VARCHAR(255)` | Event title.                            | `NOT NULL`                          |
| `description`          | `TEXT`         | Detailed description.                   |                                      |
| `current_participants` | `INTEGER`      | Current registered participants.        | `NOT NULL`, Default: `0`            |
| `total_seats`          | `INTEGER`      | Total volunteer spots.                  | `NOT NULL`, Default: `1`            |
| `start_at`             | `TIMESTAMPTZ(6)`| Start date and time.                    | Indexed                             |
| `end_at`               | `TIMESTAMPTZ(6)`| End date and time.                      |                                      |
| `registration_deadline`| `TIMESTAMPTZ(6)`| Registration deadline.                  |                                      |
| `address_id`           | `INTEGER`      | Event location.                         | Foreign Key to `addresses(id)`      |
| `status`               | `volunteer_event_status` | Approval status (enum: 'draft', 'pending', 'approved', 'rejected'). | `NOT NULL`, Default: `'draft'`      |
| `created_at`           | `TIMESTAMPTZ(6)`| Timestamp of creation.                  | `NOT NULL`, Default: `now()`        |
| `updated_at`           | `TIMESTAMPTZ(6)`| Timestamp of the last update.           | `NOT NULL`, Default: `now()`        |

### Table: `volunteer_event_participation`

This table tracks participation in volunteer events.

| Column                | Data Type       | Description                              | Constraints / Notes                  |
|-----------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                 | `SERIAL`       | Unique identifier for the record.       | **Primary Key**                     |
| `volunteer_event_id` | `INTEGER`      | Participated event.                     | Foreign Key to `volunteer_events(id)` |
| `user_id`            | `INTEGER`      | Participating user.                     | Foreign Key to `users(id)`          |
| `created_at`         | `TIMESTAMPTZ(6)`| Timestamp of registration.              | `NOT NULL`, Default: `now()`        |

---

## G7: Business Intelligence (BI)

This section employs a star schema for analytical reporting.

### Table: `dim_time`

Dimension table for time-based analytics.

| Column      | Data Type  | Description                              | Constraints / Notes                  |
|-------------|------------|------------------------------------------|--------------------------------------|
| `time_id`  | `INTEGER` | Unique identifier for the time record.  | **Primary Key**                     |
| `date_actual` | `DATE`  | Specific date.                          |                                      |
| `year_val` | `INTEGER` | Year component.                         |                                      |
| `month_val`| `INTEGER` | Month component (1-12).                 |                                      |
| `day_val`  | `INTEGER` | Day component (1-31).                   |                                      |
| `hour_val` | `INTEGER` | Hour component (0-23).                  |                                      |

### Table: `dim_location`

Dimension table for location-based analytics.

| Column        | Data Type   | Description                              | Constraints / Notes                  |
|---------------|-------------|------------------------------------------|--------------------------------------|
| `location_id`| `INTEGER`  | Unique identifier for the location.     | **Primary Key**                     |
| `district`   | `VARCHAR(255)` | District name.                        |                                      |
| `coordinates`| `geometry` | Geographic coordinates.                 |                                      |

### Table: `dim_facility`

Dimension table for healthcare facilities.

| Column         | Data Type       | Description                              | Constraints / Notes                  |
|----------------|-----------------|------------------------------------------|--------------------------------------|
| `facility_id` | `INTEGER`      | Unique identifier for the facility.     | **Primary Key**                     |
| `facility_name`| `VARCHAR(255)` | Facility name.                          |                                      |
| `location_id` | `INTEGER`      | Location reference.                     | Foreign Key to `dim_location(location_id)` |

### Table: `dim_waste_type`

Dimension table for waste types.

| Column           | Data Type       | Description                              | Constraints / Notes                  |
|------------------|-----------------|------------------------------------------|--------------------------------------|
| `waste_type_id` | `INTEGER`      | Unique identifier for the waste type.   | **Primary Key**                     |
| `waste_type_name`| `VARCHAR(255)` | Waste type name.                        |                                      |

### Table: `dim_category`

Dimension table for report or data categories.

| Column               | Data Type       | Description                              | Constraints / Notes                  |
|----------------------|-----------------|------------------------------------------|--------------------------------------|
| `category_id`       | `INTEGER`      | Unique identifier for the category.     | **Primary Key**                     |
| `category_name`     | `VARCHAR(255)` | Category name.                          |                                      |
| `category_description` | `TEXT`       | Category description.                   |                                      |

### Table: `dim_user`

Dimension table for users in analytics, with non-sensitive data.

| Column        | Data Type       | Description                              | Constraints / Notes                  |
|---------------|-----------------|------------------------------------------|--------------------------------------|
| `user_id`    | `INTEGER`      | Unique identifier for the user.         | **Primary Key**                     |
| `full_name`  | `VARCHAR(255)` | User's full name.                       |                                      |
| `email`      | `VARCHAR(255)` | User's email.                           | `UNIQUE`                            |
| `role_string`| `VARCHAR(100)` | User's role as a string.                |                                      |

### Table: `fact_traffic`

Fact table for traffic metrics.

| Column                 | Data Type        | Description                              | Constraints / Notes                  |
|------------------------|------------------|------------------------------------------|--------------------------------------|
| `traffic_id`          | `INTEGER`       | Unique identifier for the fact.         | **Primary Key**                     |
| `time_id`             | `INTEGER`       | Time reference.                         | Foreign Key to `dim_time(time_id)`  |
| `location_id`         | `INTEGER`       | Location reference.                     | Foreign Key to `dim_location(location_id)` |
| `vehicle_count`       | `INTEGER`       | Vehicle count.                          |                                      |
| `has_accident_flag`   | `BOOLEAN`       | Accident occurrence flag.               |                                      |
| `density_level_numeric`| `NUMERIC(10,2)`| Numeric traffic density.                |                                      |

### Table: `fact_waste`

Fact table for waste management metrics.

| Column                       | Data Type        | Description                              | Constraints / Notes                  |
|------------------------------|------------------|------------------------------------------|--------------------------------------|
| `waste_id`                  | `INTEGER`       | Unique identifier for the fact.         | **Primary Key**                     |
| `time_id`                   | `INTEGER`       | Time reference.                         | Foreign Key to `dim_time(time_id)`  |
| `location_id`               | `INTEGER`       | Location reference.                     | Foreign Key to `dim_location(location_id)` |
| `waste_type_id`             | `INTEGER`       | Waste type reference.                   | Foreign Key to `dim_waste_type(waste_type_id)` |
| `collection_weight_kg_numeric` | `NUMERIC(10,2)`| Waste collection weight in kg.          |                                      |

### Table: `fact_healthcare`

Fact table for healthcare metrics.

| Column                        | Data Type        | Description                              | Constraints / Notes                  |
|-------------------------------|------------------|------------------------------------------|--------------------------------------|
| `health_id`                  | `INTEGER`       | Unique identifier for the fact.         | **Primary Key**                     |
| `time_id`                    | `INTEGER`       | Time reference.                         | Foreign Key to `dim_time(time_id)`  |
| `facility_id`                | `INTEGER`       | Facility reference.                     | Foreign Key to `dim_facility(facility_id)` |
| `avg_wait_time_minutes_numeric` | `NUMERIC(10,2)`| Average wait time in minutes.           |                                      |
| `bed_occupancy_percent_numeric` | `NUMERIC(5,2)` | Bed occupancy percentage.               |                                      |
| `total_revenue_numeric`      | `NUMERIC(15,2)` | Total revenue.                          |                                      |

### Table: `fact_weather`

Fact table for weather metrics.

| Column                 | Data Type        | Description                              | Constraints / Notes                  |
|------------------------|------------------|------------------------------------------|--------------------------------------|
| `weather_id`          | `INTEGER`       | Unique identifier for the fact.         | **Primary Key**                     |
| `time_id`             | `INTEGER`       | Time reference.                         | Foreign Key to `dim_time(time_id)`  |
| `location_id`         | `INTEGER`       | Location reference.                     | Foreign Key to `dim_location(location_id)` |
| `avg_aqi_numeric`     | `NUMERIC(10,2)` | Average AQI.                            |                                      |
| `max_pm25_numeric`    | `NUMERIC(10,2)` | Maximum PM2.5.                          |                                      |
| `avg_temperature_numeric` | `NUMERIC(5,2)`| Average temperature.                    |                                      |

### Table: `fact_population`

Fact table for population metrics.

| Column                     | Data Type        | Description                              | Constraints / Notes                  |
|----------------------------|------------------|------------------------------------------|--------------------------------------|
| `population_id`           | `INTEGER`       | Unique identifier for the fact.         | **Primary Key**                     |
| `time_id`                 | `INTEGER`       | Time reference.                         | Foreign Key to `dim_time(time_id)`  |
| `location_id`             | `INTEGER`       | Location reference.                     | Foreign Key to `dim_location(location_id)` |
| `total_population`        | `INTEGER`       | Total population count.                 |                                      |
| `population_density_numeric` | `NUMERIC(10,2)`| Population density.                     |                                      |
| `median_age_numeric`      | `NUMERIC(5,2)`  | Median population age.                  |                                      |

### Table: `reports_metadata`

This table stores metadata for generated BI reports.

| Column                   | Data Type       | Description                              | Constraints / Notes                  |
|--------------------------|-----------------|------------------------------------------|--------------------------------------|
| `report_id`             | `INTEGER`      | Unique identifier for the metadata.     | **Primary Key**                     |
| `title_string`          | `VARCHAR(255)` | Report title.                           |                                      |
| `description_string`    | `TEXT`         | Report description.                     |                                      |
| `category_id`           | `INTEGER`      | Report category.                        | Foreign Key to `dim_category(category_id)` |
| `created_by`            | `INTEGER`      | Report creator.                         | Foreign Key to `dim_user(user_id)`  |
| `last_updated_datetime` | `TIMESTAMPTZ(6)`| Last update timestamp.                  |                                      |
| `power_bi_report_id_string` | `VARCHAR(255)` | Power BI report ID.                     |                                      |
| `visibility`            | `report_visibility` | Visibility (enum: 'citizens', 'admin'). | Default: `'citizens'`               |
| `power_bi_report_type`  | `power_bi_report_type` | Report type (enum: 'summary', 'trends'). | Default: `'summary'`                |

---

## G8: Transportation

This section manages public transportation routes, stops, and cards.

### Table: `transportation_vehicle_types`

This table defines vehicle types for public transport.

| Column  | Data Type      | Description                              | Constraints / Notes                  |
|---------|----------------|------------------------------------------|--------------------------------------|
| `id`   | `SERIAL`      | Unique identifier for the vehicle type. | **Primary Key**                     |
| `name` | `VARCHAR(100)`| Vehicle type name.                      | `NOT NULL`                          |

### Table: `routes`

This table stores transportation route information.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the route.        | **Primary Key**                     |
| `route_name`      | `VARCHAR(255)` | Route name or number.                   |                                      |
| `vehicle_type_id` | `INTEGER`      | Serving vehicle type.                   | Foreign Key to `transportation_vehicle_types(id)` |

### Table: `stops`

This table records bus stops or train stations.

| Column    | Data Type       | Description                              | Constraints / Notes                  |
|-----------|-----------------|------------------------------------------|--------------------------------------|
| `id`     | `SERIAL`       | Unique identifier for the stop.         | **Primary Key**                     |
| `name`   | `VARCHAR(255)` | Stop name.                              |                                      |
| `location`| `geometry`     | Geographic coordinates.                 |                                      |

### Table: `route_stops`

This table defines stop sequences for routes.

| Column                    | Data Type  | Description                              | Constraints / Notes                  |
|---------------------------|------------|------------------------------------------|--------------------------------------|
| `id`                     | `SERIAL`  | Unique identifier for the link.         | **Primary Key**                     |
| `route_id`               | `INTEGER` | Route affiliation.                      | Foreign Key to `routes(id)`         |
| `stop_id`                | `INTEGER` | Stop on the route.                      | Foreign Key to `stops(id)`          |
| `stop_order`             | `INTEGER` | Order on the route.                     |                                      |
| `travel_time_to_next_stop`| `INTEGER` | Estimated time to next stop in minutes. |                                      |

### Table: `digital_cards`

This table manages users' digital transportation cards.

| Column    | Data Type       | Description                              | Constraints / Notes                  |
|-----------|-----------------|------------------------------------------|--------------------------------------|
| `id`     | `SERIAL`       | Unique identifier for the card.         | **Primary Key**                     |
| `user_id`| `INTEGER`      | Card owner.                             | Foreign Key to `users(id)`          |
| `status` | `VARCHAR(20)`  | Card status.                            | `NOT NULL`, Default: `'active'`     |
| `balance`| `NUMERIC(14,2)`| Current balance.                        |                                      |

### Table: `metro_cards`

This table stores metro/transit card details.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the card.         | **Primary Key**                     |
| `user_id`   | `INTEGER`      | Associated user.                        | Foreign Key to `users(id)`          |
| `balance`   | `NUMERIC(14,2)`| Card balance.                           | Default: `0`                        |
| `card_number`| `VARCHAR(255)` | Unique card number.                     | `UNIQUE`                            |
| `status`    | `wallet_status`| Card status (enum: 'active', 'suspended'). | Default: `'active'`                 |
| `created_at`| `TIMESTAMPTZ(6)`| Issuance timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`| `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |

### Table: `transportation_transactions`

This table logs transactions using digital cards.

| Column            | Data Type       | Description                              | Constraints / Notes                  |
|-------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`       | Unique identifier for the transaction.  | **Primary Key**                     |
| `card_id`        | `INTEGER`      | Used card.                              | Foreign Key to `digital_cards(id)`  |
| `route_id`       | `INTEGER`      | Transaction route.                      | Foreign Key to `routes(id)`         |
| `amount`         | `NUMERIC(12,2)`| Fare amount.                            |                                      |
| `status`         | `VARCHAR(50)`  | Transaction status.                     |                                      |
| `created_at`     | `TIMESTAMPTZ(6)`| Transaction timestamp.                  | `NOT NULL`, Default: `now()`        |
| `tap_in_location`| `geometry`     | Tap-in location.                        |                                      |
| `tap_out_location`| `geometry`    | Tap-out location.                       |                                      |

---

## G9: Apartment & Housing

This section supports apartment listings, bookings, and ratings.

### Table: `apartment`

This table stores apartment listing details.

| Column            | Data Type        | Description                              | Constraints / Notes                  |
|-------------------|------------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`        | Unique identifier for the apartment.    | **Primary Key**                     |
| `name`           | `VARCHAR(255)`  | Apartment building name.                |                                      |
| `phone`          | `VARCHAR(10)`   | Contact phone.                          |                                      |
| `description`    | `TEXT`          | Apartment description.                  |                                      |
| `electric_price` | `DOUBLE PRECISION` | Electricity price per unit.             |                                      |
| `water_price`    | `DOUBLE PRECISION` | Water price per unit.                   |                                      |
| `internet`       | `apartment_internet` | Internet status (enum: 'free', 'not_free', 'none'). |                                      |
| `apartment_type` | `apartment_type` | Type (enum: 'dormitory', 'apartment').  |                                      |
| `apartment_location` | `apartment_location` | Location (enum: 'asoke', 'prachauthit', 'phathumwan'). |                                      |
| `address_id`     | `INTEGER`       | Physical address.                       | Foreign Key to `addresses(id)`      |

### Table: `apartment_owner`

This junction table links users to owned apartments.

| Column         | Data Type  | Description                              | Constraints / Notes                  |
|----------------|------------|------------------------------------------|--------------------------------------|
| `id`          | `SERIAL`  | Unique identifier for the record.       | **Primary Key**                     |
| `user_id`     | `INTEGER` | Apartment owner.                        | Foreign Key to `users(id)`          |
| `apartment_id`| `INTEGER` | Owned apartment.                        | Foreign Key to `apartment(id)`      |

### Table: `apartment_picture`

This table stores apartment images.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the picture.      | **Primary Key**                     |
| `name`      | `VARCHAR(255)` | Optional picture name or caption.       |                                      |
| `file_path` | `TEXT`         | Image URL or path.                      | `NOT NULL`                          |
| `apartment_id` | `INTEGER`    | Associated apartment.                   | Foreign Key to `apartment(id)`      |

### Table: `room`

This table details individual rooms in apartments.

| Column       | Data Type        | Description                              | Constraints / Notes                  |
|--------------|------------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`        | Unique identifier for the room.         | **Primary Key**                     |
| `name`      | `VARCHAR(255)`  | Room name or number.                    |                                      |
| `type`      | `VARCHAR(255)`  | Room type (e.g., 'Studio').             |                                      |
| `size`      | `VARCHAR(50)`   | Room size (e.g., '30 sqm').             |                                      |
| `room_status`| `room_status`   | Status (enum: 'occupied', 'pending', 'available'). |                                      |
| `price_start`| `DOUBLE PRECISION` | Starting price.                         |                                      |
| `price_end` | `DOUBLE PRECISION` | Ending price for ranges.                |                                      |
| `apartment_id` | `INTEGER`     | Containing apartment.                   | Foreign Key to `apartment(id)`      |

### Table: `apartment_booking`

This table tracks room bookings.

| Column          | Data Type       | Description                              | Constraints / Notes                  |
|-----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`           | `SERIAL`       | Unique identifier for the booking.      | **Primary Key**                     |
| `user_id`      | `INTEGER`      | Booking user.                           | Foreign Key to `users(id)`          |
| `check_in`     | `TIMESTAMPTZ(6)`| Check-in date.                          |                                      |
| `booking_status`| `booking_status`| Status (enum: 'pending', 'confirmed', 'cancelled'). | Default: `'pending'`                |
| `created_at`   | `TIMESTAMPTZ(6)`| Booking timestamp.                      | Default: `now()`                    |
| `updated_at`   | `TIMESTAMPTZ(6)`| Last update timestamp.                  | Default: `now()`                    |
| `room_id`      | `INTEGER`      | Booked room.                            | Foreign Key to `room(id)`           |
| `guest_name`   | `VARCHAR(255)` | Guest name (if not user).               |                                      |
| `guest_phone`  | `VARCHAR(10)`  | Guest phone.                            |                                      |
| `guest_email`  | `VARCHAR(255)` | Guest email.                            |                                      |
| `room_type`    | `VARCHAR(255)` | Denormalized room type.                 |                                      |

### Table: `rating`

This table stores apartment ratings and comments.

| Column       | Data Type        | Description                              | Constraints / Notes                  |
|--------------|------------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`        | Unique identifier for the rating.       | **Primary Key**                     |
| `user_id`   | `INTEGER`       | Submitting user.                        | Foreign Key to `users(id)`          |
| `rating`    | `DOUBLE PRECISION` | Numeric rating (e.g., 1-5).             |                                      |
| `comment`   | `TEXT`          | Text comment.                           |                                      |
| `created_at`| `TIMESTAMPTZ(6)` | Submission timestamp.                   | Default: `now()`                    |
| `apartment_id` | `INTEGER`     | Rated apartment.                        | Foreign Key to `apartment(id)`      |

---

## G10: Traffic Domain

This section manages traffic infrastructure and emergency requests.

### Table: `intersections`

This table stores road intersection locations.

| Column    | Data Type  | Description                              | Constraints / Notes                  |
|-----------|------------|------------------------------------------|--------------------------------------|
| `id`     | `SERIAL`  | Unique identifier for the intersection. | **Primary Key**                     |
| `location`| `geometry`| Geographic coordinates of the center.   |                                      |

### Table: `roads`

This table defines road segments.

| Column                 | Data Type       | Description                              | Constraints / Notes                  |
|------------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                  | `SERIAL`       | Unique identifier for the segment.      | **Primary Key**                     |
| `name`                | `VARCHAR(255)` | Road name.                              |                                      |
| `start_intersection_id`| `INTEGER`      | Starting intersection.                  | Foreign Key to `intersections(id)`  |
| `end_intersection_id` | `INTEGER`      | Ending intersection.                    | Foreign Key to `intersections(id)`  |
| `length_meters`       | `INTEGER`      | Segment length in meters.               |                                      |

### Table: `traffic_lights`

This table manages traffic light data and status.

| Column          | Data Type       | Description                              | Constraints / Notes                  |
|-----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`           | `SERIAL`       | Unique identifier for the light.        | **Primary Key**                     |
| `intersection_id` | `INTEGER`     | Location intersection.                  | Foreign Key to `intersections(id)`  |
| `ip_address`   | `INET`         | Network control IP address.             |                                      |
| `location`     | `geometry`     | Precise coordinates.                    | GIST Index (`idx_traffic_lights_location`) |
| `status`       | `INTEGER`      | Operational status code.                | Default: `0`                        |
| `current_color`| `SMALLINT`     | Current light color (integer).          |                                      |
| `density_level`| `SMALLINT`     | Traffic density metric.                 |                                      |
| `auto_mode`    | `BOOLEAN`      | Automatic mode flag.                    | Default: `TRUE`                     |
| `last_updated` | `TIMESTAMPTZ(6)`| Last status update timestamp.           | `NOT NULL`, Default: `now()`        |
| `road_id`      | `INTEGER`      | Controlled road.                        |                                      |
| `green_duration` | `INTEGER`    | Green light duration in seconds.        |                                      |
| `red_duration` | `INTEGER`      | Red light duration in seconds.          |                                      |
| `last_color`   | `SMALLINT`     | Previous light color.                   |                                      |

### Table: `light_requests`

This table logs traffic light change requests, often for emergencies.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the request.      | **Primary Key**                     |
| `traffic_light_id`| `INTEGER`      | Requested traffic light.                | Foreign Key to `traffic_lights(id)` |
| `requested_at`    | `TIMESTAMPTZ(6)`| Request timestamp.                      | `NOT NULL`, Default: `now()`        |

### Table: `vehicles`

This table tracks registered vehicles.

| Column           | Data Type   | Description                              | Constraints / Notes                  |
|------------------|-------------|------------------------------------------|--------------------------------------|
| `id`            | `SERIAL`   | Unique identifier for the vehicle.      | **Primary Key**                     |
| `user_id`       | `INTEGER`  | Vehicle owner.                          | Foreign Key to `users(id)`          |
| `current_location` | `geometry`| Real-time location.                     |                                      |
| `vehicle_plate` | `VARCHAR(20)` | License plate.                          |                                      |

### Table: `traffic_emergencies`

This table logs emergency traffic clearance requests.

| Column                | Data Type       | Description                              | Constraints / Notes                  |
|-----------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                 | `SERIAL`       | Unique identifier for the request.      | **Primary Key**                     |
| `user_id`            | `INTEGER`      | Initiating user.                        | Foreign Key to `users(id)`          |
| `accident_location`  | `geometry`     | Accident location.                      |                                      |
| `destination_hospital`| `VARCHAR(255)`| Destination hospital name.              |                                      |
| `status`             | `VARCHAR(50)`  | Request status.                         |                                      |
| `ambulance_vehicle_id`| `INTEGER`     | Involved ambulance.                     | Foreign Key to `vehicles(id)`       |
| `created_at`         | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

---

## G11: Financial (Wallets & Cards)

This section handles wallets, transactions, and specialized cards.

### Table: `wallets`

This table manages financial wallets for users or organizations.

| Column            | Data Type       | Description                              | Constraints / Notes                  |
|-------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`       | Unique identifier for the wallet.       | **Primary Key**                     |
| `owner_id`       | `INTEGER`      | Wallet owner.                           | Foreign Key to `users(id)`          |
| `wallet_type`    | `wallet_type`  | Type (enum: 'individual', 'organization'). |                                      |
| `organization_type`| `VARCHAR(100)`| Organization type, if applicable.       |                                      |
| `balance`        | `NUMERIC(14,2)`| Current balance.                        | Default: `0`                        |
| `status`         | `wallet_status`| Status (enum: 'active', 'suspended').   | Default: `'active'`                 |
| `created_at`     | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`     | `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |

**Note:** Unique constraint on (`owner_id`, `wallet_type`).

### Table: `wallet_transactions`

This table logs wallet transactions.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the transaction.  | **Primary Key**                     |
| `wallet_id`       | `INTEGER`      | Source wallet.                          | Foreign Key to `wallets(id)`        |
| `transaction_type`| `transaction_type` | Type (e.g., 'top_up', 'transfer_out').  |                                      |
| `amount`          | `NUMERIC(14,2)`| Transaction amount.                     | `NOT NULL`                          |
| `target_wallet_id`| `INTEGER`      | Target wallet for transfers.            | Foreign Key to `wallets(id)`        |
| `target_service`  | `VARCHAR(50)`  | Target service for payments.            |                                      |
| `description`     | `VARCHAR(255)` | Transaction description.                |                                      |
| `created_at`      | `TIMESTAMPTZ(6)`| Transaction timestamp.                  | `NOT NULL`, Default: `now()`        |

### Table: `insurance_cards`

This table stores insurance card details.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the card.         | **Primary Key**                     |
| `user_id`   | `INTEGER`      | Associated user.                        | Foreign Key to `users(id)`          |
| `balance`   | `NUMERIC(14,2)`| Card balance.                           | Default: `0`                        |
| `card_number`| `VARCHAR(50)`  | Unique card number.                     | `UNIQUE`                            |
| `status`    | `wallet_status`| Status (enum: 'active', 'suspended').   | Default: `'active'`                 |
| `created_at`| `TIMESTAMPTZ(6)`| Issuance timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`| `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |

### Table: `card_transactions`

This table consolidates transactions from various card types.

| Column                | Data Type       | Description                              | Constraints / Notes                  |
|-----------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                 | `SERIAL`       | Unique identifier for the transaction.  | **Primary Key**                     |
| `card_id`            | `INTEGER`      | Card ID (from `insurance_cards` or `metro_cards`). | `NOT NULL`                          |
| `card_type`          | `VARCHAR(50)`  | Card table identifier (e.g., 'insurance'). |                                      |
| `transaction_type`   | `card_transaction_type` | Type (enum: 'top_up', 'charge', 'refund'). |                                      |
| `transaction_category`| `transaction_category` | Category (enum: 'insurance', 'metro').  |                                      |
| `reference`          | `VARCHAR(100)` | Transaction reference code.             |                                      |
| `amount`             | `NUMERIC(12,2)`| Amount.                                 | Default: `0`                        |
| `description`        | `VARCHAR(255)` | Description.                            |                                      |
| `created_at`         | `TIMESTAMPTZ(6)`| Timestamp.                              | `NOT NULL`, Default: `now()`        |

---

## G12: Healthcare Domain

This section provides tables for healthcare services, facilities, and patient management.

### Table: `patients`

This table stores patient details linked to users.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the patient.      | **Primary Key**                     |
| `user_id`         | `INTEGER`      | Associated user.                        | Foreign Key to `users(id)`          |
| `emergency_contact`| `VARCHAR(200)` | Emergency contact information.          |                                      |
| `created_at`      | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `facilities`

This table manages healthcare facility information.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the facility.     | **Primary Key**                     |
| `name`            | `VARCHAR(255)` | Facility name.                          | `NOT NULL`                          |
| `facility_type`   | `VARCHAR(100)` | Facility type (e.g., 'Hospital').       |                                      |
| `address_id`      | `INTEGER`      | Physical address.                       | Foreign Key to `addresses(id)`      |
| `phone`           | `VARCHAR(20)`  | Contact phone.                          |                                      |
| `location`        | `geometry`     | Geographic coordinates.                 | GIST Index (`idx_facilities_location`) |
| `emergency_services`| `BOOLEAN`    | Emergency services availability.        | Default: `FALSE`                    |
| `department_id`   | `INTEGER`      | Associated department.                  | Foreign Key to `departments(id)`    |
| `created_at`      | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `beds`

This table tracks bed availability and assignments.

| Column          | Data Type       | Description                              | Constraints / Notes                  |
|-----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`           | `SERIAL`       | Unique identifier for the bed.          | **Primary Key**                     |
| `facility_id`  | `INTEGER`      | Containing facility.                    | Foreign Key to `facilities(id)`     |
| `bed_number`   | `VARCHAR(50)`  | Bed code.                               |                                      |
| `bed_type`     | `VARCHAR(50)`  | Bed type (e.g., 'ICU').                 |                                      |
| `status`       | `VARCHAR(50)`  | Bed status.                             |                                      |
| `patient_id`   | `INTEGER`      | Occupying patient.                      | Foreign Key to `patients(id)`       |
| `admission_date`| `TIMESTAMPTZ(6)`| Admission date.                         |                                      |
| `created_at`   | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `appointments`

This table schedules patient appointments.

| Column           | Data Type       | Description                              | Constraints / Notes                  |
|------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`            | `SERIAL`       | Unique identifier for the appointment.  | **Primary Key**                     |
| `patient_id`    | `INTEGER`      | Patient.                                | Foreign Key to `patients(id)`       |
| `facility_id`   | `INTEGER`      | Scheduled facility.                     | Foreign Key to `facilities(id)`     |
| `staff_user_id` | `INTEGER`      | Healthcare professional.                | Foreign Key to `users(id)`          |
| `appointment_at`| `TIMESTAMPTZ(6)`| Appointment date and time.              |                                      |
| `type`          | `VARCHAR(50)`  | Appointment type.                       |                                      |
| `status`        | `VARCHAR(50)`  | Appointment status.                     |                                      |
| `created_at`    | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `prescriptions`

This table issues medical prescriptions.

| Column              | Data Type       | Description                              | Constraints / Notes                  |
|---------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`               | `SERIAL`       | Unique identifier for the prescription. | **Primary Key**                     |
| `patient_id`       | `INTEGER`      | Intended patient.                       | Foreign Key to `patients(id)`       |
| `prescriber_user_id`| `INTEGER`      | Issuing professional.                   | Foreign Key to `users(id)`          |
| `facility_id`      | `INTEGER`      | Issuing facility.                       | Foreign Key to `facilities(id)`     |
| `medication_name`  | `VARCHAR(255)` | Medication name.                        |                                      |
| `quantity`         | `INTEGER`      | Prescribed quantity.                    |                                      |
| `status`           | `VARCHAR(50)`  | Prescription status.                    |                                      |
| `created_at`       | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `ambulances`

This table tracks ambulance status and locations.

| Column            | Data Type       | Description                              | Constraints / Notes                  |
|-------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`       | Unique identifier for the ambulance.    | **Primary Key**                     |
| `vehicle_number` | `VARCHAR(50)`  | Vehicle number or plate.                | `UNIQUE`                            |
| `status`         | `VARCHAR(50)`  | Current status.                         |                                      |
| `current_location`| `geometry`     | Real-time location.                     |                                      |
| `base_facility_id`| `INTEGER`      | Home facility.                          | Foreign Key to `facilities(id)`     |
| `created_at`     | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `emergency_calls`

This table logs medical emergency calls.

| Column           | Data Type       | Description                              | Constraints / Notes                  |
|------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`            | `SERIAL`       | Unique identifier for the call.         | **Primary Key**                     |
| `patient_id`    | `INTEGER`      | Involved patient, if known.             | Foreign Key to `patients(id)`       |
| `caller_phone`  | `VARCHAR(20)`  | Caller's phone.                         |                                      |
| `emergency_type`| `VARCHAR(100)` | Emergency type.                         |                                      |
| `severity`      | `VARCHAR(50)`  | Severity level.                         |                                      |
| `address_id`    | `INTEGER`      | Emergency location.                     | Foreign Key to `addresses(id)`      |
| `ambulance_id`  | `INTEGER`      | Dispatched ambulance.                   | Foreign Key to `ambulances(id)`     |
| `facility_id`   | `INTEGER`      | Destination facility.                   | Foreign Key to `facilities(id)`     |
| `status`        | `VARCHAR(50)`  | Response status.                        |                                      |
| `created_at`    | `TIMESTAMPTZ(6)`| Call receipt timestamp.                 | `NOT NULL`, Default: `now()`        |

### Table: `payments`

This table records healthcare-related payments.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the payment.      | **Primary Key**                     |
| `patient_id`      | `INTEGER`      | Associated patient.                     | Foreign Key to `patients(id)`       |
| `facility_id`     | `INTEGER`      | Receiving facility.                     | Foreign Key to `facilities(id)`     |
| `service_type`    | `VARCHAR(100)` | Paid service type.                      |                                      |
| `service_id`      | `INTEGER`      | Specific service ID.                    |                                      |
| `amount`          | `NUMERIC(12,2)`| Total amount.                           | Default: `0`                        |
| `currency`        | `CHAR(3)`      | Currency (e.g., 'THB').                 | Default: `'THB'`                    |
| `payment_method`  | `VARCHAR(50)`  | Payment method.                         |                                      |
| `insurance_coverage` | `NUMERIC(12,2)`| Insurance-covered amount.               | Default: `0`                        |
| `patient_copay`   | `NUMERIC(12,2)`| Patient-paid amount.                    | Default: `0`                        |
| `status`          | `VARCHAR(50)`  | Payment status.                         |                                      |
| `payment_date`    | `TIMESTAMPTZ(6)`| Payment date.                           |                                      |
| `created_at`      | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

---

## G13: Emergency Reports & Communication

This section facilitates emergency reporting, contacts, and communication.

### Table: `report_categories`

This table defines categories for reports.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the category.     | **Primary Key**                     |
| `name`      | `VARCHAR(255)` | Unique category name.                   | `NOT NULL`, `UNIQUE`                |
| `created_at`| `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`| `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |

### Table: `emergency_reports`

This table stores user-submitted emergency reports.

| Column                 | Data Type       | Description                              | Constraints / Notes                  |
|------------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                  | `SERIAL`       | Unique identifier for the report.       | **Primary Key**                     |
| `user_id`             | `INTEGER`      | Submitting user.                        | Foreign Key to `users(id)`          |
| `image_url`           | `VARCHAR(1024)`| Incident image URL.                     |                                      |
| `description`         | `TEXT`         | Incident description.                   |                                      |
| `location`            | `geometry`     | Incident location.                      | GIST Index (`idx_emergency_reports_location`) |
| `ambulance_service`   | `BOOLEAN`      | Ambulance request flag.                 | Default: `FALSE`                    |
| `level`               | `report_level` | Severity (enum: 'near_miss', 'minor', 'moderate', 'major', 'lethal'). |                                      |
| `status`              | `report_status`| Status (enum: 'pending', 'verified', 'resolved'). | Default: `'pending'`                |
| `created_at`          | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`          | `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |
| `title`               | `TEXT`         | Report title.                           | `NOT NULL`                          |
| `contact_center_service` | `BOOLEAN`   | Contact center request flag.            | Default: `FALSE`                    |
| `report_category`     | `report_type`  | Type (enum: 'traffic', 'accident', 'disaster'). |                                      |

### Table: `emergency_contacts`

This table stores users' emergency contacts.

| Column         | Data Type       | Description                              | Constraints / Notes                  |
|----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`          | `SERIAL`       | Unique identifier for the contact.      | **Primary Key**                     |
| `user_id`     | `INTEGER`      | Owning user.                            | Foreign Key to `users(id)`          |
| `contact_name`| `VARCHAR(255)` | Contact name.                           | `NOT NULL`                          |
| `phone`       | `VARCHAR(20)`  | Contact phone.                          |                                      |

### Table: `alerts`

This table manages alerts sent to users.

| Column     | Data Type       | Description                              | Constraints / Notes                  |
|------------|-----------------|------------------------------------------|--------------------------------------|
| `id`      | `SERIAL`       | Unique identifier for the alert.        | **Primary Key**                     |
| `report_id`| `INTEGER`      | Triggering report.                      | Foreign Key to `emergency_reports(id)` |
| `user_id` | `INTEGER`      | Receiving user.                         | Foreign Key to `users(id)`          |
| `message` | `TEXT`         | Alert message.                          | `NOT NULL`                          |
| `status`  | `alert_status` | Status (enum: 'unread', 'read', 'sent').| Default: `'unread'`                 |
| `location`| `geometry`     | Relevant location.                      |                                      |
| `sent_at` | `TIMESTAMPTZ(6)`| Sent timestamp.                         | Default: `now()`                    |

### Table: `sos`

This table handles SOS requests.

| Column       | Data Type       | Description                              | Constraints / Notes                  |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| `id`        | `SERIAL`       | Unique identifier for the SOS.          | **Primary Key**                     |
| `user_id`   | `INTEGER`      | Triggering user.                        | Foreign Key to `users(id)`          |
| `location`  | `geometry`     | User's location.                        |                                      |
| `status`    | `sos_status`   | Status (enum: 'open', 'closed').        | Default: `'open'`                   |
| `created_at`| `TIMESTAMPTZ(6)`| Request timestamp.                      | Default: `now()`                    |
| `updated_at`| `TIMESTAMPTZ(6)`| Last update timestamp.                  | Default: `now()`                    |

### Table: `conversations`

This table manages chat conversations.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the conversation. | **Primary Key**                     |
| `conversation_name`| `VARCHAR(255)` | Name for group chats.                   |                                      |
| `created_at`      | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

### Table: `conversation_participants`

This junction table links users to conversations.

| Column             | Data Type  | Description                              | Constraints / Notes                  |
|--------------------|------------|------------------------------------------|--------------------------------------|
| `conversation_id` | `INTEGER` | Foreign key referencing the conversation.| **Composite Primary Key**, Foreign Key to `conversations(id)` |
| `user_id`         | `INTEGER` | Foreign key referencing the user.       | **Composite Primary Key**, Foreign Key to `users(id)` |

### Table: `messages`

This table stores chat messages.

| Column          | Data Type       | Description                              | Constraints / Notes                  |
|-----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`           | `SERIAL`       | Unique identifier for the message.      | **Primary Key**                     |
| `conversation_id`| `INTEGER`     | Containing conversation.                | Foreign Key to `conversations(id)`  |
| `sender_id`    | `INTEGER`      | Sending user.                           | Foreign Key to `users(id)`          |
| `message_text` | `TEXT`         | Message content.                        |                                      |
| `sent_at`      | `TIMESTAMPTZ(6)`| Sent timestamp.                         | `NOT NULL`, Default: `now()`        |

---

## G15: Waste Management

This section tracks waste types and collection statistics.

### Table: `waste_types`

This table defines waste types.

| Column             | Data Type       | Description                              | Constraints / Notes                  |
|--------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`              | `SERIAL`       | Unique identifier for the type.         | **Primary Key**                     |
| `type_name`       | `VARCHAR(255)` | Waste type name.                        | `NOT NULL`                          |
| `typical_weight_kg`| `NUMERIC(10,3)`| Typical unit weight in kg.              |                                      |

### Table: `waste_event_statistics`

This table logs waste collection stats from events.

| Column                  | Data Type       | Description                              | Constraints / Notes                  |
|-------------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                   | `SERIAL`       | Unique identifier for the statistic.    | **Primary Key**                     |
| `event_id`             | `INTEGER`      | Collection event.                       | Foreign Key to `events(id)`         |
| `waste_type_id`        | `INTEGER`      | Collected waste type.                   | Foreign Key to `waste_types(id)`    |
| `collection_date`      | `TIMESTAMPTZ(6)`| Collection date.                        |                                      |
| `total_collection_weight`| `NUMERIC(12,3)`| Total weight in kg.                     |                                      |

### Table: `power_bi_reports`

This table links statistics to Power BI reports.

| Column                     | Data Type       | Description                              | Constraints / Notes                  |
|----------------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`                      | `SERIAL`       | Unique identifier for the link.         | **Primary Key**                     |
| `waste_event_statistic_id`| `INTEGER`      | Linked statistic.                       | Foreign Key to `waste_event_statistics(id)` |
| `report_type`             | `VARCHAR(255)` | Report type.                            |                                      |
| `report_date`             | `TIMESTAMPTZ(6)`| Generation date.                        |                                      |
| `created_at`              | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |

---

## G16: Community Map (POI)

This section manages community map markers.

### Table: `marker_type`

This table defines marker types.

| Column              | Data Type       | Description                              | Constraints / Notes                  |
|---------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`               | `SERIAL`       | Unique identifier for the type.         | **Primary Key**                     |
| `marker_type_icon` | `VARCHAR(255)` | Icon name or URL.                       |                                      |
| `marker_type_color`| `VARCHAR(255)` | Color (e.g., hex code).                 |                                      |
| `created_at`       | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`       | `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |

### Table: `marker`

This table stores map markers (Points of Interest).

| Column         | Data Type       | Description                              | Constraints / Notes                  |
|----------------|-----------------|------------------------------------------|--------------------------------------|
| `id`          | `SERIAL`       | Unique identifier for the marker.       | **Primary Key**                     |
| `marker_type_id`| `INTEGER`     | Marker type.                            | Foreign Key to `marker_type(id)`    |
| `description` | `TEXT`         | Marker description.                     |                                      |
| `location`    | `geometry`     | Geographic coordinates.                 |                                      |
| `created_at`  | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |
| `updated_at`  | `TIMESTAMPTZ(6)`| Last update timestamp.                  | `NOT NULL`, Default: `now()`        |

---

## System & Miscellaneous Tables

This section includes internal tables for system operations.

### Table: `spatial_ref_sys`

This standard PostGIS table stores spatial reference systems.

| Column     | Data Type       | Description                              | Constraints / Notes                  |
|------------|-----------------|------------------------------------------|--------------------------------------|
| `srid`    | `INTEGER`      | Spatial reference system ID.            | **Primary Key**                     |
| `auth_name`| `VARCHAR(256)` | Authority name (e.g., 'EPSG').          |                                      |
| `auth_srid`| `INTEGER`      | Authority SRID code.                    |                                      |
| `srtext`  | `VARCHAR(2048)`| Well-Known Text representation.         |                                      |
| `proj4text`| `VARCHAR(2048)`| Proj4 string representation.            |                                      |

**Note:** Standard PostGIS table; modifications should be avoided.

### Table: `team_integrations`

This table manages integrations with external systems.

| Column            | Data Type       | Description                              | Constraints / Notes                  |
|-------------------|-----------------|------------------------------------------|--------------------------------------|
| `id`             | `SERIAL`       | Unique identifier for the integration.  | **Primary Key**                     |
| `team_name`      | `VARCHAR(100)` | External team name.                     |                                      |
| `external_table` | `VARCHAR(100)` | External table name.                    |                                      |
| `external_id`    | `VARCHAR(100)` | External ID.                            |                                      |
| `data_type`      | `VARCHAR(50)`  | Integrated data type.                   |                                      |
| `status`         | `VARCHAR(50)`  | Integration status.                     |                                      |
| `additional_data`| `JSONB`        | Extra data in JSON format.              |                                      |
| `created_at`     | `TIMESTAMPTZ(6)`| Creation timestamp.                     | `NOT NULL`, Default: `now()`        |
