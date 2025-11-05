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
  imageUrl: 'https://i.ibb.co/7Jb3gRKN/Lago-Municipal-de-Cascavel.jpg',
  possibleSports: ['Corrida', 'Ciclismo', 'Caminhada'],
),
PredefinedLocation(
  name: "Parque Tarquínio Joslin dos Santos",
  description: "Parque ambiental com pista de corrida e academia ao ar livre.",
  coordinates: const GeoPoint(-24.9663, -53.4839),
  imageUrl: 'https://i.ibb.co/0VXsCVZ8/img-EAC2-F1-D5511460830-CCD2-B60-D940-ECA4863-BCE9-E-420x870.png',
  possibleSports: ['Corrida', 'Caminhada'],
),
PredefinedLocation(
  name: "Ginásio Sérgio Mauro Festugatto",
  description: "Ginásio de esportes principal do Complexo Ciro Nardi.",
  coordinates: const GeoPoint(-24.9628, -53.4520), 
  imageUrl: 'https://i.ibb.co/1JRL11Jw/img-9623-A1-FCCA7161-B3-EBA858270-C6969-D19-D18-B6-C4-420x870.png',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Centro Esportivo Ciro Nardi",
  description: "Complexo esportivo, Piscinas, Quadras e Pistas de Atletismo.",
  coordinates: const GeoPoint(-24.963019, -53.451155),
  imageUrl: 'https://i.ibb.co/f33yb2z/Centro-Esportivo-Ciro-Nardi.jpg',
  possibleSports: ['Futebol', 'Basquete', 'Vôlei', 'Corrida', 'Natação', 'Tênis', 'Atletismo'],
),
PredefinedLocation(
  name: "Praça da Bíblia",
  description: "Praça pública com quadra poliesportiva e área de lazer.",
  coordinates: const GeoPoint(-24.9587, -53.4682),
  imageUrl: 'https://i.ibb.co/1G0CJNDZ/a36aaa23-6dfa-4c19-9874-f99b25234163.webp',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Ecopark Oeste",
  description: "Parque linear com pista de caminhada, ciclovia e lazer.",
  coordinates: const GeoPoint(-24.9698, -53.4945), 
  imageUrl: 'https://i.ibb.co/F46Ff1Zp/img-7-FDA5-A2-DA0-AF9448263-BB0-EC4-DAAA54-DD0-D1-EBF2-607x1120.png',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Tuiuti Esporte Clube",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9483, -53.4655), 
  imageUrl: 'https://i.ibb.co/NndFyHQ9/2016-12-09.jpg',
  possibleSports: ['Natação', 'Futebol', 'Tênis', 'Vôlei', 'Basquete', 'Academia'],
),
PredefinedLocation(
  name: "Associação Atlética Comercial",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9597, -53.4379), 
  imageUrl: 'https://i.ibb.co/Kc6YhtDy/20250422192849-big-730x400-6.webp',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha', 'Academia'],
),
PredefinedLocation(
  name: "Cascavel Country Club",
  description: "Clube de campo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9205, -53.4903), 
  imageUrl: 'https://i.ibb.co/21hcqFqm/unnamed.webp',
  possibleSports: ['Tênis', 'Natação', 'Futebol', 'Futsal', 'Golf', 'Academia'],
),
PredefinedLocation(
  name: "Univel Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9354, -53.5008), 
  imageUrl: 'https://i.ibb.co/xSnLcMPk/destque.webp',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Academia'],
),
PredefinedLocation(
  name: "FAG - Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9748, -53.5055), 
  imageUrl: 'https://i.ibb.co/TDNzSmSZ/1634999460.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Natação', 'Atletismo', 'Academia'],
),
PredefinedLocation(
  name: "Colégio Marista de Cascavel",
  description: "Escola Particular (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9542, -53.4603), 
  imageUrl: 'https://i.ibb.co/6c18fjjH/20140661-8e12-4581-af41-d856019978bf.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol', 'Natação'],
),
PredefinedLocation(
  name: "Autódromo Internacional Zilmar Beux",
  description: "Principal autódromo de Cascavel, sedia grandes eventos e Kart.",
  coordinates: const GeoPoint(-25.0034, -53.3930),
  imageUrl: 'https://i.ibb.co/5X1VVcvk/images.jpg',
  possibleSports: ['Automobilismo', 'Kart', 'Ciclismo de Estrada', 'Arrancada'],
),
PredefinedLocation(
  name: "Pista de Atletismo (Complexo Ciro Nardi)",
  description: "Pista oficial de atletismo dentro do Complexo Esportivo Ciro Nardi.",
  coordinates: const GeoPoint(-24.9635, -53.4505), 
  imageUrl: 'https://i.ibb.co/21h8dN6d/img-2xfvw9yh7niezwn48bhplfwcearxurqukae4fory-420x870.png',
  possibleSports: ['Atletismo', 'Corrida'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Neva",
  description: "Ginásio público poliesportivo no Bairro Neva.",
  coordinates: const GeoPoint(-24.9654, -53.4646),
  imageUrl: 'https://i.ibb.co/Ps83Nrys/imagedds.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Unioeste",
  description: "Ginásio poliesportivo do campus da Universidade Estadual do Oeste do Paraná.",
  coordinates: const GeoPoint(-24.9315, -53.4210),
  imageUrl: 'https://i.ibb.co/mCSTmCsP/unioeste.webp',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Associação Copel (ACC)",
  description: "Clube para funcionários da Copel e associados, com piscinas e quadras.",
  coordinates: const GeoPoint(-24.9754, -53.4418), 
  imageUrl: 'https://i.ibb.co/BH6dFLVZ/imagess.jpg',
  possibleSports: ['Natação', 'Futebol Suíço', 'Vôlei', 'Tênis', 'Academia', 'Bocha', 'Futsal', 'Basquete', 'Volei de Praia', 'Futevôlei'],
),
PredefinedLocation(
  name: "Ginásio de Esportes São Cristóvão",
  description: "Ginásio público poliesportivo no Bairro São Cristóvão.",
  coordinates: const GeoPoint(-24.9500, -53.4835),
  imageUrl: 'https://i.ibb.co/S798D75t/img-06-A4-B3837324-BCF18-F3-CD9886-FF2-D859095803-AB-607x1120.png',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Parque de Lazer Santa Felicidade",
  description: "Parque com lago (Lago Dourado), pista de caminhada e academia ao ar livre.",
  coordinates: const GeoPoint(-24.9752, -53.4280),
  imageUrl: 'https://i.ibb.co/1YRDVZFV/img-F229-FEF830-FF43-BE856-A7-E2-D30409953788-E5074-400x400.png',
  possibleSports: ['Caminhada', 'Corrida', 'Pesca'],
),
PredefinedLocation(
  name: "Pista de Bicicross de Cascavel",
  description: "Pista oficial de BMX/Bicicross, ao lado do Kartódromo.",
  coordinates: const GeoPoint(-25.0040, -53.3955),
  imageUrl: 'https://i.ibb.co/F46KGkQN/imagesss.jpg',
  possibleSports: ['BMX', 'Bicicross'],
),
PredefinedLocation(
  name: "Associação Atlética Coopavel (ACC)",
  description: "Clube de campo da cooperativa (Acesso restrito a sócios/convidados).",
  coordinates: const GeoPoint(-24.9815, -53.3740), 
  imageUrl: 'https://i.ibb.co/ccvgRmjg/4efdd2f969559e8b1c92e99f32ded48e.jpg',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha'],
),
];