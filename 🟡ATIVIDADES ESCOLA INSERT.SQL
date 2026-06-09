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


INSERT INTO alunos (nome, idade, turma)
VALUES ('Ana', 15, '1A');

INSERT INTO alunos (nome, idade, turma)
VALUES 
('Bruno', 16, '1A'),
('Carlos', 17, '2B'),
('Daniela', 15, '2B');

INSERT INTO alunos (nome, idade)
VALUES ('Eduardo', 16);


INSERT INTO alunos (nome, idade, turma)
VALUES ('Fernanda', 18, '3A');
