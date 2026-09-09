
final int MARGEM = 20;
final int ALTURA_CABECALHO = 20;
final int LARGURA_LEGENDA = 245;

char[][] mapa;
int numLinhas;
int numColunas;

float tamanhoCelula; //em px
float origemX; // canto superior esquerdo do mapa na tela
float origemY;

String mensagemErro = "";

Coordenada gerador;
Coordenada removedor;
Coordenada totem;

// Vetores c contadores (não pode arraylist)
Coordenada[] assentos = new Coordenada[500];
int qtdAssentos = 0;

enum EstadoAssento { LIVRE, RESERVADO, OCUPADO }
EstadoAssento[] estadoAssentos = new EstadoAssento[500];
Paciente[] ocupanteAssento = new Paciente[500];

Coordenada[] enfermeiros = new Coordenada[50];
int qtdEnfermeiros = 0;

Coordenada[] medicos = new Coordenada[50];
int qtdMedicos = 0;

color corChao, corParede, corGerador, corRemovedor, corTotem, corAssento, corEnfermeiro, corMedico, corGrade;

void inicializarCoresMapa() {
  corChao       = color(239, 229, 194);
  corParede     = color(205, 164, 112);
  corGerador    = color(20, 155, 45);
  corRemovedor  = color(225, 45, 55);
  corTotem      = color(50, 90, 225);
  corAssento    = color(115, 62, 31);
  corEnfermeiro = color(35);
  corMedico     = color(250, 205, 20);
  corGrade      = color(175, 151, 112);
}

void carregarMapa(String arquivo) {
  
  mensagemErro = "";
  gerador = null; 
  removedor = null; 
  totem = null;
  qtdAssentos = 0; 
  qtdEnfermeiros = 0; 
  qtdMedicos = 0;

  String[] linhas = loadStrings(arquivo);
  if (linhas == null || linhas.length == 0) {
    mensagemErro = "Não foi possível abrir o arquivo: " + arquivo;
    return;
  }

  String[] dimensoes = splitTokens(trim(linhas[0]));
  if (dimensoes.length != 2) {
    mensagemErro = "A primeira linha deve conter dois inteiros: n m.";
    return;
  }

  numLinhas = int(dimensoes[0]);
  numColunas = int(dimensoes[1]);

  if (numLinhas <= 0 || numColunas <= 0) {
    mensagemErro = "As dimensões do mapa devem ser números inteiros positivos.";
    return;
  }

  if (linhas.length != numLinhas + 1) {
    mensagemErro = "Quantidade de linhas inválida no arquivo do mapa.";
    return;
  }

  mapa = new char[numLinhas][numColunas];
  int geradores = 0;
  int removedores = 0;
  int totens = 0;

  for (int i = 0; i < numLinhas; i++) {
    String linha = linhas[i + 1];

    if (linha.length() != numColunas) {
      mensagemErro = "A linha " + (i + 2) + " possui tamanho inválido.";
      return;
    }

    for (int j = 0; j < numColunas; j++) {
      char tipo = linha.charAt(j);
      
      // validação e mapeamento unificados por switch
      switch (tipo) {
        case 'G':
          geradores++;
          gerador = new Coordenada(i, j);
          break;
        case 'R':
          removedores++;
          removedor = new Coordenada(i, j);
          break;
        case 'T':
          totens++;
          if (totem == null) {
            totem = new Coordenada(i, j);
          }
          break;
        case 'A':
          if (qtdAssentos < assentos.length) {
            assentos[qtdAssentos++] = new Coordenada(i, j);
          }
          break;
        case 'E':
          if (qtdEnfermeiros < enfermeiros.length) {
            enfermeiros[qtdEnfermeiros++] = new Coordenada(i, j);
          }
          break;
        case 'M':
          if (qtdMedicos < medicos.length) {
            medicos[qtdMedicos++] = new Coordenada(i, j);
          }
          break;
        case '#':
        case '.':
          // Caracteres estruturais válidos
          break;
        default:
          mensagemErro = "Caractere inválido '" + tipo + "' na linha " + (i + 2) + ", coluna " + (j + 1) + ".";
          return;
      }

      mapa[i][j] = tipo;
    }
  }

  if (geradores != 1) {
    mensagemErro = "O mapa deve possuir exatamente um Gerador (G).";
    return;
  }

  if (removedores != 1) {
    mensagemErro = "O mapa deve possuir exatamente um Removedor (R).";
    return;
  }

  if (totens == 0) {
    mensagemErro = "O mapa deve possuir pelo menos um Totem (T).";
    return;
  }

  calcularGeometria();

  // Precisam rodar aqui (e não em inicializarEstado()) porque só agora
  // qtdAssentos/qtdEnfermeiros refletem o mapa que acabou de ser lido.
  inicializarAssentos();
  inicializarTriagem();

  println("Mapa carregado com sucesso! Assentos: " + qtdAssentos + ", Enfermeiros: " + qtdEnfermeiros + ", Médicos: " + qtdMedicos);
}

// Reseta o estado lógico de todos os assentos usados neste mapa.
// Chamada sempre que um mapa é (re)carregado, garantindo que um reset
// da simulação também limpe reservas/ocupações antigas.
void inicializarAssentos() {
  for (int i = 0; i < qtdAssentos; i++) {
    estadoAssentos[i] = EstadoAssento.LIVRE;
    ocupanteAssento[i] = null;
  }
}

// Escolhe, entre os assentos livres, o de menor distância real de
// caminho (via matriz do Wavefront calculada a partir da posição do
// paciente) usando um insertion sort manual — sem coleções prontas.
// Retorna o índice do assento reservado, ou -1 se nenhum livre for
// alcançável.
int reservarAssentoMaisProximo(Coordenada origem) {
  WaveFront wavefront = new WaveFront();

  int[] indicesLivres = new int[qtdAssentos];
  int[] distanciasLivres = new int[qtdAssentos];
  int n = 0;

  for (int i = 0; i < qtdAssentos; i++) {
    if (estadoAssentos[i] == EstadoAssento.LIVRE) {
      ListaEncadeada<Coordenada> caminho = wavefront.encontrarCaminho(mapa, origem, assentos[i]);
      if (caminho.count() > 0) {
        indicesLivres[n] = i;
        distanciasLivres[n] = caminho.count() - 1; // nº de passos até o assento
        n++;
      }
    }
  }

  // insertion sort manual pela distância (sem coleções prontas)
  for (int i = 1; i < n; i++) {
    int idxChave = indicesLivres[i];
    int distChave = distanciasLivres[i];
    int j = i - 1;
    while (j >= 0 && distanciasLivres[j] > distChave) {
      indicesLivres[j + 1] = indicesLivres[j];
      distanciasLivres[j + 1] = distanciasLivres[j];
      j--;
    }
    indicesLivres[j + 1] = idxChave;
    distanciasLivres[j + 1] = distChave;
  }

  if (n == 0) return -1; // nenhum assento livre alcançável

  int idxEscolhido = indicesLivres[0];
  estadoAssentos[idxEscolhido] = EstadoAssento.RESERVADO;
  return idxEscolhido;
}

// Marca um assento como efetivamente ocupado (chamar quando o paciente
// chega de fato na célula, não no momento da reserva).
void ocuparAssento(int idx, Paciente p) {
  if (idx < 0) return;
  estadoAssentos[idx] = EstadoAssento.OCUPADO;
  ocupanteAssento[idx] = p;
}

// Libera um assento (reservado ou ocupado) de volta para LIVRE.
void liberarAssento(int idx) {
  if (idx < 0) return;
  estadoAssentos[idx] = EstadoAssento.LIVRE;
  ocupanteAssento[idx] = null;
}

void calcularGeometria() {
  float larguraDisponivel = width - 2 * MARGEM - LARGURA_LEGENDA;
  float alturaDisponivel = height - ALTURA_CABECALHO - MARGEM;

  tamanhoCelula = min(
    larguraDisponivel / numColunas,
    alturaDisponivel / numLinhas
  );

  origemX = MARGEM;
  origemY = ALTURA_CABECALHO;
}

void desenharMapa() {
  stroke(corGrade);
  strokeWeight(1);

  for (int i = 0; i < numLinhas; i++) {
    for (int j = 0; j < numColunas; j++) {
      char tipo = mapa[i][j];

      float x = origemX + j * tamanhoCelula;
      float y = origemY + i * tamanhoCelula;

      fill(corDaCelula(tipo));
      rect(x, y, tamanhoCelula, tamanhoCelula);

      if (tipo != '.' && tipo != '#') {
        desenharSimbolo(tipo, x, y);
      }
    }
  }

  desenharLegenda();
}

color corDaCelula(char tipo) {
  switch (tipo) {
    case '#':
      return corParede;
    case 'G':
      return corGerador;
    case 'R':
      return corRemovedor;
    case 'T':
      return corTotem;
    case 'A':
      return corAssento;
    case 'E':
      return corEnfermeiro;
    case 'M':
      return corMedico;
    default:
      return corChao;
  }
}

void desenharSimbolo(char tipo, float x, float y) {
  textAlign(CENTER, CENTER);
  textSize(max(8, tamanhoCelula * 0.40));

  if (tipo == 'M') {
    fill(35);
  } else {
    fill(255);
  }

  text(
    str(tipo),
    x + tamanhoCelula / 2.0,
    y + tamanhoCelula / 2.0 - 1
  );
}

void desenharLegenda() {
  float x = width - LARGURA_LEGENDA + 20;
  float y = ALTURA_CABECALHO;

  fill(40);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Legenda", x, y);

  y += 32;
  itemLegenda(x, y, 'G', "Gerador", corGerador);
  y += 30;
  itemLegenda(x, y, 'R', "Removedor", corRemovedor);
  y += 30;
  itemLegenda(x, y, 'T', "Totem", corTotem);
  y += 30;
  itemLegenda(x, y, 'A', "Assento", corAssento);
  y += 30;
  itemLegenda(x, y, 'E', "Enfermeiro", corEnfermeiro);
  y += 30;
  itemLegenda(x, y, 'M', "Médico", corMedico);

  y += 44;
  fill(45, 125, 230);
  noStroke();
  ellipse(x + 10, y + 10, 18, 18);
  fill(55);
  textAlign(LEFT, CENTER);
  textSize(13);
  text("Paciente normal", x + 28, y + 10);

  y += 30;
  fill(155, 75, 180);
  noStroke();
  ellipse(x + 10, y + 10, 18, 18);
  fill(55);
  text("Paciente preferencial", x + 28, y + 10);
}

void itemLegenda(float x, float y, char simbolo, String descricao, color cor) {
  stroke(80);
  fill(cor);
  rect(x, y, 21, 21);

  fill(simbolo == 'M' ? 35 : 255);
  textAlign(CENTER, CENTER);
  textSize(11);
  text(str(simbolo), x + 10.5, y + 10);

  fill(55);
  textAlign(LEFT, CENTER);
  textSize(13);
  text(descricao, x + 31, y + 10);
}

void desenharErro() {
  fill(255, 235, 235);
  stroke(190, 40, 40);
  strokeWeight(2);
  rect(20, 90, width - 40, 120);

  fill(150, 25, 25);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Erro ao carregar o mapa", 38, 108);

  textSize(14);
  text(mensagemErro, 38, 145, width - 76, 50);
}