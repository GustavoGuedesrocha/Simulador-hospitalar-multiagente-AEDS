class NoFilaAtendimento {

  Paciente paciente;
  NoFilaAtendimento proximo;

  NoFilaAtendimento(Paciente paciente) {
    this.paciente = paciente;
    this.proximo = null;
  }
}


class FilaAtendimento {

  NoFilaAtendimento inicio;
  NoFilaAtendimento fim;

  FilaAtendimento() {
    inicio = null;
    fim = null;
  }


  void enfileirar(Paciente paciente) {

    NoFilaAtendimento novo = new NoFilaAtendimento(paciente);

    if (inicio == null) {
      inicio = novo;
      fim = novo;
    } else {
      fim.proximo = novo;
      fim = novo;
    }
  }


  Paciente desenfileirar() {

    if (inicio == null) {
      return null;
    }

    Paciente paciente = inicio.paciente;
    inicio = inicio.proximo;

    if (inicio == null) {
      fim = null;
    }

    return paciente;
  }


  boolean vazia() {
    return inicio == null;
  }
}