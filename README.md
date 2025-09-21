# Smart City DB Data Dictionary
* **Project:** Smart City DB
* **Database:** PostgreSQL
* **Last Updated:** 2025-09-22

---

## Core Features & Authentication
This group contains the core tables for user management, authentication, and general system structure.

### Table: `roles`
Stores user roles to manage permissions.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the role. | **Primary Key**, Auto-increment |
| `role_name` | `VARCHAR(50)` | The name of the role (e.g., 'Admin', 'Citizen', 'Doctor', 'Security, etc.'). | |

### Enum: `genders`
Defines the possible gender options for users.
* `MALE`
* `FEMALE`
* `NONE`

### Table: `departments`
Stores information about various city departments or organizations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the department. | **Primary Key**, Auto-increment |
| `department_name` | `VARCHAR(255)` | The official name of the department (e.g., 'Health Care', 'Education', 'Volunteer', etc.). | |
| `created_at` | `TIMESTAMP` | Timestamp when the department was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the department was last updated. | |

### Table: `users`
Stores information about individual users of the application.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the user. | **Primary Key**, Auto-increment |
| `username` | `VARCHAR(25)` | The user's unique username for login. | |
| `first_name` | `VARCHAR(255)` | User's first name. | |
| `middle_name` | `VARCHAR(255)` | User's middle name. | Optional |
| `last_name` | `VARCHAR(255)` | User's last name. | |
| `gender` | `genders` | User's gender. | Enum Type |
| `role_id` | `INT` | Foreign key referencing the user's role. | Foreign Key to `roles.id` |
| `password_hash` | `VARCHAR(256)` | Hashed password for security. | Not Null |
| `email` | `VARCHAR(255)` | User's unique email address. | Unique |
| `phone` | `VARCHAR(15)` | User's unique phone number. | Unique |
| `province` | `VARCHAR(255)` | Province of the user's address. | |
| `district` | `VARCHAR(255)` | District of the user's address. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict of the user's address. | |
| `zip_code` | `VARCHAR(20)` | Zip code of the user's address. | |
| `more_address_detail` | `TEXT` | Additional address details (e.g., street, house number). | |
| `birth_date` | `TIMESTAMP` | User's date of birth. | Not Null |
| `created_at` | `TIMESTAMP` | Timestamp when the user account was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the user account was last updated. | |

### Table: `users_departments`
A junction table linking users to the departments they belong to.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | Foreign key referencing the user. | **Composite Primary Key**, Foreign Key to `users.id` |
| `department_id` | `INT` | Foreign key referencing the department. | **Composite Primary Key**, Foreign Key to `departments.id` |

### Table: `sessions`
Stores active user login sessions.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `session_id` | `VARCHAR(255)` | Unique identifier for the session. | |
| `user_id` | `INT` | The user associated with the session. | Foreign Key to `users.id` |
| `created_at` | `TIMESTAMP` | Timestamp when the session was created. | |
| `expires_at` | `TIMESTAMP` | Timestamp when the session will expire. | |
| `last_accessed` | `TIMESTAMP` | Timestamp of the last activity in this session. | |

### Table: `refresh_tokens`
Stores refresh tokens for re-authenticating users without requiring credentials.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the token. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user associated with the token. | Foreign Key to `users.id` |
| `refresh_token` | `VARCHAR(512)` | The refresh token string. | |
| `created_at` | `TIMESTAMP` | Timestamp when the token was created. | |
| `expires_at` | `TIMESTAMP` | Timestamp when the token will expire. | |

---

## G1: Know AI Courses
Tables related to the online and onsite educational courses feature.

### Enum: `course_types`
Defines the delivery format for a course.
* `ONLINE`
* `ONSITE`
* `ONLINE_AND_ONSITE`

### Table: `courses`
Stores main information about available courses.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the course. | **Primary Key**, Auto-increment |
| `author_id` | `INT` | The user who created the course. | Foreign Key to `users.id` |
| `course_name` | `VARCHAR(255)` | The title of the course. | Not Null |
| `course_description` | `TEXT` | A detailed description of the course content. | Not Null |
| `course_type` | `course_types` | The format of the course (e.g., ONLINE, ONSITE). | Not Null, Enum Type |
| `cover_image` | `TEXT` | URL or path to the course's cover image. | Not Null |
| `created_at` | `TIMESTAMP` | Timestamp when the course was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the course was last updated. | |

### Table: `online_courses`
Stores details for online course content, such as video lessons.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the online video/module. | **Primary Key**, Auto-increment |
| `video_name` | `VARCHAR(100)` | Title of the video lesson. | Not Null |
| `video_description` | `TEXT` | Description of the video content. | Not Null |
| `duration_minutes` | `DECIMAL` | Length of the video in minutes. | Not Null |
| `video_order` | `INT` | The sequence number of the video in the course. | Not Null |
| `video_file_path` | `TEXT` | Path or URL to the video file. | Not Null |
| `course_id` | `INT` | The course this video belongs to. | Not Null, Foreign Key to `courses.id` |
| `created_at` | `TIMESTAMP` | Timestamp when the video was added. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the video was last updated. | |

### Table: `onsites`
Stores details for onsite (in-person) course events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the onsite event. | **Primary Key**, Auto-increment |
| `course_id` | `INT` | The course this onsite event belongs to. | Foreign Key to `courses.id` |
| `province` | `VARCHAR(255)` | Province where the event is held. | |
| `district` | `VARCHAR(255)` | District where the event is held. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict where the event is held. | |
| `more_address_detail` | `TEXT` | Specific location details (e.g., building, room). | |
| `duration_hours` | `DECIMAL` | Duration of the onsite event in hours. | |
| `event_datetime` | `TIMESTAMP` | The date and time of the event. | Not Null |
| `registration_deadline` | `TIMESTAMP` | The deadline for registration. | Not Null |
| `avaliable_seat` | `INT` | Number of currently available seats. | Not Null, Default: 0 |
| `total_seat` | `INT` | Total number of seats for the event. | Not Null, Default: 1 |
| `created_at` | `TIMESTAMP` | Timestamp when the event was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the event was last updated. | |

### Table: `onsite_enrollments`
Tracks user enrollments for onsite course events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the enrollment. | **Primary Key**, Auto-increment |
| `onsite_id` | `INT` | The onsite event being enrolled in. | Foreign Key to `onsites.id` |
| `user_id` | `INT` | The user who is enrolling. | **Composite Primary Key**, Foreign Key to `users.id` |

### Table: `questions`
Stores questions for exercises and quizzes.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the question. | **Primary Key**, Auto-increment |
| `question` | `TEXT` | The text of the question. | |
| `level` | `INT` | The difficulty level of the question. | |
| `created_at` | `TIMESTAMP` | Timestamp when the question was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the question was last updated. | |

### Table: `user_exercises`
Logs users' answers to exercise questions.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the user's attempt. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user who answered the question. | Foreign Key to `users.id` |
| `question_id` | `INT` | The question that was answered. | Foreign Key to `questions.id` |
| `user_answer` | `TEXT` | The answer provided by the user. | |
| `is_correct` | `BOOLEAN` | Whether the user's answer was correct. | |
| `created_at` | `TIMESTAMP` | Timestamp when the answer was submitted. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the record was last updated. | |

### Table: `user_level`
Stores the current skill or experience level of a user.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | The user associated with the level. | Foreign Key to `users.id` |
| `current_lv` | `INT` | The user's current level. | |

---

## G3: Event Hub
Tables for managing general public events.

### Table: `event`
Stores information about events created by users or departments.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the event. | **Primary Key**, Auto-increment |
| `host_event_id` | `INT` | The user ID of the event host. | Foreign Key to `users.id` |
| `from_department` | `INT` | The department organizing the event. | Foreign Key to `departments.id` |
| `image` | `TEXT` | URL or path to the event's promotional image. | |
| `title` | `VARCHAR(255)` | The title of the event. | |
| `description` | `VARCHAR(255)` | A short description of the event. | |
| `avaliable_seat` | `INT` | Number of currently available seats. | |
| `total_seat` | `INT` | Total number of seats for the event. | |
| `start_date` | `TIMESTAMP` | The start date and time of the event. | |
| `end_date` | `TIMESTAMP` | The end date and time of the event. | |
| `province` | `VARCHAR(255)` | Province where the event is held. | |
| `district` | `VARCHAR(255)` | District where the event is held. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict where the event is held. | |
| `more_location_detail` | `TEXT` | Specific location details. | |
| `created_at` | `TIMESTAMP` | Timestamp when the event was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the event was last updated. | |

### Table: `bookmark`
Allows users to save or "bookmark" events they are interested in.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | The user who bookmarked the event. | **Composite Primary Key**, Foreign Key to `users.id` |
| `event_id` | `INT` | The event that was bookmarked. | **Composite Primary Key**, Foreign Key to `event.id` |
| `createdAt` | `TIMESTAMP` | Timestamp when the bookmark was created. | |

---

## G4: Freecycle
Tables for the feature allowing users to donate and receive items for free.

### Table: `freecycle_posts`
Stores posts created by users to donate items.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the post. | **Primary Key**, Auto-increment |
| `item_name` | `VARCHAR(100)` | The name of the item being donated. | Not Null |
| `item_weight` | `DECIMAL` | The approximate weight of the item. | |
| `photo_url` | `TEXT` | URL to a photo of the item. | Not Null |
| `description` | `TEXT` | A description of the item. | Not Null |
| `donater_id` | `INT` | The user who is donating the item. | Not Null, Foreign Key to `users.id` |
| `donate_to_department_id` | `INT` | An optional specific department to donate to (can be NULL if donate to user). | Foreign Key to `departments.id` |
| `is_given` | `BOOLEAN` | Flag indicating if the item has been given away. | Default: `false` |
| `created_at` | `TIMESTAMP` | Timestamp when the post was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the post was last updated. | |

### Table: `freecycle_categories`
Stores categories for freecycle items (e.g., 'Furniture', 'Electronics').
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the category. | **Primary Key**, Auto-increment |
| `category_name` | `VARCHAR(100)` | The name of the category. | |
| `created_at` | `TIMESTAMP` | Timestamp when the category was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the category was last updated. | |

### Table: `freecycle_posts_categories`
A junction table linking freecycle posts to their respective categories.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `post_id` | `INT` | Foreign key referencing the freecycle post. | **Composite Primary Key**, Foreign Key to `freecycle_posts.id` |
| `category_id` | `INT` | Foreign key referencing the freecycle category. | **Composite Primary Key**, Foreign Key to `freecycle_categories.id` |

### Enum: `freecycle_request_status`
Defines the status of a request made by a user to receive an item.
* `PENDING`
* `ACCEPTED`
* `REJECTED`

### Table: `receiver_requests`
Tracks requests from users to receive a donated item.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the request. | **Primary Key**, Auto-increment |
| `post_id` | `INT` | The post being requested. | Foreign Key to `freecycle_posts.id` |
| `receiver_id` | `INT` | The user requesting the item. | Foreign Key to `users.id` |
| `status` | `freecycle_request_status` | The current status of the request. | Enum Type, Default: `'PENDING'` |
| `created_at` | `TIMESTAMP` | Timestamp when the request was made. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the request was last updated. | |

---

## G5: Air Quality
Tables for storing and contextualizing air quality data.

### Enum: `categories`
Defines the categories for air quality levels.
* `GOOD`
* `MODERATE`
* `UNHEALTHY`
* `HAZARDDOUS`

### Table: `air_quality`
Stores air quality index (AQI) and pollutant data for specific locations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the data reading. | **Primary Key**, Auto-increment |
| `province` | `VARCHAR(255)` | Province of the reading. | |
| `district` | `VARCHAR(255)` | District of the reading. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict of the reading. | |
| `more_address_detail` | `TEXT` | Specific location details. | |
| `aqi` | `DECIMAL` | The overall Air Quality Index value. | |
| `pm25` | `DECIMAL` | PM2.5 particle concentration. | |
| `pm10` | `DECIMAL` | PM10 particle concentration. | |
| `co` | `DECIMAL` | Carbon Monoxide concentration. | |
| `no2` | `DECIMAL` | Nitrogen Dioxide concentration. | |
| `so2` | `DECIMAL` | Sulfur Dioxide concentration. | |
| `o3` | `DECIMAL` | Ozone concentration. | |
| `category` | `categories` | The overall air quality category. | Enum Type |
| `created_at` | `TIMESTAMP` | Timestamp of the data reading. | |

### Table: `weather_context`
Stores weather data that can affect air quality.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the weather reading. | **Primary Key**, Auto-increment |
| `rain_forecast` | `DECIMAL` | Rain forecast percentage or amount. | |
| `created_at` | `TIMESTAMP` | Timestamp of the weather data. | |

### Table: `traffic_context`
Stores traffic data that can affect air quality.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the traffic reading. | **Primary Key**, Auto-increment |
| `congestion_level` | `DECIMAL` | A metric representing traffic congestion. | |
| `created_at` | `TIMESTAMP` | Timestamp of the traffic data. | |

---

## G6: Volunteer
Tables for managing volunteer events and participation.

### Enum: `volunteer_event_status`
Defines the approval status of a volunteer event.
* `DRAFT`
* `PENDING`
* `APPROVED`
* `REJECTED`

### Table: `volunteer_events`
Stores information about volunteer events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the volunteer event. | **Primary Key**, Auto-increment |
| `user_created_event_id` | `INT` | The user who created the event. | Foreign Key to `users.id` |
| `for_department` | `INT` | The department the event is for. | Foreign Key to `departments.id` |
| `image` | `TEXT` | URL or path to the event's image. | |
| `title` | `VARCHAR(255)` | The title of the volunteer event. | Not Null |
| `description` | `TEXT` | A detailed description of the event. | Not Null |
| `current_participator` | `INT` | The current number of registered participants. | Not Null, Default: 0 |
| `avaliable_seat` | `INT` | Number of available spots for volunteers. | Not Null, Default: 0 |
| `total_seat` | `INT` | Total number of spots for volunteers. | Not Null, Default: 1 |
| `start_date` | `TIMESTAMP` | The start date and time of the event. | |
| `end_date` | `TIMESTAMP` | The end date and time of the event. | |
| `register_deadline` | `TIMESTAMP` | The deadline for registration. | |
| `district` | `VARCHAR(255)` | District where the event is held. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict where the event is held. | |
| `more_location_detail` | `TEXT` | Specific location details. | |
| `status` | `volunteer_event_status` | The approval status of the event. | Enum Type |
| `created_at` | `TIMESTAMP` | Timestamp when the event was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the event was last updated. | |

### Table: `volunteer_event_participation`
Tracks which users are participating in which volunteer events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the participation record. | **Primary Key**, Auto-increment |
| `volunteer_event_id` | `INT` | The event being participated in. | Foreign Key to `volunteer_events.id` |
| `participated_user_id` | `INT` | The user who is participating. | Foreign Key to `users.id` |
| `created_at` | `TIMESTAMP` | Timestamp when the user registered. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the record was last updated. | |

---

## G7: Power BI Report Management
Data warehouse schema with dimension and fact tables for business intelligence and reporting.

### Table: `dim_time`
A dimension table for time-based analysis.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `time_id` | `INT` | Unique identifier for the time record. | **Primary Key**, Auto-increment |
| `date` | `TIMESTAMP` | The full timestamp. | |
| `year` | `INT` | The year component of the date. | |
| `month` | `INT` | The month component of the date. | |
| `day` | `INT` | The day component of the date. | |
| `hour` | `INT` | The hour component of the date. | |
| `week_a_day` | `VARCHAR(255)` | The day of the week (e.g., 'Monday'). | |

### Table: `dim_location`
A dimension table for location-based analysis.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `location_id` | `INT` | Unique identifier for the location. | **Primary Key**, Auto-increment |
| `province` | `VARCHAR(255)` | Province name. | |
| `district` | `VARCHAR(255)` | District name. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict name. | |
| `latitude` | `DECIMAL` | The latitude coordinate. | |
| `longitude` | `DECIMAL` | The longitude coordinate. | |

### Table: `dim_facility`
A dimension table for facilities like hospitals or waste collection centers.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `facility_id` | `INT` | Unique identifier for the facility. | **Primary Key**, Auto-increment |
| `facility_type` | `VARCHAR(255)` | The type of facility (e.g., 'Hospital'). | |
| `facility_name` | `VARCHAR(255)` | The name of the facility. | |
| `location_id` | `INT` | The location of the facility. | Foreign Key to `dim_location.location_id` |

### Table: `fact_traffic`
A fact table storing traffic metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `traffic_id` | `INT` | Unique identifier for the traffic fact. | **Primary Key**, Auto-increment |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time.time_id` |
| `location_id` | `INT` | Reference to the location dimension. | Foreign Key to `dim_location.location_id` |
| `speed_kmh` | `DECIMAL` | Average traffic speed in km/h. | |
| `accident_flag` | `BOOLEAN` | Flag indicating if an accident occurred. | |
| `closure_flag` | `BOOLEAN` | Flag indicating if a road was closed. | |

### Table: `fact_waste`
A fact table storing waste management metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `waste_id` | `INT` | Unique identifier for the waste fact. | **Primary Key**, Auto-increment |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time.time_id` |
| `location_id` | `INT` | Reference to the location dimension. | Foreign Key to `dim_location.location_id` |
| `bin_fill_level_percent` | `INT` | The fill level of waste bins as a percentage. | |
| `recycling_tonnage` | `DECIMAL` | Amount of recycled waste in tonnage. | |

### Table: `fact_healthcare`
A fact table storing healthcare metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `health_id` | `INT` | Unique identifier for the healthcare fact. | **Primary Key**, Auto-increment |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time.time_id` |
| `facility_id` | `INT` | Reference to the facility dimension. | Foreign Key to `dim_facility.facility_id` |
| `wait_time_minutes` | `INT` | Average patient wait time in minutes. | |
| `alert_type` | `VARCHAR(255)` | Type of health alert (e.g., 'outbreak'). | |
| `cases_reported` | `INT` | Number of new cases reported. | |

### Table: `fact_weather`
A fact table storing weather and environmental metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `weather_id` | `INT` | Unique identifier for the weather fact. | **Primary Key**, Auto-increment |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time.time_id` |
| `location_id` | `INT` | Reference to the location dimension. | Foreign Key to `dim_location.location_id` |
| `temperature` | `DECIMAL` | Temperature reading. | |
| `aqi` | `INT` | Air Quality Index value. | |
| `warning_flag` | `BOOLEAN` | Flag indicating a weather warning. | |

### Table: `fact_demographic`
A fact table storing demographic metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `demographic_id` | `INT` | Unique identifier for the demographic fact. | **Primary Key**, Auto-increment |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time.time_id` |
| `location_id` | `INT` | Reference to the location dimension. | Foreign Key to `dim_location.location_id` |
| `population_total` | `INT` | The total population in the area. | |

### Table: `dim_user`
A dimension table for user-based analysis.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | Unique identifier for the user dimension. | **Primary Key**, Auto-increment |
| `role` | `VARCHAR` | The role of the user. | |
| `department` | `VARCHAR` | The department of the user. | |

### Table: `dim_category`
A dimension table for categorizing reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `category_id` | `INT` | Unique identifier for the category. | **Primary Key**, Auto-increment |
| `category_name` | `VARCHAR(255)` | The name of the category. | |

### Table: `report_metadata`
Stores metadata about generated reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `report_id` | `INT` | Unique identifier for the report. | **Primary Key**, Auto-increment |
| `title` | `VARCHAR(255)` | The title of the report. | |
| `description` | `VARCHAR(255)` | A description of the report. | |
| `category_id` | `INT` | The category of the report. | Foreign Key to `dim_category.category_id` |
| `created_by` | `INT` | The user who created the report. | Foreign Key to `dim_user.user_id` |
| `last_updated` | `TIMESTAMP` | Timestamp of the last update. | |

---

## G8: Transportation
Tables related to public transportation services.

### Enum: `transportation_digital_card_status`
* `active`
* `inactive`

### Table: `digital_card`
Stores information about user's digital transportation cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `card_id` | `INT` | Unique identifier for the digital card. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user who owns the card. | Foreign Key to `users.id` |
| `status` | `transportation_digital_card_status` | The status of the card. | Enum Type |

### Table: `transportation_vehicle_type`
Stores different types of public transport vehicles (e.g., 'Bus', 'Train').
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `type_id` | `INT` | Unique identifier for the vehicle type. | **Primary Key**, Auto-increment |
| `type_name` | `VARCHAR(100)` | The name of the vehicle type. | |

### Table: `route`
Stores information about transportation routes.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `route_id` | `INT` | Unique identifier for the route. | **Primary Key**, Auto-increment |
| `route_name` | `VARCHAR(255)` | The name or number of the route. | |
| `type_id` | `INT` | The type of vehicle that serves this route. | Foreign Key to `transportation_vehicle_type.type_id` |

### Enum: `transportation_card_transaction_status`
* `pending`
* `confirmed`
* `failed`

### Table: `transportation_card_transaction`
Logs transactions made with digital transportation cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `transaction_id` | `INT` | Unique identifier for the transaction. | **Primary Key**, Auto-increment |
| `card_id` | `INT` | The card used for the transaction. | Foreign Key to `digital_card.card_id` |
| `route_id` | `INT` | The route on which the transaction occurred. | Foreign Key to `route.route_id` |
| `amount` | `DECIMAL` | The transaction amount. | |
| `status` | `transportation_card_transaction_status` | The status of the transaction. | Enum Type |
| `timestamp` | `TIMESTAMP` | The date and time of the transaction. | |

### Enum: `transportation_vehicle_status`
* `active`
* `maintenance`

### Table: `transportation_vehicle`
Tracks individual public transport vehicles.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `vehicle_id` | `INT` | Unique identifier for the vehicle. | **Primary Key**, Auto-increment |
| `type_id` | `INT` | The type of the vehicle. | Foreign Key to `transportation_vehicle_type.type_id` |
| `route_id` | `INT` | The current route of the vehicle. | Foreign Key to `route.route_id` |
| `current_latitude` | `VARCHAR(100)` | The current latitude of the vehicle. | |
| `current_longitude` | `VARCHAR(100)` | The current longitude of the vehicle. | |
| `status` | `transportation_vehicle_status` | The operational status of the vehicle. | Enum Type |

### Table: `stop`
Stores information about bus stops or train stations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `stop_id` | `INT` | Unique identifier for the stop. | **Primary Key**, Auto-increment |
| `stop_name` | `VARCHAR(255)` | The name of the stop. | |
| `stop_latitude` | `VARCHAR(100)` | The latitude of the stop. | |
| `stop_longitude` | `VARCHAR(100)` | The longitude of the stop. | |

### Table: `route_stop`
Defines the sequence of stops for each route.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `route_stop_id` | `INT` | Unique identifier for the route-stop link. | **Primary Key**, Auto-increment |
| `route_id` | `INT` | The route this entry belongs to. | Foreign Key to `route.route_id` |
| `stop_id` | `INT` | The stop on the route. | Foreign Key to `stop.stop_id` |
| `stop_order` | `INT` | The order of this stop on the route. | |
| `travel_time_to_next_stop` | `INT` | Estimated travel time to the next stop in minutes. | |

### Table: `transportation_user_request`
Logs user requests for trip planning.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `request_id` | `INT` | Unique identifier for the request. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user who made the request. | Foreign Key to `users.id` |
| `origin_stop_id` | `INT` | The starting stop for the trip. | Foreign Key to `stop.stop_id` |
| `destination_stop_id` | `INT` | The destination stop for the trip. | Foreign Key to `stop.stop_id` |
| `fastest_route_id` | `INT` | The suggested fastest route. | Foreign Key to `route.route_id` |
| `total_travel_time` | `INT` | The estimated total travel time in minutes. | |
| `timestamp` | `TIMESTAMP` | The date and time of the request. | |

---

## G9: Find Apartment
Tables for the apartment and point of interest (POI) locator feature.

### Table: `apartment`
Stores basic information about apartments.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the apartment. | **Primary Key**, Auto-increment |
| `apartment_name` | `VARCHAR(255)` | The name of the apartment building. | |
| `apartment_rating` | `DECIMAL` | The average user rating of the apartment. | |
| `apartment_phone` | `VARCHAR(15)` | Contact phone number for the apartment. | |

### Table: `apartment_address`
Stores address details for apartments.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the address. | **Primary Key**, Auto-increment |
| `apartment_id` | `INT` | The apartment this address belongs to. | Foreign Key to `apartment.id` |
| `apartment_latitude` | `DECIMAL` | The latitude coordinate of the apartment. | |
| `apartment_longitude` | `DECIMAL` | The longitude coordinate of the apartment. | |
| `province` | `VARCHAR(255)` | Province of the apartment's address. | |
| `district` | `VARCHAR(255)` | District of the apartment's address. | |
| `sub_district` | `VARCHAR(255)` | Subdistrict of the apartment's address. | |
| `zip_code` | `VARCHAR(255)` | Zip code of the apartment's address. | |
| `more_address_detail` | `TEXT` | Additional address details. | e.g., 'apartment number, road' |
| `created_at` | `TIMESTAMP` | Timestamp when the address was added. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the address was last updated. | |

### Table: `poi_categories`
Stores categories for Points of Interest (e.g., 'Restaurant', 'Park').
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the POI category. | **Primary Key**, Auto-increment |
| `category_name` | `VARCHAR(255)` | The name of the category. | |
| `created_at` | `TIMESTAMP` | Timestamp when the category was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the category was last updated. | |

### Table: `poi_location`
Stores information about specific Points of Interest.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the POI. | **Primary Key**, Auto-increment |
| `poi_name` | `VARCHAR(255)` | The name of the POI. | |
| `poi_latitude` | `DECIMAL` | The latitude coordinate of the POI. | |
| `poi_longitude` | `DECIMAL` | The longitude coordinate of the POI. | |
| `category_id` | `INT` | The category of the POI. | Foreign Key to `poi_categories.id` |

---

## G10: Traffic
Tables for managing traffic lights and emergency traffic requests.

### Table: `traffic_light`
Stores the status and data for individual traffic lights.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `light_id` | `INT` | Unique identifier for the traffic light. | **Primary Key**, Auto-increment |
| `latitude` | `VARCHAR(100)` | The latitude coordinate of the light. | |
| `longitude` | `VARCHAR(100)` | The longitude coordinate of the light. | |
| `status` | `BOOLEAN` | The operational status of the light (on/off). | |
| `current_color` | `INT` | The current color of the light (e.g., 1 for red). | |
| `density_level` | `INT` | A metric for traffic density at the light. | |
| `auto_mode` | `BOOLEAN` | Flag indicating if the light is in automatic mode. | |
| `last_updated` | `TIMESTAMP` | Timestamp of the last status update. | |

### Table: `intersection`
Stores location data for road intersections.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `intersection_id` | `INT` | Unique identifier for the intersection. | **Primary Key**, Auto-increment |
| `latitude` | `VARCHAR(100)` | The latitude coordinate of the intersection. | |
| `longitude` | `VARCHAR(100)` | The longitude coordinate of the intersection. | |

### Table: `light_request`
Logs requests made to change a traffic light, possibly for emergency vehicles.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `request_id` | `INT` | Unique identifier for the request. | **Primary Key**, Auto-increment |
| `light_id` | `INT` | The traffic light being requested. | Foreign Key to `traffic_light.light_id` |
| `request_time` | `TIMESTAMP` | Timestamp of the request. | |

### Table: `road`
Defines road segments between intersections.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `road_id` | `INT` | Unique identifier for the road segment. | **Primary Key**, Auto-increment |
| `light_id` | `INT` | The traffic light controlling this road segment. | Foreign Key to `traffic_light.light_id` |
| `intersection_id_start` | `INT` | The starting intersection of the road. | Foreign Key to `intersection.intersection_id` |
| `intersection_id_end` | `INT` | The ending intersection of the road. | Foreign Key to `intersection.intersection_id` |
| `length` | `INT` | The length of the road segment. | |

### Table: `vehicle`
Stores information about user-registered vehicles.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `vehicle_id` | `INT` | Unique identifier for the vehicle. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user who owns the vehicle. | Foreign Key to `users.id` |
| `current_latitude` | `VARCHAR(100)` | The last known latitude of the vehicle. | |
| `current_longitude` | `VARCHAR(100)` | The last known longitude of the vehicle. | |
| `vehicle_plate` | `VARCHAR(10)` | The license plate of the vehicle. | |

### Enum: `traffic_emergency_status`
* `active`
* `resolve`

### Table: `traffic_emergency_request`
Logs emergency requests for traffic clearance (e.g., for ambulances).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `emergency_request` | `INT` | Unique identifier for the request. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user who initiated the request. | Foreign Key to `users.id` |
| `accident_latitude` | `VARCHAR(100)` | The latitude of the accident. | |
| `accident_longitude` | `VARCHAR(100)` | The longitude of the accident. | |
| `destination_hospital` | `VARCHAR(255)` | The destination hospital. | |
| `status` | `traffic_emergency_status` | The status of the emergency request. | Enum Type |
| `ambulance_id` | `INT` | The ambulance vehicle involved. | Foreign Key to `vehicle.vehicle_id` |

---

## G11: Financial
Tables related to user wallets and financial transactions.

### Enum: `wallet_type`
* `individual`
* `organization`

### Enum: `wallet_status`
* `active`
* `suspended`

### Table: `wallets`
Stores user or organization financial wallets.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `wallet_id` | `INT` | Unique identifier for the wallet. | **Primary Key**, Auto-increment |
| `owner_id` | `INT` | The user who owns the wallet. | Unique, Foreign Key to `users.id` |
| `wallet_type` | `wallet_type` | The type of wallet. | Enum Type |
| `organization_type` | `VARCHAR(100)` | The type of organization, if applicable. | |
| `balance` | `DECIMAL` | The current balance of the wallet. | Default: 0.0 |
| `status` | `wallet_status` | The status of the wallet. | Enum Type |
| `created_at` | `TIMESTAMP` | Timestamp when the wallet was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the wallet was last updated. | |

### Enum: `transaction_type`
* `top_up`
* `transfer_in`
* `transfere_out`
* `transfer_to_service`

### Enum: `target_services`
* `insurance`
* `metro`
* `null`

### Table: `wallet_transactions`
Logs all transactions associated with wallets.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `transaction_id` | `INT` | Unique identifier for the transaction. | **Primary Key**, Auto-increment |
| `wallet_id` | `INT` | The wallet involved in the transaction. | Foreign Key to `wallets.wallet_id` |
| `transaction_type` | `transaction_type` | The type of transaction. | Enum Type |
| `amount` | `DECIMAL` | The transaction amount. | |
| `target_wallet_id` | `INT` | The target wallet for transfers. | |
| `target_service` | `target_services` | The target service for payments. | Enum Type |
| `description` | `VARCHAR(255)` | A description of the transaction. | |
| `created_at` | `TIMESTAMP` | Timestamp of the transaction. | |

### Table: `insurance_cards`
Stores details about user-specific insurance cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `card_id` | `INT` | Unique identifier for the card. | **Primary Key**, Auto-increment |
| `citizen_id` | `INT` | The user associated with the card. | Foreign Key to `users.id` |
| `balance` | `DECIMAL` | The balance on the card. | Default: 0.0 |
| `card_number` | `INT` | The unique card number. | Unique |
| `status` | `wallet_status` | The status of the card. | Enum Type |
| `created_at` | `TIMESTAMP` | Timestamp when the card was issued. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the card was last updated. | |

### Table: `metro_cards`
Stores details about user-specific metro/transit cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `card_id` | `INT` | Unique identifier for the card. | **Primary Key**, Auto-increment |
| `citizen_id` | `INT` | The user associated with the card. | Foreign Key to `users.id` |
| `balance` | `DECIMAL` | The balance on the card. | Default: 0.0 |
| `card_number` | `INT` | The unique card number. | Unique |
| `status` | `wallet_status` | The status of the card. | Enum Type |
| `created_at` | `TIMESTAMP` | Timestamp when the card was issued. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the card was last updated. | |

### Enum: `card_transaction_type`
* `top_up`
* `charge`
* `refund`

### Enum: `transaction_category`
* `insurance`
* `metro`

### Table: `transaction`
A generic table for logging transactions from various card types.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `transaction_id` | `INT` | Unique identifier for the transaction. | **Primary Key**, Auto-increment |
| `card_id` | `INT` | The card used in the transaction. | Foreign Key to `insurance_cards.card_id` |
| `transaction_type` | `card_transaction_type` | The type of transaction. | Enum Type |
| `transaction_category` | `transaction_category` | The category of the transaction. | Enum Type |
| `reference` | `VARCHAR(50)` | A reference code for the transaction. | |
| `amount` | `DECIMAL` | The transaction amount. | Default: 0.0 |
| `description` | `VARCHAR(255)` | A description of the transaction. | |
| `created_at` | `TIMESTAMP` | Timestamp of the transaction. | |

---

## G12: Healthcare
A comprehensive set of tables for managing healthcare services.

### Table: `patients`
Stores patient-specific information, linked to the main `users` table.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `patient_id` | `INT` | Unique identifier for the patient record. | **Primary Key**, Auto-increment |
| `user_id` | `INT` | The user associated with this patient record. | Foreign Key to `users.id` |
| `emergency_contact` | `VARCHAR(200)` | Contact information for emergencies. | |
| `finance_id` | `INT` | ID for linking to a financial system. | |
| `housing_id` | `INT` | ID for linking to a housing system. | |
| `sos_id` | `INT` | ID for linking to an emergency (SOS) system. | |
| `created_at` | `TIMESTAMP` | Timestamp when the patient record was created. | |

### Table: `facilities`
Stores information about healthcare facilities (hospitals, clinics).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `facility_id` | `INT` | Unique identifier for the facility. | **Primary Key**, Auto-increment |
| `name` | `VARCHAR(255)` | Name of the facility. | |
| `type` | `VARCHAR(50)` | Type of facility (e.g., 'Hospital', 'Clinic'). | |
| `province` | `VARCHAR(255)` | Province of the facility's address. | |
| `district` | `VARCHAR(255)` | District of the facility's address. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict of the facility's address. | |
| `zip_code` | `VARCHAR(20)` | Zip code of the facility's address. | |
| `more_address_detail` | `TEXT` | Specific address details. | |
| `phone` | `VARCHAR(20)` | Contact phone number for the facility. | |
| `latitude` | `DECIMAL(10,8)` | The latitude coordinate of the facility. | |
| `longitude` | `DECIMAL(11,8)` | The longitude coordinate of the facility. | |
| `emergency_services` | `BOOLEAN` | Flag indicating if emergency services are available. | |
| `finance_merchant_id` | `INT` | Merchant ID for financial system integration. | |
| `housing_zone` | `VARCHAR(100)` | Zone ID for housing system integration. | |
| `sos_code` | `VARCHAR(50)` | Code for emergency (SOS) system integration. | |
| `department_id` | `INT` | The city department associated with the facility. | Foreign Key to `departments.id` |
| `created_at` | `TIMESTAMP` | Timestamp when the facility was added. | |

### Table: `beds`
Tracks the status and assignment of beds within healthcare facilities.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `bed_id` | `INT` | Unique identifier for the bed. | **Primary Key**, Auto-increment |
| `facility_id` | `INT` | The facility where the bed is located. | Foreign Key to `facilities.facility_id` |
| `bed_number` | `VARCHAR(20)` | The number or code of the bed. | |
| `bed_type` | `VARCHAR(50)` | The type of bed (e.g., 'ICU', 'General'). | |
| `status` | `VARCHAR(20)` | The current status of the bed (e.g., 'Available'). | |
| `patient_id` | `INT` | The patient occupying the bed, if any. | Foreign Key to `patients.patient_id` |
| `admission_date` | `TIMESTAMP` | The date the patient was admitted to the bed. | |
| `finance_billing_id` | `INT` | Billing ID for financial system integration. | |
| `sos_priority` | `INTEGER` | Priority level for emergency (SOS) system. | |

### Table: `appointments`
Stores patient appointments with healthcare providers.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `appointment_id` | `INT` | Unique identifier for the appointment. | **Primary Key**, Auto-increment |
| `patient_id` | `INT` | The patient for the appointment. | Foreign Key to `patients.patient_id` |
| `facility_id` | `INT` | The facility where the appointment is scheduled. | Foreign Key to `facilities.facility_id` |
| `user_id` | `INT` | The healthcare professional for the appointment. | Foreign Key to `users.id` |
| `appointment_datetime` | `TIMESTAMP` | The date and time of the appointment. | |
| `type` | `VARCHAR(50)` | The type of appointment (e.g., 'Consultation'). | |
| `status` | `VARCHAR(20)` | The status of the appointment (e.g., 'Scheduled'). | |
| `finance_payment_id` | `INT` | Payment ID for financial system integration. | |
| `housing_transport_id` | `INT` | Transport ID for housing system integration. | |
| `sos_emergency` | `BOOLEAN` | Flag indicating if it is an emergency appointment. | |
| `created_at` | `TIMESTAMP` | Timestamp when the appointment was created. | |

### Table: `prescriptions`
Stores medical prescriptions issued to patients.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `prescription_id` | `INT` | Unique identifier for the prescription. | **Primary Key**, Auto-increment |
| `patient_id` | `INT` | The patient for whom the prescription is intended. | Foreign Key to `patients.patient_id` |
| `user_id` | `INT` | The healthcare professional who issued it. | Foreign Key to `users.id` |
| `facility_id` | `INT` | The facility that issued the prescription. | Foreign Key to `facilities.facility_id` |
| `medication_name` | `VARCHAR(255)` | The name of the medication. | |
| `quantity` | `INTEGER` | The prescribed quantity. | |
| `status` | `VARCHAR(20)` | The status of the prescription (e.g., 'Filled'). | |
| `finance_payment_id` | `INT` | Payment ID for financial system integration. | |
| `housing_delivery_id` | `INT` | Delivery ID for housing system integration. | |
| `sos_critical` | `BOOLEAN` | Flag indicating if it is a critical prescription. | |
| `created_at` | `TIMESTAMP` | Timestamp when the prescription was created. | |

### Table: `ambulances`
Tracks the status and location of ambulances.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `ambulance_id` | `INT` | Unique identifier for the ambulance. | **Primary Key**, Auto-increment |
| `vehicle_number` | `VARCHAR(50)` | The license plate or vehicle number. | |
| `status` | `VARCHAR(20)` | The current status (e.g., 'Available', 'En route'). | |
| `current_latitude` | `DECIMAL(10,8)` | The current latitude of the ambulance. | |
| `current_longitude` | `DECIMAL(11,8)` | The current longitude of the ambulance. | |
| `base_facility_id` | `INT` | The home base facility for the ambulance. | Foreign Key to `facilities.facility_id` |
| `finance_rate` | `DECIMAL(10,2)` | Rate information for financial system. | |
| `housing_coverage_zones` | `JSON` | Coverage zones for housing system. | |
| `sos_priority` | `INTEGER` | Priority level for emergency (SOS) system. | |
| `created_at` | `TIMESTAMP` | Timestamp when the ambulance was added. | |

### Table: `emergency_calls`
Logs emergency calls for medical assistance.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `emergency_id` | `INT` | Unique identifier for the emergency call. | **Primary Key**, Auto-increment |
| `patient_id` | `INT` | The patient involved, if known. | Foreign Key to `patients.patient_id` |
| `caller_phone` | `VARCHAR(20)` | The phone number of the person who called. | |
| `emergency_type` | `VARCHAR(50)` | The type of emergency. | |
| `severity` | `VARCHAR(20)` | The severity level of the emergency. | |
| `province` | `VARCHAR(255)` | Province of the emergency location. | |
| `district` | `VARCHAR(255)` | District of the emergency location. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict of the emergency location. | |
| `zip_code` | `VARCHAR(20)` | Zip code of the emergency location. | |
| `more_address_detail` | `TEXT` | Specific location details. | |
| `ambulance_id` | `INT` | The ambulance dispatched to the scene. | Foreign Key to `ambulances.ambulance_id` |
| `facility_id` | `INT` | The facility the patient is being taken to. | Foreign Key to `facilities.facility_id` |
| `status` | `VARCHAR(20)` | The current status of the emergency response. | |
| `finance_billing_id` | `INT` | Billing ID for financial system integration. | |
| `housing_unit` | `VARCHAR(100)` | Unit ID for housing system integration. | |
| `sos_incident_id` | `INT` | Incident ID for emergency (SOS) system. | |
| `created_at` | `TIMESTAMP` | Timestamp when the call was received. | |

### Table: `payments`
Logs financial payments related to healthcare services.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `payment_id` | `INT` | Unique identifier for the payment. | **Primary Key**, Auto-increment |
| `patient_id` | `INT` | The patient associated with the payment. | Foreign Key to `patients.patient_id` |
| `facility_id` | `INT` | The facility receiving the payment. | Foreign Key to `facilities.facility_id` |
| `service_type` | `VARCHAR(50)` | The type of service being paid for. | |
| `service_id` | `INT` | The ID of the specific service (e.g., appointment_id). | |
| `amount` | `DECIMAL(10,2)` | The total amount of the payment. | |
| `currency` | `VARCHAR(3)` | The currency of the payment (e.g., 'THB'). | |
| `payment_method` | `VARCHAR(50)` | The method of payment (e.g., 'Credit Card'). | |
| `insurance_coverage` | `DECIMAL(10,2)` | The amount covered by insurance. | |
| `patient_copay` | `DECIMAL(10,2)` | The amount paid by the patient. | |
| `status` | `VARCHAR(20)` | The status of the payment (e.g., 'Completed'). | |
| `payment_date` | `TIMESTAMP` | The date the payment was made. | |
| `finance_transaction_id` | `INT` | Transaction ID from a financial system. | |
| `insurance_claim_id` | `INT` | Claim ID from an insurance system. | |
| `created_at` | `TIMESTAMP` | Timestamp when the payment record was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the payment record was last updated. | |

### Table: `team_integrations`
A generic table to manage integrations with external team systems.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `integration_id` | `INT` | Unique identifier for the integration record. | **Primary Key**, Auto-increment |
| `team_name` | `VARCHAR(50)` | The name of the external team (e.g., 'Finance'). | |
| `healthcare_table` | `VARCHAR(50)` | The local healthcare table being linked. | |
| `healthcare_id` | `VARCHAR` | The ID from the local healthcare table. | |
| `external_id` | `VARCHAR(100)` | The corresponding ID in the external system. | |
| `data_type` | `VARCHAR(50)` | The type of data being integrated. | |
| `status` | `VARCHAR(20)` | The status of the integration link. | |
| `additional_data` | `JSON` | Any extra data related to the integration. | |
| `created_at` | `TIMESTAMP` | Timestamp when the integration was created. | |

---

## G13: Emergency Reports
Tables for users to report emergencies and communicate.

### Enum: `level`
Defines the severity level of a reported incident.
* `near_miss`
* `minor`
* `moderate`
* `major`
* `lethal`

### Enum: `report_status`
Defines the status of an emergency report.
* `pending`
* `verified`
* `resolved`

### Enum: `report_category`
Defines the category of an emergency report.
* `traffic`
* `disaster`
* `crime`

### Table: `reports`
Stores emergency reports submitted by users.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `report_id` | `INT` | Unique identifier for the report. | **Primary Key**, Not Null, Auto-increment |
| `user_id` | `INT` | The user who submitted the report. | Not Null, Foreign Key to `users.id` |
| `image` | `VARCHAR(255)` | URL or path to an image of the incident. | Not Null |
| `description` | `VARCHAR(255)` | A description of the incident. | Not Null |
| `latitude` | `VARCHAR(255)` | The latitude of the incident. | Not Null |
| `longitude` | `VARCHAR(255)` | The longitude of the incident. | Not Null |
| `level` | `level` | The severity level of the report. | Enum Type |
| `status` | `report_status` | The current status of the report. | Enum Type |
| `category` | `report_category` | The category of the report. | Enum Type |
| `updated_at` | `TIMESTAMP` | Timestamp when the report was last updated. | |
| `created_at` | `TIMESTAMP` | Timestamp when the report was created. | |

### Table: `emergency_contacts`
Stores user-defined emergency contacts.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `contact_id` | `INT` | Unique identifier for the contact. | **Primary Key**, Not Null, Auto-increment |
| `user_id` | `INT` | The user who owns this contact. | Not Null, Foreign Key to `users.id` |
| `contact_name` | `VARCHAR(255)` | The name of the emergency contact. | Not Null |
| `phone` | `VARCHAR(10)` | The phone number of the emergency contact. | |

### Table: `alerts`
Stores alerts sent out based on verified emergency reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `alert_id` | `INT` | Unique identifier for the alert. | **Primary Key**, Not Null, Auto-increment |
| `report_id` | `INT` | The report that triggered the alert. | Not Null, Foreign Key to `reports.report_id` |
| `message` | `TEXT` | The content of the alert message. | Not Null |
| `area` | `VARCHAR(255)` | The geographical area the alert was sent to. | |
| `sent_at` | `TIMESTAMP` | Timestamp when the alert was sent. | |

### Table: `users_contacts`
A junction table to link users with other users as contacts.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `contact_id` | `INT` | Unique identifier for the contact link. | **Primary Key**, Not Null, Auto-increment |
| `user_id` | `INT` | The user who owns the contact list. | Not Null, Foreign Key to `users.id` |
| `contact_user_id` | `INT` | The user who is in the contact list. | Not Null, Foreign Key to `users.id` |

### Table: `conversations`
Stores information about chat conversations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `conversation_id` | `INT` | Unique identifier for the conversation. | **Primary Key**, Not Null, Auto-increment |
| `conversation_name` | `VARCHAR(255)` | The name of the conversation (for group chats). | |

### Table: `messages`
Stores individual chat messages within a conversation.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `message_id` | `INT` | Unique identifier for the message. | **Primary Key**, Not Null, Auto-increment |
| `sender_id` | `INT` | The user who sent the message. | Not Null, Foreign Key to `users.id` |
| `recipient_id` | `INT` | The user who received the message. | Not Null, Foreign Key to `users.id` |
| `message_text` | `TEXT` | The content of the message. | |
| `sent_at` | `TIMESTAMP` | Timestamp when the message was sent. | |
| `conversation_id` | `INT` | The conversation the message belongs to. | Not Null, Foreign Key to `conversations.conversation_id` |

---

## G15: Waste Management
Tables for tracking waste collection and statistics.

### Table: `waste_type`
Stores different types of waste.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the waste type. | **Primary Key**, Auto-increment |
| `type_name` | `VARCHAR(255)` | The name of the waste type (e.g., 'Plastic'). | |
| `weight` | `DECIMAL` | Standard weight or metric for the waste type. | |

### Table: `waste_event_statistic`
Logs statistics for waste collected during events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the statistic record. | **Primary Key**, Auto-increment |
| `event_id` | `INT` | The event where the waste was collected. | Foreign Key to `event.id` |
| `waste_type_id` | `INT` | The type of waste collected. | Foreign Key to `waste_type.id` |
| `collection_date` | `TIMESTAMP` | The date of collection. | |
| `total_collection_weight` | `DECIMAL` | The total weight of waste collected. | |

### Table: `power_bi_report`
Links waste statistics to Power BI reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the report link. | **Primary Key**, Auto-increment |
| `waste_event_statistic_id` | `INT` | The statistic record used in the report. | Foreign Key to `waste_event_statistic.id` |
| `report_type` | `VARCHAR(255)` | The type of Power BI report. | |
| `report_date` | `TIMESTAMP` | The date the report was generated. | |

---

## G16: Community Map
Tables for managing custom markers on a community map.

### Table: `marker_type`
Stores different types of map markers (e.g., icons, colors).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the marker type. | **Primary Key**, Auto-increment |
| `marker_icon` | `VARCHAR(255)` | The icon used for the marker. | |
| `marker_color` | `VARCHAR(255)` | The color used for the marker. | |
| `created_at` | `TIMESTAMP` | Timestamp when the marker type was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the marker type was last updated. | |

### Table: `map_marker`
Stores information about individual map markers placed by users or admins.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the map marker. | **Primary Key**, Auto-increment |
| `marker_type_id` | `INT` | The type of this marker. | Foreign Key to `marker_type.id` |
| `display_name` | `VARCHAR(255)` | The name or title displayed for the marker. | |
| `description` | `VARCHAR(255)` | A description for the marker. | |
| `created_at` | `TIMESTAMP` | Timestamp when the marker was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the marker was last updated. | |
