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
  imageUrl: 'https://media.geoportal.com.br/fotos/5/381/a_3_cascavel_lago_municipal_luiz_lorenzetti.jpg',
  possibleSports: ['Corrida', 'Ciclismo', 'Caminhada'],
),
PredefinedLocation(
  name: "Parque Tarquínio Joslin dos Santos",
  description: "Parque ambiental com pista de corrida e academia ao ar livre.",
  coordinates: const GeoPoint(-24.9663, -53.4839),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/06072020-112718-an-parque-tarquinio.jpeg',
  possibleSports: ['Corrida', 'Caminhada'],
),
PredefinedLocation(
  name: "Ginásio Sérgio Mauro Festugatto",
  description: "Ginásio de esportes principal do Complexo Ciro Nardi.",
  coordinates: const GeoPoint(-24.9628, -53.4520), // Coordenada precisa do ginásio
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/06072021-164150-an-ciro-nardi.jpeg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Centro Esportivo Ciro Nardi",
  description: "Complexo esportivo, Piscinas, Quadras e Pistas de Atletismo.",
  coordinates: const GeoPoint(-24.963019, -53.451155),
  imageUrl: 'https://cdn.statically.io/img/www.cbncascavel.com.br/wp-content/uploads/2021/07/Ciro-Nardi-1.jpg',
  possibleSports: ['Futebol', 'Basquete', 'Vôlei', 'Corrida', 'Natação', 'Tênis', 'Atletismo'],
),
PredefinedLocation(
  name: "Praça da Bíblia",
  description: "Praça pública com quadra poliesportiva e área de lazer.",
  coordinates: const GeoPoint(-24.9587, -53.4682),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/10052021-163435-an-praca-da-biblia-foto-aerea-2.jpeg',
  possibleSports: ['Futebol', 'Basquete', 'Vôlei'],
),
PredefinedLocation(
  name: "Ecopark Oeste",
  description: "Parque linear com pista de caminhada, ciclovia e lazer.",
  coordinates: const GeoPoint(-24.9698, -53.4945), // Coordenada precisa
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/21102021-160244-an-ecopark-oeste-foto-aerea-1-1.jpeg',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Complexo Esportivo de Santa Cruz",
  description: "Quadras e campo de grama sintética, Bairro Santa Cruz.",
  coordinates: const GeoPoint(-24.9812, -53.4903), // Coordenada precisa
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/16032023-112102-an-foto-aerea---santa-cruz---credito-nery-a.jpeg',
  possibleSports: ['Futebol', 'Futsal', 'Caminhada'],
),
PredefinedLocation(
  name: "Tuiuti Esporte Clube",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9483, -53.4655), // Coordenada precisa
  imageUrl: 'https://tuiutiesporteclube.com.br/wp-content/uploads/2023/07/foto-aerea-tuiuti-esporte-clube-cascavel-pr.jpg',
  possibleSports: ['Natação', 'Futebol', 'Tênis', 'Vôlei', 'Basquete', 'Academia'],
),
PredefinedLocation(
  name: "Associação Atlética Comercial",
  description: "Clube social/esportivo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9597, -53.4379), // Coordenada precisa
  imageUrl: 'https://www.aaccascavel.com.br/img/fotos-aereas/01.jpg',
  possibleSports: ['Futebol', 'Natação', 'Tênis', 'Bocha', 'Academia'],
),
PredefinedLocation(
  name: "Clube Campestre de Cascavel",
  description: "Clube de campo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9082, -53.4355), // Coordenada precisa
  imageUrl: 'https://clubecampestrecascavel.com.br/wp-content/uploads/2021/04/campestre-aerea-03.jpg',
  possibleSports: ['Golf', 'Tênis', 'Natação', 'Futebol', 'Academia'],
),
PredefinedLocation(
  name: "Cascavel Country Club",
  description: "Clube de campo (Acesso restrito a sócios/convidados)",
  coordinates: const GeoPoint(-24.9205, -53.4903), // Coordenada precisa
  imageUrl: 'https://www.cascavelcountryclub.com.br/uploads/pagina/1/1.jpg',
  possibleSports: ['Tênis', 'Natação', 'Futebol', 'Golf', 'Academia'],
),
PredefinedLocation(
  name: "Univel Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9354, -53.5008), // Coordenada precisa
  imageUrl: 'https://univel.br/storage/images/univel-fachada-aerea.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Academia'],
),
PredefinedLocation(
  name: "FAG - Centro Universitário",
  description: "Instituição de Ensino Superior (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9748, -53.5055), // Coordenada precisa
  imageUrl: 'https://www.fag.edu.br/upload/noticia/fag-tem-conceito-maximo-do-mec-em-recredenciamento-1634668545.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Natação', 'Atletismo', 'Academia'],
),
PredefinedLocation(
  name: "Colégio Marista de Cascavel",
  description: "Escola Particular (Verificar acesso externo às quadras)",
  coordinates: const GeoPoint(-24.9542, -53.4603), // Coordenada precisa
  imageUrl: 'https://marista.org.br/cascavel/wp-content/uploads/sites/4/2019/07/Marista-Cascavel-Fachada-2-1.jpg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol', 'Natação'],
),
PredefinedLocation(
  name: "Autódromo Internacional Zilmar Beux",
  description: "Principal autódromo de Cascavel, sedia grandes eventos e Kart.",
  coordinates: const GeoPoint(-25.0034, -53.3930),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/06092022-102553-an-porsche-cup-autodromo-cascavel-2022-foto-divu.jpeg',
  possibleSports: ['Automobilismo', 'Kart', 'Ciclismo de Estrada', 'Arrancada'],
),
PredefinedLocation(
  name: "Pista de Atletismo (Complexo Ciro Nardi)",
  description: "Pista oficial de atletismo dentro do Complexo Esportivo Ciro Nardi.",
  coordinates: const GeoPoint(-24.9635, -53.4505), // Coordenada específica da pista
  imageUrl: 'https://c1.staticflickr.com/5/4558/38202470222_a4e8d38f8f_b.jpg',
  possibleSports: ['Atletismo', 'Corrida'],
),
PredefinedLocation(
  name: "Ecopark Leste",
  description: "Parque linear com pista de caminhada e ciclovia no Bairro Esmeralda.",
  coordinates: const GeoPoint(-24.9395, -53.4140),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/29062021-163236-an-ecopark-leste.jpeg',
  possibleSports: ['Corrida', 'Caminhada', 'Ciclismo'],
),
PredefinedLocation(
  name: "Ginásio de Esportes da Neva",
  description: "Ginásio público poliesportivo no Bairro Neva.",
  coordinates: const GeoPoint(-24.9654, -53.4646),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/20072021-145457-an-ginasio-da-neva-esta-sendo-revitalizado.jpeg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Handebol'],
),
PredefinedLocation(
  name: "Pista de Skate de Cascavel (Lago)",
  description: "Pista pública de skate e patins, anexa ao Lago Municipal.",
  coordinates: const GeoPoint(-24.9468, -53.4340),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/22092021-104938-an-pista-de-skate---lago-municipal.jpeg',
  possibleSports: ['Skate', 'Patins', 'BMX'],
),
PredefinedLocation(
  name: "Praça do Migrante",
  description: "Praça central com quadra poliesportiva e academia ao ar livre.",
  coordinates: const GeoPoint(-24.9546, -53.4503),
  imageUrl: 'https://www.cascavel.pr.gov.br/arquivos/04112022-111059-an-praca-do-migrante-revitalizada---foto-edgar-ma.jpeg',
  possibleSports: ['Futsal', 'Basquete', 'Vôlei', 'Academia ao ar livre'],
),
PredefinedLocation(
  name: "Arena (Ex: Arena GoOn)", 
  description: "Exemplo de arena privada para Beach Tennis (várias na cidade).",
  coordinates: const GeoPoint(-24.9390, -53.4658),
  imageUrl: 'https://lh3.googleusercontent.com/p/AF1QipOkW-t-m_q_Y76fPz7Vvj80P0-R5j_lP2H1N31j=s1360-w1360-h1020',
  possibleSports: ['Beach Tennis', 'Vôlei de Praia', 'Futevôlei'],
),
];