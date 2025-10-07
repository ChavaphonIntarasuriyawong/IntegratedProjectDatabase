# PostGIS Examples

## 1\. Inserting Geographic Data 

The first step is to get location data into your database. PostGIS needs the data in a specific geometric format. The most common way to do this is by creating a `POINT` geometry from longitude and latitude values.

**Goal**: Add a new healthcare facility to the `facilities` table.

The location is at longitude `100.523186` and latitude `13.736717`.

**SQL Query**:

```sql
INSERT INTO facilities (name, facility_type, location, emergency_services)
VALUES (
    'Samut Prakan General Hospital',
    'Hospital',
    -- Create a geometry point and set its Spatial Reference ID to 4326 (WGS 84)
    ST_SetSRID(ST_MakePoint(100.523186, 13.736717), 4326),
    TRUE
);
```

**Explanation**:

  * `ST_MakePoint(longitude, latitude)`: This function creates a point geometry from its X (longitude) and Y (latitude) coordinates. **Always remember the order is longitude, then latitude.**
  * `ST_SetSRID(geometry, srid)`: This function assigns a Spatial Reference Identifier (SRID) to the geometry. Your schema correctly specifies SRID `4326`, which is the standard for GPS coordinates (WGS 84). **This step is critical for ensuring your data is correctly interpreted on a map.**

-----

## 2\. Finding Nearby Objects (Proximity Search) 

This is the most common and powerful use of PostGIS. You can efficiently find all points within a certain distance of another point.

**Goal**: An emergency is reported at a specific location. Find all available ambulances within a 2-kilometer radius.

**SQL Query**:

```sql
-- First, let's get the location of a specific emergency report
-- We'll assume the report with id = 50 has just been created.
-- In a real app, you would get this location from the new report.
-- For this example, let's pretend it's at POINT(100.53 13.74)

SELECT
    a.id AS ambulance_id,
    a.vehicle_number,
    -- Calculate the precise distance for display (optional but useful)
    ST_Distance(
        a.current_location::geography,
        (SELECT location FROM emergency_reports WHERE id = 50)::geography
    ) AS distance_in_meters
FROM
    ambulances AS a
WHERE
    -- Use ST_DWithin for an efficient, index-powered search
    ST_DWithin(
        a.current_location::geography, -- Location of each ambulance
        (SELECT location FROM emergency_reports WHERE id = 50)::geography, -- The emergency location
        2000 -- The distance in meters (2km)
    )
    AND a.status = 'available'; -- And the ambulance is available
```

**Explanation**:

  * `ST_DWithin(geom1, geom2, distance)`: This is the **most important function for proximity searches**. It checks if two geometries are within a specified distance of each other. It's highly optimized and uses the spatial index (`idx_ambulances_current_location`), making it much faster than calculating the distance for every row.
  * `::geography`: This is a PostgreSQL type cast. When you cast a `geometry` to a `geography`, PostGIS performs calculations on a spheroid (like the Earth), giving you highly accurate results in **meters**. If you don't cast, the distance unit would be in abstract "degrees," which is not useful for real-world distances.

-----

## 3\. Finding the Closest Object (K-Nearest Neighbor) 

Sometimes you don't need everything within a radius; you just need the single closest one.

**Goal**: A user sends an SOS request. Find the single closest hospital with emergency services.

**SQL Query**:

```sql
-- Assume the SOS call with id = 101 is the one we're responding to.
SELECT
    f.name AS facility_name,
    f.phone,
    ST_Distance(
      f.location::geography,
      (SELECT location FROM sos WHERE id = 101)::geography
    ) / 1000 AS distance_km
FROM
    facilities AS f
WHERE
    f.emergency_services = TRUE
ORDER BY
    -- The <-> operator finds the distance between two geometries.
    -- When used in ORDER BY, it's highly optimized for finding the nearest neighbors.
    f.location <-> (SELECT location FROM sos WHERE id = 101)
LIMIT 1; -- We only want the closest one
```

**Explanation**:

  * `<->`: This is the **K-Nearest Neighbor (KNN) distance operator**. When used in an `ORDER BY` clause with a `LIMIT`, it allows PostgreSQL to use the spatial index to very quickly find the closest N items without checking every row in the table. It's the most efficient way to answer "which one is closest?".
  * `ST_Distance(...)`: We still use `ST_Distance` in the `SELECT` clause to display the actual distance in a human-readable format (like kilometers). The `<->` operator in the `ORDER BY` clause handles the efficient sorting.

-----

## 4\. Retrieving and Formatting Geospatial Data 

When you send location data to a front-end application (like a web map), you often need it in a standard format like GeoJSON or simply as separate latitude/longitude numbers.

**Goal**: Get the address details and location for a user's profile, formatted for an API response.

**SQL Query**:

```sql
SELECT
    up.first_name,
    a.address_line,
    -- ST_AsGeoJSON: Converts the geometry into the standard GeoJSON format
    ST_AsGeoJSON(a.location) AS location_geojson,

    -- ST_X and ST_Y: Extract the raw longitude and latitude values
    ST_X(a.location) AS longitude,
    ST_Y(a.location) AS latitude,

    -- ST_AsText: A simple text representation (e.g., 'POINT(100.5 13.7)')
    ST_AsText(a.location) AS location_wkt
FROM
    user_profiles AS up
JOIN
    addresses AS a ON up.address_id = a.id
WHERE
    up.user_id = 25; -- For a specific user
```

**Explanation**:

  * `ST_AsGeoJSON(geometry)`: This is extremely useful for web development. It produces a JSON string that JavaScript mapping libraries (like Leaflet, Mapbox, or Google Maps API) can directly understand and plot on a map.
  * `ST_X(point)` and `ST_Y(point)`: These functions extract the longitude (X) and latitude (Y) values from a point geometry, which is useful if your application needs them as separate numbers.
  * `ST_AsText(geometry)`: Provides the Well-Known Text (WKT) representation of the geometry. It's great for debugging or logging.
