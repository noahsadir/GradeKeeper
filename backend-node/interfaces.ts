// interfaces.ts
/*
 Copyright (c) 2021-2022 Noah Sadir

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

export interface Credentials {
  host: string;
  user: string;
  password: string;
}

export interface QueryError {
  code: string,
  errno: number,
  sqlMessage: string,
  sqlState: string,
  fatal: boolean
}

/* API Arguments */
export interface CreateUserArgs {
  api_key: string; // required
  email: string; // required
  password: string; // required
}

export interface Timeslot {
  day_of_week: number;
  start_time: number;
  end_time: number;
  start_date: number;
  end_date: number;
  description: string;
  address: string;
}

export interface SetClassScheduleArgs {
  internal_id: string;
  token: string;
  class_id: string;
  timeslots: Timeslot[];
}

export interface GetClassScheduleArgs {
  internal_id: string;
  token: string;
  class_id: string;
}

export interface AuthenticateUserArgs {
  api_key: string; // required
  email: string; // required
  password: string; // required
}

export interface CreateClassArgs {
  internal_id: string; // required
  token: string; // required
  class_name: string; // required
  class_code: string;
  color: number;
  weight: number;
  instructor: string;
  term_id: string;
}

export interface CreateCategoryArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  category_name: string; //required
  drop_count: number;
  weight: number;
}

export interface CreateTermArgs {
  internal_id: string; // required
  token: string; // required
  term_title: string; // required
  start_date: number;
  end_date: number;
}

export interface CreateGradeArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  grade_id: string; // required
  min_score: number; // required
  max_score: number;
  credit: number;
}

export interface CreateAssignmentArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  category_id: string; // required
  title: string;
  description: string;
  grade_id: string;
  act_score: number;
  max_score: number;
  weight: number;
  penalty: number;
  due_date: number;
  assign_date: number;
  graded_date: number;
  modify_date: number;
}

export interface DeleteAssignmentArgs {
  internal_id: string;
  token: string;
  class_id: string;
  assignment_id: string;
}

export interface DeleteCategoryArgs {
  internal_id: string;
  token: string;
  class_id: string;
  category_id: string;
}

export interface DeleteGradeArgs {
  internal_id: string;
  token: string;
  class_id: string;
  grade_id: string;
}

export interface DeleteClassArgs {
  internal_id: string;
  token: string;
  class_id: string;
}

export interface DeleteTermArgs {
  internal_id: string;
  token: string;
  term_id: string;
}

export interface ModifyClassArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string // required
  class_name: string; // required
  class_code: string;
  color: number;
  weight: number;
  instructor: string;
  term_id: string;
}

export interface ModifyCategoryArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  category_id: string; // required
  category_name: string; //required
  drop_count: number;
  weight: number;
}

export interface ModifyTermArgs {
  internal_id: string; // required
  token: string; // required
  term_id: string; // required
  term_title: string; // required
  start_date: number;
  end_date: number;
}


export interface ModifyGradeArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  grade_id: string; // required
  min_score: number; // required
  max_score: number;
  credit: number;
}

export interface ModifyAssignmentArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  category_id: string; // required
  assignment_id: string; // required
  title: string;
  description: string;
  grade_id: string;
  act_score: number;
  max_score: number;
  weight: number;
  penalty: number;
  due_date: number;
  assign_date: number;
  graded_date: number;
  modify_date: number;
}

export interface GetClassesArgs {
  internal_id: string; // required
  token: string; // required
}

export interface GetStructureArgs {
  internal_id: string; // required
  token: string; // required
}

export interface GetAssignmentsArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  ignore_before_date: number;
}

export interface GetTermsArgs {
  internal_id: string;
  token: string;
}

export interface GetLogsArgs {
  api_key: string
}
