import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { TableModule } from 'primeng/table';
import { Toast } from 'primeng/toast';
import { MessageService } from 'primeng/api';
import { Column, Exam, Student } from '../../models';
import { ExamService } from '../../services/exam-service';
import { ExamRegistrationService } from '../../services/exam-management-service';
import { forkJoin } from 'rxjs';

type ExamExtended = Exam & {
  isRegistered: boolean;
};

@Component({
  selector: 'app-manage',
  imports: [TableModule, CommonModule, ButtonModule, Toast],
  templateUrl: './manage.html',
  styleUrl: './manage.scss',
  providers: [ExamService, ExamRegistrationService, MessageService],
})
export class Manage {
  exams!: ExamExtended[];

  columns: Column[] = [
    { field: 'name', header: 'Name' },
    { field: 'description', header: 'Description' },
    { field: 'englishDescription', header: 'Translation' },
    { field: 'credits', header: 'Credits' },
  ];

  student!: Student;

  constructor(
    private examService: ExamService,
    private examRegistrationService: ExamRegistrationService,
    private messageService: MessageService,
  ) {}

  ngOnInit(): void {
    const storedStudent = localStorage.getItem('student');
    if (!storedStudent) return;
    this.student = JSON.parse(storedStudent);

    forkJoin({
      allExams: this.examService.getExams(),
      registeredExams: this.examRegistrationService.getRegisteredExams(this.student.id ?? 'invalid'),
    }).subscribe((result) => {
      this.exams = result.allExams.map((exam) => ({
        ...exam,
        isRegistered: result.registeredExams.some((registeredExam) => registeredExam.id === exam.id),
      }));
      this.exams.sort((a, b) => Number(b.isRegistered) - Number(a.isRegistered));
    });
  }

  registerExam(examExtended: ExamExtended) {
    if (!this.student.id || !examExtended.id) return;
    this.examRegistrationService.registerExam(this.student.id, examExtended.id).subscribe(() => {
      this.exams = this.exams.map((exam) => {
        if (exam.id === examExtended.id) {
          exam.isRegistered = true;
        }
        this.messageService.clear();
        this.messageService.add({
          severity: 'success',
          summary: 'Success',
          detail: `Erfolgreich für die Prüfung ${exam.name} angemeldet`,
        });
        return exam;
      });
    });
  }

  unregisterExam(examExtended: ExamExtended) {
    if (!this.student.id || !examExtended.id) return;
    this.examRegistrationService.unregisterExam(this.student.id, examExtended.id).subscribe(() => {
      this.exams = this.exams.map((exam) => {
        if (exam.id === examExtended.id) {
          exam.isRegistered = false;
        }
        this.messageService.clear();
        this.messageService.add({
          severity: 'success',
          summary: 'Success',
          detail: `Erfolgreich von der Prüfung ${exam.name} abgemeldet`,
        });
        return exam;
      });
    });
  }
}
