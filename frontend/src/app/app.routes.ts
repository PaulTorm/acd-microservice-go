import { Routes } from '@angular/router';
import { Login } from './components/login/login';
import { Home } from './components/home/home';
import { Overview } from './components/overview/overview';
import { Exams } from './components/exams/exams';

export const routes: Routes = [
  { path: '', component: Login },
  { path: 'home', component: Home },
  { path: 'overview', component: Overview },
  { path: 'exams', component: Exams },
];
