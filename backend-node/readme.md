# GradeKeeper API

## Handling Errors
All calls made to the API should return a JSON object with the property `success`

Anything that does not return a 200 (success) status code will return the following:
```
{
  "success": boolean
  "error": string,
  "message": string
}
```
Note: Some errors may also contain a `details` property which can be used for debugging purposes. Those that do will have the prefix `DBG` for the value of `error`.

Programs which implement this API can ignore the `details` property by casting it into a struct which
does not include this. Alternatively, you can create a separate struct which includes it.

`400` errors should be handled by either the program, or passed to the user.

`500` errors indicate a server-side issue and it is unlikely that the client (user or app) can resolve such error.

You may want to notify the user of this error in a manner such as the example below:
```
Server Error

Unable to [desired action] due to a server issue.
Please try again later.
```

## Handling Successful Requests

Successful request will return a JSON object with a unique structure. The return structures are documented below.

## Authentication

Requests which do not accept `api_key` typically require an `internal_id` and its `token` in order to perform the request. You can generate a token which lasts 30 minutes using [user_authenticate](user_authenticate).

If the id-token combination is invalid, a `401` error will be returned.

Applications which implement this API should call `user_authenticate` *once* to retrieve a new token. If that request is successful, API calls which accept a token should no longer return a 401 error under any circumstances.

*Note*: If `user_authenticate` does not return a new token (status code != 200), it is likely that the username and/or password is no longer valid and the user should be prompted to re-enter their credentials.

#### 401 Errors
- `ERR_TOKEN_NOT_AVAILABLE`: A token has not been created for this user.
- `ERR_INVALID_TOKEN`: The token is invalid.
- `ERR_TOKEN_EXPIRED`: Token expired; please renew.

A `500: ERR_TOKEN_VERIFY` error may also be encountered. This likely indicates a serious server-side issue and cannot be handled by the client.

## API Calls

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
- `DBG_ERR_SQL_QUERY`: Unable to perform query.
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
- `DBG_ERR_SQL_QUERY`: Unable to perform query.
- `ERR_RANDSTR_GENERATION`: Unable to generate random string for token.
- `ERR_MULTIPLE_EMAILS`: Multiple accounts exist with the same email.
- `ERR_TOKEN_COUNT`: Abnormal token count (Not 1 or 0).

### create_class

Authenticate a user with the specified credentials.

#### Accepts
```
{
  "internal_id": string,
  "token": string,
  "class_name": string,
  ~opt~ "class_code": string,
  ~opt~ "color": number,
  ~opt~ "weight": number
}
```

#### Returns
```
{
  "success": true (boolean),
  "gradebook": {
    "classes": {
      "[CLASS_ID]": {
        "name": string,
        "code": string,
        "color": number,
        "weight": number,
        "grade_scale": {},
        "categories": {}
      },
      ...
    }
  }
}
```

#### 400 Errors
- `ERR_MISSING_ARGS`: The request is missing required arguments.
- `ERR_EMAIL_NOT_REGISTERED`: The provided email is not registered.
- `ERR_INCORRECT_PASSWORD`: The password is incorrect.

#### 500 Errors
- `DBG_ERR_SQL_QUERY`: Unable to perform query.
- `ERR_TOKEN_VERIFY`: Unable to verify token due to server-side malfunction.
- `ERR_RANDSTR_GENERATION`: Unable to generate random string for class ID.
- `DBG_ERR_USER_EDIT`: Created list, but unable to give user edit permissions.

#### 401 Errors
See [authentication](authentication)
