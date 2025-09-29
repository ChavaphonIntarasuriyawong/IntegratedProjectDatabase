# Smart City DB Data Dictionary
* **Project:** Smart City DB
* **Database:** Firebase RTDB and PostgreSQL with PostGIS
* **Last Updated:** 2025-09-28
---

## Core Infrastructure & Users
This group contains the foundational tables for the entire system, including user authentication, profiles, roles, departments, and a reusable address management system.

### Table: `roles`
Stores user roles to manage permissions across the application.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the role. | **Primary Key** (Generated) |
| `role_name` | `VARCHAR(50)` | The unique name of the role (e.g., 'Admin', 'Citizen'). | `NOT NULL`, `UNIQUE` |

### Table: `departments`
Stores information about various city departments or organizations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the department. | **Primary Key** (Generated) |
| `department_name` | `VARCHAR(255)` | The unique official name of the department. | `NOT NULL`, `UNIQUE` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `addresses`
A centralized, reusable table for storing physical addresses and geographic coordinates for various entities like users, facilities, and events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the address record. | **Primary Key** (Generated) |
| `address_line` | `TEXT` | Main address line (e.g., street, house number). | |
| `province` | `VARCHAR(255)` | Province name. | |
| `district` | `VARCHAR(255)` | District name. | |
| `subdistrict` | `VARCHAR(255)` | Subdistrict name. | |
| `postal_code` | `VARCHAR(20)` | The postal or zip code. | |
| `location` | `GEOMETRY(Point, 4326)` | Geographic coordinates (longitude, latitude) using PostGIS SRID 4326. | GIST Index for spatial queries |
| `created_at` | `TIMESTAMPTZ` | Timestamp of creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |
---
### `Example of how to use PostGIS`

**Document: https://postgis.net/docs/manual-3.6/reference.html#PostGIS_Types**

**Example of Prisma data model**
```
model Address {
  id          Int      @id @default(autoincrement())
  addressLine String
  province    String
  district    String
  postalCode  String
  location    Bytes    // <-- store geometry here
  createdAt   DateTime @default(now())
  updatedAt   DateTime @default(now())
}
```
**inserting**
```
await prisma.$executeRaw`
  INSERT INTO "Address" (addressLine, province, district, postalCode, location)
  VALUES (${line}, ${province}, ${district}, ${postal}, ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326))
`;
```
**querying with 5 km**
```
const nearby = await prisma.$queryRaw`
  SELECT * FROM "Address"
  WHERE ST_DWithin(
    location,
    ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326),
    5000
  )
`;
```
---
### Table: `users`
Stores core authentication credentials and essential user information. Personal details are normalized into `user_profiles`.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the user. | **Primary Key** (Generated) |
| `username` | `VARCHAR(50)` | The user's unique username for login. | `NOT NULL`, `UNIQUE` |
| `email` | `VARCHAR(255)` | The user's unique email address. | `NOT NULL`, `UNIQUE`, Indexed |
| `phone` | `VARCHAR(20)` | The user's unique phone number. | `UNIQUE`, Indexed |
| `password_hash` | `VARCHAR(512)` | The securely hashed password. | `NOT NULL` |
| `role_id` | `INT` | The user's role. | Foreign Key to `roles(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of account creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `user_profiles`
Stores personal profile information, linked one-to-one with the `users` table.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | Links to the user's authentication record. | **Primary Key**, Foreign Key to `users(id)` |
| `first_name` | `VARCHAR(255)` | User's first name. | |
| `middle_name` | `VARCHAR(255)` | User's middle name (optional). | |
| `last_name` | `VARCHAR(255)` | User's last name. | |
| `birth_date` | `DATE` | User's date of birth. | |
| `gender` | `gender` | User's gender from the enum ('male', 'female', 'none'). | |
| `address_id` | `INT` | The user's primary address. | Foreign Key to `addresses(id)` |
| `more_address_detail` | `TEXT` | Additional address details not in the main `addresses` record. | |

### Table: `users_departments`
A junction table linking users to the departments they belong to (many-to-many relationship).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | Foreign key referencing the user. | **Composite Primary Key**, FK to `users(id)` |
| `department_id` | `INT` | Foreign key referencing the department. | **Composite Primary Key**, FK to `departments(id)` |

---

## Authentication & Sessions
Tables responsible for managing user sessions and persistent logins.

### Table: `sessions`
Stores active user login sessions.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `session_id` | `UUID` | Unique identifier for the session. | **Primary Key**, Default: `uuid_generate_v4()` |
| `user_id` | `INT` | The user associated with the session. | Foreign Key to `users(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of session creation. | `NOT NULL`, Default: `now()` |
| `expires_at` | `TIMESTAMPTZ` | Timestamp when the session will expire. | |
| `last_accessed` | `TIMESTAMPTZ` | Timestamp of the last activity in this session. | |

### Table: `refresh_tokens`
Stores refresh tokens used to obtain new access tokens without re-authentication.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the token. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user associated with the token. | Foreign Key to `users(id)` |
| `refresh_token` | `TEXT` | The secure refresh token string. | `NOT NULL` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of token creation. | `NOT NULL`, Default: `now()` |
| `expires_at` | `TIMESTAMPTZ` | Timestamp when the token will expire. | |

---

## G1: Courses & Education
Tables related to the online and onsite educational courses feature.

### Table: `courses`
Stores main information about available educational courses.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the course. | **Primary Key** (Generated) |
| `author_id` | `INT` | The user who created the course. | Foreign Key to `users(id)` |
| `course_name` | `VARCHAR(255)` | The title of the course. | `NOT NULL` |
| `course_description` | `TEXT` | A detailed description of the course content. | |
| `course_type` | `course_type` | Delivery format ('online', 'onsite', 'online_and_onsite'). | `NOT NULL` |
| `cover_image` | `TEXT` | URL to the course's cover image. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of course creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `course_videos`
Stores details for online course video lessons.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the video. | **Primary Key** (Generated) |
| `course_id` | `INT` | The course this video belongs to. | Foreign Key to `courses(id)` |
| `video_name` | `VARCHAR(255)` | Title of the video lesson. | `NOT NULL` |
| `video_description` | `TEXT` | Description of the video content. | |
| `duration_minutes` | `INT` | Length of the video in minutes. | `NOT NULL` |
| `video_order` | `INT` | The sequence number of the video in the course. | `NOT NULL`, `UNIQUE` with `course_id` |
| `video_file_path` | `TEXT` | Path or URL to the video file. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of video creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `onsite_sessions`
Stores details for onsite (in-person) course events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the onsite session. | **Primary Key** (Generated) |
| `course_id` | `INT` | The course this session belongs to. | Foreign Key to `courses(id)` |
| `address_id` | `INT` | The location of the onsite session. | Foreign Key to `addresses(id)` |
| `duration_hours` | `NUMERIC(6,2)` | Duration of the session in hours. | |
| `event_at` | `TIMESTAMPTZ` | The date and time of the session. | `NOT NULL` |
| `registration_deadline` | `TIMESTAMPTZ` | The deadline for registration. | `NOT NULL` |
| `total_seats` | `INT` | Total number of seats available. | `NOT NULL`, Default: `1` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of session creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `onsite_enrollments`
Tracks user enrollments for onsite course sessions.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the enrollment. | **Primary Key** (Generated) |
| `onsite_id` | `INT` | The onsite session being enrolled in. | Foreign Key to `onsite_sessions(id)` |
| `user_id` | `INT` | The user who is enrolling. | Foreign Key to `users(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of enrollment. | `NOT NULL`, Default: `now()` |
| *Note* | | | `UNIQUE` constraint on (`onsite_id`, `user_id`) |

### Table: `questions`
Stores questions for exercises and quizzes.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the question. | **Primary Key** (Generated) |
| `question` | `TEXT` | The text of the question. | `NOT NULL` |
| `level` | `INT` | The difficulty level of the question. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `user_exercises`
Logs users' answers to exercise questions.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the user's attempt. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who answered the question. | Foreign Key to `users(id)` |
| `question_id` | `INT` | The question that was answered. | Foreign Key to `questions(id)` |
| `user_answer` | `TEXT` | The answer provided by the user. | |
| `is_correct` | `BOOLEAN` | Whether the user's answer was correct. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the answer was submitted. | `NOT NULL`, Default: `now()` |

### Table: `user_levels`
Stores the current skill or experience level of a user within the education domain.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | The user associated with the level. | **Primary Key**, Foreign Key to `users(id)` |
| `current_level` | `INT` | The user's current level. | `NOT NULL`, Default: `1` |

---

## G3: Events Hub
Tables for managing general public events.

### Table: `events`
Stores information about events created by users or departments.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the event. | **Primary Key** (Generated) |
| `host_user_id` | `INT` | The user ID of the event host. | Foreign Key to `users(id)` |
| `department_id` | `INT` | The department organizing the event. | Foreign Key to `departments(id)` |
| `image_url` | `TEXT` | URL to the event's promotional image. | |
| `title` | `VARCHAR(255)` | The title of the event. | |
| `description` | `TEXT` | A detailed description of the event. | |
| `total_seats` | `INT` | Total number of seats available for the event. | Default: `0` |
| `start_at` | `TIMESTAMPTZ` | The start date and time of the event. | Indexed |
| `end_at` | `TIMESTAMPTZ` | The end date and time of the event. | |
| `address_id` | `INT` | The location of the event. | Foreign Key to `addresses(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of event creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `event_bookmarks`
Allows users to save or "bookmark" events they are interested in.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `user_id` | `INT` | The user who bookmarked the event. | **Composite Primary Key**, FK to `users(id)` |
| `event_id` | `INT` | The event that was bookmarked. | **Composite Primary Key**, FK to `events(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the bookmark was created. | `NOT NULL`, Default: `now()` |

---

## G4: Freecycle (Donation) Domain
Tables for the feature allowing users to donate and receive items for free.

### Table: `freecycle_categories`
Stores categories for freecycle items (e.g., 'Furniture', 'Electronics').
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the category. | **Primary Key** (Generated) |
| `category_name` | `VARCHAR(100)` | The unique name of the category. | `NOT NULL`, `UNIQUE` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `freecycle_posts`
Stores posts created by users to donate items.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the post. | **Primary Key** (Generated) |
| `item_name` | `VARCHAR(255)` | The name of the item being donated. | `NOT NULL` |
| `item_weight` | `NUMERIC(10,3)` | The approximate weight of the item. | |
| `photo_url` | `TEXT` | URL to a photo of the item. | |
| `description` | `TEXT` | A description of the item and its condition. | |
| `donater_id` | `INT` | The user donating the item. | Foreign Key to `users(id)` |
| `donate_to_department_id` | `INT` | An optional specific department to donate to. | Foreign Key to `departments(id)` |
| `is_given` | `BOOLEAN` | Flag indicating if the item has been given away. | `NOT NULL`, Default: `FALSE` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of post creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `freecycle_posts_categories`
Junction table linking freecycle posts to their categories.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `post_id` | `INT` | Foreign key referencing the post. | **Composite Primary Key**, FK to `freecycle_posts(id)` |
| `category_id` | `INT` | Foreign key referencing the category. | **Composite Primary Key**, FK to `freecycle_categories(id)` |

### Table: `receiver_requests`
Tracks requests from users to receive a donated item.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the request. | **Primary Key** (Generated) |
| `post_id` | `INT` | The post being requested. | Foreign Key to `freecycle_posts(id)` |
| `receiver_id` | `INT` | The user requesting the item. | Foreign Key to `users(id)` |
| `status` | `freecycle_request_status` | Current status ('pending', 'accepted', 'rejected'). | `NOT NULL`, Default: `'pending'` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of request creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

---

## G5: Air Quality & G14: Weather Report ((Firebase RTDB))
Tables for storing and contextualizing air quality and weather data.

### Table: `air_quality`
Stores air quality index (AQI) and pollutant data for specific locations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the data reading. | **Primary Key** (Generated) |
| `location_id` | `INT` | The location of the reading. | Foreign Key to `addresses(id)` |
| `aqi` | `NUMERIC(6,2)` | The overall Air Quality Index value. | |
| `pm25` | `NUMERIC(8,3)` | PM2.5 particle concentration. | |
| `pm10` | `NUMERIC(8,3)` | PM10 particle concentration. | |
| `co` | `NUMERIC(8,3)` | Carbon Monoxide concentration. | |
| `no2` | `NUMERIC(8,3)` | Nitrogen Dioxide concentration. | |
| `so2` | `NUMERIC(8,3)` | Sulfur Dioxide concentration. | |
| `o3` | `NUMERIC(8,3)` | Ozone concentration. | |
| `category` | `air_quality_category` | The overall air quality category. | |
| `measured_at` | `TIMESTAMPTZ` | Timestamp of the data reading. | `NOT NULL`, Default: `now()` |

### Table: `weather_data`
Stores detailed weather condition data.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the weather record. | **Primary Key** (Generated) |
| `location_id` | `INT` | The location of the weather reading. | Foreign Key to `addresses(id)` |
| `temperature` | `NUMERIC(6,2)` | The measured temperature (Celsius). | |
| `feel_temperature` | `NUMERIC(6,2)` | The 'feels like' temperature. | |
| `humidity` | `NUMERIC(6,2)` | The relative humidity percentage. | |
| `wind_speed` | `NUMERIC(6,2)` | The wind speed (km/h). | |
| `wind_direction` | `VARCHAR(50)` | The direction from which the wind is blowing. | |
| `rainfall_probability` | `NUMERIC(5,2)` | The probability of precipitation percentage. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of record creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

---

## G6: Volunteer Events
Tables for managing volunteer events and participation.

### Table: `volunteer_events`
Stores information about volunteer events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the event. | **Primary Key** (Generated) |
| `created_by_user_id` | `INT` | The user who created the event. | Foreign Key to `users(id)` |
| `department_id` | `INT` | The department the event is for. | Foreign Key to `departments(id)` |
| `image_url` | `TEXT` | URL to the event's promotional image. | |
| `title` | `VARCHAR(255)` | The title of the volunteer event. | `NOT NULL` |
| `description` | `TEXT` | A detailed description of the event. | |
| `current_participants` | `INT` | Current number of registered participants. | `NOT NULL`, Default: `0`, `CHECK (>= 0)` |
| `total_seats` | `INT` | Total number of spots for volunteers. | `NOT NULL`, Default: `1`, `CHECK (>= 0)` |
| `start_at` | `TIMESTAMPTZ` | The start date and time of the event. | Indexed |
| `end_at` | `TIMESTAMPTZ` | The end date and time of the event. | |
| `registration_deadline` | `TIMESTAMPTZ` | The deadline for registration. | |
| `address_id` | `INT` | The location of the event. | Foreign Key to `addresses(id)` |
| `status` | `volunteer_event_status` | Approval status ('draft', 'pending', 'approved', 'rejected'). | `NOT NULL`, Default: `'draft'` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of event creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `volunteer_event_participation`
Tracks which users are participating in which volunteer events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the participation record. | **Primary Key** (Generated) |
| `volunteer_event_id` | `INT` | The event being participated in. | Foreign Key to `volunteer_events(id)` |
| `user_id` | `INT` | The user who is participating. | Foreign Key to `users(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the user registered for the event. | `NOT NULL`, Default: `now()` |

---

## G7: Business Intelligence (BI)
A simplified star schema with dimension and fact tables for data analysis and reporting.

### Table: `dim_time`
A dimension table for time-based analysis.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the time record. | **Primary Key** (Generated) |
| `date` | `DATE` | The specific date. | `NOT NULL` |
| `year` | `INT` | The year component of the date. | |
| `month` | `INT` | The month component of the date. | |
| `day` | `INT` | The day component of the date. | |
| `hour` | `INT` | The hour component of the date. | |
| `week_day` | `VARCHAR(20)` | The day of the week (e.g., 'Monday'). | |

### Table: `dim_location`
A dimension table for location-based analysis, linking to the normalized addresses.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the location dimension. | **Primary Key** (Generated) |
| `address_id` | `INT` | Links to the full address details. | Foreign Key to `addresses(id)` |

### Table: `dim_facility`
A dimension table for facilities, linking to the operational facilities table.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the facility dimension. | **Primary Key** (Generated) |
| `facility_id` | `INT` | Links to the operational facility record. | Foreign Key to `facilities(id)` |

### Table: `fact_traffic`
A fact table storing traffic metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the traffic fact. | **Primary Key** (Generated) |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time(id)` |
| `location_id` | `INT` | Reference to the location dimension. | Foreign Key to `dim_location(id)` |
| `speed_kmh` | `NUMERIC(8,2)` | Average traffic speed in km/h. | |
| `accident_flag` | `BOOLEAN` | Flag indicating if an accident occurred. | |
| `closure_flag` | `BOOLEAN` | Flag indicating if a road was closed. | |

### Table: `fact_waste`
A fact table storing waste management metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the waste fact. | **Primary Key** (Generated) |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time(id)` |
| `location_id` | `INT` | Reference to the location dimension. | Foreign Key to `dim_location(id)` |
| `bin_fill_level_percent` | `INT` | The fill level of waste bins as a percentage. | |
| `recycling_tonnage` | `NUMERIC(12,3)` | Amount of recycled waste in tonnage. | |

### Table: `fact_healthcare`
A fact table storing healthcare metrics.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the healthcare fact. | **Primary Key** (Generated) |
| `time_id` | `INT` | Reference to the time dimension. | Foreign Key to `dim_time(id)` |
| `facility_id` | `INT` | Reference to the facility dimension. | Foreign Key to `dim_facility(id)` |
| `wait_time_minutes` | `INT` | Average patient wait time in minutes. | |
| `alert_type` | `VARCHAR(255)` | Type of health alert (e.g., 'outbreak'). | |
| `cases_reported` | `INT` | Number of new cases reported. | |

### Table: `report_metadata`
Stores metadata about generated BI reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the report. | **Primary Key** (Generated) |
| `title` | `VARCHAR(255)` | The title of the report. | |
| `description` | `TEXT` | A description of the report. | |
| `category_id` | `INT` | The category of the report. | Foreign Key to `poi_categories(id)` |
| `created_by_user_id` | `INT` | The user who created the report. | Foreign Key to `users(id)` |
| `last_updated` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

---

## G8: Transportation
Tables related to public transportation services, routes, and digital cards.

### Table: `digital_cards`
Stores information about user's digital transportation cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the digital card. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who owns the card. | Foreign Key to `users(id)` |
| `status` | `VARCHAR(20)` | The status of the card (e.g., 'active'). | `NOT NULL`, Default: `'active'` |

### Table: `transportation_vehicle_types`
Stores different types of public transport vehicles (e.g., 'Bus', 'Train').
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the vehicle type. | **Primary Key** (Generated) |
| `name` | `VARCHAR(100)` | The name of the vehicle type. | `NOT NULL` |

### Table: `routes`
Stores information about transportation routes.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the route. | **Primary Key** (Generated) |
| `route_name` | `VARCHAR(255)` | The name or number of the route. | |
| `vehicle_type_id` | `INT` | The type of vehicle that serves this route. | Foreign Key to `transportation_vehicle_types(id)` |

### Table: `stops`
Stores information about bus stops or train stations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the stop. | **Primary Key** (Generated) |
| `name` | `VARCHAR(255)` | The name of the stop. | |
| `location` | `GEOMETRY(Point, 4326)` | The geographic coordinates of the stop. | |

### Table: `route_stops`
Defines the sequence of stops for each route.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the route-stop link. | **Primary Key** (Generated) |
| `route_id` | `INT` | The route this entry belongs to. | Foreign Key to `routes(id)` |
| `stop_id` | `INT` | The stop on the route. | Foreign Key to `stops(id)` |
| `stop_order` | `INT` | The order of this stop on the route. | |
| `travel_time_to_next_stop` | `INT` | Estimated travel time to the next stop in minutes. | |

### Table: `transportation_transactions`
Logs transactions made with digital transportation cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the transaction. | **Primary Key** (Generated) |
| `card_id` | `INT` | The card used for the transaction. | Foreign Key to `digital_cards(id)` |
| `route_id` | `INT` | The route on which the transaction occurred. | Foreign Key to `routes(id)` |
| `amount` | `NUMERIC(12,2)` | The transaction amount. | |
| `status` | `VARCHAR(50)` | The status of the transaction (e.g., 'confirmed'). | |
| `created_at` | `TIMESTAMPTZ` | The date and time of the transaction. | `NOT NULL`, Default: `now()` |

---

## G9: Find Apartment & POI
Tables for the apartment and point of interest (POI) locator feature.

### Table: `apartments`
Stores basic information about apartments.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the apartment. | **Primary Key** (Generated) |
| `name` | `VARCHAR(255)` | The name of the apartment building. | |
| `rating` | `NUMERIC(3,2)` | The average user rating of the apartment. | |
| `phone` | `VARCHAR(20)` | Contact phone number for the apartment. | |

### Table: `apartment_addresses`
Links apartments to their physical addresses in the main `addresses` table.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the address link. | **Primary Key** (Generated) |
| `apartment_id` | `INT` | The apartment this address belongs to. | Foreign Key to `apartments(id)` |
| `address_id` | `INT` | The address record for the apartment. | Foreign Key to `addresses(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of link creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `poi_categories`
Stores categories for Points of Interest (e.g., 'Restaurant', 'Park').
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the POI category. | **Primary Key** (Generated) |
| `category_name` | `VARCHAR(255)` | The name of the category. | `NOT NULL` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of category creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `poi_locations`
Stores information about specific Points of Interest.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the POI. | **Primary Key** (Generated) |
| `name` | `VARCHAR(255)` | The name of the POI. | `NOT NULL` |
| `location` | `GEOMETRY(Point, 4326)` | The geographic coordinates of the POI. | |
| `category_id` | `INT` | The category of the POI. | Foreign Key to `poi_categories(id)` |

---

## G10: Traffic Domain (Firebase RTDB)
Tables for managing traffic infrastructure and emergency traffic requests.

### Table: `intersections`
Stores location data for road intersections.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the intersection. | **Primary Key** (Generated) |
| `location` | `GEOMETRY(Point, 4326)` | The geographic coordinates of the intersection. | |

### Table: `traffic_lights`
Stores the status and data for individual traffic lights.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the traffic light. | **Primary Key** (Generated) |
| `intersection_id` | `INT` | The intersection where the light is located. | Foreign Key to `intersections(id)` |
| `ip_address` | `INET` | The IP address for network control of the light. | |
| `location` | `GEOMETRY(Point, 4326)` | The precise geographic coordinates of the light. | GIST Index for spatial queries |
| `status` | `BOOLEAN` | The operational status of the light (true=on/false=off). | Default: `TRUE` |
| `current_color` | `SMALLINT` | The current color of the light (e.g., 1 for red). | |
| `density_level` | `SMALLINT` | A metric for traffic density at the light. | |
| `auto_mode` | `BOOLEAN` | Flag indicating if the light is in automatic mode. | Default: `TRUE` |
| `last_updated` | `TIMESTAMPTZ` | Timestamp of the last status update. | `NOT NULL`, Default: `now()` |

### Table: `roads`
Defines road segments between intersections.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the road segment. | **Primary Key** (Generated) |
| `name` | `VARCHAR(255)` | The name of the road. | |
| `start_intersection_id` | `INT` | The starting intersection of the road. | Foreign Key to `intersections(id)` |
| `end_intersection_id` | `INT` | The ending intersection of the road. | Foreign Key to `intersections(id)` |
| `length_meters` | `INT` | The length of the road segment in meters. | |

### Table: `light_requests`
Logs requests made to change a traffic light, possibly for emergency vehicles.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the request. | **Primary Key** (Generated) |
| `traffic_light_id` | `INT` | The traffic light being requested. | Foreign Key to `traffic_lights(id)` |
| `requested_at` | `TIMESTAMPTZ` | Timestamp of the request. | `NOT NULL`, Default: `now()` |

### Table: `vehicles`
Stores information about user-registered or system-tracked vehicles.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the vehicle. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who owns the vehicle. | Foreign Key to `users(id)` |
| `current_location` | `GEOMETRY(Point, 4326)` | The last known geographic location of the vehicle. | |
| `vehicle_plate` | `VARCHAR(20)` | The license plate of the vehicle. | |

### Table: `traffic_emergencies`
Logs emergency requests for traffic clearance (e.g., for ambulances).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the emergency request. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who initiated the request. | Foreign Key to `users(id)` |
| `accident_location` | `GEOMETRY(Point, 4326)` | The geographic location of the accident. | |
| `destination_hospital` | `VARCHAR(255)` | The name of the destination hospital. | |
| `status` | `VARCHAR(50)` | The status of the emergency request. | |
| `ambulance_vehicle_id` | `INT` | The ambulance vehicle involved in the emergency. | Foreign Key to `vehicles(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the request was created. | `NOT NULL`, Default: `now()` |

---

## G11: Financial (Wallets & Cards)
Tables related to user wallets, financial transactions, and specific-purpose cards.

### Table: `wallets`
Stores user or organization financial wallets.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the wallet. | **Primary Key** (Generated) |
| `owner_id` | `INT` | The user who owns the wallet. | Foreign Key to `users(id)` |
| `wallet_type` | `wallet_type` | Type ('individual', 'organization'). | |
| `organization_type` | `VARCHAR(100)` | The type of organization, if applicable. | |
| `balance` | `NUMERIC(14,2)` | The current balance of the wallet. | Default: `0` |
| `status` | `wallet_status` | Status ('active', 'suspended'). | Default: `'active'` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of wallet creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |
| *Note* | | | `UNIQUE` constraint on (`owner_id`, `wallet_type`) |

### Table: `wallet_transactions`
Logs all transactions associated with wallets.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the transaction. | **Primary Key** (Generated) |
| `wallet_id` | `INT` | The wallet involved in the transaction. | Foreign Key to `wallets(id)` |
| `transaction_type` | `transaction_type` | The type of transaction (e.g., 'top_up', 'transfer_out'). | |
| `amount` | `NUMERIC(14,2)` | The transaction amount. | `NOT NULL` |
| `target_wallet_id` | `INT` | The target wallet for transfers. | Foreign Key to `wallets(id)` |
| `target_service` | `VARCHAR(50)` | The target service for payments (e.g., 'insurance'). | |
| `description` | `VARCHAR(255)` | A description of the transaction. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of the transaction. | `NOT NULL`, Default: `now()` |

### Table: `insurance_cards`
Stores details about user-specific insurance cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the card. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user associated with the card. | Foreign Key to `users(id)` |
| `balance` | `NUMERIC(14,2)` | The balance on the card. | Default: `0` |
| `card_number` | `VARCHAR(50)` | The unique card number. | `UNIQUE` |
| `status` | `wallet_status` | The status of the card ('active', 'suspended'). | Default: `'active'` |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the card was issued. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp when the card was last updated. | `NOT NULL`, Default: `now()` |

### Table: `metro_cards`
Stores details about user-specific metro/transit cards.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the card. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user associated with the card. | Foreign Key to `users(id)` |
| `balance` | `NUMERIC(14,2)` | The balance on the card. | Default: `0` |
| `card_number` | `VARCHAR(50)` | The unique card number. | `UNIQUE` |
| `status` | `wallet_status` | The status of the card ('active', 'suspended'). | Default: `'active'` |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the card was issued. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp when the card was last updated. | `NOT NULL`, Default: `now()` |

### Table: `card_transactions`
A consolidated table for logging transactions from various card types.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the transaction. | **Primary Key** (Generated) |
| `card_id` | `INT` | The ID of the card used (from `insurance_cards` or `metro_cards`). | `NOT NULL` |
| `card_type` | `VARCHAR(50)` | Identifies the card table (e.g., 'insurance', 'metro'). | |
| `transaction_type` | `card_transaction_type` | The type of transaction ('top_up', 'charge', 'refund'). | |
| `transaction_category` | `transaction_category` | The category of transaction ('insurance', 'metro'). | |
| `reference` | `VARCHAR(100)` | A reference code for the transaction. | |
| `amount` | `NUMERIC(12,2)` | The transaction amount. | Default: `0` |
| `description` | `VARCHAR(255)` | A description of the transaction. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of the transaction. | `NOT NULL`, Default: `now()` |

---

## G12: Healthcare Domain
A comprehensive set of tables for managing healthcare services, facilities, and patient information.

### Table: `patients`
Stores patient-specific information, linked to the main `users` table.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the patient record. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user associated with this patient record. | Foreign Key to `users(id)` |
| `emergency_contact` | `VARCHAR(200)` | Contact information for emergencies. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of record creation. | `NOT NULL`, Default: `now()` |

### Table: `facilities`
Stores information about healthcare facilities (hospitals, clinics).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the facility. | **Primary Key** (Generated) |
| `name` | `VARCHAR(255)` | Name of the facility. | `NOT NULL` |
| `facility_type` | `VARCHAR(100)` | Type of facility (e.g., 'Hospital', 'Clinic'). | |
| `address_id` | `INT` | The physical address of the facility. | Foreign Key to `addresses(id)` |
| `phone` | `VARCHAR(20)` | Contact phone number for the facility. | |
| `location` | `GEOMETRY(Point, 4326)` | Geographic coordinates for mapping. | GIST Index for spatial queries |
| `emergency_services` | `BOOLEAN` | Flag indicating if emergency services are available. | Default: `FALSE` |
| `department_id` | `INT` | The city department associated with the facility. | Foreign Key to `departments(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of record creation. | `NOT NULL`, Default: `now()` |

### Table: `beds`
Tracks the status and assignment of beds within healthcare facilities.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the bed. | **Primary Key** (Generated) |
| `facility_id` | `INT` | The facility where the bed is located. | Foreign Key to `facilities(id)` |
| `bed_number` | `VARCHAR(50)` | The number or code of the bed. | |
| `bed_type` | `VARCHAR(50)` | The type of bed (e.g., 'ICU', 'General'). | |
| `status` | `VARCHAR(50)` | The current status of the bed (e.g., 'Available'). | |
| `patient_id` | `INT` | The patient occupying the bed, if any. | Foreign Key to `patients(id)` |
| `admission_date` | `TIMESTAMPTZ` | The date the patient was admitted to the bed. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of record creation. | `NOT NULL`, Default: `now()` |

### Table: `appointments`
Stores patient appointments with healthcare providers.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the appointment. | **Primary Key** (Generated) |
| `patient_id` | `INT` | The patient for the appointment. | Foreign Key to `patients(id)` |
| `facility_id` | `INT` | The facility where the appointment is scheduled. | Foreign Key to `facilities(id)` |
| `staff_user_id` | `INT` | The healthcare professional for the appointment. | Foreign Key to `users(id)` |
| `appointment_at` | `TIMESTAMPTZ` | The date and time of the appointment. | |
| `type` | `VARCHAR(50)` | The type of appointment (e.g., 'Consultation'). | |
| `status` | `VARCHAR(50)` | The status of the appointment (e.g., 'Scheduled'). | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of appointment creation. | `NOT NULL`, Default: `now()` |

### Table: `prescriptions`
Stores medical prescriptions issued to patients.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the prescription. | **Primary Key** (Generated) |
| `patient_id` | `INT` | The patient for whom the prescription is intended. | Foreign Key to `patients(id)` |
| `prescriber_user_id` | `INT` | The healthcare professional who issued it. | Foreign Key to `users(id)` |
| `facility_id` | `INT` | The facility that issued the prescription. | Foreign Key to `facilities(id)` |
| `medication_name` | `VARCHAR(255)` | The name of the medication. | |
| `quantity` | `INT` | The prescribed quantity. | |
| `status` | `VARCHAR(50)` | The status of the prescription (e.g., 'Filled'). | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of prescription creation. | `NOT NULL`, Default: `now()` |

### Table: `ambulances`
Tracks the status and location of ambulances.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the ambulance. | **Primary Key** (Generated) |
| `vehicle_number` | `VARCHAR(50)` | The license plate or vehicle number. | `UNIQUE` |
| `status` | `VARCHAR(50)` | The current status (e.g., 'Available', 'En route'). | |
| `current_location` | `GEOMETRY(Point, 4326)` | The real-time geographic location of the ambulance. | |
| `base_facility_id` | `INT` | The home base facility for the ambulance. | Foreign Key to `facilities(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of record creation. | `NOT NULL`, Default: `now()` |

### Table: `emergency_calls`
Logs emergency calls for medical assistance.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the emergency call. | **Primary Key** (Generated) |
| `patient_id` | `INT` | The patient involved, if known. | Foreign Key to `patients(id)` |
| `caller_phone` | `VARCHAR(20)` | The phone number of the person who called. | |
| `emergency_type` | `VARCHAR(100)` | The type of emergency. | |
| `severity` | `VARCHAR(50)` | The severity level of the emergency. | |
| `address_id` | `INT` | The location of the emergency. | Foreign Key to `addresses(id)` |
| `ambulance_id` | `INT` | The ambulance dispatched to the scene. | Foreign Key to `ambulances(id)` |
| `facility_id` | `INT` | The facility the patient is being taken to. | Foreign Key to `facilities(id)` |
| `status` | `VARCHAR(50)` | The current status of the emergency response. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp when the call was received. | `NOT NULL`, Default: `now()` |

### Table: `payments`
Logs financial payments related to healthcare services.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the payment. | **Primary Key** (Generated) |
| `patient_id` | `INT` | The patient associated with the payment. | Foreign Key to `patients(id)` |
| `facility_id` | `INT` | The facility receiving the payment. | Foreign Key to `facilities(id)` |
| `service_type` | `VARCHAR(100)` | The type of service being paid for. | |
| `service_id` | `INT` | The ID of the specific service (e.g., `appointment_id`). | |
| `amount` | `NUMERIC(12,2)` | The total amount of the payment. | Default: `0` |
| `currency` | `CHAR(3)` | The currency of the payment (e.g., 'THB'). | Default: `'THB'` |
| `payment_method` | `VARCHAR(50)` | The method of payment (e.g., 'Credit Card'). | |
| `insurance_coverage` | `NUMERIC(12,2)` | The amount covered by insurance. | Default: `0` |
| `patient_copay` | `NUMERIC(12,2)` | The amount paid by the patient. | Default: `0` |
| `status` | `VARCHAR(50)` | The status of the payment (e.g., 'Completed'). | |
| `payment_date` | `TIMESTAMPTZ` | The date the payment was made. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of record creation. | `NOT NULL`, Default: `now()` |

### Table: `team_integrations`
A generic table to manage integrations with external team systems (Finance, Housing, etc.).
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the integration record. | **Primary Key** (Generated) |
| `team_name` | `VARCHAR(100)` | The name of the external team (e.g., 'Finance'). | |
| `external_table` | `VARCHAR(100)` | The table name in the external system. | |
| `external_id` | `VARCHAR(100)` | The corresponding ID in the external system. | |
| `data_type` | `VARCHAR(50)` | The type of data being integrated. | |
| `status` | `VARCHAR(50)` | The status of the integration link. | |
| `additional_data` | `JSONB` | Flexible storage for any extra integration data. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of integration creation. | `NOT NULL`, Default: `now()` |

---

## G13: Emergency Reports & Communication
Tables for users to report emergencies, manage contacts, and communicate.

### Table: `report_categories`
Stores different categories for emergency reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the category. | **Primary Key** (Generated) |
| `name` | `VARCHAR(255)` | The unique name of the report category (e.g., 'Traffic', 'Crime'). | `NOT NULL`, `UNIQUE` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `emergency_reports`
Stores emergency reports submitted by users.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the report. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who submitted the report. | Foreign Key to `users(id)` |
| `image_url` | `VARCHAR(1024)` | URL to an image of the incident. | |
| `description` | `TEXT` | A description of the incident. | |
| `location` | `GEOMETRY(Point, 4326)` | The geographic location of the incident. | GIST Index for spatial queries |
| `ambulance_service` | `BOOLEAN` | Flag indicating if ambulance service is requested. | Default: `FALSE` |
| `level` | `report_level` | The severity level of the report. | |
| `status` | `report_status` | The current status of the report ('pending', 'verified', 'resolved'). | Default: `'pending'` |
| `report_category_id` | `INT` | The category of the report. | Foreign Key to `report_categories(id)` |
| `created_at` | `TIMESTAMPTZ` | Timestamp of report creation. | `NOT NULL`, Default: `now()` |
| `updated_at` | `TIMESTAMPTZ` | Timestamp of the last update. | `NOT NULL`, Default: `now()` |

### Table: `emergency_contacts`
Stores user-defined emergency contacts.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the contact. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who owns this contact. | Foreign Key to `users(id)` |
| `contact_name` | `VARCHAR(255)` | The name of the emergency contact. | `NOT NULL` |
| `phone` | `VARCHAR(20)` | The phone number of the emergency contact. | |

### Table: `alerts`
Stores alerts sent out based on verified emergency reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the alert. | **Primary Key** (Generated) |
| `report_id` | `INT` | The report that triggered the alert. | Foreign Key to `emergency_reports(id)` |
| `user_id` | `INT` | The user who sent the alert. | Foreign Key to `users(id)` |
| `message` | `TEXT` | The content of the alert message. | `NOT NULL` |
| `area` | `GEOMETRY(Point, 4326)` | The geographical area the alert was sent to. | |
| `status` | `alert_status` | Alert status from the enum ('unread', 'read', 'sent'). | Default: `unread`|
| `sent_at` | `TIMESTAMPTZ` | Timestamp when the alert was sent. | Default: `now()` |


### Table: `sos`
Stores SOS information.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the alert. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who sent the alert. | Foreign Key to `users(id)` |
| `status` | `sos_status` | Sos status from the enum ('open', 'closed'). | Default: `open`|
| `location` | `GEOMETRY(Point, 4326)` | The geographical area the alert was sent to. | |
| `created_at` | `TIMESTAMP` | Timestamp when the sos was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the sos was last updated. | |


### Table: `fcm_tokens`
Stores fcm token.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the alert. | **Primary Key** (Generated) |
| `user_id` | `INT` | The user who has fcm token. | Foreign Key to `users(id)` |
| `fcm_token` | `TEXT` | store fcm token. | |
| `created_at` | `TIMESTAMP` | Timestamp when the fcm token was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the fcm token was last updated. | |

### Table: `conversations`
Stores information about chat conversations.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the conversation. | **Primary Key** (Generated) |
| `conversation_name` | `VARCHAR(255)` | The name of the conversation (for group chats). | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of creation. | `NOT NULL`, Default: `now()` |

### Table: `conversation_participants`
Junction table linking users to the conversations they are part of.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `conversation_id` | `INT` | Foreign key referencing the conversation. | **Composite Primary Key**, FK to `conversations(id)` |
| `user_id` | `INT` | Foreign key referencing the user. | **Composite Primary Key**, FK to `users(id)` |

### Table: `messages`
Stores individual chat messages within a conversation.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the message. | **Primary Key** (Generated) |
| `conversation_id` | `INT` | The conversation the message belongs to. | Foreign Key to `conversations(id)` |
| `sender_id` | `INT` | The user who sent the message. | Foreign Key to `users(id)` |
| `message_text` | `TEXT` | The content of the message. | |
| `sent_at` | `TIMESTAMPTZ` | Timestamp when the message was sent. | `NOT NULL`, Default: `now()` |

---

## G15: Waste Management
Tables for tracking waste collection types and statistics.

### Table: `waste_types`
Stores different types of waste.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the waste type. | **Primary Key** (Generated) |
| `type_name` | `VARCHAR(255)` | The name of the waste type (e.g., 'Plastic'). | `NOT NULL` |
| `typical_weight_kg` | `NUMERIC(10,3)` | The typical weight of a standard unit of this waste type. | |

### Table: `waste_event_statistics`
Logs statistics for waste collected during events.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the statistic record. | **Primary Key** (Generated) |
| `event_id` | `INT` | The event where the waste was collected. | Foreign Key to `events(id)` |
| `waste_type_id` | `INT` | The type of waste collected. | Foreign Key to `waste_types(id)` |
| `collection_date` | `TIMESTAMPTZ` | The date of collection. | |
| `total_collection_weight` | `NUMERIC(12,3)` | The total weight of waste collected in kg. | |

### Table: `power_bi_reports`
Links waste statistics to Power BI reports.
| Column | Data Type | Description | Constraints / Notes |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | Unique identifier for the report link. | **Primary Key** (Generated) |
| `waste_event_statistic_id` | `INT` | The statistic record used in the report. | Foreign Key to `waste_event_statistics(id)` |
| `report_type` | `VARCHAR(255)` | The type of Power BI report. | |
| `report_date` | `TIMESTAMPTZ` | The date the report was generated. | |
| `created_at` | `TIMESTAMPTZ` | Timestamp of link creation. | `NOT NULL`, Default: `now()`

## G16: Community Map (Firebase RTDB)
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
| `location` | `geometry` | Location of the marker respective to the world | PostGIS Point(4326) |
| `created_at` | `TIMESTAMP` | Timestamp when the marker was created. | |
| `updated_at` | `TIMESTAMP` | Timestamp when the marker was last updated. | |

