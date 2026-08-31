EstadoJogo estadoAtual = EstadoJogo.MENU_INICIAL;

// seleção de mapas
final int MAX_MAPAS_DISPONIVEIS = 5;
String[] mapasDisponiveis = new String[MAX_MAPAS_DISPONIVEIS];
int qtdMapas = 0;
int mapaSelecionado = -1;

// layout do menu inicial
final float BOTAO_MAPA_X = 60;
final float BOTAO_MAPA_Y_INICIAL = 110;
final float BOTAO_MAPA_LARGURA = 320;
final float BOTAO_MAPA_ALTURA = 34;
final float BOTAO_MAPA_ESPACO = 10; // espaço extra entre botões 

final float BOTAO_INICIAR_LARGURA = 220;
final float BOTAO_INICIAR_ALTURA = 44;

//layout do menu de pausa
final float BOTAO_PAUSA_LARGURA = 260;
final float BOTAO_PAUSA_ALTURA = 46;
final float BOTAO_PAUSA_ESPACO = 16;

//variaveis de controle do tempo
//a pausa nao pode "empurrar" os timers da simulação (spawn, triagem, consulta)
long momentoPausa = 0;
long tempoTotalPausado = 0;

/* !!!RELOGIO GLOBAL!!!!! usar no lugar da função millis() puro p/ calcular
o tempo de spawn, triagem/consulta etc. 
caso contrario a pausa vai acelerar tudo qdo a simulação voltar */
long millisSimulacao() {
  return millis() - tempoTotalPausado;
}

// o sistema foi pensado p ter suporte para ler dinamicamente qualquer
// layout de hospital que for colocado na pasta do projeto
// eh interessante existir outras configurações do mapa além de "mapa_hospital_professor.txt" para testar isso dps
// vou tentar adicioná-las eventualmente

void listarMapas() {
  qtdMapas = 0;
  File pastaMapas = new File(dataPath("."));
  String[] arquivos = pastaMapas.list();

  if (arquivos == null) return;

  for (int i = 0; i < arquivos.length; i++) {
    if (arquivos[i].toLowerCase().endsWith(".txt") && qtdMapas < MAX_MAPAS_DISPONIVEIS ) {
      mapasDisponiveis[qtdMapas++] = arquivos[i];
    }
  }
}

// função auxiliar: calcula posição Y do botão de indice qualquer numa pilha vertical
float YBotaoEmpilhado(float yInicial, float altura, float espaco, int indice) {
  return yInicial + indice * (altura + espaco);
}

/* DESENHO DOS MENUS */

void desenharMenuInicial(){
  
  fill(40);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Simulador Hospitalar Multiagente", BOTAO_MAPA_X, 40);

  textSize(14);
  fill(90);
  text("Selecione um mapa:", BOTAO_MAPA_X, 80);

  // desenha a lista de mapas
  for (int i = 0; i < qtdMapas; i++) {
    float y = YBotaoEmpilhado(BOTAO_MAPA_Y_INICIAL, BOTAO_MAPA_ALTURA, BOTAO_MAPA_ESPACO, i);
    
    if (i == mapaSelecionado) {
      stroke(#248E93);
      fill(#A5F4F7);
    } else {
      stroke(0);
      fill(255);
    }
    
    rect(BOTAO_MAPA_X, y, BOTAO_MAPA_LARGURA, BOTAO_MAPA_ALTURA, 6);
    
    fill(40);
    noStroke();
    textAlign(LEFT, CENTER);
    text(mapasDisponiveis[i], BOTAO_MAPA_X + 14, y + BOTAO_MAPA_ALTURA / 2.0);
    
  }
  
  if (qtdMapas == 0) {
    fill(0);
    textAlign(LEFT, TOP);
    textSize(13);
    text("Nenhum arquivo .txt encontrado na pasta data/.", BOTAO_MAPA_X, BOTAO_MAPA_Y_INICIAL);
  }
  
  //botao de iniciar simulação
  float yBotaoIniciar = YBotaoEmpilhado(BOTAO_MAPA_Y_INICIAL, BOTAO_MAPA_ALTURA, BOTAO_MAPA_ESPACO, qtdMapas) + 30;
  boolean habilitado = (mapaSelecionado != -1);
  
  noStroke();
  fill(habilitado ? color(#21D811) : color(0));
  rect(BOTAO_MAPA_X, yBotaoIniciar, BOTAO_INICIAR_LARGURA, BOTAO_INICIAR_ALTURA, 8);
  
  fill(255);
  textAlign(CENTER, CENTER);
  text("Iniciar Simulação",
       BOTAO_MAPA_X + BOTAO_INICIAR_LARGURA / 2.0,
       yBotaoIniciar + BOTAO_INICIAR_ALTURA / 2.0);
}

void desenharMenuPausa() {

  noStroke();
  fill(180);
  rect(0, 0, width, height);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(26);
  text("Simulação Pausada",  width / 2.0, height / 2.0 - 100);

  String[] nomesBotoes = {"Continuar", "Resetar", "Voltar ao Menu"};
  for (int i = 0; i < nomesBotoes.length; i++) {
    float y =  YBotaoEmpilhado(height / 2.0 - 40, BOTAO_PAUSA_ALTURA, BOTAO_PAUSA_ESPACO, i);

    noStroke();
    fill(255);
    rect(width / 2.0 - BOTAO_PAUSA_LARGURA / 2.0, y, BOTAO_PAUSA_LARGURA, BOTAO_PAUSA_ALTURA, 8);

    fill(0);
    text(nomesBotoes[i], width / 2.0, y + BOTAO_PAUSA_ALTURA / 2.0);
  }
}

/* LÓGICA DE CLIQUES */

boolean clicouRetangulo(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}

void mousePressed() {
  
  if (estadoAtual == EstadoJogo.MENU_INICIAL) {

    for (int i = 0; i < qtdMapas; i++) {
      if (clicouRetangulo(BOTAO_MAPA_X,
          YBotaoEmpilhado(BOTAO_MAPA_Y_INICIAL, BOTAO_MAPA_ALTURA, BOTAO_MAPA_ESPACO, i),
          BOTAO_MAPA_LARGURA, BOTAO_MAPA_ALTURA)) {
        mapaSelecionado = i;
      }
    }

    float yBotaoIniciar = YBotaoEmpilhado(BOTAO_MAPA_Y_INICIAL, BOTAO_MAPA_ALTURA, BOTAO_MAPA_ESPACO, qtdMapas) + 30;
    if (mapaSelecionado != -1 &&
        clicouRetangulo(BOTAO_MAPA_X, yBotaoIniciar, BOTAO_INICIAR_LARGURA, BOTAO_INICIAR_ALTURA)) {
      nomeArquivo = mapasDisponiveis[mapaSelecionado];
      carregarMapa(nomeArquivo);
      tempoTotalPausado = 0;
      estadoAtual = EstadoJogo.SIMULACAO;
    }

  } else if (estadoAtual == EstadoJogo.MENU_PAUSA) {
    // Verifica qual dos 3 botões de pausa foi clicado
    for (int i = 0; i < 3; i++) {
      float y = YBotaoEmpilhado(height / 2.0 - 40, BOTAO_PAUSA_ALTURA, BOTAO_PAUSA_ESPACO, i);
      
      if (clicouRetangulo(width / 2.0 - BOTAO_PAUSA_LARGURA / 2.0, y, BOTAO_PAUSA_LARGURA, BOTAO_PAUSA_ALTURA)) {
        if (i == 0) continuarSimulacao();
        else if (i == 1) resetarSimulacao();
        else if (i == 2) voltarAoMenuInicial();
      }
    }
  }
}

// Controle de simulação
void pausarSimulacao() {
  momentoPausa = millis();
  estadoAtual = EstadoJogo.MENU_PAUSA;
}

void continuarSimulacao() {
  tempoTotalPausado += millis() - momentoPausa;
  estadoAtual = EstadoJogo.SIMULACAO;
}

// soft reboot: inicializarEstado() (definida no Main.pde) recria do zero as
// estruturas de estado de todo mundo
void resetarSimulacao() {
  inicializarEstado();
  carregarMapa(nomeArquivo);
  estadoAtual = EstadoJogo.SIMULACAO;
}

void voltarAoMenuInicial() {
  resetarSimulacao();
  mapaSelecionado = -1;
  listarMapas();
  estadoAtual = EstadoJogo.MENU_INICIAL;
}
