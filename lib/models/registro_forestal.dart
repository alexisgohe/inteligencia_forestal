import 'dart:convert';

class RegistroForestal {
  final String id; // UUID generado en Flutter
  final String numeroSitio;
  final String numeroArbol;
  final String especieNombreComun;
  final double? diametroTocon;
  final double diametroNormal;
  final double alturaTotal;
  final double? diametroCopa;
  final String? dano;
  final String? vigorosidad;
  final double areaBasal;
  final double volumenCilindro;
  final DateTime fechaRegistro;

  RegistroForestal({
    required this.id,
    required this.numeroSitio,
    required this.numeroArbol,
    required this.especieNombreComun,
    this.diametroTocon,
    required this.diametroNormal,
    required this.alturaTotal,
    this.diametroCopa,
    this.dano,
    this.vigorosidad,
    required this.areaBasal,
    required this.volumenCilindro,
    required this.fechaRegistro,
  });

  // Para insertar en SQLite
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
      'dano': dano,
      'vigorosidad': vigorosidad,
      'areaBasal': areaBasal,
      'volumenCilindro': volumenCilindro,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  // Para enviar al Backend (JSON)
  Map<String, dynamic> toJson() => toMap();

  factory RegistroForestal.fromMap(Map<String, dynamic> map) {
    return RegistroForestal(
      id: map['id'],
      numeroSitio: map['numeroSitio'],
      numeroArbol: map['numeroArbol'],
      especieNombreComun: map['especieNombreComun'],
      diametroTocon: map['diametroTocon']?.toDouble(),
      diametroNormal: map['diametroNormal'].toDouble(),
      alturaTotal: map['alturaTotal'].toDouble(),
      diametroCopa: map['diametroCopa']?.toDouble(),
      dano: map['dano'],
      vigorosidad: map['vigorosidad'],
      areaBasal: map['areaBasal'].toDouble(),
      volumenCilindro: map['volumenCilindro'].toDouble(),
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
    );
  }
}
