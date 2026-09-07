class Paciente {
  
  int id;
  boolean ehPreferencial;
  String senha;
  int assentoReservado = -1;
  
  Coordenada posicao;
  Coordenada destino;
  
  int saturacaoOxigenio;
  float temperaturaCorporal;
  int nivelDor;
  boolean conscienciaAlterada;
  
  EstadoPaciente estado;
  
  Paciente(int id, int numNormal, int numPreferencial, Coordenada posicao, Coordenada destino) {
    this.id = id;
    this.ehPreferencial = random(1) < 0.25 ? true : false;
    
    if(ehPreferencial) {
      this.senha = "P" + numPreferencial;
    } else {
      this.senha = "N" + numNormal;
    }
    
    this.posicao = posicao.copy();
    this.destino = destino.copy();
    
    saturacaoOxigenio = (int) random(70, 100);
    temperaturaCorporal = random(34, 42);
    nivelDor = (int) random(0, 10);
    conscienciaAlterada = random(1) > 0.25 ? false : true;
                          
    this.estado = EstadoPaciente.INDO_TOTEM;
  }
}
