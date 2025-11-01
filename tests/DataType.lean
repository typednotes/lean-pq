/-
Test file for PostgreSQL Data Types
Demonstrates that all types from https://www.postgresql.org/docs/current/datatype.html
can be represented as DataType.

This file contains examples showing how to construct each type from Table 8.1
of the PostgreSQL documentation.
-/

import LeanPq.DataType
open DataType

namespace Tests

/-! ## 8.1. Numeric Types -/

/-! ### 8.1.1. Integer Types -/
def test_bigint : DataType := bigint
def test_int8 : DataType := bigint  -- Alias

def test_integer : DataType := integer
def test_int : DataType := integer  -- Alias
def test_int4 : DataType := integer  -- Alias

def test_smallint : DataType := smallint
def test_int2 : DataType := smallint  -- Alias

/-! ### 8.1.2. Arbitrary Precision Numbers -/
def test_numeric : DataType := numeric none none
def test_numeric_10 : DataType := numeric (some 10) none
def test_numeric_10_2 : DataType := numeric (some 10) (some 2)

def test_decimal : DataType := numeric none none  -- Alias for numeric
def test_decimal_5_2 : DataType := numeric (some 5) (some 2)

/-! ### 8.1.3. Floating-Point Types -/
def test_real : DataType := real
def test_float4 : DataType := real  -- Alias

def test_double_precision : DataType := double_precision
def test_float : DataType := double_precision  -- Alias
def test_float8 : DataType := double_precision  -- Alias

/-! ### 8.1.4. Serial Types -/
def test_bigserial : DataType := bigserial
def test_serial8 : DataType := bigserial  -- Alias

def test_serial : DataType := serial
def test_serial4 : DataType := serial  -- Alias

def test_smallserial : DataType := smallserial
def test_serial2 : DataType := smallserial  -- Alias

/-! ## 8.2. Monetary Types -/
def test_money : DataType := money

/-! ## 8.3. Character Types -/
def test_character : DataType := character none
def test_character_10 : DataType := character (some 10)
def test_char : DataType := character none  -- Alias
def test_char_5 : DataType := character (some 5)  -- Alias

def test_character_varying : DataType := character_varying none
def test_character_varying_255 : DataType := character_varying (some 255)
def test_varchar : DataType := character_varying none  -- Alias
def test_varchar_100 : DataType := character_varying (some 100)  -- Alias

def test_text : DataType := text

/-! ## 8.4. Binary Data Types -/
def test_bytea : DataType := bytea

/-! ## 8.5. Date/Time Types -/
def test_date : DataType := date

def test_time : DataType := time none false  -- time without time zone
def test_time_3 : DataType := time (some 3) false  -- time(3) without time zone
def test_time_with_tz : DataType := time none true  -- time with time zone
def test_timetz : DataType := time none true  -- Alias for time with time zone
def test_time_6_with_tz : DataType := time (some 6) true

def test_timestamp : DataType := timestamp none false  -- timestamp without time zone
def test_timestamp_3 : DataType := timestamp (some 3) false
def test_timestamp_with_tz : DataType := timestamp none true  -- timestamp with time zone
def test_timestamptz : DataType := timestamp none true  -- Alias
def test_timestamp_6_with_tz : DataType := timestamp (some 6) true

def test_interval : DataType := interval none none
def test_interval_year : DataType := interval (some "YEAR") none
def test_interval_day_to_second : DataType := interval (some "DAY TO SECOND") none
def test_interval_6 : DataType := interval none (some 6)

/-! ## 8.6. Boolean Type -/
def test_boolean : DataType := boolean
def test_bool : DataType := boolean  -- Alias

/-! ## 8.7. Enumerated Types -/
def test_enum_mood : DataType := enum "mood"
def test_enum_color : DataType := enum "color"
-- Example: CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy')

/-! ## 8.8. Geometric Types -/
def test_point : DataType := point
def test_line : DataType := line
def test_lseg : DataType := lseg
def test_box : DataType := box
def test_path : DataType := path
def test_polygon : DataType := polygon
def test_circle : DataType := circle

/-! ## 8.9. Network Address Types -/
def test_inet : DataType := inet
def test_cidr : DataType := cidr
def test_macaddr : DataType := macaddr
def test_macaddr8 : DataType := macaddr8

/-! ## 8.10. Bit String Types -/
def test_bit : DataType := bit none
def test_bit_5 : DataType := bit (some 5)

def test_bit_varying : DataType := bit_varying none
def test_bit_varying_10 : DataType := bit_varying (some 10)
def test_varbit : DataType := bit_varying none  -- Alias
def test_varbit_20 : DataType := bit_varying (some 20)  -- Alias

/-! ## 8.11. Text Search Types -/
def test_tsvector : DataType := tsvector
def test_tsquery : DataType := tsquery

/-! ## 8.12. UUID Type -/
def test_uuid : DataType := uuid

/-! ## 8.13. XML Type -/
def test_xml : DataType := xml

/-! ## 8.14. JSON Types -/
def test_json : DataType := json
def test_jsonb : DataType := jsonb

/-! ## 8.15. Arrays -/
-- Simple arrays (unspecified size)
def test_integer_array : DataType := array integer none
def test_text_array : DataType := array text none

-- Arrays with specified size
def test_integer_array_3 : DataType := array integer (some 3)
def test_varchar_array_5 : DataType := array (character_varying (some 50)) (some 5)

-- Multidimensional arrays
def test_integer_2d_array : DataType := array (array integer none) none
def test_integer_3x4_array : DataType := array (array integer (some 4)) (some 3)
def test_text_2d_array_10x20 : DataType :=
  array (array text (some 20)) (some 10)

-- 3D arrays
def test_integer_3d_array : DataType :=
  array (array (array integer none) none) none
def test_integer_3d_sized : DataType :=
  array (array (array integer (some 5)) (some 4)) (some 3)

/-! ## 8.16. Composite Types -/
-- Example: CREATE TYPE inventory_item AS (name text, supplier_id integer, price numeric)
def test_inventory_item : DataType :=
  composite "inventory_item" [
    ("name", text),
    ("supplier_id", integer),
    ("price", numeric none none)
  ]

-- Example: CREATE TYPE address AS (street varchar(100), city text, zip char(5))
def test_address : DataType :=
  composite "address" [
    ("street", character_varying (some 100)),
    ("city", text),
    ("zip", character (some 5))
  ]

-- Nested composite types
def test_person : DataType :=
  composite "person" [
    ("name", text),
    ("age", integer),
    ("address", composite "address" [
      ("street", text),
      ("city", text)
    ])
  ]

/-! ## 8.17. Range Types -/
def test_int4range : DataType := int4range
def test_int8range : DataType := int8range
def test_numrange : DataType := numrange
def test_tsrange : DataType := tsrange
def test_tstzrange : DataType := tstzrange
def test_daterange : DataType := daterange

-- Multirange types
def test_int4multirange : DataType := int4multirange
def test_int8multirange : DataType := int8multirange
def test_nummultirange : DataType := nummultirange
def test_tsmultirange : DataType := tsmultirange
def test_tstzmultirange : DataType := tstzmultirange
def test_datemultirange : DataType := datemultirange

/-! ## 8.18. Domain Types -/
-- Example: CREATE DOMAIN email_address AS text CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
def test_email_domain : DataType := domain "email_address"

-- Example: CREATE DOMAIN positive_integer AS integer CHECK (VALUE > 0)
def test_positive_integer : DataType := domain "positive_integer"

-- Example: CREATE DOMAIN us_postal_code AS text CHECK (VALUE ~ '^\d{5}$' OR VALUE ~ '^\d{5}-\d{4}$')
def test_us_postal_code : DataType := domain "us_postal_code"

/-! ## 8.19. Object Identifier Types -/
def test_oid : DataType := oid
def test_regclass : DataType := regclass
def test_regcollation : DataType := regcollation
def test_regconfig : DataType := regconfig
def test_regdictionary : DataType := regdictionary
def test_regnamespace : DataType := regnamespace
def test_regoper : DataType := regoper
def test_regoperator : DataType := regoperator
def test_regproc : DataType := regproc
def test_regprocedure : DataType := regprocedure
def test_regrole : DataType := regrole
def test_regtype : DataType := regtype

/-! ## 8.20. pg_lsn Type -/
def test_pg_lsn : DataType := pg_lsn
def test_pg_snapshot : DataType := pg_snapshot
def test_txid_snapshot : DataType := txid_snapshot  -- Deprecated

/-! ## 8.21. Pseudo-Types -/
def test_any : DataType := any
def test_anyelement : DataType := anyelement
def test_anyarray : DataType := anyarray
def test_anynonarray : DataType := anynonarray
def test_anyenum : DataType := anyenum
def test_anyrange : DataType := anyrange
def test_anymultirange : DataType := anymultirange
def test_anycompatible : DataType := anycompatible
def test_anycompatiblearray : DataType := anycompatiblearray
def test_anycompatiblenonarray : DataType := anycompatiblenonarray
def test_anycompatiblerange : DataType := anycompatiblerange
def test_anycompatiblemultirange : DataType := anycompatiblemultirange
def test_cstring : DataType := cstring
def test_internal : DataType := internal
def test_language_handler : DataType := language_handler
def test_fdw_handler : DataType := fdw_handler
def test_table_am_handler : DataType := table_am_handler
def test_index_am_handler : DataType := index_am_handler
def test_tsm_handler : DataType := tsm_handler
def test_record : DataType := record
def test_trigger : DataType := trigger
def test_event_trigger : DataType := event_trigger
def test_pg_ddl_command : DataType := pg_ddl_command
def test_void : DataType := void
def test_unknown : DataType := unknown

/-! ## Complex Real-World Examples -/

-- Table column types from a typical e-commerce database
def test_product_table_columns : List (String × DataType) := [
  ("id", serial),
  ("sku", character_varying (some 50)),
  ("name", text),
  ("description", text),
  ("price", numeric (some 10) (some 2)),
  ("quantity", integer),
  ("created_at", timestamp (some 6) true),
  ("updated_at", timestamp (some 6) true),
  ("tags", array text none),
  ("metadata", jsonb),
  ("is_active", boolean)
]

-- User table with composite types and arrays
def test_user_table_columns : List (String × DataType) := [
  ("id", bigserial),
  ("email", domain "email_address"),
  ("username", character_varying (some 50)),
  ("password_hash", character (some 60)),
  ("profile_image", bytea),
  ("addresses", array (composite "address" [
    ("street", text),
    ("city", text),
    ("state", character (some 2)),
    ("zip", character (some 10)),
    ("country", character (some 2))
  ]) none),
  ("preferences", jsonb),
  ("ip_address", inet),
  ("last_login", timestamp none true),  -- timestamptz alias
  ("created_at", timestamp none true),  -- timestamptz alias
  ("deleted_at", timestamp none true)  -- Nullable timestamp with time zone
]

-- Geospatial data
def test_location_columns : List (String × DataType) := [
  ("id", serial),
  ("name", text),
  ("coordinates", point),
  ("area", polygon),
  ("boundary", box),
  ("route", path),
  ("radius", circle)
]

-- Financial data with precise numeric types
def test_financial_columns : List (String × DataType) := [
  ("id", bigserial),
  ("account_number", character (some 20)),
  ("balance", numeric (some 19) (some 4)),
  ("currency", character (some 3)),
  ("interest_rate", real),
  ("transaction_date", date),
  ("settlement_timestamp", timestamp (some 6) false),
  ("audit_log", jsonb),
  ("approved_by", regproc),
  ("transaction_ids", array uuid none)
]

-- Network and system monitoring
def test_monitoring_columns : List (String × DataType) := [
  ("id", bigserial),
  ("hostname", text),
  ("ip_address", inet),
  ("network", cidr),
  ("mac_address", macaddr8),
  ("uptime", interval none none),
  ("cpu_usage", real),
  ("memory_bytes", bigint),
  ("disk_usage_json", json),
  ("metrics_jsonb", jsonb),
  ("log_sequence", pg_lsn),
  ("snapshot", pg_snapshot),
  ("collected_at", timestamp none true)  -- timestamptz alias
]

-- Testing arrays of different types
def test_array_variations : List (String × DataType) := [
  ("integers", array integer none),
  ("sized_integers", array integer (some 10)),
  ("matrix_3x3", array (array integer (some 3)) (some 3)),
  ("texts", array text none),
  ("varchars", array (character_varying (some 100)) none),
  ("booleans", array boolean none),
  ("dates", array date none),
  ("timestamps", array (timestamp none true) none),
  ("uuids", array uuid none),
  ("json_array", array jsonb none),
  ("enum_array", array (enum "status") none),
  ("composite_array", array (composite "address" [("city", text)]) none)
]

-- Testing all bit string variations
def test_bit_variations : List (String × DataType) := [
  ("bit_unspec", bit none),
  ("bit_1", bit (some 1)),
  ("bit_8", bit (some 8)),
  ("bit_32", bit (some 32)),
  ("varbit_unspec", bit_varying none),
  ("varbit_64", bit_varying (some 64))
]

/-! ## Verification that Table 8.1 from the documentation is complete -/

-- This section proves that all types from Table 8.1 of the PostgreSQL documentation
-- (https://www.postgresql.org/docs/current/datatype.html) can be represented.

section Table8_1_Coverage
  -- Row 1: bigint
  example : DataType := bigint

  -- Row 2: bigserial
  example : DataType := bigserial

  -- Row 3: bit [(n)]
  example : DataType := bit none
  example : DataType := bit (some 5)

  -- Row 4: bit varying [(n)]
  example : DataType := bit_varying none
  example : DataType := bit_varying (some 10)

  -- Row 5: boolean
  example : DataType := boolean

  -- Row 6: box
  example : DataType := box

  -- Row 7: bytea
  example : DataType := bytea

  -- Row 8: character [(n)]
  example : DataType := character none
  example : DataType := character (some 10)

  -- Row 9: character varying [(n)]
  example : DataType := character_varying none
  example : DataType := character_varying (some 255)

  -- Row 10: cidr
  example : DataType := cidr

  -- Row 11: circle
  example : DataType := circle

  -- Row 12: date
  example : DataType := date

  -- Row 13: double precision
  example : DataType := double_precision

  -- Row 14: inet
  example : DataType := inet

  -- Row 15: integer
  example : DataType := integer

  -- Row 16: interval [fields] [(p)]
  example : DataType := interval none none
  example : DataType := interval (some "YEAR") none
  example : DataType := interval none (some 6)
  example : DataType := interval (some "DAY TO SECOND") (some 3)

  -- Row 17: json
  example : DataType := json

  -- Row 18: jsonb
  example : DataType := jsonb

  -- Row 19: line
  example : DataType := line

  -- Row 20: lseg
  example : DataType := lseg

  -- Row 21: macaddr
  example : DataType := macaddr

  -- Row 22: macaddr8
  example : DataType := macaddr8

  -- Row 23: money
  example : DataType := money

  -- Row 24: numeric [(p, s)]
  example : DataType := numeric none none
  example : DataType := numeric (some 10) none
  example : DataType := numeric (some 10) (some 2)

  -- Row 25: path
  example : DataType := path

  -- Row 26: pg_lsn
  example : DataType := pg_lsn

  -- Row 27: pg_snapshot
  example : DataType := pg_snapshot

  -- Row 28: point
  example : DataType := point

  -- Row 29: polygon
  example : DataType := polygon

  -- Row 30: real
  example : DataType := real

  -- Row 31: smallint
  example : DataType := smallint

  -- Row 32: smallserial
  example : DataType := smallserial

  -- Row 33: serial
  example : DataType := serial

  -- Row 34: text
  example : DataType := text

  -- Row 35: time [(p)] [without time zone]
  example : DataType := time none false
  example : DataType := time (some 6) false

  -- Row 36: time [(p)] with time zone
  example : DataType := time none true
  example : DataType := time (some 6) true

  -- Row 37: timestamp [(p)] [without time zone]
  example : DataType := timestamp none false
  example : DataType := timestamp (some 6) false

  -- Row 38: timestamp [(p)] with time zone
  example : DataType := timestamp none true
  example : DataType := timestamp (some 6) true

  -- Row 39: tsquery
  example : DataType := tsquery

  -- Row 40: tsvector
  example : DataType := tsvector

  -- Row 41: txid_snapshot
  example : DataType := txid_snapshot

  -- Row 42: uuid
  example : DataType := uuid

  -- Row 43: xml
  example : DataType := xml

end Table8_1_Coverage

#check test_inventory_item
#check test_integer_3x4_array
#check test_product_table_columns

end Tests
