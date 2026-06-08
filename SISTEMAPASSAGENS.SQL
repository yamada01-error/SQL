const Database = require('better-sqlite3');

const db = new Database('sistema_passagens.db');

db.exec(`
 create table if not exists companhia (
 id integer primary key autoincrement, 
 nome text not null,
 anofundacao integer
);

 create table if not exists cupom (
 id integer primary key autoincrement, 
 idCompanhia integer, 
 codigo text not null,
 percentual real not null,
numerocupom integer 
codigo text not null, 
foreign key (idCompanhia) references companhia(id)
);

create table if not exists trecho (
id INTEGER primary key autoincrement,
idCompanhia  integer, 
origem text not null,
destino text not null,
valor real not null, 
numeropassagens integer,
foreign key (idCompanhia) references companhia(id)
);
`);


module.exports = db;
