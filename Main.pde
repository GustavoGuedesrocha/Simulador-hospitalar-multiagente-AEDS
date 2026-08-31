final int LARGURA_JANELA = 800;
final int ALTURA_JANELA = 600;

String nomeArquivo = "";

void settings() {
  size(LARGURA_JANELA, ALTURA_JANELA);
}

void setup() {
  inicializarEstado();
  carregarAssets();
}

void carregarAssets() {
  inicializarCoresMapa();
  listarMapas();
}

void inicializarEstado() {
  // Pessoa 1 — lista de pacientes ativos
  // pacientes = new ListaEncadeada<Paciente>();
  // proximoIdPaciente = 1;

  // Pessoa 2 — filas de triagem
  // filaTriagemNormal = new Fila();
  // filaTriagemPreferencial = new Fila();

  // Pessoa 3 — filas médicas por cor
  // filaVermelha = new Fila();
  // filaLaranja  = new Fila();
  // filaAmarela  = new Fila();
  // filaVerde    = new Fila();
  // filaAzul     = new Fila();

  tempoTotalPausado = 0;
}

void draw() {
  background(245);

  switch (estadoAtual) {
    case MENU_INICIAL:
      desenharMenuInicial();
      break;
    case SIMULACAO:
      desenharSimulacao();
      break;
    case MENU_PAUSA:
      desenharMenuPausa();
      break;
  }
}

void desenharSimulacao() {
  if (!mensagemErro.equals("")) {
    desenharErro();
    return;
  }
  desenharMapa();
  // aqui entram o desenho dos pacientes (sprites) e o painel de estatísticas
}

void keyPressed() {
  if (key == ESC) {
    key = 0; // impede o Processing de fechar o sketch sozinho ao apertar ESC

    if (estadoAtual == EstadoJogo.SIMULACAO) {
      pausarSimulacao();
    } else if (estadoAtual == EstadoJogo.MENU_PAUSA) {
      continuarSimulacao();
    }
  }
}
