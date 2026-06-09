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

🔴 Excluir um aluno pelo nome

DELETE FROM alunos
WHERE nome = 'Ana';

🔴 Excluir um aluno pelo ID

DELETE FROM alunos
WHERE id = 3;

🔴 Excluir alunos de uma turma específica

DELETE FROM alunos
WHERE turma = '1A';

🔴 Excluir alunos com idade menor que 16

DELETE FROM alunos
WHERE idade < 16;
