CREATE TABLE alunos (
    id INT PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100),
    idade INT,
    turma VARCHAR(10)
);

INSERT INTO alunos (nome, idade, turma) VALUES
('Ana', 15, '1A'),
('Bruno', 16, '1A'),
('Carlos', 17, '2B'),
('Daniela', 15, '2B'),
('Eduardo', 16, '3A');

-- Comandos --

SELECT * FROM alunos;

SELECT nome FROM alunos;

SELECT turma FROM alunos;

SELECT nome, idade FROM alunos;

SELECT nome, turma FROM alunos;

SELECT id, nome, idade, turma FROM alunos;
