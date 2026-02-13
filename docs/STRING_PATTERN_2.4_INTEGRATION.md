# string_pattern v2.4.0 – integration with NiceHash

Summary of 2.4.0 features and how NiceHash uses or could use them.

## New in string_pattern 2.4.0

| Feature | Description |
|--------|--------------|
| **StringPattern.valid_email?** | Email format validation (same rules as `@` pattern). |
| **StringPattern.analyze** | Returns a Pattern struct (min_length, max_length, symbol_type, etc.); `silent: true` avoids logging. NiceHash already uses `analyze` in pattern_fields, select_key, generate, validate. |
| **StringPattern.uuid** | Generates a random UUID v4. |
| **StringPattern.valid_uuid?** | Validates UUID v4 format. |
| **seed:** | Reproducible generation: `"10:N".gen(seed: 42)`. |
| **StringPattern.sample(pattern, n)** | Generates up to `n` distinct strings (temporary dont_repeat). |
| **StringPattern.valid?** | Boolean validation (no full error list). |
| **raise_on_error** / **logger** | `StringPattern.raise_on_error = true` raises on invalid pattern / impossible generation; `StringPattern.logger` redirects messages. |
| **block_list as Proc** | Custom block with a lambda. |

---

## Implemented in NiceHash

1. **Reproducible generation (seed)**  
   `generate` and `generate_n` accept `seed:` and pass it through to `StringPattern.generate`, so `my_hash.generate(:correct, seed: 42)` and `my_hash.generate_n(5, :correct, seed: 123)` are reproducible.

2. **UUID shorthand**  
   In a pattern hash, use `id: :uuid` (or any key with value `:uuid`) to generate a UUID v4. In `validate`, `:uuid` is accepted and validated with `StringPattern.valid_uuid?`. In `compare_structure`, patterns hash can use `:uuid` to check UUID format.

3. **Configuration**  
   README documents that `StringPattern.logger` and `StringPattern.raise_on_error` affect generation/validation when using NiceHash.

---

## Possible future use

- **StringPattern.valid_email?**  
  Email validation is already covered by the `@` pattern in validate/generate. Could add a shorthand `email: true` or use `valid_email?` in compare_structure patterns for consistency.

- **StringPattern.sample**  
  When generating an array of one pattern (e.g. `user_names: [:'3-10:L']`), could call `StringPattern.sample(pattern, n)` to get distinct values when `expected_errors` is empty.

- **StringPattern.valid?**  
  In `compare_structure`, when checking a single pattern we could use `StringPattern.valid?` instead of `validate(...).empty?` for a small optimization.

- **Pattern metadata**  
  Use `StringPattern.analyze` to expose something like `pattern_fields_with_metadata` (min/max length, symbol_type) for docs or tooling.
