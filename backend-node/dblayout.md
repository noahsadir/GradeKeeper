# Database Layout

## api_keys
Field   | Type        | Null | Key | Default | Extra |
------- | ----------- | ---- | --- | ------- | ----- |
id      | int         | NO   | PRI | NULL    | AI    |
api_key | varchar(32) | NO   |     | NULL    |       |

# categories

Field         | Type          | Null | Key | Default | Extra |
------------- | ------------- | ---- | --- | ------- | ----- |
id            | int           | NO   | PRI | NULL    | AI    |
class_id      | varchar(16)   | NO   |     | NULL    |       |
category_name | varchar(32)   | NO   |     | NULL    |       |
weight        | decimal(10,2) | YES  |     | NULL    |       |
drop_count    | int           | YES  |     | NULL    |       |
category_id   | varchar(16)   | NO   |     | NULL    |       |
