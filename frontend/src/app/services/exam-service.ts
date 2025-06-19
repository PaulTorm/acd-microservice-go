import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Exam } from '../models';
import { ApiUrl } from '../app.config';

@Injectable({
  providedIn: 'root',
})
export class ExamService {
  constructor(private http: HttpClient) {}

  createExam(exam: Exam): Observable<Exam> {
    return this.http.post<Exam>(`${ApiUrl}/exams`, exam);
  }

  getExams(): Observable<Exam[]> {
    return this.http.get<Exam[]>(`${ApiUrl}/exams`);
  }

  getExam(id: string): Observable<Exam> {
    return this.http.get<Exam>(`${ApiUrl}/exams/${id}`);
  }

  updateExam(id: string, exam: Exam): Observable<void> {
    return this.http.patch<void>(`${ApiUrl}/exams/${id}`, exam);
  }

  deleteExam(id: string): Observable<void> {
    return this.http.delete<void>(`${ApiUrl}/exams/${id}`);
  }
}
