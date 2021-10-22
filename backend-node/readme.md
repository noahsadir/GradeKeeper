# GradeKeeper API

### create_user

Create a new user with the specified credentials.

#### Accepts
```
{
  "api_key": string,
  "email": string,
  "password": string
}
```

#### Returns
```
{
  "success": true (boolean),
  "message": "Successfully generated user!" (string)
}
```

#### 400 Errors
- `ERR_MISSING_ARGS`: The request is missing required arguments.
- `ERR_INVALID_API_KEY`: The API Key is invalid.
- `ERR_EMAIL_REGISTERED`: The provided email is already registered.
- `ERR_INVALID_EMAIL`: The provided email is invalid.
- `ERR_INSECURE_PASSWORD`: The password must be at least 8 characters and contain at least one uppercase and lowercase letter, one number, and one special character.

#### 500 Errors
- `ERR_SQL_QUERY`: Unable to perform query.
- `ERR_RANDSTR_GENERATION`: Unable to generate random string for internal ID.
- `ERR_PASSWORD_HASH`: Unable to hash password.
- `ERR_DATABASE_INSERT`: Unable to store user in database.

### authenticate_user

Authenticate a user with the specified credentials.

#### Accepts
```
{
  "api_key": string,
  "email": string,
  "password": string
}
```

#### Returns
```
{
  "success": true (boolean),
  "internal_id": string,
  "token": string
}
```

#### 400 Errors
- `ERR_MISSING_ARGS`: The request is missing required arguments.
- `ERR_INVALID_API_KEY`: The API Key is invalid.
- `ERR_EMAIL_NOT_REGISTERED`: The provided email is not registered.
- `ERR_INCORRECT_PASSWORD`: The password is incorrect.

#### 500 Errors
- `ERR_SQL_QUERY`: Unable to perform query.
- `ERR_RANDSTR_GENERATION`: Unable to generate random string for token.
- `ERR_MULTIPLE_EMAILS`: Multiple accounts exist with the same email (that shouldn't happen)
- `ERR_TOKEN_COUNT`: Abnormal token count (Not 1 or 0).
