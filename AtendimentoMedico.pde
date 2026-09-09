class AtendimentoMedico {

  FilaAtendimento filaVermelha;
  FilaAtendimento filaLaranja;
  FilaAtendimento filaAmarela;
  FilaAtendimento filaVerde;
  FilaAtendimento filaAzul;


  AtendimentoMedico() {

    filaVermelha = new FilaAtendimento();
    filaLaranja = new FilaAtendimento();
    filaAmarela = new FilaAtendimento();
    filaVerde = new FilaAtendimento();
    filaAzul = new FilaAtendimento();
  }


  void adicionarPaciente(Paciente paciente, String cor) {

    if (cor.equals("VERMELHO")) {
      filaVermelha.enfileirar(paciente);
    }

    else if (cor.equals("LARANJA")) {
      filaLaranja.enfileirar(paciente);
    }

    else if (cor.equals("AMARELO")) {
      filaAmarela.enfileirar(paciente);
    }

    else if (cor.equals("VERDE")) {
      filaVerde.enfileirar(paciente);
    }

    else if (cor.equals("AZUL")) {
      filaAzul.enfileirar(paciente);
    }
  }


  Paciente chamarProximoPaciente() {

    if (!filaVermelha.vazia()) {
      return filaVermelha.desenfileirar();
    }

    if (!filaLaranja.vazia()) {
      return filaLaranja.desenfileirar();
    }

    if (!filaAmarela.vazia()) {
      return filaAmarela.desenfileirar();
    }

    if (!filaVerde.vazia()) {
      return filaVerde.desenfileirar();
    }

    if (!filaAzul.vazia()) {
      return filaAzul.desenfileirar();
    }

    return null;
  }


  void iniciarConsulta(Medico medico, Paciente paciente) {

    if (!medico.ocupado && paciente != null) {
      medico.iniciarAtendimento(paciente);
    }
  }


  Paciente atualizarConsulta(Medico medico) {

    if (medico.atendimentoTerminou()) {
      return medico.finalizarAtendimento();
    }

    return null;
  }


  boolean temPaciente() {

    return !filaVermelha.vazia() ||
           !filaLaranja.vazia() ||
           !filaAmarela.vazia() ||
           !filaVerde.vazia() ||
           !filaAzul.vazia();
  }
}