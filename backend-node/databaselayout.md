# Database Layout

* Required

## logins

id  | internal_id | email        | password     |
--- | ----------- | ------------ | ------------ |
int* | varchar(16)* | varchar(512)* | varchar(255)* |

## tokens

id  | internal_id | token       | expiration |
--- | ----------- | ----------- | ---------- |
int* | varchar(16)* | varchar(64)* | bigint*     |

## edit_permissions

id  | internal_id | class_id    |
--- | ----------- | ----------- |
int* | varchar(16)* | varchar(16)* |

## classes

id  | class_id    | class_name   | class_code  | color | weight |
--- | ----------- | ------------ | ----------- | ----- | ------ |
int* | varchar(16)* | varchar(255)* | varchar(16) | int   | decimal    |

## grade_scales

id  | class_id    | grade_id   | min_score | max_score | credit |
--- | ----------- | ---------- | --------- | --------- | ------ |
int* | varchar(16)* | varchar(8) | decimal       | decimal       | decimal    |

## categories

id   | class_id     | category_name  | weight |
---- | ------------ | -------------- | ------ |
int* | varchar(16)* | varchar(32)*   | decimal    |

## item

id   | class_id     | category_name  | item_id      | item_title  | item_description  | grade_id   | act_score | max_score | credit |
---- | ------------ | -------------- | ------------ | ----------- | ----------------- | ---------- | --------- | --------- | ------ |
int* | varchar(16)* | varchar(32)*   | varchar(16)* | varchar(64)* | varchar(512)     | varchar(8) | decimal       | decimal       | decimal    |
