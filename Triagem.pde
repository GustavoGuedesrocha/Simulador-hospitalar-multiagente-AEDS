Fila<Paciente> filaTriagemNormal;
Fila<Paciente> filaTriagemPreferencial;

boolean[] enfermeiraOciosa;
Paciente[] pacienteNaTriagem;
long[] fimTriagem; // instante (millisSimulacao) em que o atendimento atual termina

int atendimentosPreferenciaisSeguidos = 0;

void inicializarTriagem() {
  filaTriagemNormal = new Fila<Paciente>();
  filaTriagemPreferencial = new Fila<Paciente>();

  enfermeiraOciosa = new boolean[qtdEnfermeiros];
  pacienteNaTriagem = new Paciente[qtdEnfermeiros];
  fimTriagem = new long[qtdEnfermeiros];

  for (int i = 0; i < qtdEnfermeiros; i++) {
    enfermeiraOciosa[i] = true;
    pacienteNaTriagem[i] = null;
    fimTriagem[i] = 0;
  }

  atendimentosPreferenciaisSeguidos = 0;
}

// Decide qual fila fornece o próximo paciente, respeitando a regra de
// alternância: no máximo 2 preferenciais consecutivos para cada normal.
Paciente proximoDaTriagem() {
  if (filaTriagemNormal.vazia() && filaTriagemPreferencial.vazia()) {
    return null;
  }

  if (!filaTriagemPreferencial.vazia() &&
      (filaTriagemNormal.vazia() || atendimentosPreferenciaisSeguidos < 2)) {
    atendimentosPreferenciaisSeguidos++;
    return filaTriagemPreferencial.desenfileirar();
  }

  if (!filaTriagemNormal.vazia()) {
    atendimentosPreferenciaisSeguidos = 0;
    return filaTriagemNormal.desenfileirar();
  }

  // só sobrou fila preferencial, mesmo já tendo estourado o limite de 2
  atendimentosPreferenciaisSeguidos++;
  return filaTriagemPreferencial.desenfileirar();
}

// Distribuição normal (gaussiana) truncada, conforme parâmetros do enunciado:
// média 6.0s, desvio padrão 2.0s, mínimo 2.0s.
float sortearTempoTriagem() {
  float t = 6.0 + 2.0 * randomGaussian();
  return max(t, 2.0);
}

// Retorna a primeira célula de chão livre e adjacente (4-vizinhança) à
// enfermeira de índice i. Usada como destino do paciente chamado.
Coordenada celulaAdjacenteLivre(Coordenada base) {
  int[] dLinha = {-1, 1, 0, 0};
  int[] dColuna = {0, 0, -1, 1};

  for (int k = 0; k < 4; k++) {
    int l = base.linha + dLinha[k];
    int c = base.coluna + dColuna[k];
    if (l >= 0 && l < numLinhas && c >= 0 && c < numColunas) {
      if (mapa[l][c] == '.') {
        return new Coordenada(l, c);
      }
    }
  }
  return null; // não deveria acontecer em um mapa bem formado
}

// Chamada a cada frame (ex.: dentro de desenharSimulacao() ou de uma
// atualizarSimulacao() central). Libera enfermeiras cujo atendimento
// acabou e tenta chamar um novo paciente para as que estão ociosas.
void atualizarTriagem() {
  for (int i = 0; i < qtdEnfermeiros; i++) {

    if (!enfermeiraOciosa[i] && millisSimulacao() >= fimTriagem[i]) {
      Paciente p = pacienteNaTriagem[i];


      classificarManchester(p);
      enfileirarNaFilaMedica(p);

      p.estado = EstadoPaciente.INDO_ASSENTO_MEDICO;

      pacienteNaTriagem[i] = null;
      enfermeiraOciosa[i] = true;
    }

    if (enfermeiraOciosa[i]) {
      Paciente proximo = proximoDaTriagem();
      if (proximo != null) {
        liberarAssento(proximo.assentoReservado);

        Coordenada destino = celulaAdjacenteLivre(enfermeiros[i]);
        proximo.destino = destino.copy();
        proximo.estado = EstadoPaciente.INDO_TRIAGEM;

        pacienteNaTriagem[i] = proximo;
        enfermeiraOciosa[i] = false;
       
      }
    }
  }
}

// adjacente à enfermeira que o chamou (estado == INDO_TRIAGEM).
void iniciarAtendimentoTriagem(int idxEnfermeira, Paciente p) {
  p.estado = EstadoPaciente.EM_TRIAGEM;
  fimTriagem[idxEnfermeira] = millisSimulacao() + (long) (sortearTempoTriagem() * 1000);
}