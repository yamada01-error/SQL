const Database = require('better-sqlite3');

const db = new Database('sistema_passagens.db');

db.exec(`
CREATE TABLE IF NOT EXISTS COMPANHIA (
 ID INTEGER PRIMARY KEY AUTOINCREMENT, 
 NOME TEXT NOT NULL,
 ANOFUNDACAO INTEGER
);

CREATE TABLE IF NOT EXISTS CUPOM (
 ID INTEGER PRIMARY KEY AUTOINCREMENT, 
 IDCOMPANHIA INTEGER, 
 CODIGO TEXT NOT NULL,
 PERCENTUAL REAL NOT NULL,
 NUMEROCUPOM INTEGER, 
 FOREIGN KEY (IDCOMPANHIA) REFERENCES COMPANHIA(ID)
);

CREATE TABLE IF NOT EXISTS TRECHO (
 ID INTEGER PRIMARY KEY AUTOINCREMENT,
 IDCOMPANHIA INTEGER, 
 ORIGEM TEXT NOT NULL,
 DESTINO TEXT NOT NULL,
 VALOR REAL NOT NULL, 
 NUMEROPASSAGENS INTEGER,
 FOREIGN KEY (IDCOMPANHIA) REFERENCES COMPANHIA(ID)
);

module.exports = db;

--- RESOLUCAO COMPANHIA ---

const prompt = require('prompt-sync')();
const db = require('./database');

// -------------------------------------------
// FUNÇÕES AUXILIARES
// -------------------------------------------

function pausar() {
    console.log('\n----(par---------------------------------------');
    prompt('Pressione ENTER para continuar...');
    console.clear();
}

// Exibe todas as companhias cadastradas e retorna a lista
function listarCompanhias() {
    const companhias = db.prepare('SELECT * FROM Companhia').all();

    if (companhias.length === 0) {
        console.log('\nNenhuma companhia cadastrada.');
    } else {
        console.log('\n======= COMPANHIAS =======');
        for (let i = 0; i < companhias.length; i++) {
            console.log(`[${companhias[i].id}] ${companhias[i].nome} - Fundada em ${companhias[i].anoFundacao}`);
        }
    }

    return companhias;
}

// Verifica se uma companhia com o id informado existe.
// Caso nao exista, oferece a opcao de cadastrar uma nova e retorna o id gerado.
// Retorna o id valido ou null se o usuario optar por nao cadastrar.
function validarOuCadastrarCompanhia(idInformado) {
    const companhia = db.prepare('SELECT * FROM Companhia WHERE id = ?').get(idInformado);

    if (companhia) {
        return companhia.id;
    }

    console.log('\nNenhuma companhia encontrada com esse ID.');
    const opcaoCadastro = prompt('Deseja cadastrar uma nova companhia? (s/n): ');

    if (opcaoCadastro.toLowerCase() !== 's') {
        return null;
    }

    const nomeCompanhia = prompt('Nome da companhia: ');
    const anoFundacao = parseInt(prompt('Ano de fundacao: '));

    const resultado = db.prepare('INSERT INTO Companhia (nome, anoFundacao) VALUES (?, ?)').run(nomeCompanhia, anoFundacao);
    console.log('\nCompanhia cadastrada com sucesso!');

    return resultado.lastInsertRowid;
}

// -------------------------------------------
// FUNÇÕES DE TRECHOS
// -------------------------------------------

function cadastrarTrecho() {
    listarCompanhias();
    const idCompanhia = parseInt(prompt('\nID da companhia responsavel pelo trecho: '));
    const idValido = validarOuCadastrarCompanhia(idCompanhia);

    if (idValido === null) {
        return;
    }

    const origem = prompt('Cidade de origem: ');
    const destino = prompt('Cidade de destino: ');
    const valor = parseFloat(prompt('Valor do trecho: R$ '));
    const numeroPassagens = parseInt(prompt('Numero de passagens disponiveis: '));

    db.prepare('INSERT INTO Trecho (idCompanhia, origem, destino, valor, numeroPassagens) VALUES (?, ?, ?, ?, ?)')
        .run(idValido, origem, destino, valor, numeroPassagens);

    console.log('\nTrecho cadastrado com sucesso!');
}

function listarTrechos() {
    const trechos = db.prepare(`
        SELECT Trecho.*, Companhia.nome AS nomeCompanhia
        FROM Trecho
        JOIN Companhia ON Trecho.idCompanhia = Companhia.id
    `).all();

    if (trechos.length === 0) {
        console.log('\nNenhum trecho cadastrado.');
        return;
    }

    console.log('\n======= TRECHOS =======');
    for (let i = 0; i < trechos.length; i++) {
        const trecho = trechos[i];
        console.log(`\n[${trecho.id}] ${trecho.origem} -> ${trecho.destino}`);
        console.log(`   Companhia: ${trecho.nomeCompanhia}`);
        console.log(`   Valor: R$ ${trecho.valor.toFixed(2)}`);
        console.log(`   Passagens disponiveis: ${trecho.numeroPassagens}`);
        console.log('-------------------------------------------');
    }
}

function editarTrecho() {
    listarTrechos();
    const idTrecho = parseInt(prompt('\nID do trecho para editar: '));
    const trecho = db.prepare('SELECT * FROM Trecho WHERE id = ?').get(idTrecho);

    if (!trecho) {
        console.log('\nErro: Trecho nao encontrado.');
        return;
    }

    const novaOrigem = prompt('Nova origem: ');
    const novoDestino = prompt('Novo destino: ');
    const novoValor = parseFloat(prompt('Novo valor: R$ '));
    const novoNumeroPassagens = parseInt(prompt('Novo numero de passagens: '));

    db.prepare('UPDATE Trecho SET origem = ?, destino = ?, valor = ?, numeroPassagens = ? WHERE id = ?')
        .run(novaOrigem, novoDestino, novoValor, novoNumeroPassagens, idTrecho);

    console.log('\nTrecho atualizado com sucesso!');
}

function excluirTrecho() {
    listarTrechos();
    const idTrecho = parseInt(prompt('\nID do trecho para excluir: '));
    const trecho = db.prepare('SELECT * FROM Trecho WHERE id = ?').get(idTrecho);

    if (!trecho) {
        console.log('\nErro: Trecho nao encontrado.');
        return;
    }

    db.prepare('DELETE FROM Trecho WHERE id = ?').run(idTrecho);
    console.log('\nTrecho removido com sucesso!');
}

// -------------------------------------------
// FUNÇÕES DE CUPONS
// -------------------------------------------

function cadastrarCupom() {
    listarCompanhias();
    const idCompanhia = parseInt(prompt('\nID da companhia responsavel pelo cupom: '));
    const idValido = validarOuCadastrarCompanhia(idCompanhia);

    if (idValido === null) {
        return;
    }

    const codigo = prompt('Codigo do cupom (ex.: VIAGEM10): ').toUpperCase();
    const percentualDesconto = parseFloat(prompt('Percentual de desconto (ex.: 10 para 10%): '));
    const numeroCupons = parseInt(prompt('Numero de cupons disponiveis: '));

    db.prepare('INSERT INTO Cupom (idCompanhia, codigo, percentualDesconto, numeroCupons) VALUES (?, ?, ?, ?)')
        .run(idValido, codigo, percentualDesconto, numeroCupons);

    console.log('\nCupom cadastrado com sucesso!');
}

function listarCupons() {
    const cupons = db.prepare(`
        SELECT Cupom.*, Companhia.nome AS nomeCompanhia
        FROM Cupom
        JOIN Companhia ON Cupom.idCompanhia = Companhia.id
    `).all();

    if (cupons.length === 0) {
        console.log('\nNenhum cupom cadastrado.');
        return;
    }

    console.log('\n======= CUPONS =======');
    for (let i = 0; i < cupons.length; i++) {
        const cupom = cupons[i];
        console.log(`\n[${cupom.id}] Codigo: ${cupom.codigo}`);
        console.log(`   Companhia: ${cupom.nomeCompanhia}`);
        console.log(`   Desconto: ${cupom.percentualDesconto}%`);
        console.log(`   Cupons disponiveis: ${cupom.numeroCupons}`);
        console.log('-------------------------------------------');
    }
}

function editarCupom() {
    listarCupons();
    const codigoCupom = prompt('\nCodigo do cupom para editar: ').toUpperCase();
    const cupom = db.prepare('SELECT * FROM Cupom WHERE codigo = ?').get(codigoCupom);

    if (!cupom) {
        console.log('\nErro: Cupom nao encontrado.');
        return;
    }

    const novoCodigo = prompt('Novo codigo: ').toUpperCase();
    const novoPercentual = parseFloat(prompt('Novo percentual de desconto: '));
    const novoNumeroCupons = parseInt(prompt('Novo numero de cupons disponiveis: '));

    db.prepare('UPDATE Cupom SET codigo = ?, percentualDesconto = ?, numeroCupons = ? WHERE id = ?')
        .run(novoCodigo, novoPercentual, novoNumeroCupons, cupom.id);

    console.log('\nCupom atualizado com sucesso!');
}

function excluirCupom() {
    listarCupons();
    const codigoCupom = prompt('\nCodigo do cupom para excluir: ').toUpperCase();
    const cupom = db.prepare('SELECT * FROM Cupom WHERE codigo = ?').get(codigoCupom);

    if (!cupom) {
        console.log('\nErro: Cupom nao encontrado.');
        return;
    }

    db.prepare('DELETE FROM Cupom WHERE id = ?').run(cupom.id);
    console.log('\nCupom removido com sucesso!');
}

// -------------------------------------------
// MENU PRINCIPAL
// -------------------------------------------

let opcao = -1;

console.clear();
console.log('\n===========================================');
console.log('   SISTEMA DE PASSAGENS - COMPANHIA        ');
console.log('===========================================');

while (opcao !== 0) {
    console.log('\n---- MENU ----');
    console.log('1 - Gerenciar Trechos');
    console.log('2 - Gerenciar Cupons');
    console.log('0 - Sair');
    console.log('-------------------------\n');

    opcao = parseInt(prompt('Escolha uma opcao: '));

    switch (opcao) {

        case 1:
            console.log('\n---- TRECHOS ----');
            console.log('1 - Cadastrar');
            console.log('2 - Listar');
            console.log('3 - Editar');
            console.log('4 - Excluir');
            const opcaoTrecho = parseInt(prompt('Escolha: '));

            switch (opcaoTrecho) {
                case 1: cadastrarTrecho(); break;
                case 2: listarTrechos(); break;
                case 3: editarTrecho(); break;
                case 4: excluirTrecho(); break;
                default: console.log('\nOpcao invalida.'); break;
            }
            pausar();
            break;

        case 2:
            console.log('\n---- CUPONS ----');
            console.log('1 - Cadastrar');
            console.log('2 - Listar');
            console.log('3 - Editar');
            console.log('4 - Excluir');
            const opcaoCupom = parseInt(prompt('Escolha: '));

            switch (opcaoCupom) {
                case 1: cadastrarCupom(); break;
                case 2: listarCupons(); break;
                case 3: editarCupom(); break;
                case 4: excluirCupom(); break;
                default: console.log('\nOpcao invalida.'); break;
            }
            pausar();
            break;

        case 0:
            console.log('\nFinalizando o sistema... Ate logo!\n');
            break;

        default:
            console.log('\nOpcao invalida! Tente novamente.');
            pausar();
            break;
    }
}
