class NoFila<X> {
  X dado;
  NoFila<X> proximo;
  NoFila(X dado) { this.dado = dado; }
}

class Fila<T> {
  NoFila<T> inicio, fim;
  int tamanho = 0;

  void enfileirar(T dado) {
    NoFila<T> novo = new NoFila<T>(dado);
    if (fim == null) { inicio = fim = novo; }
    else { fim.proximo = novo; fim = novo; }
    tamanho++;
  }

  T desenfileirar() {
    if (inicio == null) return null;
    T dado = inicio.dado;
    inicio = inicio.proximo;
    if (inicio == null) fim = null;
    tamanho--;
    return dado;
  }

  boolean vazia() { return inicio == null; }
}