import { Routes } from '@angular/router';
import { Login } from './components/login/login';
import { Overview } from './components/overview/overview';
import { Exams } from './components/exams/exams';
import { Manage } from './components/manage/manage';

export const routes: Routes = [
  { path: '', component: Login },
  { path: 'overview', component: Overview },
  { path: 'exams', component: Exams },
  { path: 'manage', component: Manage },
];
