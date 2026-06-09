CREATE TABLE alunos (
    id INT PRIMARY KEY AUTO_INCREMENT,
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


-- COMANDOS --

UPDATE alunos
SET idade = 16
WHERE nome = 'Ana';

UPDATE alunos
SET idade = 17,
    turma = '2C'
WHERE nome = 'Carlos';

UPDATE alunos
SET turma = '4A'
WHERE idade > 17;


UPDATE alunos
SET turma = '3A'
WHERE nome = 'Bruno';
