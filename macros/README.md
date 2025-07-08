# Macros

Reusable SQL components for the lottery e-commerce analytics project.

## Files

### `test_non_negative_values.sql`
Custom test macro for validating fields that can be 0 but not negative.

**Usage**:
```yaml
# schema.yml
columns:
  - name: total_web_events
    tests:
      - non_negative_values
```

### `display_results.sql`, `query_results.sql`, `show_results.sql`
Utility macros for displaying and querying results.

## Usage

Macros provide consistent, maintainable data transformations across models. Use them to:
- Avoid code duplication
- Ensure uniform business logic
- Simplify complex SQL operations 