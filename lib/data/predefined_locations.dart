import 'package:cloud_firestore/cloud_firestore.dart';

class PredefinedLocation {
  final String name;
  final String description; 
  final GeoPoint coordinates;
  final String imageUrl;        
  final List<String> possibleSports;

  PredefinedLocation({
    required this.name,
    required this.description,
    required this.coordinates,
    required this.imageUrl,
    required this.possibleSports,
  });
}

final List<PredefinedLocation> predefinedLocationsCascavel = [
PredefinedLocation(
  name: "Lago Municipal de Cascavel",
  description: "Parque ambiental com calçadão, ideal para corridas e caminhadas.",
  coordinates: const GeoPoint(-24.9458, -53.4322),
  imageUrl: 'https://ibb.co/ccxWbCQX',
  possibleSports: ['Corrida', 'Ciclismo', 'Caminhada'],
),
PredefinedLocation(
  name: "Parque Tarquínio Joslin dos Santos",
  description: "Parque ambiental com pista de corrida e academia ao ar livre.",
  coordinates: const GeoPoint(-24.9663, -53.4839),
  imageUrl: 'https://ibb.co/R4Sj34PZ',
  possibleSports: ['Corrida', 'Caminhada'],
),
PredefinedLocation(
  name: "Ginásio Sérgio Mauro Festugatto",
  description: "Ginásio de esportes principal do Complexo Ciro Nardi.",
  coordinates: const GeoPoint(-24.9628, -53.4520), 
  imageUrl: 'https://ibb.co/M5Psrr53',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Centro Esportivo Ciro Nardi",
  description: "Complexo esportivo, Piscinas, Quadras e Pistas de Atletismo.",
  coordinates: const GeoPoint(-24.963019, -53.451155),
  imageUrl: 'https://ibb.co/4bbXc7n',
  possibleSports: ['Futebol', 'Basquete', 'Vôlei', 'Corrida', 'Natação', 'Tênis', 'Atletismo'],
),
PredefinedLocation(
  name: "Praça da Bíblia",
  description: "Praça pública com quadra poliesportiva e área de lazer.",
  coordinates: const GeoPoint(-24.9587, -53.4682),
  imageUrl: 'https://ibb.co/3mTxYbD1',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Ecopark Oeste",
  description: "Parque linear com pista de caminhada, ciclovia e lazer.",
  coordinates: const GeoPoint(-24.9698, -53.4945), 
  imageUrl: 'https://ibb.co/qYBv48q6',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Tuiuti Esporte Clube",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9483, -53.4655), 
  imageUrl: 'https://ibb.co/sJdgVMkK',
  possibleSports: ['Natação', 'Futebol', 'Tênis', 'Vôlei', 'Basquete', 'Academia'],
),
PredefinedLocation(
  name: "Associação Atlética Comercial",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9597, -53.4379), 
  imageUrl: 'https://ibb.co/j9hdfCz4',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha', 'Academia'],
),
PredefinedLocation(
  name: "Cascavel Country Club",
  description: "Clube de campo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9205, -53.4903), 
  imageUrl: 'https://ibb.co/0R2Yqnq8',
  possibleSports: ['Tênis', 'Natação', 'Futebol', 'Futsal', 'Golf', 'Academia'],
),
PredefinedLocation(
  name: "Univel Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9354, -53.5008), 
  imageUrl: 'https://ibb.co/ccW3pNMB',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Academia'],
),
PredefinedLocation(
  name: "FAG - Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9748, -53.5055), 
  imageUrl: 'https://ibb.co/5XJqyByd',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Natação', 'Atletismo', 'Academia'],
),
PredefinedLocation(
  name: "Colégio Marista de Cascavel",
  description: "Escola Particular (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9542, -53.4603), 
  imageUrl: 'https://ibb.co/gbPdBkkS',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol', 'Natação'],
),
PredefinedLocation(
  name: "Autódromo Internacional Zilmar Beux",
  description: "Principal autódromo de Cascavel, sedia grandes eventos e Kart.",
  coordinates: const GeoPoint(-25.0034, -53.3930),
  imageUrl: 'https://ibb.co/fVX770t9',
  possibleSports: ['Automobilismo', 'Kart', 'Ciclismo de Estrada', 'Arrancada'],
),
PredefinedLocation(
  name: "Pista de Atletismo (Complexo Ciro Nardi)",
  description: "Pista oficial de atletismo dentro do Complexo Esportivo Ciro Nardi.",
  coordinates: const GeoPoint(-24.9635, -53.4505), 
  imageUrl: 'https://ibb.co/RkbhcySc',
  possibleSports: ['Atletismo', 'Corrida'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Neva",
  description: "Ginásio público poliesportivo no Bairro Neva.",
  coordinates: const GeoPoint(-24.9654, -53.4646),
  imageUrl: 'https://ibb.co/KcHRX5gc',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Unioeste",
  description: "Ginásio poliesportivo do campus da Universidade Estadual do Oeste do Paraná.",
  coordinates: const GeoPoint(-24.9315, -53.4210),
  imageUrl: 'https://ibb.co/pvnwgvDk',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Associação Copel (ACC)",
  description: "Clube para funcionários da Copel e associados, com piscinas e quadras.",
  coordinates: const GeoPoint(-24.9754, -53.4418), 
  imageUrl: 'https://ibb.co/RG6Zd2p0',
  possibleSports: ['Natação', 'Futebol Suíço', 'Vôlei', 'Tênis', 'Academia', 'Bocha', 'Futsal', 'Basquete', 'Volei de Praia', 'Futevôlei'],
),
PredefinedLocation(
  name: "Ginásio de Esportes São Cristóvão",
  description: "Ginásio público poliesportivo no Bairro São Cristóvão.",
  coordinates: const GeoPoint(-24.9500, -53.4835),
  imageUrl: 'https://ibb.co/yBb1mBd6',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Parque de Lazer Santa Felicidade",
  description: "Parque com lago (Lago Dourado), pista de caminhada e academia ao ar livre.",
  coordinates: const GeoPoint(-24.9752, -53.4280),
  imageUrl: 'https://ibb.co/bjNSh1ch',
  possibleSports: ['Caminhada', 'Corrida', 'Pesca'],
),
PredefinedLocation(
  name: "Pista de Bicicross de Cascavel",
  description: "Pista oficial de BMX/Bicicross, ao lado do Kartódromo.",
  coordinates: const GeoPoint(-25.0040, -53.3955),
  imageUrl: 'https://ibb.co/r2kmnKBT',
  possibleSports: ['BMX', 'Bicicross'],
),
PredefinedLocation(
  name: "Associação Atlética Coopavel (ACC)",
  description: "Clube de campo da cooperativa (Acesso restrito a sócios/convidados).",
  coordinates: const GeoPoint(-24.9815, -53.3740), 
  imageUrl: 'https://ibb.co/3ysrVJnr',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha'],
),
];