-- Smart City DB
-- PostgreSQL SQL and PostGIS geometry
-- Last updated: 2025-09-28
-- Notes:
-- 1) Timestamps use timestamptz and default to now().
-- 2) Use GENERATED AS IDENTITY for PKs.
-- 3) Use PostGIS geometry(Point,4326) for coordinates.


-- Required extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
DO $$ BEGIN
    CREATE TYPE gender AS ENUM ('male','female','none');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE freecycle_request_status AS ENUM ('pending','accepted','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE volunteer_event_status AS ENUM ('draft','pending','approved','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE course_type AS ENUM ('online','onsite','online_and_onsite');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE wallet_type AS ENUM ('individual','organization');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE wallet_status AS ENUM ('active','suspended');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE transaction_type AS ENUM ('top_up','transfer_in','transfer_out','transfer_to_service');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE card_transaction_type AS ENUM ('top_up','charge','refund');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE transaction_category AS ENUM ('insurance','metro');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE air_quality_category AS ENUM ('good','moderate','unhealthy','hazardous');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE report_level AS ENUM ('near_miss','minor','moderate','major','lethal');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE report_status AS ENUM ('pending','verified','resolved');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE sos_status AS ENUM ('open','closed');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE alert_status AS ENUM ('unread','read', 'sent');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE course_status AS ENUM ('pending','approve', 'not_approve');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

DO $$ BEGIN
    CREATE TYPE apartment_internet AS ENUM ('free', 'not_free', 'none');
    CREATE TYPE apartment_type AS ENUM ('dormitory', 'apartment');
    CREATE TYPE apartment_location AS ENUM ('asoke', 'prachauthit', 'phathumwan');
    CREATE TYPE room_status AS ENUM ('occupied', 'pending', 'available');
    CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END$$;

-- Core lookup tables
CREATE TABLE IF NOT EXISTS roles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS departments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Normalized addresses, reusable for users, facilities, events, etc.
CREATE TABLE IF NOT EXISTS addresses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address_line TEXT,
    province VARCHAR(255),
    district VARCHAR(255),
    subdistrict VARCHAR(255),
    postal_code VARCHAR(20),
    location geometry(Point,4326), -- longitude/latitude as Point
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Users and profiles -- split auth credentials from profile data
CREATE TABLE IF NOT EXISTS users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(512) NOT NULL,
    role_id INT REFERENCES roles(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    last_name VARCHAR(255),
    birth_date DATE,
    gender gender,
    address_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    more_address_detail TEXT
);

CREATE TABLE IF NOT EXISTS users_departments (
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    department_id INT REFERENCES departments(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, department_id)
);

-- Authentication & sessions
CREATE TABLE IF NOT EXISTS sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz,
    last_accessed timestamptz
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    refresh_token TEXT NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz
);

-- Freecycle (donation) domain
CREATE TABLE IF NOT EXISTS freecycle_categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS freecycle_posts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    item_weight NUMERIC(10,3),
    photo_url TEXT,
    description TEXT,
    donater_id INT REFERENCES users(id) ON DELETE SET NULL,
    donate_to_department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    is_given BOOLEAN NOT NULL DEFAULT FALSE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS freecycle_posts_categories (
    post_id INT REFERENCES freecycle_posts(id) ON DELETE CASCADE,
    category_id INT REFERENCES freecycle_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, category_id)
);

CREATE TABLE IF NOT EXISTS receiver_requests (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INT REFERENCES freecycle_posts(id) ON DELETE CASCADE,
    receiver_id INT REFERENCES users(id) ON DELETE SET NULL,
    status freecycle_request_status NOT NULL DEFAULT 'pending',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Volunteer events
CREATE TABLE IF NOT EXISTS volunteer_events (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    image_url TEXT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    current_participants INT NOT NULL DEFAULT 0,
    total_seats INT NOT NULL DEFAULT 1,
    start_at timestamptz,
    end_at timestamptz,
    registration_deadline timestamptz,
    address_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    status volunteer_event_status NOT NULL DEFAULT 'draft',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CHECK (current_participants >= 0 AND total_seats >= 0)
);

CREATE TABLE IF NOT EXISTS volunteer_event_participation (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    volunteer_event_id INT REFERENCES volunteer_events(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id INT REFERENCES users(id) ON DELETE SET NULL,
    course_name VARCHAR(255) NOT NULL,
    course_description TEXT,
    course_type course_type NOT NULL,
    course_status course_status NOT NULL, DEFAULT "pending"
    cover_image TEXT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS course_videos (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT REFERENCES courses(id) ON DELETE CASCADE,
    video_name VARCHAR(255) NOT NULL,
    video_description TEXT,
    duration_minutes INT NOT NULL,
    video_order INT NOT NULL,
    video_file_path TEXT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (course_id, video_order)
);

CREATE TABLE IF NOT EXISTS onsite_sessions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT REFERENCES courses(id) ON DELETE CASCADE,
    address_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    duration_hours NUMERIC(6,2),
    event_at timestamptz NOT NULL,
    registration_deadline timestamptz NOT NULL,
    total_seats INT NOT NULL DEFAULT 1,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS onsite_enrollments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    onsite_id INT REFERENCES onsite_sessions(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (onsite_id, user_id)
);

-- Questions / exercises
CREATE TABLE IF NOT EXISTS questions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question TEXT NOT NULL,
    level INT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_exercises (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    question_id INT REFERENCES questions(id) ON DELETE CASCADE,
    user_answer TEXT,
    is_correct BOOLEAN,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_levels (
    user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_level INT NOT NULL DEFAULT 1
);

-- Events hub
CREATE TABLE IF NOT EXISTS events (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    host_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    image_url TEXT,
    title VARCHAR(255),
    description TEXT,
    total_seats INT DEFAULT 0,
    start_at timestamptz,
    end_at timestamptz,
    address_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS event_bookmarks (
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    event_id INT REFERENCES events(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, event_id)
);

-- Healthcare domain
CREATE TABLE IF NOT EXISTS patients (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    emergency_contact VARCHAR(200),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS facilities (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    facility_type VARCHAR(100),
    address_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    phone VARCHAR(20),
    location geometry(Point,4326),
    emergency_services BOOLEAN DEFAULT FALSE,
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS beds (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_id INT REFERENCES facilities(id) ON DELETE CASCADE,
    bed_number VARCHAR(50),
    bed_type VARCHAR(50),
    status VARCHAR(50),
    patient_id INT REFERENCES patients(id) ON DELETE SET NULL,
    admission_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS appointments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id INT REFERENCES patients(id) ON DELETE SET NULL,
    facility_id INT REFERENCES facilities(id) ON DELETE SET NULL,
    staff_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    appointment_at timestamptz,
    type VARCHAR(50),
    status VARCHAR(50),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS prescriptions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id INT REFERENCES patients(id) ON DELETE SET NULL,
    prescriber_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    facility_id INT REFERENCES facilities(id) ON DELETE SET NULL,
    medication_name VARCHAR(255),
    quantity INT,
    status VARCHAR(50),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ambulances (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_number VARCHAR(50) UNIQUE,
    status VARCHAR(50),
    current_location geometry(Point,4326),
    base_facility_id INT REFERENCES facilities(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS emergency_calls (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id INT REFERENCES patients(id) ON DELETE SET NULL,
    caller_phone VARCHAR(20),
    emergency_type VARCHAR(100),
    severity VARCHAR(50),
    address_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    ambulance_id INT REFERENCES ambulances(id) ON DELETE SET NULL,
    facility_id INT REFERENCES facilities(id) ON DELETE SET NULL,
    status VARCHAR(50),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id INT REFERENCES patients(id) ON DELETE SET NULL,
    facility_id INT REFERENCES facilities(id) ON DELETE SET NULL,
    service_type VARCHAR(100),
    service_id INT,
    amount NUMERIC(12,2) DEFAULT 0,
    currency CHAR(3) DEFAULT 'THB',
    payment_method VARCHAR(50),
    insurance_coverage NUMERIC(12,2) DEFAULT 0,
    patient_copay NUMERIC(12,2) DEFAULT 0,
    status VARCHAR(50),
    payment_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Healthcare integrations
CREATE TABLE IF NOT EXISTS team_integrations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_name VARCHAR(100),
    external_table VARCHAR(100),
    external_id VARCHAR(100),
    data_type VARCHAR(50),
    status VARCHAR(50),
    additional_data JSONB,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Wallets & cards
CREATE TABLE IF NOT EXISTS wallets (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id INT REFERENCES users(id) ON DELETE CASCADE,
    wallet_type wallet_type,
    organization_type VARCHAR(100),
    balance NUMERIC(14,2) DEFAULT 0,
    status wallet_status DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (owner_id, wallet_type)
);

CREATE TABLE IF NOT EXISTS wallet_transactions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wallet_id INT REFERENCES wallets(id) ON DELETE CASCADE,
    transaction_type transaction_type,
    amount NUMERIC(14,2) NOT NULL,
    target_wallet_id INT REFERENCES wallets(id) ON DELETE SET NULL,
    target_service VARCHAR(50),
    description VARCHAR(255),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS insurance_cards (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    balance NUMERIC(14,2) DEFAULT 0,
    card_number VARCHAR(50) UNIQUE,
    status wallet_status DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS metro_cards (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    balance NUMERIC(14,2) DEFAULT 0,
    card_number VARCHAR(50) UNIQUE,
    status wallet_status DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS card_transactions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    card_id INT NOT NULL,
    card_type VARCHAR(50), -- 'insurance' or 'metro'
    transaction_type card_transaction_type,
    transaction_category transaction_category,
    reference VARCHAR(100),
    amount NUMERIC(12,2) DEFAULT 0,
    description VARCHAR(255),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Traffic domain
CREATE TABLE IF NOT EXISTS intersections (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location geometry(Point,4326)
);

CREATE TABLE IF NOT EXISTS traffic_lights (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    intersection_id INT REFERENCES intersections(id) ON DELETE SET NULL,
    ip_address INET,
    location geometry(Point,4326),
    status INT DEFAULT,
    current_color SMALLINT,
    density_level SMALLINT,
    auto_mode BOOLEAN DEFAULT TRUE,
    last_updated timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS roads (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    start_intersection_id INT REFERENCES intersections(id) ON DELETE SET NULL,
    end_intersection_id INT REFERENCES intersections(id) ON DELETE SET NULL,
    length_meters INT
);

CREATE TABLE IF NOT EXISTS light_requests (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    traffic_light_id INT REFERENCES traffic_lights(id) ON DELETE CASCADE,
    requested_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS vehicles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    current_location geometry(Point,4326),
    vehicle_plate VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS traffic_emergencies (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    accident_location geometry(Point,4326),
    destination_hospital VARCHAR(255),
    status VARCHAR(50),
    ambulance_vehicle_id INT REFERENCES vehicles(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Emergency reports & communication
CREATE TABLE IF NOT EXISTS report_categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS emergency_reports (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    image_url VARCHAR(1024),
    description TEXT,
    location geometry(Point,4326),
    ambulance_service BOOLEAN DEFAULT FALSE,
    level report_level,
    status report_status DEFAULT 'pending',
    report_category_id INT REFERENCES report_categories(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    contact_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS alerts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_id INT REFERENCES emergency_reports(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    status alert_status DEFAULT 'unread',
    location geometry(Point,4326), -- longitude/latitude as Point
    sent_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fcm_token (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sos (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    location geometry(Point,4326), -- longitude/latitude as Point
    status sos_status DEFAULT 'open',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Messaging & conversations
CREATE TABLE IF NOT EXISTS conversations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conversation_name VARCHAR(255),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS conversation_participants (
    conversation_id INT REFERENCES conversations(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conversation_id INT REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id INT REFERENCES users(id) ON DELETE SET NULL,
    message_text TEXT,
    sent_at timestamptz NOT NULL DEFAULT now()
);

-- Air quality & weather
CREATE TABLE IF NOT EXISTS air_quality (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    aqi NUMERIC(6,2),
    pm25 NUMERIC(8,3),
    pm10 NUMERIC(8,3),
    co NUMERIC(8,3),
    no2 NUMERIC(8,3),
    so2 NUMERIC(8,3),
    o3 NUMERIC(8,3),
    category air_quality_category,
    measured_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS weather_data (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_id INT REFERENCES addresses(id) ON DELETE SET NULL,
    temperature NUMERIC(6,2),
    feel_temperature NUMERIC(6,2),
    humidity NUMERIC(6,2),
    wind_speed NUMERIC(6,2),
    wind_direction VARCHAR(50),
    rainfall_probability NUMERIC(5,2),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Transportation & digital cards
CREATE TABLE IF NOT EXISTS digital_cards (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS transportation_vehicle_types (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS routes (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    route_name VARCHAR(255),
    vehicle_type_id INT REFERENCES transportation_vehicle_types(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS stops (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    location geometry(Point,4326)
);

CREATE TABLE IF NOT EXISTS route_stops (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    route_id INT REFERENCES routes(id) ON DELETE CASCADE,
    stop_id INT REFERENCES stops(id) ON DELETE CASCADE,
    stop_order INT,
    travel_time_to_next_stop INT -- minutes
);

CREATE TABLE IF NOT EXISTS transportation_transactions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    card_id INT REFERENCES digital_cards(id) ON DELETE SET NULL,
    route_id INT REFERENCES routes(id) ON DELETE SET NULL,
    amount NUMERIC(12,2),
    status VARCHAR(50),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Apartment

-- Create table: apartment
CREATE TABLE apartment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    phone VARCHAR(10),
    description TEXT,
    rating_id INTEGER,
    electric_price DOUBLE PRECISION,
    water_price DOUBLE PRECISION,
    internet apartment_internet,
    apartment_type apartment_type,
    apartment_location apartment_location,
    address_id INTEGER,
    FOREIGN KEY (address_id) REFERENCES addresses(id)
    FOREIGN KEY (rating_id) REFERENCES rating(id);
);

-- Create table: room
CREATE TABLE room (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(255),
    size VARCHAR(50),
    room_status room_status,
    price_start DOUBLE PRECISION,
    price_end DOUBLE PRECISION,
    apartment_id INTEGER REFERENCES apartment(id)
);

-- Create table: apartment_picture
CREATE TABLE apartment_picture (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    file_path TEXT NOT NULL,
    apartment_id INTEGER NOT NULL REFERENCES apartment(id)
);

-- Create table: rating
CREATE TABLE rating (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    rating DOUBLE PRECISION,
    comment TEXT,
    created_at TIMESTAMPTZ
);

-- Create table: apartment_owner
CREATE TABLE apartment_owner (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    apartment_id INTEGER NOT NULL REFERENCES apartment(id)
);

-- Create table: apartment_booking
CREATE TABLE apartment_booking (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    check_in TIMESTAMPTZ,
    booking_status booking_status DEFAULT 'pending',
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);




-- Waste management
CREATE TABLE IF NOT EXISTS waste_types (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL,
    typical_weight_kg NUMERIC(10,3)
);

CREATE TABLE IF NOT EXISTS waste_event_statistics (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id INT REFERENCES events(id) ON DELETE SET NULL,
    waste_type_id INT REFERENCES waste_types(id) ON DELETE SET NULL,
    collection_date timestamptz,
    total_collection_weight NUMERIC(12,3)
);

CREATE TABLE IF NOT EXISTS power_bi_reports (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    waste_event_statistic_id INT REFERENCES waste_event_statistics(id) ON DELETE SET NULL,
    report_type VARCHAR(255),
    report_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- BI Dim / Fact simplified (star schema)
-- Dimension table for time-related data
CREATE TABLE Dim_Time (
    time_id INT PRIMARY KEY,
    date_actual DATE,
    year_val INT,
    month_val INT,
    day_val INT,
    hour_val INT
);

-- Dimension table for geographical locations
CREATE TABLE Dim_Location (
    location_id INT PRIMARY KEY,
    district VARCHAR(255),
    coordinates GEOMETRY(Point, 4326) -- Using PostGIS for coordinates
);

-- Dimension table for facilities like hospitals or clinics
CREATE TABLE Dim_Facility (
    facility_id INT PRIMARY KEY,
    facility_name VARCHAR(255),
    location_id INT,
    CONSTRAINT fk_location
        FOREIGN KEY(location_id) 
        REFERENCES Dim_Location(location_id)
);

-- Dimension table for different types of waste
CREATE TABLE Dim_Waste_Type (
    waste_type_id INT PRIMARY KEY,
    waste_type_name VARCHAR(255)
);

-- Dimension table for users/authors of reports
CREATE TABLE Dim_User (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    role_string VARCHAR(100)
);

-- Dimension table for report categories
CREATE TABLE Dim_Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255),
    category_description TEXT
);


-- ========= METADATA TABLE =========

-- Table to store metadata about the reports
CREATE TABLE Reports_Metadata (
    report_id INT PRIMARY KEY,
    title_string VARCHAR(255),
    description_string TEXT,
    category_id INT,
    created_by INT,
    last_updated_datetime TIMESTAMP WITH TIME ZONE,
    power_bi_report_id_string VARCHAR(255),
    CONSTRAINT fk_category
        FOREIGN KEY(category_id) 
        REFERENCES Dim_Category(category_id),
    CONSTRAINT fk_created_by
        FOREIGN KEY(created_by) 
        REFERENCES Dim_User(user_id)
);


-- ========= FACT TABLES =========

-- Fact table for traffic data
CREATE TABLE Fact_Traffic (
    traffic_id INT PRIMARY KEY,
    time_id INT,
    location_id INT,
    vehicle_count INT,
    has_accident_flag BOOLEAN,
    density_level_numeric NUMERIC(10, 2),
    CONSTRAINT fk_time
        FOREIGN KEY(time_id) 
        REFERENCES Dim_Time(time_id),
    CONSTRAINT fk_location
        FOREIGN KEY(location_id) 
        REFERENCES Dim_Location(location_id)
);

-- Fact table for waste collection data
CREATE TABLE Fact_Waste (
    waste_id INT PRIMARY KEY,
    time_id INT,
    location_id INT,
    waste_type_id INT,
    collection_weight_kg_numeric NUMERIC(10, 2),
    CONSTRAINT fk_time
        FOREIGN KEY(time_id) 
        REFERENCES Dim_Time(time_id),
    CONSTRAINT fk_location
        FOREIGN KEY(location_id) 
        REFERENCES Dim_Location(location_id),
    CONSTRAINT fk_waste_type
        FOREIGN KEY(waste_type_id) 
        REFERENCES Dim_Waste_Type(waste_type_id)
);

-- Fact table for healthcare metrics
CREATE TABLE Fact_Healthcare (
    health_id INT PRIMARY KEY,
    time_id INT,
    facility_id INT,
    avg_wait_time_minutes_numeric NUMERIC(10, 2),
    bed_occupancy_percent_numeric NUMERIC(5, 2),
    total_revenue_numeric NUMERIC(15, 2),
    CONSTRAINT fk_time
        FOREIGN KEY(time_id) 
        REFERENCES Dim_Time(time_id),
    CONSTRAINT fk_facility
        FOREIGN KEY(facility_id) 
        REFERENCES Dim_Facility(facility_id)
);

-- Fact table for weather data
CREATE TABLE Fact_Weather (
    weather_id INT PRIMARY KEY,
    time_id INT,
    location_id INT,
    avg_aqi_numeric NUMERIC(10, 2),
    max_pm25_numeric NUMERIC(10, 2),
    avg_temperature_numeric NUMERIC(5, 2),
    CONSTRAINT fk_time
        FOREIGN KEY(time_id) 
        REFERENCES Dim_Time(time_id),
    CONSTRAINT fk_location
        FOREIGN KEY(location_id) 
        REFERENCES Dim_Location(location_id)
);

-- Fact table for population data
CREATE TABLE Fact_Population (
    population_id INT PRIMARY KEY,
    time_id INT,
    location_id INT,
    total_population INT,
    population_density_numeric NUMERIC(10, 2),
    median_age_numeric NUMERIC(5, 2),
    CONSTRAINT fk_time
        FOREIGN KEY(time_id) 
        REFERENCES Dim_Time(time_id),
    CONSTRAINT fk_location
        FOREIGN KEY(location_id) 
        REFERENCES Dim_Location(location_id)
);


-- map marker
CREATE TABLE IF NOT EXISTS marker_type (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marker_type_icon VARCHAR(255),
    marker_type_color VARCHAR(255),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS marker (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marker_type_id INT REFERENCES marker_type(id) ON DELETE CASCADE,
    description TEXT,
    location geometry(Point,4326),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexing
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_addresses_location ON addresses USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_facilities_location ON facilities USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_emergency_reports_location ON emergency_reports USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_traffic_lights_location ON traffic_lights USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_events_start_at ON events(start_at);
CREATE INDEX IF NOT EXISTS idx_volunteer_events_start_at ON volunteer_events(start_at);

-- Check constraint and triggers
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS last_login timestamptz;


