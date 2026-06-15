const prompt = require('prompt-sync')();
const db = require('./database');

// -------------------------------------------
// FUNÇÕES AUXILIARES
// -------------------------------------------

function pausar() {
    console.log('\n-------------------------------------------');
    prompt('Pressione ENTER para continuar...');
    console.clear();
}

// -------------------------------------------
// FUNÇÕES DE VISUALIZAÇÃO DE TRECHOS
// -------------------------------------------

function listarTodosOsTrechos() {
    const trechos = db.prepare(`
        SELECT Trecho.*, Companhia.nome AS nomeCompanhia
        FROM Trecho
        JOIN Companhia ON Trecho.idCompanhia = Companhia.id
        WHERE Trecho.numeroPassagens > 0
    `).all();

    if (trechos.length === 0) {
        console.log('\nNenhum trecho disponivel no momento.');
        return;
    }

    console.log('\n======= TRECHOS DISPONIVEIS =======');
    for (let i = 0; i < trechos.length; i++) {
        const trecho = trechos[i];
        console.log(`\n[${trecho.id}] ${trecho.origem} -> ${trecho.destino}`);
        console.log(`   Companhia: ${trecho.nomeCompanhia}`);
        console.log(`   Valor: R$ ${trecho.valor.toFixed(2)}`);
        console.log(`   Passagens disponiveis: ${trecho.numeroPassagens}`);
        console.log('-------------------------------------------');
    }
}

function listarTrechosPorCompanhia() {
    const companhias = db.prepare('SELECT * FROM Companhia').all();

    if (companhias.length === 0) {
        console.log('\nNenhuma companhia cadastrada.');
        return;
    }

    console.log('\n======= COMPANHIAS =======');
    for (let i = 0; i < companhias.length; i++) {
        console.log(`[${companhias[i].id}] ${companhias[i].nome}`);
    }

    const idCompanhia = parseInt(prompt('\nID da companhia: '));
    const companhia = db.prepare('SELECT * FROM Companhia WHERE id = ?').get(idCompanhia);

    if (!companhia) {
        console.log('\nCompanhia nao encontrada.');
        return;
    }

    const trechos = db.prepare(`
        SELECT Trecho.*, Companhia.nome AS nomeCompanhia
        FROM Trecho
        JOIN Companhia ON Trecho.idCompanhia = Companhia.id
        WHERE Trecho.idCompanhia = ? AND Trecho.numeroPassagens > 0
    `).all(idCompanhia);

    if (trechos.length === 0) {
        console.log(`\nNenhum trecho disponivel para a companhia ${companhia.nome}.`);
        return;
    }

    console.log(`\n======= TRECHOS - ${companhia.nome.toUpperCase()} =======`);
    for (let i = 0; i < trechos.length; i++) {
        const trecho = trechos[i];
        console.log(`\n[${trecho.id}] ${trecho.origem} -> ${trecho.destino}`);
        console.log(`   Valor: R$ ${trecho.valor.toFixed(2)}`);
        console.log(`   Passagens disponiveis: ${trecho.numeroPassagens}`);
        console.log('-------------------------------------------');
    }
}

// -------------------------------------------
// FUNÇÕES DE COMPRA
// -------------------------------------------

// Exibe o carrinho atual do cliente
function exibirCarrinho(carrinho) {
    if (carrinho.length === 0) {
        console.log('\nSeu carrinho esta vazio.');
        return;
    }

    console.log('\n======= SEU CARRINHO =======');
    for (let i = 0; i < carrinho.length; i++) {
        const item = carrinho[i];
        console.log(`[${i}] ${item.origem} -> ${item.destino} | R$ ${item.valor.toFixed(2)} | Companhia: ${item.nomeCompanhia}`);
    }
}

// Adiciona um trecho ao carrinho pelo ID
function adicionarAoCarrinho(carrinho) {
    listarTodosOsTrechos();
    const idTrecho = parseInt(prompt('\nID do trecho que deseja adicionar: '));

    const trecho = db.prepare(`
        SELECT Trecho.*, Companhia.nome AS nomeCompanhia
        FROM Trecho
        JOIN Companhia ON Trecho.idCompanhia = Companhia.id
        WHERE Trecho.id = ? AND Trecho.numeroPassagens > 0
    `).get(idTrecho);

    if (!trecho) {
        console.log('\nTrecho nao encontrado ou sem passagens disponiveis.');
        return;
    }

    carrinho.push(trecho);
    console.log(`\nTrecho ${trecho.origem} -> ${trecho.destino} adicionado ao carrinho!`);
}

// Remove um trecho do carrinho pelo indice
function removerDoCarrinho(carrinho) {
    exibirCarrinho(carrinho);

    if (carrinho.length === 0) return;

    const indice = parseInt(prompt('\nNumero do item para remover: '));

    if (indice < 0 || indice >= carrinho.length) {
        console.log('\nItem nao encontrado no carrinho.');
        return;
    }

    const removido = carrinho.splice(indice, 1);
    console.log(`\nTrecho ${removido[0].origem} -> ${removido[0].destino} removido do carrinho.`);
}

// Aplica um cupom e retorna o percentual de desconto. Retorna 0 se invalido ou esgotado.
function aplicarCupom() {
    const codigoCupom = prompt('Codigo do cupom (ou ENTER para pular): ').toUpperCase();

    if (codigoCupom === '') {
        return null;
    }

    const cupom = db.prepare('SELECT * FROM Cupom WHERE codigo = ?').get(codigoCupom);

    if (!cupom) {
        console.log('\nCupom invalido.');
        return null;
    }

    if (cupom.numeroCupons <= 0) {
        console.log('\nCupom esgotado.');
        return null;
    }

    console.log(`\nDesconto de ${cupom.percentualDesconto}% aplicado!`);
    return cupom;
}

// Exibe o cupom fiscal e finaliza a compra
function finalizarCompra(carrinho) {
    if (carrinho.length === 0) {
        console.log('\nSeu carrinho esta vazio. Adicione trechos antes de finalizar.');
        return false;
    }

    const cupom = aplicarCupom();
    const percentualDesconto = cupom ? cupom.percentualDesconto : 0;
    let subtotal = 0;

    for (let i = 0; i < carrinho.length; i++) {
        subtotal += carrinho[i].valor;
    }

    const valorDesconto = subtotal * (percentualDesconto / 100);
    const valorFinal = subtotal - valorDesconto;

    console.log('\n============================================');
    console.log('              CUPOM FISCAL                  ');
    console.log('============================================');

    for (let i = 0; i < carrinho.length; i++) {
        const item = carrinho[i];
        console.log(`${item.origem} -> ${item.destino} (${item.nomeCompanhia})`);
        console.log(`   R$ ${item.valor.toFixed(2)}`);
    }

    console.log('--------------------------------------------');
    console.log(`Subtotal:          R$ ${subtotal.toFixed(2)}`);

    if (percentualDesconto > 0) {
        console.log(`Desconto (${percentualDesconto}%):    - R$ ${valorDesconto.toFixed(2)}`);
    }

    console.log(`TOTAL:             R$ ${valorFinal.toFixed(2)}`);
    console.log('============================================');

    const confirmacao = prompt('\nDigite "comprar" para confirmar ou ENTER para cancelar: ');

    if (confirmacao.toLowerCase() !== 'comprar') {
        console.log('\nCompra cancelada. Seu carrinho foi mantido.');
        return false;
    }

    for (let i = 0; i < carrinho.length; i++) {
        db.prepare('UPDATE Trecho SET numeroPassagens = numeroPassagens - 1 WHERE id = ?').run(carrinho[i].id);
    }

    if (cupom) {
        db.prepare('UPDATE Cupom SET numeroCupons = numeroCupons - 1 WHERE id = ?').run(cupom.id);
    }

    console.log('\nCompra realizada com sucesso! Boa viagem!');
    return true;
}

// -------------------------------------------
// MENU PRINCIPAL
// -------------------------------------------

let opcao = -1;
const carrinho = [];

console.clear();
console.log('\n===========================================');
console.log('   SISTEMA DE PASSAGENS - CLIENTE          ');
console.log('===========================================');

while (opcao !== 0) {
    console.log('\n---- MENU ----');
    console.log('1 - Ver trechos disponiveis');
    console.log('2 - Adicionar trecho ao carrinho');
    console.log('3 - Remover trecho do carrinho');
    console.log('4 - Ver carrinho');
    console.log('5 - Finalizar compra');
    console.log('0 - Sair');
    console.log('-------------------------\n');

    opcao = parseInt(prompt('Escolha uma opcao: '));

    switch (opcao) {

        case 1:
            console.log('\n---- VISUALIZAR TRECHOS ----');
            console.log('1 - Todos os trechos');
            console.log('2 - Por companhia');
            const opcaoVisualizacao = parseInt(prompt('Escolha: '));

            if (opcaoVisualizacao === 1) listarTodosOsTrechos();
            else if (opcaoVisualizacao === 2) listarTrechosPorCompanhia();
            else console.log('\nOpcao invalida.');

            pausar();
            break;

        case 2:
            adicionarAoCarrinho(carrinho);
            pausar();
            break;

        case 3:
            removerDoCarrinho(carrinho);
            pausar();
            break;

        case 4:
            exibirCarrinho(carrinho);
            pausar();
            break;

        case 5:
            const compraFinalizada = finalizarCompra(carrinho);
            if (compraFinalizada) {
                carrinho.length = 0;
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
