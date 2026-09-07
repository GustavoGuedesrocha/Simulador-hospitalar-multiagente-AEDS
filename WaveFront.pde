class WaveFront {

  ListaEncadeada<Coordenada> encontrarCaminho(
    char[][] mapa,
    Coordenada origem,
    Coordenada destino
  ) {

    ListaEncadeada<Coordenada> caminho =
      new ListaEncadeada<Coordenada>();

    if (!coordenadaValida(mapa, origem) ||
        !coordenadaValida(mapa, destino)) {

      return caminho;
    }

    if (origem.equals(destino)) {

      caminho.add(origem.copy());

      return caminho;
    }

    int[][] distancia =
      new int[mapa.length][mapa[0].length];

    for (int i = 0; i < mapa.length; i++) {

      for (int j = 0; j < mapa[i].length; j++) {

        distancia[i][j] = -1;
      }
    }

    ListaEncadeada<Coordenada> frente =
      new ListaEncadeada<Coordenada>();

    frente.add(origem.copy());

    distancia[origem.linha][origem.coluna] = 0;

    int indiceFrente = 0;

    boolean encontrouDestino = false;

    while (indiceFrente < frente.count()) {

      Coordenada atual = frente.get(indiceFrente);

      indiceFrente++;

      if (atual.equals(destino)) {

        encontrouDestino = true;

        break;
      }

      int novaDistancia =
        distancia[atual.linha][atual.coluna] + 1;

      Coordenada cima =
        new Coordenada(
          atual.linha - 1,
          atual.coluna
        );

      if (coordenadaValida(mapa, cima) &&
          distancia[cima.linha][cima.coluna] == -1) {

        distancia[cima.linha][cima.coluna] =
          novaDistancia;

        frente.add(cima);
      }

      Coordenada baixo =
        new Coordenada(
          atual.linha + 1,
          atual.coluna
        );

      if (coordenadaValida(mapa, baixo) &&
          distancia[baixo.linha][baixo.coluna] == -1) {

        distancia[baixo.linha][baixo.coluna] =
          novaDistancia;

        frente.add(baixo);
      }

      Coordenada esquerda =
        new Coordenada(
          atual.linha,
          atual.coluna - 1
        );

      if (coordenadaValida(mapa, esquerda) &&
          distancia[esquerda.linha][esquerda.coluna] == -1) {

        distancia[esquerda.linha][esquerda.coluna] =
          novaDistancia;

        frente.add(esquerda);
      }

      Coordenada direita =
        new Coordenada(
          atual.linha,
          atual.coluna + 1
        );

      if (coordenadaValida(mapa, direita) &&
          distancia[direita.linha][direita.coluna] == -1) {

        distancia[direita.linha][direita.coluna] =
          novaDistancia;

        frente.add(direita);
      }
    }

    if (!encontrouDestino &&
        distancia[destino.linha][destino.coluna] == -1) {

      println(
        "Não existe caminho entre "
        + origem.linha + "," + origem.coluna
        + " e "
        + destino.linha + "," + destino.coluna
      );

      return caminho;
    }

    int tamanhoCaminho =
      distancia[destino.linha][destino.coluna] + 1;

    Coordenada[] caminhoTemporario =
      new Coordenada[tamanhoCaminho];

    Coordenada atual = destino.copy();

    int indice = tamanhoCaminho - 1;

    caminhoTemporario[indice] =
      atual.copy();

    indice--;

    while (!atual.equals(origem)) {

      int distanciaAtual =
        distancia[atual.linha][atual.coluna];

      Coordenada cima =
        new Coordenada(
          atual.linha - 1,
          atual.coluna
        );

      if (coordenadaValida(mapa, cima) &&
          distancia[cima.linha][cima.coluna]
          == distanciaAtual - 1) {

        atual = cima;

      } else {

        Coordenada baixo =
          new Coordenada(
            atual.linha + 1,
            atual.coluna
          );

        if (coordenadaValida(mapa, baixo) &&
            distancia[baixo.linha][baixo.coluna]
            == distanciaAtual - 1) {

          atual = baixo;

        } else {

          Coordenada esquerda =
            new Coordenada(
              atual.linha,
              atual.coluna - 1
            );

          if (coordenadaValida(mapa, esquerda) &&
              distancia[esquerda.linha][esquerda.coluna]
              == distanciaAtual - 1) {

            atual = esquerda;

          } else {

            Coordenada direita =
              new Coordenada(
                atual.linha,
                atual.coluna + 1
              );

            if (coordenadaValida(mapa, direita) &&
                distancia[direita.linha][direita.coluna]
                == distanciaAtual - 1) {

              atual = direita;
            }
          }
        }
      }

      caminhoTemporario[indice] =
        atual.copy();

      indice--;
    }

    for (int i = 0; i < tamanhoCaminho; i++) {

      caminho.add(
        caminhoTemporario[i]
      );
    }

    return caminho;
  }

  boolean coordenadaValida(
    char[][] mapa,
    Coordenada coordenada
  ) {

    if (coordenada.linha < 0) {
      return false;
    }

    if (coordenada.linha >= mapa.length) {
      return false;
    }

    if (coordenada.coluna < 0) {
      return false;
    }

    if (coordenada.coluna >= mapa[coordenada.linha].length) {
      return false;
    }

    if (mapa[coordenada.linha][coordenada.coluna] == '#') {
      return false;
    }

    return true;
  }
}
