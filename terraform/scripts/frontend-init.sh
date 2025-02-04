#!/bin/bash
cd /var/www/html
git clone https://github.com/Abbeyo01/spring-boot-react-example.git
cd frontend
npm install
npm run build