# LittleSis

## About

[LittleSis](https://littlesis.org) is a free database of who-knows-who at the heights of business and government. It is a public wiki and purpose-built database for researching powerful organizations, tracking conflicts of interest, and visualizing networks of political influence. LittleSis started in 2009 and our database contains over 1.6 million relationships between over 400 thousand people and organizations.

LittleSis is a project of [The Public Accountability Initiative](https://public-accountability.org/), a non-profit public interest research organization focused on corporate and government accountability. Visit [Eyes on the Ties](https://news.littlesis.org) to read our research or follow [@twittlesis](https://twitter.com/twittlesis) on twitter.

This repository [littlesis-rails](https://github.com/public-accountability/littlesis-rails) is our core application. See [public-accountability/oligrapher](https://github.com/public-accountability/oligrapher) for our javascript mapping tool.


## Project history & software

Matthew Skomarovsky ([@lovemedicine](https://github.com/lovemedicine)) co-founded LittleSis and was the lead developer behind the project, with help from co-founder Kevin Connor. LittleSis started in 2009 as a [PHP application](https://github.com/littlesis-org/littlesis). The port to Ruby on Rails began in 2013 and finished in 2017.

Ziggy ([@aepyornis](https://github.com/aepyornis)) joined in 2016 and currently maintains the project.

Along the way, Eddie ([@eddietejeda](https://github.com/eddietejeda)) helped with some of the first data import scripts. Austin ([@aguestuser](https://github.com/aguestuser)) worked on on oligrapher and the rails codebase. Liz ([@lizstarin](https://github.com/lizstarin)) helped port PHP code to rails and developed the chrome extension. Pea ([@misfist](https://github.com/misfist)) coded our wordpress sites. Since 2020, Rob [@robjlucas](https://github.com/robjlucas) has contributed to the rails application.



| Key software |               |
|:------------:|:-------------:|
| Application  | Ruby on Rails |
| Database     | Postgresql    |
| Web Server   | Puma, Nginx   |
| Search       | Manticore     |
| Cache        | Redis         |
| Blog         | Wordpress     |
| OS           | Debian        |


[Developer Instructions](./DEVELOPMENT.md)
