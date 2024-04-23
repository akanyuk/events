# events.retroscene.org

A system of events focused on demoparty: acceptance of works, voting, counting and publication of results, generation of releases and much more...

## Requires

* PHP 5.6 or 7.x (8.x never tested)
* MySQL database (PostgreSQL and SQLite supported too, but never tested)

## Installation and run with docker

* Update vendors by [composer](https://getcomposer.org/)

* Create default docker compose `.env` from `env.example`
  
* Run docker project by `make` command

* Create empty DB from `empty.sql` file. I.e:
```cmd
    restore_db.cmd empty.sql
```

* Create default `config.local.php` and `debug.php` (if need) 
  from `config.local.php.example` and `debug.php.example` files
  
* Allow access to write in:
`public_html/assets`,
`public_html/cache`, 
`public_html/files`, 
`public_html/media` and all subfolders,
`var/images_cache`,
`var/protected_media`,

* Open `http://localhost` in browser and login with username `admin` password `admin`

## Installation without docker

* Just like with a docker, only without docker