# Data Quality Tests

This directory contains custom data quality tests that ensure data integrity, business rule compliance, and overall data reliability across the lottery e-commerce analytics project.

## 🎯 Purpose

- **Data Quality Assurance**: Validate data completeness, accuracy, and consistency
- **Business Rule Enforcement**: Ensure business logic and constraints are maintained
- **Regression Prevention**: Catch data quality issues before they impact downstream models
- **Documentation**: Document expected data behavior and constraints

## 📁 Files

### `assert_purchase_after_signup.sql`
**Purpose**: Business rule test ensuring ticket purchases occur after user signup

**Business Rule**: A player's first ticket purchase cannot occur before their signup timestamp

**Test Logic**:
```sql
-- Find violations where purchase timestamp < signup timestamp
SELECT *
FROM validation 
WHERE invalid_purchase = 1
```

**Expected Result**: 0 rows (no violations)

**Business Impact**: 
- Ensures data integrity for customer journey analysis
- Prevents incorrect attribution and timing calculations
- Maintains logical consistency in user behavior data

## 🧪 Testing Strategy

### Test Categories

#### 1. **Standard dbt Tests**
Located in `schema.yml` files throughout the project:

**Generic Tests**:
- `not_null`: Required fields validation
- `unique`: Primary key constraints
- `relationships`: Foreign key integrity
- `accepted_values`: Domain validation
- `positive_values`: Numeric field validation

**Example Configuration**:
```yaml
columns:
  - name: user_id
    tests:
      - not_null
      - unique
  
  - name: country
    tests:
      - not_null
      - accepted_values:
          values: ['US', 'CA', 'GB', 'DE', 'FR', 'AU']
  
  - name: total_purchases
    tests:
      - not_null
      - positive_values
```

#### 2. **Custom Business Rule Tests**
Located in `tests/` directory:

**Purpose**: Enforce domain-specific business logic that can't be expressed with generic tests

**Examples**:
- Purchase timing validation
- Revenue calculation verification
- Customer segmentation logic
- Attribution rule compliance

#### 3. **Custom Macro Tests**
Located in `macros/` directory:

**Purpose**: Reusable test logic for common validation patterns

**Examples**:
- `non_negative_values`: Validates fields that can be 0
- `date_range_validation`: Ensures dates are within expected ranges
- `percentage_validation`: Validates percentage fields (0-100)

## 📊 Test Coverage

### Current Test Suite: 71 Tests

#### Staging Layer Tests (24 tests)
- **Data Quality**: Field validation, data types, formats
- **Relationships**: Foreign key integrity
- **Business Rules**: Domain-specific validation

#### Intermediate Layer Tests (0 tests)
- **Data Integrity**: Transformation validation
- **Business Logic**: Complex transformation verification

#### Marts Layer Tests (47 tests)
- **Completeness**: All required fields populated
- **Business Rules**: Domain-specific validation
- **Performance**: Query optimization validation

### Test Distribution by Type
```
Standard Tests: 65 tests
├── not_null: 25 tests
├── unique: 7 tests
├── relationships: 4 tests
├── accepted_values: 4 tests
├── positive_values: 25 tests
└── non_negative_values: 4 tests

Custom Tests: 6 tests
├── assert_purchase_after_signup: 1 test
└── Custom macros: 5 tests
```

## 🔧 Test Configuration

### Test Severity Levels
```yaml
# schema.yml
columns:
  - name: user_id
    tests:
      - not_null:
          severity: error  # Fail the run
      - unique:
          severity: error  # Fail the run
      - relationships:
          to: ref('stg_signups')
          field: user_id
          severity: warn   # Warning only
```

### Test Dependencies
```yaml
# dbt_project.yml
tests:
  +store_failures: true      # Store failed test results
  +warn_if: ">10"           # Warn if more than 10 failures
  +error_if: ">100"         # Error if more than 100 failures
```

## 🚀 Running Tests

### Basic Commands
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select model_name

# Run tests for specific layer
dbt test --select staging
dbt test --select marts

# Run specific test
dbt test --select test_name

# Run tests with custom severity
dbt test --severity warn
```

### Test Selection Patterns
```bash
# Run all custom tests
dbt test --select test_type:generic

# Run all custom tests
dbt test --select test_type:singular

# Run tests for specific model and its dependencies
dbt test --select model_name+

# Run tests for specific model and its dependents
dbt test --select +model_name
```

## 📈 Test Results

### Success Criteria
- **All Tests Passing**: 71/71 tests pass
- **No Data Quality Issues**: All business rules satisfied
- **Performance Acceptable**: Tests complete within reasonable time

### Test Output Example
```
23:22:16  Finished running 71 data tests in 0 hours 0 minutes and 0.70 seconds (0.70s).
23:22:16  
23:22:16  Completed successfully
23:22:16  
23:22:16  Done. PASS=71 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=71
```

