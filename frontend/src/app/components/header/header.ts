import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { Toolbar } from 'primeng/toolbar';

@Component({
  selector: 'app-header',
  imports: [Toolbar, ButtonModule, RouterLink],
  templateUrl: './header.html',
  styleUrl: './header.scss',
})
export class Header {
  toggleDarkMode() {
    const element = document.querySelector('html');
    element?.classList.toggle('app-dark-theme');
  }
}
