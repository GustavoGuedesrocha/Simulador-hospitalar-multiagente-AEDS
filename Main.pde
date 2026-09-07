final int LARGURA_JANELA = 800;
final int ALTURA_JANELA = 600;

final float mediaSpawnMillis = 5000;

float tempoProximoSpawn;
int idProximoPaciente;
int numNormal, numPreferencial;
ListaEncadeada<Paciente> pacientes;

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
  
  idProximoPaciente = 1;
  numNormal = 1;
  numPreferencial = 1;
  pacientes = new ListaEncadeada<>();
  tempoProximoSpawn = millisSimulacao() + gerarProximoSpawn();

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
      if(millisSimulacao() > tempoProximoSpawn) {
        gerarPaciente();
      }
      
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

float gerarProximoSpawn() {
  float u = random(0, 1);
  float proximoSpawn = -mediaSpawnMillis * log(1 - u);
  return proximoSpawn;
}

void atualizarIDs(boolean ehPreferencial) {
  idProximoPaciente++;
   
  if(ehPreferencial) {
    numPreferencial++;
  } else {
    numNormal++;
  }
}

void gerarPaciente() {
  Paciente novoPaciente = new Paciente(idProximoPaciente, numNormal, numPreferencial, gerador, totem);
        
  atualizarIDs(novoPaciente.ehPreferencial);
  tempoProximoSpawn = millisSimulacao() + gerarProximoSpawn();
        
  pacientes.add(novoPaciente);
}
