class RegistroForestal {
  final int? id;
  final String numeroSitio;
  final String numeroArbol;
  final String especieNombreComun;
  final double? diametroTocon;
  final double diametroNormal;
  final double alturaTotal;
  final double? diametroCopa;
  // final String? estadoFitosanitario;
  final String? dano;
  final String? vigorosidad;
  final double areaBasal;
  final double volumenCilindro;
  final DateTime fechaRegistro;

  RegistroForestal({
    this.id,
    required this.numeroSitio,
    required this.numeroArbol,
    required this.especieNombreComun,
    this.diametroTocon,
    required this.diametroNormal,
    required this.alturaTotal,
    this.diametroCopa,
    // this.estadoFitosanitario,
    this.dano,
    this.vigorosidad,
    required this.areaBasal,
    required this.volumenCilindro,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroSitio': numeroSitio,
      'numeroArbol': numeroArbol,
      'especieNombreComun': especieNombreComun,
      'diametroTocon': diametroTocon,
      'diametroNormal': diametroNormal,
      'alturaTotal': alturaTotal,
      'diametroCopa': diametroCopa,
      // 'estadoFitosanitario': estadoFitosanitario,
      'dano': dano,
      'vigorosidad': vigorosidad,
      'areaBasal': areaBasal,
      'volumenCilindro': volumenCilindro,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory RegistroForestal.fromMap(Map<String, dynamic> map) {
    return RegistroForestal(
      id: map['id'],
      numeroSitio: map['numeroSitio'],
      numeroArbol: map['numeroArbol'],
      especieNombreComun: map['especieNombreComun'],
      diametroTocon: map['diametroTocon'],
      diametroNormal: map['diametroNormal'],
      alturaTotal: map['alturaTotal'],
      diametroCopa: map['diametroCopa'],
      // estadoFitosanitario: map['estadoFitosanitario'],
      dano: map['dano'],
      vigorosidad: map['vigorosidad'],
      areaBasal: map['areaBasal'],
      volumenCilindro: map['volumenCilindro'],
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
    );
  }
}