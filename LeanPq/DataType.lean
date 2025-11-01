/-
PostgreSQL Data Types
Based on: https://www.postgresql.org/docs/current/datatype.html
Organized by subsections following Chapter 8 structure.
-/

inductive DataType where

  -- 8.1. Numeric Types
  -- 8.1.1. Integer Types
  | smallint : DataType
    -- Alias: int2
    -- signed two-byte integer

  | integer : DataType
    -- Aliases: int, int4
    -- signed four-byte integer

  | bigint : DataType
    -- Alias: int8
    -- signed eight-byte integer

  -- 8.1.2. Arbitrary Precision Numbers
  | numeric : Option Nat → Option Nat → DataType
    -- Alias: decimal [(p, s)]
    -- exact numeric of selectable precision
    -- p is precision (total digits), s is scale (decimal digits)

  -- 8.1.3. Floating-Point Types
  | real : DataType
    -- Alias: float4
    -- single precision floating-point number (4 bytes)

  | double_precision : DataType
    -- Aliases: float, float8
    -- double precision floating-point number (8 bytes)

  -- 8.1.4. Serial Types
  | smallserial : DataType
    -- Alias: serial2
    -- autoincrementing two-byte integer

  | serial : DataType
    -- Alias: serial4
    -- autoincrementing four-byte integer

  | bigserial : DataType
    -- Alias: serial8
    -- autoincrementing eight-byte integer

  -- 8.2. Monetary Types
  | money : DataType
    -- currency amount

  -- 8.3. Character Types
  | character : Option Nat → DataType
    -- Alias: char [(n)]
    -- fixed-length character string

  | character_varying : Option Nat → DataType
    -- Alias: varchar [(n)]
    -- variable-length character string

  | text : DataType
    -- variable-length character string

  -- 8.4. Binary Data Types
  | bytea : DataType
    -- binary data ("byte array")

  -- 8.5. Date/Time Types
  | date : DataType
    -- calendar date (year, month, day)

  | time : Option Nat → Bool → DataType
    -- time [(p)] [without time zone] or time [(p)] with time zone
    -- p is precision for seconds
    -- Bool: false = without time zone, true = with time zone (timetz)

  | timestamp : Option Nat → Bool → DataType
    -- timestamp [(p)] [without time zone] or timestamp [(p)] with time zone
    -- p is precision for seconds
    -- Bool: false = without time zone, true = with time zone (timestamptz)

  | interval : Option String → Option Nat → DataType
    -- interval [fields] [(p)]
    -- time span
    -- fields can be: YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, etc.
    -- p is precision for seconds

  -- 8.6. Boolean Type
  | boolean : DataType
    -- Alias: bool
    -- logical Boolean (true/false)

  -- 8.7. Enumerated Types
  | enum : String → DataType
    -- User-defined enumerated type
    -- The String parameter is the name of the enum type
    -- Enums are created with CREATE TYPE ... AS ENUM
    -- Example: enum "mood" represents an enum like CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy')

  -- 8.8. Geometric Types
  | point : DataType
    -- geometric point on a plane

  | line : DataType
    -- infinite line on a plane

  | lseg : DataType
    -- line segment on a plane

  | box : DataType
    -- rectangular box on a plane

  | path : DataType
    -- geometric path on a plane

  | polygon : DataType
    -- closed geometric path on a plane

  | circle : DataType
    -- circle on a plane

  -- 8.9. Network Address Types
  | inet : DataType
    -- IPv4 or IPv6 host address

  | cidr : DataType
    -- IPv4 or IPv6 network address

  | macaddr : DataType
    -- MAC (Media Access Control) address

  | macaddr8 : DataType
    -- MAC (Media Access Control) address (EUI-64 format)

  -- 8.10. Bit String Types
  | bit : Option Nat → DataType
    -- bit [(n)]
    -- fixed-length bit string

  | bit_varying : Option Nat → DataType
    -- Alias: varbit [(n)]
    -- variable-length bit string

  -- 8.11. Text Search Types
  | tsvector : DataType
    -- text search document

  | tsquery : DataType
    -- text search query

  -- 8.12. UUID Type
  | uuid : DataType
    -- universally unique identifier

  -- 8.13. XML Type
  | xml : DataType
    -- XML data

  -- 8.14. JSON Types
  | json : DataType
    -- textual JSON data

  | jsonb : DataType
    -- binary JSON data, decomposed

  -- 8.15. Arrays
  | array : DataType → Option Nat → DataType
    -- Array of any data type with optional dimension size
    -- First parameter: element type (can be another array for multidimensional arrays)
    -- Second parameter: optional dimension size
    -- Example: array integer none represents integer[]
    -- Example: array integer (some 3) represents integer[3]
    -- Example: array (array integer (some 4)) (some 3) represents integer[3][4]
    -- Example: array (array integer none) none represents integer[][]
    -- Note: PostgreSQL doesn't enforce array size constraints, but allows declaring them

  -- 8.16. Composite Types
  | composite : String → List (String × DataType) → DataType
    -- User-defined composite type (record type)
    -- First parameter: name of the composite type
    -- Second parameter: list of (field_name, field_type) pairs
    -- Composite types are created with CREATE TYPE ... AS (...)
    -- Example: composite "inventory_item" [("name", text), ("supplier_id", integer), ("price", numeric none none)]

  -- 8.17. Range Types
  | int4range : DataType
    -- Range of integer

  | int8range : DataType
    -- Range of bigint

  | numrange : DataType
    -- Range of numeric

  | tsrange : DataType
    -- Range of timestamp without time zone

  | tstzrange : DataType
    -- Range of timestamp with time zone

  | daterange : DataType
    -- Range of date

  | int4multirange : DataType
    -- Multirange of integer

  | int8multirange : DataType
    -- Multirange of bigint

  | nummultirange : DataType
    -- Multirange of numeric

  | tsmultirange : DataType
    -- Multirange of timestamp without time zone

  | tstzmultirange : DataType
    -- Multirange of timestamp with time zone

  | datemultirange : DataType
    -- Multirange of date

  -- 8.18. Domain Types
  | domain : String → DataType
    -- User-defined domain type (constrained base type)
    -- The String parameter is the name of the domain type
    -- Domains are created with CREATE DOMAIN and add constraints to base types
    -- Example: domain "email_address" represents a domain created with CREATE DOMAIN

  -- 8.19. Object Identifier Types
  | oid : DataType
    -- Object identifier

  | regclass : DataType
    -- Registered class (relation name)

  | regcollation : DataType
    -- Registered collation

  | regconfig : DataType
    -- Registered text search configuration

  | regdictionary : DataType
    -- Registered text search dictionary

  | regnamespace : DataType
    -- Registered namespace

  | regoper : DataType
    -- Registered operator

  | regoperator : DataType
    -- Registered operator with argument types

  | regproc : DataType
    -- Registered procedure (function name)

  | regprocedure : DataType
    -- Registered procedure with argument types

  | regrole : DataType
    -- Registered role

  | regtype : DataType
    -- Registered type

  -- 8.20. pg_lsn Type
  | pg_lsn : DataType
    -- PostgreSQL Log Sequence Number

  | pg_snapshot : DataType
    -- user-level transaction ID snapshot

  | txid_snapshot : DataType
    -- user-level transaction ID snapshot (deprecated; see pg_snapshot)

  -- 8.21. Pseudo-Types
  | any : DataType
    -- indicates a function accepts any input data type

  | anyelement : DataType
    -- indicates a function accepts any data type

  | anyarray : DataType
    -- indicates a function accepts any array data type

  | anynonarray : DataType
    -- indicates a function accepts any non-array data type

  | anyenum : DataType
    -- indicates a function accepts any enum data type

  | anyrange : DataType
    -- indicates a function accepts any range data type

  | anymultirange : DataType
    -- indicates a function accepts any multirange data type

  | anycompatible : DataType
    -- indicates a function accepts any data type, with automatic promotion

  | anycompatiblearray : DataType
    -- like anycompatible, but for arrays

  | anycompatiblenonarray : DataType
    -- like anycompatible, but for non-arrays

  | anycompatiblerange : DataType
    -- like anycompatible, but for ranges

  | anycompatiblemultirange : DataType
    -- like anycompatible, but for multiranges

  | cstring : DataType
    -- indicates a function accepts or returns a null-terminated C string

  | internal : DataType
    -- indicates a function accepts or returns a server-internal data type

  | language_handler : DataType
    -- procedural language call handler

  | fdw_handler : DataType
    -- foreign-data wrapper handler

  | table_am_handler : DataType
    -- table access method handler

  | index_am_handler : DataType
    -- index access method handler

  | tsm_handler : DataType
    -- tablesample method handler

  | record : DataType
    -- identifies a function taking or returning an unspecified row type

  | trigger : DataType
    -- trigger function return type

  | event_trigger : DataType
    -- event trigger function return type

  | pg_ddl_command : DataType
    -- identifies a DDL command event trigger

  | void : DataType
    -- indicates a function returns no value

  | unknown : DataType
    -- identifies a not-yet-resolved type
