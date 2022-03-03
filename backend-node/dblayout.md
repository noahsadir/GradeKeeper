# Database Layout

## api_keys
Field   | Type        | Null | Key | Default | Extra |
------- | ----------- | ---- | --- | ------- | ----- |
id      | int         | NO   | PRI | NULL    | AI    |
api_key | varchar(32) | NO   |     | NULL    |       |

## categories

Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
class_id      | varchar(16)   | NO   |     | NULL    |       |
category_name | varchar(32)   | NO   |     | NULL    |       |
weight        | decimal(10,2) | YES  |     | NULL    |       |
drop_count    | int           | YES  |     | NULL    |       |
category_id   | varchar(16)   | NO   |     | NULL    |       |

## classes
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
class_id      | varchar(16)   | NO   |     | NULL    |       |
class_name    | varchar(255)  | NO   |     | NULL    |       |
class_code    | varchar(16)   | YES  |     | NULL    |       |
color         | int           | YES  |     | NULL    |       |
weight        | decimal(10,2) | YES  |     | NULL    |       |
instructor    | text          | YES  |     | NULL    |       |
term_id       | varchar(16)   | YES  |     | NULL    |       |

## grade_scales
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
class_id      | varchar(16)   | NO   |     | NULL    |       |
grade_id      | varchar(8)    | NO   |     | NULL    |       |
min_score     | decimal(10,2) | NO   |     | NULL    |       |
max_score     | decimal(10,2) | YES  |     | NULL    |       |
credit        | decimal(10,2) | NO   |     | NULL    |       |

## items (assignments)
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
class_id      | varchar(16)   | NO   |     | NULL    |       |
category_id   | varchar(16)   | NO   |     | NULL    |       |
assignment_id | varchar(16)   | NO   |     | NULL    |       |
title         | varchar(64)   | YES  |     | NULL    |       |
description   | varchar(512)  | YES  |     | NULL    |       |
grade_id      | varchar(8)    | YES  |     | NULL    |       |
act_score     | decimal(10,2) | YES  |     | NULL    |       |
max_score     | decimal(10,2) | YES  |     | NULL    |       |
weight        | decimal(10,2) | YES  |     | NULL    |       |
penalty       | decimal(10,2) | YES  |     | NULL    |       |
due_date      | bigint        | YES  |     | NULL    |       |
assign_date   | bigint        | YES  |     | NULL    |       |
graded_date   | bigint        | YES  |     | NULL    |       |
modify_date   | bigint        | NO   |     | NULL    |       |

## terms
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
internal_id   | varchar(16)   | NO   |     | NULL    |       |
term_id       | varchar(16)   | NO   |     | NULL    |       |
title         | varchar(64)   | NO   |     | NULL    |       |
start_date    | bigint        | YES  |     | NULL    |       |
end_date      | bigint        | YES  |     | NULL    |       |

## edit_permissions
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
internal_id   | varchar(16)   | NO   |     | NULL    |       |
class_id      | varchar(16)   | NO   |     | NULL    |       |

## view_permissions
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
internal_id   | varchar(16)   | NO   |     | NULL    |       |
class_id      | varchar(16)   | NO   |     | NULL    |       |

## logins
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
email         | varchar(330)  | NO   |     | NULL    |       |
password      | varchar(256)  | NO   |     | NULL    |       |
internal_id   | varchar(16)   | NO   |     | NULL    |       |

## tokens
Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
internal_id   | varchar(16)   | NO   |     | NULL    |       |
token         | varchar(64)   | NO   |     | NULL    |       |
expiration    | bigint        | YES  |     | NULL    |       |
