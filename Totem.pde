int contadorSenhaNormal = 0;
int contadorSenhaPreferencial = 0;

// Apenas um paciente interage com o totem por vez.
boolean totemOcupado = false;

void inicializarTotem() {
  contadorSenhaNormal = 0;
  contadorSenhaPreferencial = 0;
  totemOcupado = false;
}

// código de senha no formato N0001 / P0001
// independentes para cada tipo de atendimento.
String gerarSenha(boolean preferencial) {
  if (preferencial) {
    contadorSenhaPreferencial++;
    return "P" + nf(contadorSenhaPreferencial, 4);
  } else {
    contadorSenhaNormal++;
    return "N" + nf(contadorSenhaNormal, 4);
  }
}

void processarTotem(Paciente p, int[][] distanciasAPartirDoPaciente) {
  if (totemOcupado) return; // outro paciente está retirando a senha agora

  totemOcupado = true;

  p.senha = gerarSenha(p.ehPreferencial);

  if (p.ehPreferencial) {
    filaTriagemPreferencial.enfileirar(p);
  } else {
    filaTriagemNormal.enfileirar(p);
  }

  int idxAssento = reservarAssentoMaisProximo(distanciasAPartirDoPaciente);
  if (idxAssento != -1) {
    p.destino = assentos[idxAssento].copy();
    p.assentoReservado = idxAssento;
    p.estado = EstadoPaciente.INDO_ASSENTO_TRIAGEM;
  }
  // se idxAssento == -1 (nenhum assento livre alcançável), o paciente


  totemOcupado = false; 
}