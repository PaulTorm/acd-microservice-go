import { Component, OnInit } from '@angular/core';
import { TableModule } from 'primeng/table';
import { Dialog } from 'primeng/dialog'
import { Column, Exam } from '../../models';
import { ExamService } from '../../services/exam-service';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumberModule } from 'primeng/inputnumber';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-exams',
  imports: [TableModule, CommonModule, ButtonModule, Dialog, InputTextModule, InputNumberModule, FormsModule],
  templateUrl: './exams.html',
  styleUrl: './exams.scss',
  providers: [ExamService],
})
export class Exams implements OnInit {
  exams!: Exam[];

  columns: Column[] = [
    { field: 'id', header: 'ID' },
    { field: 'name', header: 'Name' },
    { field: 'description', header: 'Description' },
    { field: 'englishDescription', header: 'Translation' },
    { field: 'credits', header: 'Credits' }
  ];

  dialogVisible: boolean = false;

  nameInput: string = '';
  descriptionInput: string = '';
  translationInput: string = '';
  creditsInput: number = 0;

  constructor(private examService: ExamService) { }

  ngOnInit(): void {
    this.examService.getExams().subscribe(exams => this.exams = exams);
  }

  deleteExam(id: string) {
    this.examService.deleteExam(id).subscribe(() => {
      this.exams = this.exams.filter(exam => exam.id === id);
    })
  }

  cancel() {
    this.reset();
  }

  save() {
    this.examService.createExam({
      name: this.nameInput,
      description: this.descriptionInput,
      englishDescription: this.translationInput,
      credits: this.creditsInput
    }).subscribe(exam => {
      this.exams = [...this.exams, exam];
      this.reset();
    });
  }

  reset() {
    this.toggleDialog();

    this.nameInput = '';
    this.descriptionInput = '';
    this.translationInput = '';
    this.creditsInput = 0;
  }

  toggleDialog() {
    this.dialogVisible = !this.dialogVisible;
  }
}
