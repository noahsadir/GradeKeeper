# Porting API

It's *strongly* recommended to implement or use a library which interacts with the API when developing an application.

GradeKeeper libraries should typically contain 3 components

## 1. Direct API Call Bindings

Make API calls using methods rather than dealing all the nasty post/JSON stuff

The ultimate goal is to make an API call like this:
```
CallBindingLayer.getAssignments(String internalID, String token, String classID, (Bool success, JSON result, ErrorStruct error) => {
  if (success) {
    // do stuff with result (e.g. parsing, formatting, casting to object)
  } else {
    // do stuff with error (e.g. print message, error dialog)
  }
});
```
while hiding all the network-specific stuff behind the scenes.

## 2. Structures
Even if using JavaScript, you'll probably want to define data structures since the API returns fragmented data

This is the JSON guideline I use for my ports
```
{
  "USER_ID_1": {
    "email": string,
    "password": string,
    "internalID": string,
    "tempToken": string,
    "lastFetch": long,
    "courses": {
      "COURSE_ID_1": {
        "className": string,
        "classCode": string,
        "instructor": string,
        "editable": boolean,
        "color": int,
        "weight": double,
        "categories": {
          "name": string,
          "dropCount": int,
          "weight": double,
          "assignmentIDs": ["ASG_ID_1", "ASG_ID_2", ...]
        },
        "gradeScale": {
          "A": {
            "minScore": double,
            "maxScore": double,
            "credit": double
          },
          ...
        }
      },
      "COURSE_ID_1": {
        ...
      },
      ...
    },
    "assignments": {
      "ASG_ID_1": {
        "title": string,
        "description': string,
        "gradeID": string,
        "actScore": double,
        "maxScore": double,
        "weight": double,
        "penalty": double,
        "dueDate": long,
        "assignDate": long,
        "gradedDate": long,
        "modifyDate": long
      },
      "ASG_ID_2": {
        ...
      },
      ...
    },
    "terms": {
      "TERM_ID_1": {
        "title": string,
        "startDate": string,
        "endDate": string,
        "courseIDs": ["COURSE_ID_1", "COURSE_ID_2", ...]
      },
      "TERM_ID_2": {
        ...
      },
      ...
    }
  },
  "USER_ID_2": {
    ...
  },
  ...
}
```

## 3. Library

Using the call bindings and structures, create and manage user data.

These should be the methods called by the UI. This is an example of an add category button action:
```
void addCategoryButtonClicked() {
  Library.createCategory(categoryNameTextField.text, Double(weightTextField.text), Int(dropCount.text));
  updateCategoryList();
}

void updateCategoryList() {
  categoryList.clear();
  StringArray catIDs = Library.userData.class[selectedClassID].categories.keys;
  for (catID in catIDs) {
    categoryList.addItem(Library.userData.class[selectedClassID].categories[catID].name);
  }
}
```
