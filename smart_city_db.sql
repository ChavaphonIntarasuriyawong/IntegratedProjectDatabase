-- Smart City DB
-- PostgreSQL SQL and PostGIS geometry
-- Last updated: 2025-11-14
-- Notes:
-- 1) Timestamps use timestamptz and default to now().
-- 2) Use GENERATED AS IDENTITY for PKs.
-- 3) Use PostGIS geometry(Point,4326) for coordinates.

-- Part 1: Enable Extensions
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

-- Part 2: Create ENUM Types
CREATE TYPE "air_quality_category" AS ENUM ('good', 'moderate', 'unhealthy', 'hazardous');
CREATE TYPE "alert_status" AS ENUM ('unread', 'read', 'sent');
CREATE TYPE "apartment_internet" AS ENUM ('free', 'not_free', 'none');
CREATE TYPE "apartment_location" AS ENUM ('asoke', 'prachauthit', 'phathumwan');
CREATE TYPE "apartment_type" AS ENUM ('dormitory', 'apartment');
CREATE TYPE "booking_status" AS ENUM ('pending', 'confirmed', 'cancelled');
CREATE TYPE "card_transaction_type" AS ENUM ('top_up', 'charge', 'refund');
CREATE TYPE "course_status" AS ENUM ('pending', 'approve', 'not_approve');
CREATE TYPE "course_type" AS ENUM ('online', 'onsite', 'online_and_onsite');
CREATE TYPE "freecycle_request_status" AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE "gender" AS ENUM ('male', 'female', 'none');
CREATE TYPE "report_level" AS ENUM ('near_miss', 'minor', 'moderate', 'major', 'lethal');
CREATE TYPE "report_status" AS ENUM ('pending', 'verified', 'resolved');
CREATE TYPE "room_status" AS ENUM ('occupied', 'pending', 'available');
CREATE TYPE "sos_status" AS ENUM ('open', 'closed');
CREATE TYPE "transaction_category" AS ENUM ('insurance', 'metro');
CREATE TYPE "transaction_type" AS ENUM ('top_up', 'transfer_in', 'transfer_out', 'transfer_to_service');
CREATE TYPE "volunteer_event_status" AS ENUM ('draft', 'pending', 'approved', 'rejected');
CREATE TYPE "wallet_status" AS ENUM ('active', 'suspended');
CREATE TYPE "wallet_type" AS ENUM ('individual', 'organization');
CREATE TYPE "report_type" AS ENUM ('traffic', 'accident', 'disaster');
CREATE TYPE "blood_type" AS ENUM ('A', 'B', 'AB', 'O');
CREATE TYPE "power_bi_report_type" AS ENUM ('summary', 'trends');
CREATE TYPE "report_visibility" AS ENUM ('citizens', 'admin');

-- Part 3: Create Tables
CREATE TABLE "addresses" (
    "id" SERIAL PRIMARY KEY,
    "address_line" TEXT,
    "province" VARCHAR(255),
    "district" VARCHAR(255),
    "subdistrict" VARCHAR(255),
    "postal_code" VARCHAR(20),
    "location" geometry,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "air_quality" (
    "id" SERIAL PRIMARY KEY,
    "location_id" INTEGER,
    "aqi" DECIMAL(6, 2),
    "pm25" DECIMAL(8, 3),
    "category" "air_quality_category",
    "measured_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "alerts" (
    "id" SERIAL PRIMARY KEY,
    "report_id" INTEGER,
    "user_id" INTEGER,
    "message" TEXT NOT NULL,
    "status" "alert_status" DEFAULT 'unread',
    "location" geometry,
    "sent_at" TIMESTAMPTZ(6) DEFAULT now()
);

CREATE TABLE "ambulances" (
    "id" SERIAL PRIMARY KEY,
    "vehicle_number" VARCHAR(50) UNIQUE,
    "status" VARCHAR(50),
    "current_location" geometry,
    "base_facility_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "apartment" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "phone" VARCHAR(10),
    "description" TEXT,
    "electric_price" DOUBLE PRECISION,
    "water_price" DOUBLE PRECISION,
    "internet" "apartment_internet",
    "apartment_type" "apartment_type",
    "apartment_location" "apartment_location",
    "address_id" INTEGER
);

CREATE TABLE "apartment_booking" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER, -- Made nullable to support onDelete: SetNull
    "check_in" TIMESTAMPTZ(6),
    "booking_status" "booking_status" DEFAULT 'pending',
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) DEFAULT now(),
    "room_id" INTEGER,
    "guest_name" VARCHAR(255),
    "guest_phone" VARCHAR(10),
    "guest_email" VARCHAR(255),
    "room_type" VARCHAR(255)
);

CREATE TABLE "apartment_owner" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER, -- Made nullable to support onDelete: SetNull
    "apartment_id" INTEGER NOT NULL
);

CREATE TABLE "apartment_picture" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "file_path" TEXT NOT NULL,
    "apartment_id" INTEGER NOT NULL
);

CREATE TABLE "appointments" (
    "id" SERIAL PRIMARY KEY,
    "patient_id" INTEGER,
    "facility_id" INTEGER,
    "staff_user_id" INTEGER,
    "appointment_at" TIMESTAMPTZ(6),
    "type" VARCHAR(50),
    "status" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "beds" (
    "id" SERIAL PRIMARY KEY,
    "facility_id" INTEGER,
    "bed_number" VARCHAR(50),
    "bed_type" VARCHAR(50),
    "status" VARCHAR(50),
    "patient_id" INTEGER,
    "admission_date" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "card_transactions" (
    "id" SERIAL PRIMARY KEY,
    "card_id" INTEGER NOT NULL,
    "card_type" VARCHAR(50),
    "transaction_type" "card_transaction_type",
    "transaction_category" "transaction_category",
    "reference" VARCHAR(100),
    "amount" DECIMAL(12, 2) DEFAULT 0,
    "description" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "conversation_participants" (
    "conversation_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    PRIMARY KEY ("conversation_id", "user_id")
);

CREATE TABLE "conversations" (
    "id" SERIAL PRIMARY KEY,
    "conversation_name" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "course_videos" (
    "id" SERIAL PRIMARY KEY,
    "course_id" INTEGER,
    "video_name" VARCHAR(255) NOT NULL,
    "video_description" TEXT,
    "duration_minutes" INTEGER NOT NULL,
    "video_order" INTEGER NOT NULL,
    "video_file_path" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    UNIQUE ("course_id", "video_order")
);

CREATE TABLE "courses" (
    "id" SERIAL PRIMARY KEY,
    "author_id" INTEGER,
    "course_name" VARCHAR(255) NOT NULL,
    "course_description" TEXT,
    "course_type" "course_type" NOT NULL,
    "course_status" "course_status" NOT NULL DEFAULT 'pending',
    "cover_image" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "departments" (
    "id" SERIAL PRIMARY KEY,
    "department_name" VARCHAR(255) NOT NULL UNIQUE,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "digital_cards" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "status" VARCHAR(20) NOT NULL DEFAULT 'active',
    "balance" DECIMAL(14, 2)
);

CREATE TABLE "dim_category" (
    "category_id" INTEGER NOT NULL PRIMARY KEY,
    "category_name" VARCHAR(255),
    "category_description" TEXT
);

CREATE TABLE "dim_location" (
    "location_id" INTEGER NOT NULL PRIMARY KEY,
    "district" VARCHAR(255),
    "coordinates" geometry
);

CREATE TABLE "dim_facility" (
    "facility_id" INTEGER NOT NULL PRIMARY KEY,
    "facility_name" VARCHAR(255),
    "location_id" INTEGER
);

CREATE TABLE "dim_time" (
    "time_id" INTEGER NOT NULL PRIMARY KEY,
    "date_actual" DATE,
    "year_val" INTEGER,
    "month_val" INTEGER,
    "day_val" INTEGER,
    "hour_val" INTEGER
);

CREATE TABLE "dim_user" (
    "user_id" INTEGER NOT NULL PRIMARY KEY,
    "full_name" VARCHAR(255),
    "email" VARCHAR(255) UNIQUE,
    "role_string" VARCHAR(100)
);

CREATE TABLE "dim_waste_type" (
    "waste_type_id" INTEGER NOT NULL PRIMARY KEY,
    "waste_type_name" VARCHAR(255)
);

CREATE TABLE "emergency_calls" (
    "id" SERIAL PRIMARY KEY,
    "patient_id" INTEGER,
    "caller_phone" VARCHAR(20),
    "emergency_type" VARCHAR(100),
    "severity" VARCHAR(50),
    "address_id" INTEGER,
    "ambulance_id" INTEGER,
    "facility_id" INTEGER,
    "status" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "emergency_contacts" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "contact_name" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(20)
);

CREATE TABLE "emergency_reports" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "image_url" VARCHAR(1024),
    "description" TEXT,
    "location" geometry,
    "ambulance_service" BOOLEAN DEFAULT false,
    "level" "report_level",
    "status" "report_status" DEFAULT 'pending',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "title" TEXT NOT NULL,
    "contact_center_service" BOOLEAN DEFAULT false,
    "report_category" "report_type"
);

CREATE TABLE "event_bookmarks" (
    "user_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    PRIMARY KEY ("user_id", "event_id")
);

CREATE TABLE "events" (
    "id" SERIAL PRIMARY KEY,
    "host_user_id" INTEGER,
    "department_id" INTEGER,
    "image_url" TEXT,
    "title" VARCHAR(255),
    "description" TEXT,
    "total_seats" INTEGER DEFAULT 0,
    "start_at" TIMESTAMPTZ(6),
    "end_at" TIMESTAMPTZ(6),
    "address_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "organization_id" INTEGER,
    "event_tag" INTEGER -- This is a 1-to-1 relation, FK added later
);

CREATE TABLE "facilities" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "facility_type" VARCHAR(100),
    "address_id" INTEGER,
    "phone" VARCHAR(20),
    "location" geometry,
    "emergency_services" BOOLEAN DEFAULT false,
    "department_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "fact_healthcare" (
    "health_id" INTEGER NOT NULL PRIMARY KEY,
    "time_id" INTEGER,
    "facility_id" INTEGER,
    "avg_wait_time_minutes_numeric" DECIMAL(10, 2),
    "bed_occupancy_percent_numeric" DECIMAL(5, 2),
    "total_revenue_numeric" DECIMAL(15, 2)
);

CREATE TABLE "fact_population" (
    "population_id" INTEGER NOT NULL PRIMARY KEY,
    "time_id" INTEGER,
    "location_id" INTEGER,
    "total_population" INTEGER,
    "population_density_numeric" DECIMAL(10, 2),
    "median_age_numeric" DECIMAL(5, 2)
);

CREATE TABLE "fact_traffic" (
    "traffic_id" INTEGER NOT NULL PRIMARY KEY,
    "time_id" INTEGER,
    "location_id" INTEGER,
    "vehicle_count" INTEGER,
    "has_accident_flag" BOOLEAN,
    "density_level_numeric" DECIMAL(10, 2)
);

CREATE TABLE "fact_waste" (
    "waste_id" INTEGER NOT NULL PRIMARY KEY,
    "time_id" INTEGER,
    "location_id" INTEGER,
    "waste_type_id" INTEGER,
    "collection_weight_kg_numeric" DECIMAL(10, 2)
);

CREATE TABLE "fact_weather" (
    "weather_id" INTEGER NOT NULL PRIMARY KEY,
    "time_id" INTEGER,
    "location_id" INTEGER,
    "avg_aqi_numeric" DECIMAL(10, 2),
    "max_pm25_numeric" DECIMAL(10, 2),
    "avg_temperature_numeric" DECIMAL(5, 2)
);

CREATE TABLE "fcm_token" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) DEFAULT now(),
    "tokens" TEXT NOT NULL
);

CREATE TABLE "freecycle_categories" (
    "id" SERIAL PRIMARY KEY,
    "category_name" VARCHAR(100) NOT NULL UNIQUE,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "freecycle_posts" (
    "id" SERIAL PRIMARY KEY,
    "item_name" VARCHAR(255) NOT NULL,
    "item_weight" DECIMAL(10, 3),
    "photo_url" TEXT,
    "description" TEXT,
    "donater_id" INTEGER,
    "donate_to_department_id" INTEGER,
    "is_given" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "freecycle_posts_categories" (
    "post_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,
    PRIMARY KEY ("post_id", "category_id")
);

CREATE TABLE "insurance_cards" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "balance" DECIMAL(14, 2) DEFAULT 0,
    "card_number" VARCHAR(50) UNIQUE,
    "status" "wallet_status" DEFAULT 'active',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "intersections" (
    "id" SERIAL PRIMARY KEY,
    "location" geometry
);

CREATE TABLE "light_requests" (
    "id" SERIAL PRIMARY KEY,
    "traffic_light_id" INTEGER,
    "requested_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "marker" (
    "id" SERIAL PRIMARY KEY,
    "marker_type_id" INTEGER,
    "description" TEXT,
    "location" geometry,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "marker_type" (
    "id" SERIAL PRIMARY KEY,
    "marker_type_icon" VARCHAR(255),
    "marker_type_color" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "messages" (
    "id" SERIAL PRIMARY KEY,
    "conversation_id" INTEGER,
    "sender_id" INTEGER,
    "message_text" TEXT,
    "sent_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "metro_cards" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "balance" DECIMAL(14, 2) DEFAULT 0,
    "card_number" VARCHAR(255) UNIQUE,
    "status" "wallet_status" DEFAULT 'active',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "onsite_enrollments" (
    "id" SERIAL PRIMARY KEY,
    "onsite_id" INTEGER,
    "user_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    UNIQUE ("onsite_id", "user_id")
);

CREATE TABLE "onsite_sessions" (
    "id" SERIAL PRIMARY KEY,
    "course_id" INTEGER,
    "address_id" INTEGER,
    "duration_hours" DECIMAL(6, 2),
    "event_at" TIMESTAMPTZ(6) NOT NULL,
    "registration_deadline" TIMESTAMPTZ(6) NOT NULL,
    "total_seats" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "patients" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "emergency_contact" VARCHAR(200),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "payments" (
    "id" SERIAL PRIMARY KEY,
    "patient_id" INTEGER,
    "facility_id" INTEGER,
    "service_type" VARCHAR(100),
    "service_id" INTEGER,
    "amount" DECIMAL(12, 2) DEFAULT 0,
    "currency" CHAR(3) DEFAULT 'THB',
    "payment_method" VARCHAR(50),
    "insurance_coverage" DECIMAL(12, 2) DEFAULT 0,
    "patient_copay" DECIMAL(12, 2) DEFAULT 0,
    "status" VARCHAR(50),
    "payment_date" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "power_bi_reports" (
    "id" SERIAL PRIMARY KEY,
    "waste_event_statistic_id" INTEGER,
    "report_type" VARCHAR(255),
    "report_date" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "prescriptions" (
    "id" SERIAL PRIMARY KEY,
    "patient_id" INTEGER,
    "prescriber_user_id" INTEGER,
    "facility_id" INTEGER,
    "medication_name" VARCHAR(255),
    "quantity" INTEGER,
    "status" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "questions" (
    "id" SERIAL PRIMARY KEY,
    "question" TEXT NOT NULL,
    "level" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "rating" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER, -- Made nullable to support onDelete: SetNull
    "rating" DOUBLE PRECISION,
    "comment" TEXT,
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "apartment_id" INTEGER
);

CREATE TABLE "receiver_requests" (
    "id" SERIAL PRIMARY KEY,
    "post_id" INTEGER,
    "receiver_id" INTEGER,
    "status" "freecycle_request_status" NOT NULL DEFAULT 'pending',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "refresh_tokens" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "refresh_token" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "expires_at" TIMESTAMPTZ(6)
);

CREATE TABLE "report_categories" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL UNIQUE,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "reports_metadata" (
    "report_id" INTEGER NOT NULL PRIMARY KEY,
    "title_string" VARCHAR(255),
    "description_string" TEXT,
    "category_id" INTEGER,
    "created_by" INTEGER,
    "last_updated_datetime" TIMESTAMPTZ(6),
    "power_bi_report_id_string" VARCHAR(255),
    "visibility" "report_visibility" DEFAULT 'citizens',
    "power_bi_report_type" "power_bi_report_type" DEFAULT 'summary'
);

CREATE TABLE "roads" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "start_intersection_id" INTEGER,
    "end_intersection_id" INTEGER,
    "length_meters" INTEGER
);

CREATE TABLE "roles" (
    "id" SERIAL PRIMARY KEY,
    "role_name" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "room" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "type" VARCHAR(255),
    "size" VARCHAR(50),
    "room_status" "room_status",
    "price_start" DOUBLE PRECISION,
    "price_end" DOUBLE PRECISION,
    "apartment_id" INTEGER
);

CREATE TABLE "route_stops" (
    "id" SERIAL PRIMARY KEY,
    "route_id" INTEGER,
    "stop_id" INTEGER,
    "stop_order" INTEGER,
    "travel_time_to_next_stop" INTEGER
);

CREATE TABLE "stops" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "location" geometry
);

CREATE TABLE "routes" (
    "id" SERIAL PRIMARY KEY,
    "route_name" VARCHAR(255),
    "vehicle_type_id" INTEGER
);

CREATE TABLE "sessions" (
    "session_id" UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    "user_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "expires_at" TIMESTAMPTZ(6),
    "last_accessed" TIMESTAMPTZ(6)
);

CREATE TABLE "sos" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "location" geometry,
    "status" "sos_status" DEFAULT 'open',
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) DEFAULT now()
);

CREATE TABLE "spatial_ref_sys" (
    "srid" INTEGER NOT NULL PRIMARY KEY,
    "auth_name" VARCHAR(256),
    "auth_srid" INTEGER,
    "srtext" VARCHAR(2048),
    "proj4text" VARCHAR(2048)
);

CREATE TABLE "specialty" (
    "id" SERIAL PRIMARY KEY,
    "specialty_name" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "team_integrations" (
    "id" SERIAL PRIMARY KEY,
    "team_name" VARCHAR(100),
    "external_table" VARCHAR(100),
    "external_id" VARCHAR(100),
    "data_type" VARCHAR(50),
    "status" VARCHAR(50),
    "additional_data" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "traffic_emergencies" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "accident_location" geometry,
    "destination_hospital" VARCHAR(255),
    "status" VARCHAR(50),
    "ambulance_vehicle_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "traffic_lights" (
    "id" SERIAL PRIMARY KEY,
    "intersection_id" INTEGER,
    "ip_address" INET,
    "location" geometry,
    "status" INTEGER DEFAULT 0,
    "current_color" SMALLINT,
    "density_level" SMALLINT,
    "auto_mode" BOOLEAN DEFAULT true,
    "last_updated" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "road_id" INTEGER,
    "green_duration" INTEGER,
    "red_duration" INTEGER,
    "last_color" SMALLINT
);

CREATE TABLE "transportation_transactions" (
    "id" SERIAL PRIMARY KEY,
    "card_id" INTEGER,
    "route_id" INTEGER,
    "amount" DECIMAL(12, 2),
    "status" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "tap_in_location" geometry,
    "tap_out_location" geometry
);

CREATE TABLE "transportation_vehicle_types" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL
);

CREATE TABLE "user_exercises" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "question_id" INTEGER,
    "user_answer" TEXT,
    "is_correct" BOOLEAN,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "users" (
    "id" SERIAL PRIMARY KEY,
    "username" VARCHAR(50) NOT NULL UNIQUE,
    "email" VARCHAR(255) NOT NULL UNIQUE,
    "phone" VARCHAR(20) UNIQUE,
    "password_hash" VARCHAR(512) NOT NULL,
    "role_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "last_login" TIMESTAMPTZ(6)
);

CREATE TABLE "user_levels" (
    "user_id" INTEGER NOT NULL PRIMARY KEY
);

CREATE TABLE "user_profiles" (
    "user_id" INTEGER NOT NULL PRIMARY KEY,
    "first_name" VARCHAR(255),
    "middle_name" VARCHAR(255),
    "last_name" VARCHAR(255),
    "birth_date" DATE,
    "gender" "gender",
    "address_id" INTEGER,
    "more_address_detail" TEXT,
    "id_card_number" VARCHAR(13),
    "blood_type" "blood_type",
    "congenital_disease" VARCHAR(255),
    "allergy" VARCHAR(255),
    "height" INTEGER,
    "weight" INTEGER,
    "profile_picture" VARCHAR(255),
    "ethnicity" VARCHAR(255),
    "nationality" VARCHAR(255),
    "religion" VARCHAR(255)
);

CREATE TABLE "users_departments" (
    "user_id" INTEGER NOT NULL,
    "department_id" INTEGER NOT NULL,
    PRIMARY KEY ("user_id", "department_id")
);

CREATE TABLE "vehicles" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER,
    "current_location" geometry,
    "vehicle_plate" VARCHAR(20)
);

CREATE TABLE "volunteer_event_participation" (
    "id" SERIAL PRIMARY KEY,
    "volunteer_event_id" INTEGER,
    "user_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "volunteer_events" (
    "id" SERIAL PRIMARY KEY,
    "created_by_user_id" INTEGER,
    "department_id" INTEGER,
    "image_url" TEXT,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "current_participants" INTEGER NOT NULL DEFAULT 0,
    "total_seats" INTEGER NOT NULL DEFAULT 1,
    "start_at" TIMESTAMPTZ(6),
    "end_at" TIMESTAMPTZ(6),
    "registration_deadline" TIMESTAMPTZ(6),
    "address_id" INTEGER,
    "status" "volunteer_event_status" NOT NULL DEFAULT 'draft',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "wallets" (
    "id" SERIAL PRIMARY KEY,
    "owner_id" INTEGER,
    "wallet_type" "wallet_type",
    "organization_type" VARCHAR(100),
    "balance" DECIMAL(14, 2) DEFAULT 0,
    "status" "wallet_status" DEFAULT 'active',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    UNIQUE ("owner_id", "wallet_type")
);

CREATE TABLE "wallet_transactions" (
    "id" SERIAL PRIMARY KEY,
    "wallet_id" INTEGER,
    "transaction_type" "transaction_type",
    "amount" DECIMAL(14, 2) NOT NULL,
    "target_wallet_id" INTEGER,
    "target_service" VARCHAR(50),
    "description" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "waste_event_statistics" (
    "id" SERIAL PRIMARY KEY,
    "event_id" INTEGER,
    "waste_type_id" INTEGER,
    "collection_date" TIMESTAMPTZ(6),
    "total_collection_weight" DECIMAL(12, 3)
);

CREATE TABLE "waste_types" (
    "id" SERIAL PRIMARY KEY,
    "type_name" VARCHAR(255) NOT NULL,
    "typical_weight_kg" DECIMAL(10, 3)
);

CREATE TABLE "weather_data" (
    "id" SERIAL PRIMARY KEY,
    "location_id" INTEGER,
    "temperature" DECIMAL(6, 2),
    "feel_temperature" DECIMAL(6, 2),
    "humidity" DECIMAL(6, 2),
    "wind_speed" DECIMAL(6, 2),
    "wind_direction" VARCHAR(50),
    "rainfall_probability" DECIMAL(5, 2),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT now()
);

CREATE TABLE "users_specialty" (
    "user_id" INTEGER, -- Made nullable to support onDelete: SetNull
    "specialty_id" INTEGER, -- Made nullable to support onDelete: SetNull
    PRIMARY KEY ("user_id", "specialty_id")
);

CREATE TABLE "event_organization" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" VARCHAR(255),
    "email" VARCHAR(255),
    "phone_number" VARCHAR(255)
);

CREATE TABLE "event_tag_name" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" VARCHAR(255)
);

CREATE TABLE "event_tag" (
    "event_id" INTEGER NOT NULL PRIMARY KEY,
    "event_tag_id" INTEGER,
    "name" VARCHAR(255)
);


-- Part 4: Add Foreign Keys and Indexes
-- Foreign Keys
ALTER TABLE "air_quality" ADD CONSTRAINT "air_quality_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "alerts" ADD CONSTRAINT "alerts_report_id_fkey" FOREIGN KEY ("report_id") REFERENCES "emergency_reports"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "alerts" ADD CONSTRAINT "alerts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "ambulances" ADD CONSTRAINT "ambulances_base_facility_id_fkey" FOREIGN KEY ("base_facility_id") REFERENCES "facilities"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "apartment" ADD CONSTRAINT "apartment_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "apartment_booking" ADD CONSTRAINT "apartment_booking_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "apartment_booking" ADD CONSTRAINT "fk_room_id" FOREIGN KEY ("room_id") REFERENCES "room"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "apartment_owner" ADD CONSTRAINT "apartment_owner_apartment_id_fkey" FOREIGN KEY ("apartment_id") REFERENCES "apartment"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "apartment_owner" ADD CONSTRAINT "apartment_owner_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "apartment_picture" ADD CONSTRAINT "apartment_picture_apartment_id_fkey" FOREIGN KEY ("apartment_id") REFERENCES "apartment"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_staff_user_id_fkey" FOREIGN KEY ("staff_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "beds" ADD CONSTRAINT "beds_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "beds" ADD CONSTRAINT "beds_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "conversation_participants" ADD CONSTRAINT "conversation_participants_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "conversation_participants" ADD CONSTRAINT "conversation_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "course_videos" ADD CONSTRAINT "course_videos_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "courses" ADD CONSTRAINT "courses_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "digital_cards" ADD CONSTRAINT "digital_cards_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "dim_facility" ADD CONSTRAINT "fk_location" FOREIGN KEY ("location_id") REFERENCES "dim_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "emergency_calls" ADD CONSTRAINT "emergency_calls_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "emergency_calls" ADD CONSTRAINT "emergency_calls_ambulance_id_fkey" FOREIGN KEY ("ambulance_id") REFERENCES "ambulances"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "emergency_calls" ADD CONSTRAINT "emergency_calls_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "emergency_calls" ADD CONSTRAINT "emergency_calls_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "emergency_contacts" ADD CONSTRAINT "emergency_contacts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "emergency_reports" ADD CONSTRAINT "emergency_reports_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "event_bookmarks" ADD CONSTRAINT "event_bookmarks_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "event_bookmarks" ADD CONSTRAINT "event_bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "events" ADD CONSTRAINT "events_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "events" ADD CONSTRAINT "events_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "events" ADD CONSTRAINT "events_host_user_id_fkey" FOREIGN KEY ("host_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "events" ADD CONSTRAINT "organization_id" FOREIGN KEY ("organization_id") REFERENCES "event_organization"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "events" ADD CONSTRAINT "events_event_tag_fkey" FOREIGN KEY ("event_tag") REFERENCES "event_tag"("event_id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "facilities" ADD CONSTRAINT "facilities_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "facilities" ADD CONSTRAINT "facilities_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "fact_healthcare" ADD CONSTRAINT "fk_facility" FOREIGN KEY ("facility_id") REFERENCES "dim_facility"("facility_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_healthcare" ADD CONSTRAINT "fk_time" FOREIGN KEY ("time_id") REFERENCES "dim_time"("time_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_population" ADD CONSTRAINT "fk_location" FOREIGN KEY ("location_id") REFERENCES "dim_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_population" ADD CONSTRAINT "fk_time" FOREIGN KEY ("time_id") REFERENCES "dim_time"("time_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_traffic" ADD CONSTRAINT "fk_location" FOREIGN KEY ("location_id") REFERENCES "dim_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_traffic" ADD CONSTRAINT "fk_time" FOREIGN KEY ("time_id") REFERENCES "dim_time"("time_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_waste" ADD CONSTRAINT "fk_location" FOREIGN KEY ("location_id") REFERENCES "dim_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_waste" ADD CONSTRAINT "fk_time" FOREIGN KEY ("time_id") REFERENCES "dim_time"("time_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_waste" ADD CONSTRAINT "fk_waste_type" FOREIGN KEY ("waste_type_id") REFERENCES "dim_waste_type"("waste_type_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_weather" ADD CONSTRAINT "fk_location" FOREIGN KEY ("location_id") REFERENCES "dim_location"("location_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fact_weather" ADD CONSTRAINT "fk_time" FOREIGN KEY ("time_id") REFERENCES "dim_time"("time_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fcm_token" ADD CONSTRAINT "fcm_token_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "freecycle_posts" ADD CONSTRAINT "freecycle_posts_donate_to_department_id_fkey" FOREIGN KEY ("donate_to_department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "freecycle_posts" ADD CONSTRAINT "freecycle_posts_donater_id_fkey" FOREIGN KEY ("donater_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "freecycle_posts_categories" ADD CONSTRAINT "freecycle_posts_categories_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "freecycle_categories"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "freecycle_posts_categories" ADD CONSTRAINT "freecycle_posts_categories_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "freecycle_posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "insurance_cards" ADD CONSTRAINT "insurance_cards_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "light_requests" ADD CONSTRAINT "light_requests_traffic_light_id_fkey" FOREIGN KEY ("traffic_light_id") REFERENCES "traffic_lights"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "marker" ADD CONSTRAINT "marker_marker_type_id_fkey" FOREIGN KEY ("marker_type_id") REFERENCES "marker_type"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "metro_cards" ADD CONSTRAINT "metro_cards_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "onsite_enrollments" ADD CONSTRAINT "onsite_enrollments_onsite_id_fkey" FOREIGN KEY ("onsite_id") REFERENCES "onsite_sessions"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "onsite_enrollments" ADD CONSTRAINT "onsite_enrollments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "onsite_sessions" ADD CONSTRAINT "onsite_sessions_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "onsite_sessions" ADD CONSTRAINT "onsite_sessions_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "patients" ADD CONSTRAINT "patients_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "payments" ADD CONSTRAINT "payments_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "payments" ADD CONSTRAINT "payments_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "power_bi_reports" ADD CONSTRAINT "power_bi_reports_waste_event_statistic_id_fkey" FOREIGN KEY ("waste_event_statistic_id") REFERENCES "waste_event_statistics"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "prescriptions" ADD CONSTRAINT "prescriptions_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "prescriptions" ADD CONSTRAINT "prescriptions_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "prescriptions" ADD CONSTRAINT "prescriptions_prescriber_user_id_fkey" FOREIGN KEY ("prescriber_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "rating" ADD CONSTRAINT "rating_apartment_id_fkey" FOREIGN KEY ("apartment_id") REFERENCES "apartment"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "rating" ADD CONSTRAINT "rating_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "receiver_requests" ADD CONSTRAINT "receiver_requests_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "freecycle_posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "receiver_requests" ADD CONSTRAINT "receiver_requests_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "reports_metadata" ADD CONSTRAINT "fk_category" FOREIGN KEY ("category_id") REFERENCES "dim_category"("category_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "reports_metadata" ADD CONSTRAINT "fk_created_by" FOREIGN KEY ("created_by") REFERENCES "dim_user"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "roads" ADD CONSTRAINT "roads_end_intersection_id_fkey" FOREIGN KEY ("end_intersection_id") REFERENCES "intersections"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "roads" ADD CONSTRAINT "roads_start_intersection_id_fkey" FOREIGN KEY ("start_intersection_id") REFERENCES "intersections"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "room" ADD CONSTRAINT "room_apartment_id_fkey" FOREIGN KEY ("apartment_id") REFERENCES "apartment"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "route_stops" ADD CONSTRAINT "route_stops_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "routes"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "route_stops" ADD CONSTRAINT "route_stops_stop_id_fkey" FOREIGN KEY ("stop_id") REFERENCES "stops"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "routes" ADD CONSTRAINT "routes_vehicle_type_id_fkey" FOREIGN KEY ("vehicle_type_id") REFERENCES "transportation_vehicle_types"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "sos" ADD CONSTRAINT "sos_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "traffic_emergencies" ADD CONSTRAINT "traffic_emergencies_ambulance_vehicle_id_fkey" FOREIGN KEY ("ambulance_vehicle_id") REFERENCES "vehicles"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "traffic_emergencies" ADD CONSTRAINT "traffic_emergencies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "traffic_lights" ADD CONSTRAINT "traffic_lights_intersection_id_fkey" FOREIGN KEY ("intersection_id") REFERENCES "intersections"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "transportation_transactions" ADD CONSTRAINT "transportation_transactions_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "digital_cards"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "transportation_transactions" ADD CONSTRAINT "transportation_transactions_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "routes"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "user_exercises" ADD CONSTRAINT "user_exercises_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "user_exercises" ADD CONSTRAINT "user_exercises_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "user_levels" ADD CONSTRAINT "user_levels_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "users" ADD CONSTRAINT "users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "users_departments" ADD CONSTRAINT "users_departments_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "users_departments" ADD CONSTRAINT "users_departments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "vehicles" ADD CONSTRAINT "vehicles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "volunteer_event_participation" ADD CONSTRAINT "volunteer_event_participation_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "volunteer_event_participation" ADD CONSTRAINT "volunteer_event_participation_volunteer_event_id_fkey" FOREIGN KEY ("volunteer_event_id") REFERENCES "volunteer_events"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "volunteer_events" ADD CONSTRAINT "volunteer_events_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "volunteer_events" ADD CONSTRAINT "volunteer_events_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "volunteer_events" ADD CONSTRAINT "volunteer_events_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_target_wallet_id_fkey" FOREIGN KEY ("target_wallet_id") REFERENCES "wallets"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "waste_event_statistics" ADD CONSTRAINT "waste_event_statistics_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "waste_event_statistics" ADD CONSTRAINT "waste_event_statistics_waste_type_id_fkey" FOREIGN KEY ("waste_type_id") REFERENCES "waste_types"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "weather_data" ADD CONSTRAINT "weather_data_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "users_specialty" ADD CONSTRAINT "users_specialty_specialty_id_fkey" FOREIGN KEY ("specialty_id") REFERENCES "specialty"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "users_specialty" ADD CONSTRAINT "users_specialty_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "event_organization" ADD CONSTRAINT "event_organization_id_fkey" FOREIGN KEY ("id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "event_tag" ADD CONSTRAINT "event_tag_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "event_tag" ADD CONSTRAINT "event_tag_event_tag_id_fkey" FOREIGN KEY ("event_tag_id") REFERENCES "event_tag_name"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "event_tag_name" ADD CONSTRAINT "event_tag_name_id_fkey" FOREIGN KEY ("id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- Indexes
CREATE INDEX "idx_addresses_location" ON "addresses" USING Gist ("location");
CREATE INDEX "idx_emergency_reports_location" ON "emergency_reports" USING Gist ("location");
CREATE INDEX "idx_events_start_at" ON "events" ("start_at");
CREATE INDEX "idx_facilities_location" ON "facilities" USING Gist ("location");
CREATE INDEX "idx_traffic_lights_location" ON "traffic_lights" USING Gist ("location");
CREATE INDEX "idx_users_email" ON "users" ("email");
CREATE INDEX "idx_users_phone" ON "users" ("phone");
CREATE INDEX "idx_volunteer_events_start_at" ON "volunteer_events" ("start_at");
