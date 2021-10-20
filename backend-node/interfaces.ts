export interface Credentials {
  host: string;
  user: string;
  password: string;
  api_key: string;
}

export interface QueryError {
  code: string,
  errno: number,
  sqlMessage: string,
  sqlState: string,
  fatal: boolean
}

export interface CreateUserArgs {
  api_key: string;
  email: string;
  password: string;
}
