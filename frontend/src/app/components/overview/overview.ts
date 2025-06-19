import { Component, OnInit } from '@angular/core';
import { Column, Exam, Student } from '../../models';
import { TableModule } from 'primeng/table';
import { CommonModule } from '@angular/common';
import { ExamRegistrationService } from '../../services/exam-management-service';

@Component({
  selector: 'app-overview',
  imports: [TableModule, CommonModule],
  templateUrl: './overview.html',
  styleUrl: './overview.scss',
  providers: [ExamRegistrationService],
})
export class Overview implements OnInit {
  exams!: Exam[];

  columns: Column[] = [
    { field: 'name', header: 'Name' },
    { field: 'description', header: 'Description' },
    { field: 'englishDescription', header: 'Translation' },
    { field: 'credits', header: 'Credits' },
  ];

  constructor(private examRegistrationService: ExamRegistrationService) {}

  ngOnInit(): void {
    const storedStudent = localStorage.getItem('student');
    if (!storedStudent) return;
    const student: Student = JSON.parse(storedStudent);
    this.examRegistrationService.getRegisteredExams(student.id ?? 'invalid').subscribe((exams) => (this.exams = exams));
  }
}
