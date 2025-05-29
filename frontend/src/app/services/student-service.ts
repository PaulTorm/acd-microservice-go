import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Student } from '../models';
import { ApiUrl } from '../app.config';

@Injectable({
  providedIn: 'root',
})
export class StudentService {
  constructor(private http: HttpClient) {}

  createStudent(student: Student): Observable<Student> {
    return this.http.post<Student>(`${ApiUrl}/students`, student);
  }

  getStudents(): Observable<Student[]> {
    return this.http.get<Student[]>(`${ApiUrl}/students`);
  }

  getStudent(id: string): Observable<Student> {
    return this.http.get<Student>(`${ApiUrl}/students/${id}`);
  }

  updateStudent(id: string, student: Student): Observable<void> {
    return this.http.patch<void>(`${ApiUrl}/students/${id}`, student);
  }

  deleteStudent(id: string): Observable<void> {
    return this.http.delete<void>(`${ApiUrl}/students/${id}`);
  }
}
