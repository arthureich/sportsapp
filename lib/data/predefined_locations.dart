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
  coordinates: const GeoPoint(-24.964498987669195, -53.43486335578723),
  imageUrl: 'https://i.ibb.co/7Jb3gRKN/Lago-Municipal-de-Cascavel.jpg',
  possibleSports: ['Corrida', 'Ciclismo', 'Caminhada'],
),
PredefinedLocation(
  name: "Parque Tarquínio",
  description: "Parque ambiental com pista de corrida e academia ao ar livre.",
  coordinates: const GeoPoint(-24.971483454203142, -53.460782702184915),
  imageUrl: 'https://i.ibb.co/0VXsCVZ8/img-EAC2-F1-D5511460830-CCD2-B60-D940-ECA4863-BCE9-E-420x870.png',
  possibleSports: ['Corrida', 'Caminhada'],
),
PredefinedLocation(
  name: "Ginásio Sérgio Mauro Festugatto",
  description: "Ginásio de esportes principal do Complexo Ciro Nardi.",
  coordinates: const GeoPoint(-24.96375772996681, -53.452222818778864), 
  imageUrl: 'https://i.ibb.co/1JRL11Jw/img-9623-A1-FCCA7161-B3-EBA858270-C6969-D19-D18-B6-C4-420x870.png',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Centro Esportivo Ciro Nardi",
  description: "Complexo esportivo, Piscinas, Quadras e Pistas de Atletismo.",
  coordinates: const GeoPoint(-24.963191491027555, -53.451235664273774),
  imageUrl: 'https://i.ibb.co/f33yb2z/Centro-Esportivo-Ciro-Nardi.jpg',
  possibleSports: ['Futebol', 'Basquete', 'Vôlei', 'Corrida', 'Natação', 'Tênis', 'Atletismo'],
),
PredefinedLocation(
  name: "Praça da Bíblia",
  description: "Praça pública com quadra poliesportiva e área de lazer.",
  coordinates: const GeoPoint(-24.95397431443637, -53.4769338154346),
  imageUrl: 'https://i.ibb.co/1G0CJNDZ/a36aaa23-6dfa-4c19-9874-f99b25234163.webp',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Ecopark Oeste",
  description: "Parque linear com pista de caminhada, ciclovia e lazer.",
  coordinates: const GeoPoint(-24.9526083126028, -53.4985925805043), 
  imageUrl: 'https://i.ibb.co/F46Ff1Zp/img-7-FDA5-A2-DA0-AF9448263-BB0-EC4-DAAA54-DD0-D1-EBF2-607x1120.png',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Tuiuti Esporte Clube",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.946899904941244, -53.426089488448824), 
  imageUrl: 'https://i.ibb.co/NndFyHQ9/2016-12-09.jpg',
  possibleSports: ['Natação', 'Futebol', 'Tênis', 'Vôlei', 'Basquete', 'Academia'],
),
PredefinedLocation(
  name: "Associação Atlética Comercial",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.95088376592834, -53.48130833283882), 
  imageUrl: 'https://i.ibb.co/Kc6YhtDy/20250422192849-big-730x400-6.webp',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha', 'Academia'],
),
PredefinedLocation(
  name: "Cascavel Country Club",
  description: "Clube de campo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.94295230279352, -53.45036882892808), 
  imageUrl: 'https://i.ibb.co/21hcqFqm/unnamed.webp',
  possibleSports: ['Tênis', 'Natação', 'Futebol', 'Futsal', 'Golf', 'Academia'],
),
PredefinedLocation(
  name: "Univel Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.96129213087781, -53.506749959612485), 
  imageUrl: 'https://i.ibb.co/xSnLcMPk/destque.webp',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Academia'],
),
PredefinedLocation(
  name: "FAG - Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.946960705022736, -53.50828043338493), 
  imageUrl: 'https://i.ibb.co/TDNzSmSZ/1634999460.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Natação', 'Atletismo', 'Academia'],
),
PredefinedLocation(
  name: "Colégio Marista de Cascavel",
  description: "Escola Particular (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.95265079473766, -53.454785798242426), 
  imageUrl: 'https://i.ibb.co/6c18fjjH/20140661-8e12-4581-af41-d856019978bf.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol', 'Natação'],
),
PredefinedLocation(
  name: "Autódromo Internacional Zilmar Beux",
  description: "Principal autódromo de Cascavel, sedia grandes eventos e Kart.",
  coordinates: const GeoPoint(-24.98180015180817, -53.38667246516031),
  imageUrl: 'https://i.ibb.co/5X1VVcvk/images.jpg',
  possibleSports: ['Automobilismo', 'Kart', 'Ciclismo de Estrada', 'Arrancada'],
),
PredefinedLocation(
  name: "Pista de Atletismo (Complexo Ciro Nardi)",
  description: "Pista oficial de atletismo dentro do Complexo Esportivo Ciro Nardi.",
  coordinates: const GeoPoint(-24.96380713770797, -53.45266796045831), 
  imageUrl: 'https://i.ibb.co/21h8dN6d/img-2xfvw9yh7niezwn48bhplfwcearxurqukae4fory-420x870.png',
  possibleSports: ['Atletismo', 'Corrida'],
),
PredefinedLocation(
  name: "Centro Nacional de Treinamento em Atletismo (CNTA)",
  description: "Pista nacional de atletismo. Para uso de atletas federados e competições oficiais.",
  coordinates: const GeoPoint(-24.939689096611488, -53.504118840025704), 
  imageUrl: 'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSzFp9L9y0MDR9AAN9GDMuG4DVy8mLlknhcbO9ZyX0lGt5PnaMHVpOpJ2lHG0RA_hq1vnM1uuypxMRBNvAvIAumI1vCnqVb8uBJApj2oedNgRVA-cr55l1e_NKKHqY0HqMoxO5VM=w426-h240-k-no',
  possibleSports: ['Atletismo', 'Corrida'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Neva",
  description: "Ginásio público poliesportivo no Bairro Neva.",
  coordinates: const GeoPoint(-24.9691359654974, -53.4684632896559),
  imageUrl: 'https://i.ibb.co/Ps83Nrys/imagedds.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Unioeste",
  description: "Ginásio poliesportivo do campus da Universidade Estadual do Oeste do Paraná.",
  coordinates: const GeoPoint(-24.987526674794484, -53.4505854277245),
  imageUrl: 'https://i.ibb.co/mCSTmCsP/unioeste.webp',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Associação Copel (ACC)",
  description: "Clube para funcionários da Copel e associados, com piscinas e quadras.",
  coordinates: const GeoPoint(-24.93401312999294, -53.444026800092885), 
  imageUrl: 'https://i.ibb.co/BH6dFLVZ/imagess.jpg',
  possibleSports: ['Natação', 'Futebol Suíço', 'Vôlei', 'Tênis', 'Academia', 'Bocha', 'Futsal', 'Basquete', 'Volei de Praia', 'Futevôlei'],
),
PredefinedLocation(
  name: "Ginásio de Esportes São Cristóvão",
  description: "Ginásio público poliesportivo no Bairro São Cristóvão.",
  coordinates: const GeoPoint(-24.938523893038102, -53.428818728382325),
  imageUrl: 'https://i.ibb.co/S798D75t/img-06-A4-B3837324-BCF18-F3-CD9886-FF2-D859095803-AB-607x1120.png',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Parque de Lazer Santa Felicidade",
  description: "Parque com lago (Lago Dourado), pista de caminhada e academia ao ar livre.",
  coordinates: const GeoPoint(-24.988747485650084, -53.461340301939956),
  imageUrl: 'https://i.ibb.co/1YRDVZFV/img-F229-FEF830-FF43-BE856-A7-E2-D30409953788-E5074-400x400.png',
  possibleSports: ['Caminhada', 'Corrida', 'Pesca'],
),
PredefinedLocation(
  name: "Pista de Bicicross de Cascavel",
  description: "Pista oficial de BMX/Bicicross, ao lado do Kartódromo.",
  coordinates: const GeoPoint(-24.96990927592811, -53.43293090933921),
  imageUrl: 'https://i.ibb.co/F46KGkQN/imagesss.jpg',
  possibleSports: ['BMX', 'Bicicross'],
),
PredefinedLocation(
  name: "Associação Atlética Coopavel (ACC)",
  description: "Clube de campo da cooperativa (Acesso restrito a sócios/convidados).",
  coordinates: const GeoPoint(-24.910940734659025, -53.48770779890877), 
  imageUrl: 'https://i.ibb.co/ccvgRmjg/4efdd2f969559e8b1c92e99f32ded48e.jpg',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha'],
),
PredefinedLocation(
  name: "Arena Julião Beach Tennis",
  description: "Quadras de Areia na Arena Julião.",
  coordinates: const GeoPoint(-24.94012996010749, -53.44238154971567),
  imageUrl: 'https://i.ibb.co/7W6y2vD/arena-juliao-beach-tennis-cascavel-1.jpg',
  possibleSports: ['Beach Tennis', 'Futevôlei', 'Vôlei de Praia'],
),
PredefinedLocation(
  name: "Arena Match Point",
  description: "Reserva de Quadras de Areia.",
  coordinates: const GeoPoint(-24.953294471602696, -53.475447461938316),
  imageUrl: 'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSx-tEU4dr0cQJBwKbgQRzpi9w1d6Hyrx1GwFp3RxNjdCGHNucOlqu218dNwTI17MtBlMTjnlD6lm2HpsB3Bd0-IfzERKu-e537Xyv9vTHlwmhQngePj6FM-GK7a6V3wtu157AEZ=w408-h306-k-no',
  possibleSports: ['Beach Tennis', 'Futevôlei', 'Vôlei de Praia'],
),
PredefinedLocation(
  name: "Quadra de Tenis do Ciro Nardi",
  description: "Quadra de Tênis no Complexo Esportivo Ciro Nardi.",
  coordinates: const GeoPoint(-24.96418006842266, -53.45148168410769),
  imageUrl: 'https://cdn.cgn.inf.br/fotos-cgn/2025/03/05092030/WhatsApp-Image-2025-03-05-at-09.16.39-880x586.jpeg',
  possibleSports: ['Tênis'],
),
PredefinedLocation(
  name: "Estação Padel Cascavel",
  description: "Quadras de Padel na Estação Padel Cascavel.",
  coordinates: const GeoPoint(-24.947840856904886, -53.48751556423336),
  imageUrl: 'https://lh3.googleusercontent.com/p/AF1QipOFKxLkXhghCJUBCAQjM2w5CoBZb-p0KrdV0MeF=w408-h306-k-no',
  possibleSports: ['Padel'],
),
PredefinedLocation(
  name: "Pista de Skate do Ciro Nardi",
  description: "Pista de Skate no Complexo Esportivo Ciro Nardi.",
  coordinates: const GeoPoint(-24.96164613962427, -53.45090283843761),
  imageUrl: 'https://www.paranaoeste.com.br/arquivos/noticias/23838/nova-pista-de-skate-no-ciro-nardi-recebera-atletas-de-todo-o-pais.jpeg',
  possibleSports: ['Skate', 'BMX'],
),
PredefinedLocation(
  name: "Associação Atlética Comercial Sede Campestre",
  description: "Clube de campo da Associação Atlética Comercial (Acesso restrito a sócios/convidados).",
  coordinates: const GeoPoint(-24.926559354120776, -53.432465981328875),
  imageUrl: 'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSzInh4JxLCKFZ_YZ54mdRdNcqOdASOZYdscGMeDtmfKj676HZ__lOFn-fmnCIByrfO6GTtd04hRsdBRsNJ9HZkoW06RFEX4rZk12ORzmpRAUZka_2DJ4vDisRBtn1G8eMQnSIve=w426-h240-k-no',
  possibleSports: ['Futebol', 'Volei de Praia', 'Natação', 'Beach Tennis'],
),
];