import { Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';

import { StudentService } from '../../services/student-service';
import { FormsModule } from '@angular/forms';
import { Student } from '../../models';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  imports: [FormsModule, ButtonModule, InputTextModule, SelectModule],
  templateUrl: './login.html',
  styleUrl: './login.scss',
})
export class Login {
  constructor(
    private studentService: StudentService,
    private router: Router,
  ) {
    this.studentService
      .getStudents()
      .subscribe((students) => (this.students = students));
  }

  studentName: string = '';

  selectedStudent: Student | undefined;
  students: Student[] = [];

  onLoginClick() {
    this.router.navigate(['/home'], { state: this.selectedStudent });
  }

  onRegisterClick() {
    this.studentService
      .createStudent({ name: this.studentName })
      .subscribe((student) =>
        this.router.navigate(['/home'], { state: student }),
      );
  }
}
