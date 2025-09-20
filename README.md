## Core User Features
Essential tables for user management, roles, and departmental structures.
***
### Table: `roles`
Stores user roles within the system.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the role. |
| `role_name` | `varchar(50)` | | The name of the role (e.g., 'Admin', 'User', 'Doctor', etc.). |

### Table: `departments`
Stores information about different departments.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the department. |
| `department_name` | `varchar(255)` | | The name of the department. |
| `created_at` | `timestamp` | | Timestamp of when the record was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update to the record. |

### Table: `users`
The main table for storing user profile information.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the user. |
| `username` | `varchar(25)` | | The user's chosen username. |
| `first_name` | `varchar(255)` | | The user's first name. |
| `middle_name` | `varchar(255)` | | The user's middle name. |
| `last_name` | `varchar(255)` | | The user's last name. |
| `gender` | `genders` (Enum) | | The user's gender (`MALE`, `FEMALE`, `NONE`). |
| `role_id` | `int` | **Foreign Key** (`roles.id`) | The ID of the role assigned to the user. |
| `password_hash`| `varchar(256)` | `NOT NULL` | The user's hashed password for security. |
| `email` | `varchar(255)` | `UNIQUE` | The user's unique email address. |
| `phone` | `varchar(15)` | `UNIQUE` | The user's unique phone number. |
| `address` | `text` | `NOT NULL` | The user's physical address. |
| `birth_date` | `timestamp` | `NOT NULL` | The user's date of birth. |
| `created_at` | `timestamp` | | Timestamp of when the user account was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update to the user profile. |

### Table: `users_departments`
A junction table linking users to departments.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | `int` | **Primary Key**, **Foreign Key** (`users.id`) | The identifier for the user. |
| `department_id` | `int` | **Primary Key**, **Foreign Key** (`departments.id`) | The identifier for the department. |

***
## G1: Know AI Courses
This group manages online and onsite educational courses.
***
### Table: `courses`
Stores general information about available courses.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the course. |
| `course_name` | `varchar(255)` | `NOT NULL` | The title of the course. |
| `course_description` | `text` | `NOT NULL` | A detailed description of the course. |
| `course_type` | `course_types` (Enum) | `NOT NULL` | Type (`ONLINE`, `ONSITE`, `ONLINE_AND_ONSITE`). |
| `cover_image` | `text` | `NOT NULL` | URL or path to the course's cover image. |
| `created_at` | `timestamp` | | Timestamp of when the course was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `online_courses`
Contains details specific to online course content, like video lessons.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the online video/module. |
| `video_name` | `varchar(100)` | `NOT NULL` | The title of the video lesson. |
| `video_description` | `text` | `NOT NULL` | A description of the video content. |
| `duration_minutes` | `decimal` | `NOT NULL` | The length of the video in minutes. |
| `video_order` | `int` | `NOT NULL` | The sequence number of the video in the course. |
| `video_file_path` | `text` | `NOT NULL` | The file path or URL to the video. |
| `course_id` | `int` | `NOT NULL`, **Foreign Key** (`courses.id`) | The course this video belongs to. |
| `created_at` | `timestamp` | | Timestamp of when the record was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `onsites`
Stores information about physical, in-person course events.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the onsite event. |
| `course_id` | `int` | **Foreign Key** (`courses.id`) | The course this event is for. |
| `event_venue` | `text` | `NOT NULL` | The location/venue of the event. |
| `duration_hours` | `decimal` | | The duration of the event in hours. |
| `event_datetime` | `timestamp` | `NOT NULL` | The date and time of the event. |
| `registration_deadline` | `timestamp` | `NOT NULL` | The deadline for event registration. |
| `avaliable_seat` | `int` | `NOT NULL`, `DEFAULT: 0` | The number of seats currently available. |
| `total_seat` | `int` | `NOT NULL`, `DEFAULT: 1` | The total number of seats for the event. |
| `created_at` | `timestamp` | | Timestamp of when the record was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `onsite_enrollments`
Tracks user enrollments for onsite events.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the enrollment. |
| `onsite_id` | `int` | **Foreign Key** (`onsites.id`) | The ID of the onsite event. |
| `user_id` | `int` | **Primary Key**, **Foreign Key** (`users.id`) | The ID of the user who enrolled. |

***
## G3: Event Hub
This group is for managing general events and user bookmarks.
***
### Table: `event`
Stores details about events.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the event. |
| `host_event_id` | `int` | **Foreign Key** (`users.id`) | The ID of the user hosting the event. |
| `title` | `varchar(255)` | | The title of the event. |
| `description` | `varchar(255)` | | A description of the event. |
| `avaliable_seat` | `int` | | Number of available seats. |
| `total_seat` | `int` | | Total number of seats. |
| `start_date` | `timestamp` | | The start date and time of the event. |
| `end_date` | `timestamp` | | The end date and time of the event. |
| `location` | `text` | | The location of the event. |
| `created_at` | `timestamp` | | Timestamp of record creation. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `bookmark`
Allows users to save or bookmark events they are interested in.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | `int` | **Primary Key**, **Foreign Key** (`users.id`) | The ID of the user bookmarking the event. |
| `event_id` | `int` | **Primary Key**, **Foreign Key** (`event.id`) | The ID of the bookmarked event. |
| `createdAt` | `timestamp` | | Timestamp of when the bookmark was created. |

***
## G4: Freecycle
This group facilitates a system for users to give away items for free.
***
### Table: `freecycle_posts`
Stores posts created by users for items they are giving away.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the post. |
| `item_name` | `varchar(100)` | `NOT NULL` | The name of the item being offered. |
| `item_weight` | `decimal` | | The weight of the item. |
| `photo_url` | `text` | `NOT NULL` | URL to a photo of the item. |
| `description` | `text` | `NOT NULL` | A description of the item. |
| `donater_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The ID of the user who created the post.|
| `receiver_id` | `int` | **Foreign Key** (`users.id`) | The ID of the user who received the item. Can be NULL if the item is given to another department instead of being gave to a user.|
| `donate_to_department_id` | `int` | **Foreign Key** (`departments.id`) | Indicates if the user chose to donate the item to a department or give it to another user. Can be NULL if the item is given to another user instead of being donated to a department. |
| `is_given` | `boolean` | `DEFAULT: false` | A flag indicating if the item has been given away. |
| `created_at` | `timestamp` | | Timestamp of when the post was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `freecycle_categories`
Stores categories for freecycle items (e.g., 'Furniture', 'Electronics').

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the category. |
| `category_name`| `varchar(100)` | | The name of the category. |
| `created_at` | `timestamp` | | Timestamp of when the category was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `freecycle_posts_categories`
A junction table linking freecycle posts to their respective categories.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `post_id` | `int` | **Primary Key**, **Foreign Key** (`freecycle_posts.id`) | The identifier for the freecycle post. |
| `category_id` | `int` | **Primary Key**, **Foreign Key** (`freecycle_categories.id`) | The identifier for the category. |

***
## G5: Air Quality
This group manages data related to air quality and environmental context.
***
### Table: `air_quality`
Stores air quality index (AQI) and pollutant measurements for specific locations.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the air quality reading. |
| `location` | `text` | `NOT NULL` | The location where the measurement was taken. |
| `aqi` | `decimal` | | The overall Air Quality Index value. |
| `pm25` | `decimal` | | PM2.5 particle concentration. |
| `pm10` | `decimal` | | PM10 particle concentration. |
| `co` | `decimal` | | Carbon Monoxide concentration. |
| `no2` | `decimal` | | Nitrogen Dioxide concentration. |
| `so2` | `decimal` | | Sulfur Dioxide concentration. |
| `o3` | `decimal` | | Ozone concentration. |
| `category` | `categories` (Enum) | | The air quality category (`GOOD`, `MODERATE`, etc.). |
| `created_at` | `timestamp` | | Timestamp of when the reading was recorded. |

### Table: `weather_context`
Stores weather-related data that can affect air quality.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the weather context record. |
| `rain_forecast`| `decimal` | | The forecasted probability or amount of rain. |
| `created_at` | `timestamp` | | Timestamp of when the record was created. |

### Table: `traffic_context`
Stores traffic data that can influence air quality.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the traffic context record. |
| `congestion_level`| `decimal` | | A metric representing the level of traffic congestion. |
| `created_at` | `timestamp` | | Timestamp of when the record was created. |

***
## G6: Volunteer
This group handles volunteer events and participant tracking.
***
### Table: `volunteer_events`
Stores information about volunteer opportunities.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the volunteer event. |
| `user_created_event_id` | `int` | **Foreign Key** (`users.id`) | The ID of the user who created the event. |
| `title` | `varchar(255)` | `NOT NULL` | The title of the volunteer event. |
| `description` | `text` | `NOT NULL` | A detailed description of the event. |
| `start_date` | `timestamp` | | The start date and time of the event. |
| `end_date` | `timestamp` | | The end date and time of the event. |
| `register_deadline` | `timestamp` | | The deadline for registration. |
| `location` | `text` | | The location of the event. |
| `status` | `volunteer_event_status` (Enum) | | The status (`DRAFT`, `PENDING`, `APPROVED`). |
| `created_at` | `timestamp` | | Timestamp of when the event was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `volunteer_event_participation`
Tracks user participation in volunteer events.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the participation record. |
| `volunteer_event_id` | `int` | **Foreign Key** (`volunteer_events.id`) | The ID of the volunteer event. |
| `participated_user_id` | `int` | **Foreign Key** (`users.id`) | The ID of the user participating. |
| `current_participator` | `int` | `NOT NULL`, `DEFAULT: 0` | The current number of participants. |
| `avaliable_seat` | `int` | `NOT NULL`, `DEFAULT: 0` | The number of available spots. |
| `total_seat` | `int` | `NOT NULL`, `DEFAULT: 1` | The total number of spots. |
| `created_at` | `timestamp` | | Timestamp of when the participation was recorded. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

***
## G7: Power BI Report Management
This group contains the data warehouse star schema for BI reporting.
***
### Table: `dim_time`
A dimension table for time-based analysis.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `time_id` | `int` | **Primary Key** | Unique identifier for the time record. |
| `date` | `timestamp` | | The full date and time. |
| `year` | `int` | | The year component. |
| `month` | `int` | | The month component. |
| `day` | `int` | | The day component. |
| `hour` | `int` | | The hour component. |
| `week_a_day` | `varchar(255)` | | The day of the week (e.g., 'Monday'). |

### Table: `dim_location`
A dimension table for geographical location data.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `location_id` | `int` | **Primary Key** | Unique identifier for the location. |
| `district` | `varchar(255)` | | The district name. |
| `subdistrict` | `varchar(255)` | | The subdistrict name. |
| `latitude` | `decimal` | | The latitude coordinate. |
| `longitude` | `decimal` | | The longitude coordinate. |

### Table: `dim_facility`
A dimension table for facilities like hospitals.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `facility_id` | `int` | **Primary Key** | Unique identifier for the facility. |
| `facility_type` | `varchar(255)` | | The type of facility (e.g., 'Hospital'). |
| `facility_name` | `varchar(255)` | | The name of the facility. |
| `location_id` | `int` | **Foreign Key** (`dim_location.location_id`) | Link to the location dimension. |

### Table: `dim_user`
A dimension table for user information.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | `int` | **Primary Key** | Unique identifier for the user. |
| `role` | `varchar` | | The user's role. |
| `department` | `varchar` | | The user's department. |

### Table: `dim_category`
A dimension table for categories.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `category_id` | `int` | **Primary Key** | Unique identifier for the category. |
| `category_name` | `varchar(255)` | | The name of the category. |

### Table: `report_metadata`
Stores metadata about the generated BI reports.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `report_id` | `int` | **Primary Key**, Auto-Increment | Unique ID for the report metadata. |
| `title` | `varchar(255)` | | The title of the report. |
| `description` | `varchar(255)` | | A description of the report. |
| `category_id` | `int` | **Foreign Key** (`dim_category.category_id`) | Link to the category dimension. |
| `created_by` | `int` | **Foreign Key** (`dim_user.user_id`) | Link to the user dimension. |
| `last_updated` | `timestamp` | | Timestamp of the last update. |

### Table: `fact_traffic`, `fact_waste`, `fact_healthcare`, `fact_weather`, `fact_demographic`
Fact tables containing quantitative measures for analysis.

| Table | Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| **fact_traffic** | `traffic_id` | `int` | **PK**, Auto-Inc | Unique identifier for traffic fact. |
| | `time_id` | `int` | **FK** (`dim_time.time_id`) | Link to time dimension. |
| | `location_id` | `int` | **FK** (`dim_location.location_id`) | Link to location dimension. |
| | `speed_kmh` | `decimal` | | Average speed in km/h. |
| | `accident_flag`| `boolean` | | Flag for accidents. |
| | `closure_flag` | `boolean` | | Flag for road closures. |
| **fact_waste** | `waste_id` | `int` | **PK**, Auto-Inc | Unique identifier for waste fact. |
| | `time_id` | `int` | **FK** (`dim_time.time_id`) | Link to time dimension. |
| | `location_id` | `int` | **FK** (`dim_location.location_id`) | Link to location dimension. |
| | `bin_fill_level_percent` | `int` | | Waste bin fill level percentage. |
| | `recycling_tonnage` | `decimal` | | Weight of recycled materials in tons. |
| **fact_healthcare**| `health_id` | `int` | **PK**, Auto-Inc | Unique identifier for healthcare fact. |
| | `time_id` | `int` | **FK** (`dim_time.time_id`) | Link to time dimension. |
| | `facility_id` | `int` | **FK** (`dim_facility.facility_id`) | Link to facility dimension. |
| | `wait_time_minutes` | `int` | | Patient wait time in minutes. |
| | `alert_type` | `varchar(255)` | | Type of health alert. |
| | `cases_reported`| `int` | | Number of cases reported. |
| **fact_weather** | `weather_id` | `int` | **PK**, Auto-Inc | Unique identifier for weather fact. |
| | `time_id` | `int` | **FK** (`dim_time.time_id`) | Link to time dimension. |
| | `location_id` | `int` | **FK** (`dim_location.location_id`) | Link to location dimension. |
| | `temperature` | `decimal` | | Temperature reading. |
| | `aqi` | `int` | | Air Quality Index. |
| | `warning_flag` | `boolean` | | Flag for weather warnings. |
| **fact_demographic**|`demographic_id`| `int` | **PK**, Auto-Inc | Unique identifier for demographic fact. |
| | `time_id` | `int` | **FK** (`dim_time.time_id`) | Link to time dimension. |
| | `location_id` | `int` | **FK** (`dim_location.location_id`) | Link to location dimension. |
| | `population_total`|`int` | | Total population count. |

***
## G8: Transportation
This group manages public transportation systems, including cards, vehicles, and routes. 🚌
***
### Table: `digital_card`
Stores user transportation digital cards.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `card_id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the card. |
| `user_id` | `int` | **Foreign Key** (`users.id`) | The user associated with the card. |
| `status` | `transportation_digital_card_status` (Enum) | | Status (`active`, `inactive`). |

### Table: `transportation_vehicle_type`
Defines types of transportation vehicles.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `type_id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the vehicle type. |
| `type_name` | `varchar(100)` | | Name of the type (e.g., 'Bus', 'Van'). |

### Table: `route`
Stores information about transportation routes.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `route_id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the route. |
| `route_name` | `varchar(255)` | | The name or number of the route. |
| `type_id` | `int` | **Foreign Key** (`transportation_vehicle_type.type_id`) | The type of vehicle for this route. |

### Table: `transportation_card_transaction`
Logs transactions made with digital transportation cards.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `transaction_id` | `int` | **Primary Key**, Auto-Increment | Unique ID for the transaction. |
| `card_id` | `int` | **Foreign Key** (`digital_card.card_id`) | The card used for the transaction. |
| `route_id` | `int` | **Foreign Key** (`route.route_id`) | The route taken. |
| `amount` | `decimal` | | The transaction amount. |
| `status` | `transportation_card_transaction_status` (Enum) | | Status (`pending`, `confirmed`, `failed`). |
| `timestamp` | `timestamp` | | Time of the transaction. |

### Table: `transportation_vehicle`
Tracks individual transportation vehicles.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `vehicle_id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the vehicle. |
| `type_id` | `int` | **Foreign Key** (`transportation_vehicle_type.type_id`) | The type of vehicle. |
| `route_id` | `int` | **Foreign Key** (`route.route_id`) | The current assigned route. |
| `current_latitude` | `varchar(100)` | | The vehicle's current latitude. |
| `current_longitude` | `varchar(100)` | | The vehicle's current longitude. |
| `status` | `transportation_vehicle_status` (Enum) | | Status (`active`, `maintenance`). |

### Table: `stop`
Stores information about individual bus/van stops.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `stop_id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the stop. |
| `stop_name` | `varchar(255)` | | The name of the stop. |
| `stop_latitude` | `varchar(100)` | | The latitude of the stop. |
| `stop_longitude`| `varchar(100)` | | The longitude of the stop. |

### Table: `route_stop`
A junction table that defines the sequence of stops for each route.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `route_stop_id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for this entry. |
| `route_id` | `int` | **Foreign Key** (`route.route_id`) | The route identifier. |
| `stop_id` | `int` | **Foreign Key** (`stop.stop_id`) | The stop identifier. |
| `stop_order` | `int` | | The order of this stop on the route. |
| `travel_time_to_next_stop` | `int` | | Estimated travel time to the next stop in minutes. |

### Table: `transportation_user_request`
Logs user requests for route planning.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `request_id` | `int` | **Primary Key**, Auto-Increment | Unique ID for the request. |
| `user_id` | `int` | **Foreign Key** (`users.id`) | The user making the request. |
| `origin_stop_id`| `int` | **Foreign Key** (`stop.stop_id`) | The starting stop. |
| `destination_stop_id`| `int` | **Foreign Key** (`stop.stop_id`) | The destination stop. |
| `fastest_route_id`| `int` | **Foreign Key** (`route.route_id`) | The recommended route. |
| `total_travel_time`| `int` | | The total estimated travel time in minutes. |
| `timestamp` | `timestamp` | | Time of the request. |

***
## G9: Find Apartment
This group manages apartment listings and related points of interest. 🏢
***
### Table: `apartment`
Stores basic information about apartments.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the apartment. |
| `apartment_name`| `varchar(255)` | | The name of the apartment building. |
| `apartment_rating`| `decimal` | | The user rating of the apartment. |
| `apartment_phone`| `varchar(15)` | | The contact phone number. |

### Table: `apartment_address`
Stores detailed address information for apartments.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the address. |
| `apartment_id`| `int` | **Foreign Key** (`apartment.id`), One-to-One | Link to the apartment table. |
| `apartment_latitude`| `decimal` | | The latitude coordinate. |
| `apartment_longitude`| `decimal` | | The longitude coordinate. |
| `district` | `varchar(255)` | | The district name. |
| `sub_district`| `varchar(255)` | | The sub-district name. |
| `zip_code` | `varchar(255)` | | The postal zip code. |
| `more_address_detail`| `text` | | More details like building number, road, etc. |
| `created_at` | `timestamp` | | Timestamp of record creation. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `poi_categories`
Stores categories for Points of Interest (POI).

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique ID for the POI category. |
| `category_name`| `varchar(255)` | | Name of the category (e.g., 'Restaurant', 'Park'). |
| `created_at` | `timestamp` | | Timestamp of record creation. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `poi_location`
Stores information about specific Points of Interest.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique ID for the POI. |
| `poi_name` | `varchar(255)` | | The name of the POI. |
| `poi_latitude`| `decimal` | | The latitude coordinate of the POI. |
| `poi_longitude`| `decimal` | | The longitude coordinate of the POI. |
| `category_id` | `int` | **Foreign Key** (`poi_categories.id`) | The category this POI belongs to. |

***
## G10: Traffic
This group manages traffic control systems, intersections, and emergency requests. 🚦
***
### Table: `traffic_light`, `intersection`, `light_request`, `road`, `vehicle`, `traffic_emergency_request`
(This section is unchanged from the previous version)

---
## G11: Financial

This group manages user wallets, financial cards, and transactions.

---

### Table: `wallets`
Stores user or organization digital wallets.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `wallet_id` | `int` | **Primary Key** | Unique identifier for the wallet. |
| `owner_id` | `int` | `UNIQUE`, **Foreign Key** (`users.id`) | The ID of the user who owns the wallet. |
| `wallet_type` | `wallet_type` (Enum) | | The type of wallet (`individual`, `organization`). |
| `organization_type` | `varchar(100)`| | The type of organization, if applicable. |
| `balance` | `decimal` | `DEFAULT: 0.0` | The current balance of the wallet. |
| `status` | `wallet_status` (Enum) | | The status of the wallet (`active`, `suspended`). |
| `created_at` | `timestamp` | | Timestamp of when the wallet was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `wallet_transactions`
Logs all transactions associated with wallets.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `transaction_id`| `int` | **Primary Key** | Unique identifier for the transaction. |
| `wallet_id` | `int` | **Foreign Key** (`wallets.wallet_id`) | The wallet involved in the transaction. |
| `transaction_type` | `transaction_type` (Enum) | | The type of transaction (`top_up`, `transfer_in`, etc.). |
| `amount` | `decimal` | | The amount of the transaction. |
| `target_wallet_id`| `int` | | The ID of the recipient wallet in a transfer. |
| `target_service`| `target_services` (Enum) | | The service the payment is for (`insurance`, `metro`). |
| `description` | `varchar(255)` | | A description of the transaction. |
| `created_at` | `timestamp` | | Timestamp of when the transaction occurred. |

### Table: `insurance_cards`
Stores details about user insurance cards.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `card_id` | `int` | **Primary Key** | Unique identifier for the insurance card. |
| `citizen_id` | `int` | **Foreign Key** (`users.id`) | The user associated with the card. |
| `balance` | `decimal` | `DEFAULT: 0.0` | The current balance on the card. |
| `card_number` | `int` | `UNIQUE` | The unique number of the insurance card. |
| `status` | `wallet_status` (Enum) | | The status of the card (`active`, `suspended`). |
| `created_at` | `timestamp` | | Timestamp of when the card was issued. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `metro_cards`
Stores details about user metro/transit cards.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `card_id` | `int` | **Primary Key** | Unique identifier for the metro card. |
| `citizen_id` | `int` | **Foreign Key** (`users.id`) | The user associated with the card. |
| `balance` | `decimal` | `DEFAULT: 0.0` | The current balance on the card. |
| `card_number` | `int` | `UNIQUE` | The unique number of the metro card. |
| `status` | `wallet_status` (Enum) | | The status of the card (`active`, `suspended`). |
| `created_at` | `timestamp` | | Timestamp of when the card was issued. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `transaction`
A general table for logging transactions from various card types.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `transaction_id`| `int` | **Primary Key** | Unique identifier for the transaction. |
| `card_id` | `int` | **Foreign Key** (`insurance_cards.card_id`, etc.) | The ID of the card used for the transaction. |
| `transaction_type` | `card_transaction_type` (Enum) | | The type of transaction (`top_up`, `charge`, `refund`). |
| `transaction_category` | `transaction_category` (Enum) | | The category of the transaction (`insurance`, `metro`). |
| `reference` | `varchar(50)` | | A reference code for the transaction. |
| `amount` | `decimal` | `DEFAULT: 0.0` | The amount of the transaction. |
| `description` | `varchar(255)` | | A description of the transaction. |
| `created_at` | `timestamp` | | Timestamp of when the transaction occurred. |

---
## G12: Healthcare

This group manages a comprehensive healthcare system including patients, facilities, appointments, and emergencies.

---

### Table: `patients`
Stores information about patients, linking them to users.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `patient_id` | `int` | **Primary Key** | Unique identifier for the patient. |
| `user_id` | `int` | **Foreign Key** (`users.id`) | The corresponding user account for the patient. |
| `emergency_contact` | `varchar(200)`| | Information for the patient's emergency contact. |
| `finance_id` | `int` | | ID for linking to a financial system. |
| `housing_id` | `int` | | ID for linking to a housing system. |
| `sos_id` | `int` | | ID for linking to an emergency (SOS) system. |
| `created_at` | `timestamp` | | Timestamp of when the patient record was created. |

### Table: `facilities`
Stores information about healthcare facilities like hospitals and clinics.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `facility_id` | `int` | **Primary Key** | Unique identifier for the facility. |
| `name` | `varchar(255)` | | The name of the facility. |
| `type` | `varchar(50)` | | The type of facility (e.g., 'Hospital', 'Clinic'). |
| `address` | `text` | | The address of the facility. |
| `phone` | `varchar(20)` | | The contact phone number for the facility. |
| `latitude` | `decimal(10,8)`| | The latitude coordinate of the facility. |
| `longitude` | `decimal(11,8)`| | The longitude coordinate of the facility. |
| `emergency_services` | `boolean` | | A flag indicating if emergency services are available. |
| `finance_merchant_id` | `int` | | Merchant ID for financial transactions. |
| `housing_zone` | `varchar(100)`| | Zone information for housing/logistics. |
| `sos_code` | `varchar(50)` | | Code for the emergency (SOS) system. |
| `department_id` | `int` | **Foreign Key** (`departments.id`) | Associated department ID. |
| `created_at` | `timestamp` | | Timestamp of when the record was created. |

### Table: `beds`
Manages hospital bed allocation and status.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `bed_id` | `int` | **Primary Key** | Unique identifier for the bed. |
| `facility_id` | `int` | **Foreign Key** (`facilities.facility_id`) | The facility where the bed is located. |
| `bed_number` | `varchar(20)` | | The number or identifier of the bed. |
| `bed_type` | `varchar(50)` | | The type of bed (e.g., 'ICU', 'General'). |
| `status` | `varchar(20)` | | The current status of the bed (e.g., 'occupied', 'available'). |
| `patient_id` | `int` | **Foreign Key** (`patients.patient_id`) | The patient currently occupying the bed. |
| `admission_date` | `timestamp` | | The date and time of admission. |
| `finance_billing_id` | `int` | | ID for linking to billing systems. |
| `sos_priority` | `integer` | | Priority level for emergency systems. |

### Table: `appointments`
Tracks patient appointments with healthcare providers.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `appointment_id`| `int` | **Primary Key** | Unique identifier for the appointment. |
| `patient_id` | `int` | **Foreign Key** (`patients.patient_id`) | The patient for whom the appointment is scheduled. |
| `facility_id` | `int` | **Foreign Key** (`facilities.facility_id`) | The facility where the appointment will take place. |
| `user_id` | `int` | **Foreign Key** (`users.id`) | The healthcare provider (user) for the appointment. |
| `appointment_datetime` | `timestamp` | | The scheduled date and time of the appointment. |
| `type` | `varchar(50)` | | The type of appointment (e.g., 'Consultation', 'Check-up'). |
| `status` | `varchar(20)` | | The status of the appointment (e.g., 'Scheduled', 'Completed'). |
| `finance_payment_id` | `int` | | ID for linking to payment systems. |
| `housing_transport_id` | `int` | | ID for linking to transport/housing systems. |
| `sos_emergency` | `boolean` | | A flag indicating if it is an emergency appointment. |
| `created_at` | `timestamp` | | Timestamp of when the appointment was created. |

### Table: `prescriptions`
Stores medication prescriptions for patients.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `prescription_id` | `int` | **Primary Key** | Unique identifier for the prescription. |
| `patient_id` | `int` | **Foreign Key** (`patients.patient_id`) | The patient the prescription is for. |
| `user_id` | `int` | **Foreign Key** (`users.id`) | The healthcare provider who issued the prescription. |
| `facility_id` | `int` | **Foreign Key** (`facilities.facility_id`) | The facility where the prescription was issued. |
| `medication_name` | `varchar(255)`| | The name of the medication. |
| `quantity` | `integer` | | The prescribed quantity. |
| `status` | `varchar(20)` | | The status of the prescription (e.g., 'filled', 'pending'). |
| `finance_payment_id` | `int` | | ID for linking to payment systems. |
| `housing_delivery_id` | `int` | | ID for linking to delivery/housing systems. |
| `sos_critical` | `boolean` | | A flag indicating if the medication is critical. |
| `created_at` | `timestamp` | | Timestamp of when the prescription was created. |

### Table: `ambulances`
Tracks the status and location of ambulances.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `ambulance_id` | `int` | **Primary Key** | Unique identifier for the ambulance. |
| `vehicle_number`| `varchar(50)` | | The license plate or vehicle number. |
| `status` | `varchar(20)` | | The current status (e.g., 'available', 'en-route'). |
| `current_latitude` | `decimal(10,8)`| | The current latitude of the ambulance. |
| `current_longitude` | `decimal(11,8)`| | The current longitude of the ambulance. |
| `base_facility_id` | `int` | **Foreign Key** (`facilities.facility_id`) | The home base facility of the ambulance. |
| `finance_rate` | `decimal(10,2)`| | The billing rate for the ambulance service. |
| `housing_coverage_zones` | `json` | | The service coverage zones. |
| `sos_priority` | `integer` | | The priority level in an emergency. |
| `created_at` | `timestamp` | | Timestamp of when the ambulance record was created. |

### Table: `emergency_calls`
Logs incoming emergency calls and dispatch information.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `emergency_id` | `int` | **Primary Key** | Unique identifier for the emergency call. |
| `patient_id` | `int` | **Foreign Key** (`patients.patient_id`) | The patient associated with the call, if known. |
| `caller_phone` | `varchar(20)` | | The phone number of the person who called. |
| `emergency_type`| `varchar(50)` | | The type of emergency (e.g., 'Cardiac Arrest', 'Accident'). |
| `severity` | `varchar(20)` | | The severity level of the emergency. |
| `location_address` | `text` | | The address of the emergency location. |
| `ambulance_id` | `int` | **Foreign Key** (`ambulances.ambulance_id`) | The ambulance dispatched to the scene. |
| `facility_id` | `int` | **Foreign Key** (`facilities.facility_id`) | The destination facility. |
| `status` | `varchar(20)` | | The status of the emergency call (e.g., 'dispatched', 'resolved'). |
| `finance_billing_id` | `int` | | ID for linking to billing systems. |
| `housing_unit`| `varchar(100)`| | Unit information for housing/logistics. |
| `sos_incident_id` | `int` | | The incident ID from the emergency (SOS) system. |
| `created_at` | `timestamp` | | Timestamp of when the call was received. |

### Table: `payments`
Stores records of payments for healthcare services.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `payment_id` | `int` | **Primary Key** | Unique identifier for the payment. |
| `patient_id` | `int` | **Foreign Key** (`patients.patient_id`) | The patient making the payment. |
| `facility_id` | `int` | **Foreign Key** (`facilities.facility_id`) | The facility receiving the payment. |
| `service_type` | `varchar(50)` | | The type of service paid for (e.g., 'Appointment', 'Prescription'). |
| `service_id` | `int` | | The ID of the specific service record. |
| `amount` | `decimal(10,2)`| | The total amount of the payment. |
| `currency` | `varchar(3)` | | The currency of the payment (e.g., 'THB'). |
| `payment_method`| `varchar(50)` | | The method of payment (e.g., 'Credit Card', 'Wallet'). |
| `insurance_coverage` | `decimal(10,2)`| | The amount covered by insurance. |
| `patient_copay`| `decimal(10,2)`| | The co-payment amount paid by the patient. |
| `status` | `varchar(20)` | | The status of the payment (e.g., 'completed', 'pending'). |
| `payment_date` | `timestamp` | | The date and time of the payment. |
| `finance_transaction_id`| `int` | | The transaction ID from the financial system. |
| `insurance_claim_id` | `int` | | The claim ID from the insurance system. |
| `created_at` | `timestamp` | | Timestamp of when the payment record was created. |
| `updated_at` | `timestamp` | | Timestamp of the last update. |

### Table: `team_integrations`
Manages integrations with external systems or teams.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `integration_id`| `int` | **Primary Key** | Unique identifier for the integration. |
| `team_name` | `varchar(50)` | | The name of the integrated team (e.g., 'Finance', 'Housing'). |
| `healthcare_table` | `varchar(50)` | | The healthcare table being linked. |
| `healthcare_id` | `varchar` | | The ID from the healthcare table. |
| `external_id` | `varchar(100)`| | The corresponding ID in the external system. |
| `data_type` | `varchar(50)` | | The type of data being integrated. |
| `status` | `varchar(20)` | | The status of the integration link. |
| `additional_data`| `json` | | Additional data stored in JSON format. |
| `created_at` | `timestamp` | | Timestamp of when the integration was created. |

---
## G13: Emergency Reports

This group is dedicated to user-submitted emergency reports, alerts, and secure messaging.

---

### Table: `reports`
Stores emergency reports submitted by users.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `report_id` | `int` | `NOT NULL`, **Primary Key** | Unique identifier for the report. |
| `user_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The user who submitted the report. |
| `image` | `varchar(255)` | `NOT NULL` | URL or path to an image of the incident. |
| `description` | `varchar(255)` | `NOT NULL` | A description of the incident. |
| `latitude` | `varchar(255)` | `NOT NULL` | The latitude of the incident location. |
| `longitude` | `varchar(255)` | `NOT NULL` | The longitude of the incident location. |
| `level` | `level` (Enum) | | The severity level of the report (`minor`, `major`, etc.). |
| `status` | `report_status` (Enum) | | The status of the report (`pending`, `verified`, `resolved`). |
| `category` | `report_category` (Enum) | | The category of the report (`traffic`, `disaster`, `crime`). |
| `updated_at` | `timestamp` | | Timestamp of the last update. |
| `created_at` | `timestamp` | | Timestamp of when the report was created. |

### Table: `emergency_contacts`
Stores a user's designated emergency contacts.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `contact_id` | `int` | `NOT NULL`, **Primary Key** | Unique identifier for the emergency contact. |
| `user_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The user to whom this contact belongs. |
| `contact_name` | `varchar(255)` | `NOT NULL` | The name of the emergency contact person. |
| `phone` | `varchar(10)` | | The phone number of the contact person. |

### Table: `alerts`
Stores alerts that are sent out based on verified reports.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `alert_id` | `int` | `NOT NULL`, **Primary Key** | Unique identifier for the alert. |
| `report_id` | `int` | `NOT NULL` | The report that triggered this alert. |
| `message` | `text` | `NOT NULL` | The content of the alert message. |
| `area` | `varchar(255)` | | The geographical area the alert is targeted to. |
| `sent_at` | `timestamp` | | The timestamp of when the alert was sent. |

### Table: `users_contacts`
A list of contacts (other users) that a user has saved.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `contact_id` | `int` | `NOT NULL`, **Primary Key** | Unique identifier for the contact entry. |
| `user_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The user who owns the contact list. |
| `contact_user_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The user who is saved as a contact. |

### Table: `messages`
Stores individual messages between users.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `message_id` | `int` | `NOT NULL`, **Primary Key** | Unique identifier for the message. |
| `sender_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The user who sent the message. |
| `recipient_id` | `int` | `NOT NULL`, **Foreign Key** (`users.id`) | The user who received the message. |
| `message_text`| `text` | | The content of the message. |
| `sent_at` | `timestamp` | | The timestamp of when the message was sent. |
| `conversation_id` | `int` | `NOT NULL`, **Foreign Key** (`conversations.conversation_id`) | The conversation this message belongs to. |

### Table: `conversations`
Groups messages into conversations.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `conversation_id` | `int` | `NOT NULL`, **Primary Key** | Unique identifier for the conversation. |
| `conversation_name` | `varchar(255)`| | The name or title of the conversation. |

## G15: Waste Management
This group manages waste collection data from events.
***
### Table: `waste_type`
Defines different types of waste.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the waste type. |
| `type_name` | `varchar(255)` | | Name of the waste type (e.g., 'Plastic', 'Glass'). |
| `weight` | `decimal` | | Standard weight reference if applicable. |

### Table: `waste_event_statistic`
Stores waste collection statistics from events.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the statistic record. |
| `event_id` | `int` | **Foreign Key** (`event.id`) | The event where the waste was collected. |
| `waste_type_id` | `int` | **Foreign Key** (`waste_type.id`) | The type of waste collected. |
| `collection_date`| `timestamp` | | The date of collection. |
| `total_collection_weight` | `decimal` | | The total weight collected for this type. |

### Table: `power_bi_report`
Links waste statistics to a Power BI report entry.

| Field | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int` | **Primary Key**, Auto-Increment | Unique identifier for the report link. |
| `waste_event_statistic_id` | `int` | **Foreign Key** (`waste_event_statistic.id`) | Link to the specific waste statistic record. |
| `report_type` | `varchar(255)` | | The type or name of the report. |
| `report_date` | `timestamp` | | The date the report was generated. |
