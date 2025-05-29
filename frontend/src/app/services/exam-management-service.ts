import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Exam } from '../models';
import { ApiUrl } from '../app.config';

@Injectable({
  providedIn: 'root',
})
export class ExamRegistrationService {
  constructor(private http: HttpClient) {}

  registerExam(studentId: string, examId: string): Observable<void> {
    return this.http.post<void>(`${ApiUrl}/register`, {
      studentId: studentId,
      examId: examId,
    });
  }

  unregisterExam(studentId: string, examId: string): Observable<void> {
    return this.http.delete<void>(`${ApiUrl}/unregister`, {
      body: {
        studentId: studentId,
        examId: examId,
      },
    });
  }

  getRegisteredExams(studentId: string): Observable<Exam[]> {
    return this.http.get<Exam[]>(`${ApiUrl}/registrations/${studentId}`);
  }
}
