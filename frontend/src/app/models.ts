export type Student = {
  id?: string;
  name: string;
};

export type Exam = {
  id?: string;
  name: string;
  description: string;
  englishDescription: string;
  credits: number;
};

export type Column = {
  field: string;
  header: string;
};
