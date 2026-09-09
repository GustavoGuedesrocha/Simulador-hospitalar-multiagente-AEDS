class Manchester {

  NoManchester[] arvore;

  Manchester() {

    arvore = new NoManchester[31];

    arvore[0] = new NoManchester(false, 3, "==", 1, "");
    arvore[1] = new NoManchester(true, -1, "", 0, "VERMELHO");

    arvore[2] = new NoManchester(false, 0, "<", 92, "");
    arvore[5] = new NoManchester(true, -1, "", 0, "LARANJA");

    arvore[6] = new NoManchester(false, 2, ">=", 8, "");
    arvore[13] = new NoManchester(true, -1, "", 0, "AMARELO");

    arvore[14] = new NoManchester(false, 1, ">=", 38, "");
    arvore[29] = new NoManchester(true, -1, "", 0, "VERDE");

    arvore[30] = new NoManchester(true, -1, "", 0, "AZUL");
  }


  String classificar(Paciente paciente) {

    int indice = 0;

    while (!arvore[indice].folha) {

      NoManchester no = arvore[indice];
      boolean resultado = false;

      if (no.indiceAtributo == 3) {
        resultado = paciente.conscienciaAlterada;
      }

      if (no.indiceAtributo == 0) {
        resultado = paciente.saturacaoOxigenio < no.valorComparacao;
      }

      if (no.indiceAtributo == 2) {
        resultado = paciente.nivelDor >= no.valorComparacao;
      }

      if (no.indiceAtributo == 1) {
        resultado = paciente.temperaturaCorporal >= no.valorComparacao;
      }

      if (resultado) {
        indice = 2 * indice + 1;
      } else {
        indice = 2 * indice + 2;
      }
    }

    return arvore[indice].cor;
  }
}