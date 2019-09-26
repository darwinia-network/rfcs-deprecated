#!/usr/bin/env bash

bundle exec jekyll b -d docs
git add .
git commit -m 'deploy new rfcs docs'
git push origin master