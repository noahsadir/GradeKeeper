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
}

export interface CreateCategoryArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  category_name: string; //required
  drop_count: number;
  weight: number;
}

export interface CreateGradeArgs {
  internal_id: string; // required
  token: string; // required
  class_id: string; // required
  grade_id: string; // required
  min_score: number;
  max_score: number;
  credit: number;
}

export interface GetClassesArgs {
  internal_id: string; // required
  token: string; // required
}

export interface GetStructureArgs {
  internal_id: string; // required
  token: string; // required
}

export interface GetLogsArgs {
  api_key: string
}

/* Gradebook Objects */

export interface Grade {
  id: string;
  min_score: number;
  max_score: number;
  credit: number;
}

export interface Assignment {
  title: string;
  description: string;
  grade_id: string;
  act_score: number;
  max_score: number;
  penalty: number;
  weight: number;
  assign_date: number;
  due_date: number;
  graded_date: number;
}

export interface Category {
  name: string;
  weight: number;
  drop_count: number;
  assignments: any;
}

export interface Class {
  name: string;
  code: string;
  color: number;
  grade_scale: Grade[];
  categories: any;
}

export interface Gradebook {
  classes: any;
}
