import '../models/user_model.dart';

class CampusLocationData {
  const CampusLocationData({
    required this.id,
    required this.displayName,
    required this.building,
    required this.floor,
    required this.room,
    required this.x,
    required this.y,
    this.aliases = const <String>[],
  });

  final int id;
  final String displayName;
  final String building;
  final String floor;
  final String room;
  final double x;
  final double y;
  final List<String> aliases;

  String get label => '$id · $displayName';
}

const List<String> kCategories = [
  'All',
  'Academic',
  'Social',
  'Sports',
  'Career',
  'Arts'
];

const List<CampusLocationData> kCampusMapLocations = [
  // Coordinates are normalized against the full 2048x1472 campus_map.jpg
  // asset, including its title, legend, and footer. They are aligned to the
  // official numbered location badges shown on that image.
  CampusLocationData(
    id: 1,
    displayName: 'Administration Building',
    building: 'Administration Building',
    floor: '1',
    room: 'Main Hall',
    x: 0.274,
    y: 0.551,
    aliases: ['Rektorlugu Binasi', 'Rektörlük Binası', 'Administration Building'],
  ),
  CampusLocationData(
    id: 2,
    displayName: 'School of Languages',
    building: 'School of Languages',
    floor: '1',
    room: 'Seminar Hall',
    x: 0.319,
    y: 0.547,
    aliases: ['Diller Okulu', 'School of Languages'],
  ),
  CampusLocationData(
    id: 3,
    displayName: 'Sabancı Business School',
    building: 'Sabancı Business School',
    floor: '1',
    room: 'Lecture Hall',
    x: 0.378,
    y: 0.520,
    aliases: ['Yonetim Bilimleri Fakultesi', 'Yönetim Bilimleri Fakültesi', 'SBS', 'YBF'],
  ),
  CampusLocationData(
    id: 4,
    displayName: 'Faculty of Engineering and Natural Sciences',
    building: 'Faculty of Engineering and Natural Sciences',
    floor: 'B',
    room: '3',
    x: 0.396,
    y: 0.638,
    aliases: [
      'Muhendislik ve Doga Bilimleri Fakultesi',
      'Mühendislik ve Doğa Bilimleri Fakültesi',
      'FENS',
      'MDBF',
      'Engineering Hall B3',
      'Faculty of Engineering and Natural Sciences',
    ],
  ),
  CampusLocationData(
    id: 5,
    displayName: 'Faculty of Arts and Social Sciences',
    building: 'Faculty of Arts and Social Sciences',
    floor: '1',
    room: 'A1',
    x: 0.350,
    y: 0.670,
    aliases: [
      'Sanat ve Sosyal Bilimler Fakultesi',
      'Sanat ve Sosyal Bilimler Fakültesi',
      'FASS',
      'SSBF',
      'Lecture Hall A1',
      'Faculty of Arts and Social Sciences',
    ],
  ),
  CampusLocationData(
    id: 6,
    displayName: 'Art Studios',
    building: 'Art Studios',
    floor: '1',
    room: 'Studio A',
    x: 0.386,
    y: 0.754,
    aliases: ['Sanat Studyolari', 'Sanat Stüdyoları', 'Art Studios'],
  ),
  CampusLocationData(
    id: 7,
    displayName: 'Information Center',
    building: 'Information Center',
    floor: '1',
    room: 'Seminar Room',
    x: 0.325,
    y: 0.690,
    aliases: [
      'Bilgi Merkezi',
      'Information Center',
      'Library',
      'Library Room 204',
    ],
  ),
  CampusLocationData(
    id: 8,
    displayName: 'SUNUM',
    building: 'SUNUM',
    floor: '1',
    room: 'Conference Room',
    x: 0.427,
    y: 0.765,
    aliases: [
      'Nanoteknoloji Araştırma ve Uygulama Merkezi',
      'Nanoteknoloji Arastirma ve Uygulama Merkezi',
      'SUNUM',
    ],
  ),
  CampusLocationData(
    id: 9,
    displayName: 'Main Gate and Security',
    building: 'Main Gate and Security',
    floor: 'Outdoor',
    room: 'Entrance',
    x: 0.168,
    y: 0.756,
    aliases: [
      'Ana Giriş ve Güvenlik',
      'Ana Giris ve Guvenlik',
      'Main Gate and Security',
      'Main Gate',
      'Meet at Main Gate',
    ],
  ),
  CampusLocationData(
    id: 10,
    displayName: 'University Center - Cafeteria',
    building: 'University Center',
    floor: '1',
    room: 'Cafeteria Hall',
    x: 0.435,
    y: 0.596,
    aliases: [
      'Üniversite Merkezi - Yemekhane',
      'Universite Merkezi - Yemekhane',
      'University Center - Cafeteria',
      'University Center',
      'Cafeteria',
      'UC',
      'Main Conference Center',
      'Main Lawn',
      'Student Center Courtyard',
    ],
  ),
  CampusLocationData(
    id: 11,
    displayName: 'Cinema Hall',
    building: 'Cinema Hall',
    floor: '1',
    room: 'Main Hall',
    x: 0.423,
    y: 0.525,
    aliases: ['Sinema Salonu', 'Cinema Hall'],
  ),
  CampusLocationData(
    id: 12,
    displayName: 'Central Plant',
    building: 'Central Plant',
    floor: '1',
    room: 'Meeting Room',
    x: 0.483,
    y: 0.887,
    aliases: ['Kampus İşletim Merkezi', 'Kampüs İşletim Merkezi', 'Central Plant'],
  ),
  CampusLocationData(
    id: 13,
    displayName: 'Performing Arts Center (SGM)',
    building: 'Performing Arts Center (SGM)',
    floor: '1',
    room: 'Main Stage',
    x: 0.227,
    y: 0.480,
    aliases: [
      'Sabanci Gosteri Merkezi',
      'Sabancı Gösteri Merkezi',
      'Performing Arts Center',
      'Performing Arts Center (SGM)',
      'SGM',
      'Student Center Auditorium',
    ],
  ),
  CampusLocationData(
    id: 14,
    displayName: 'Amphitheater',
    building: 'Amphitheater',
    floor: 'Outdoor',
    room: 'Stage Area',
    x: 0.404,
    y: 0.453,
    aliases: ['Amfitiyatro', 'Amphitheater', 'Central Campus Green'],
  ),
  CampusLocationData(
    id: 15,
    displayName: 'President\'s House',
    building: 'President\'s House',
    floor: '1',
    room: 'Reception Hall',
    x: 0.604,
    y: 0.522,
    aliases: ['Rektör Konutu', 'Rektor Konutu', 'President\'s House'],
  ),
  CampusLocationData(
    id: 16,
    displayName: 'Health Center and Social Services',
    building: 'Health Center and Social Services',
    floor: '1',
    room: 'Conference Room',
    x: 0.567,
    y: 0.553,
    aliases: [
      'Sağlık Merkezi ve Sosyal Hizmetler',
      'Saglik Merkezi ve Sosyal Hizmetler',
      'Health Center and Social Services',
    ],
  ),
  CampusLocationData(
    id: 17,
    displayName: 'Nursery School',
    building: 'Nursery School',
    floor: 'Ground',
    room: 'Activity Hall',
    x: 0.507,
    y: 0.736,
    aliases: ['Anaokulu', 'Nursery', 'Nursery School'],
  ),
  CampusLocationData(
    id: 18,
    displayName: 'Student Clubs Buildings',
    building: 'Student Clubs Buildings',
    floor: '1',
    room: 'Event Room',
    x: 0.458,
    y: 0.866,
    aliases: [
      'Öğrenci Kulüp Binaları',
      'Ogrenci Kulup Binalari',
      'Student Clubs Buildings',
      'Student Clubs',
    ],
  ),
  CampusLocationData(
    id: 19,
    displayName: 'Entrepreneurship and Incubation Center',
    building: 'Entrepreneurship and Incubation Center',
    floor: '1',
    room: 'Workshop Hall',
    x: 0.233,
    y: 0.301,
    aliases: [
      'Girişimcilik ve Kuluçka Merkezi',
      'Girisimcilik ve Kulucka Merkezi',
      'Entrepreneurship and Incubation Center',
    ],
  ),
  CampusLocationData(
    id: 20,
    displayName: 'Treatment Plant',
    building: 'Treatment Plant',
    floor: '1',
    room: 'Operations Room',
    x: 0.184,
    y: 0.275,
    aliases: ['Arıtma Tesisi', 'Aritma Tesisi', 'Treatment Plant'],
  ),
  CampusLocationData(
    id: 21,
    displayName: 'Sports Center',
    building: 'Sports Center',
    floor: '1',
    room: 'Court A',
    x: 0.218,
    y: 0.415,
    aliases: [
      'Spor Merkezi',
      'Sports Center',
      'Indoor Sports Complex',
    ],
  ),
  CampusLocationData(
    id: 22,
    displayName: 'Tennis Court',
    building: 'Tennis Court',
    floor: 'Outdoor',
    room: 'Court',
    x: 0.205,
    y: 0.226,
    aliases: ['Kapalı Tenis Kortu', 'Kapali Tenis Kortu', 'Tennis Court'],
  ),
  CampusLocationData(
    id: 23,
    displayName: 'Football Field',
    building: 'Football Field',
    floor: 'Outdoor',
    room: 'Field',
    x: 0.376,
    y: 0.359,
    aliases: ['Futbol Sahası', 'Futbol Sahasi', 'Football Field'],
  ),
  CampusLocationData(
    id: 24,
    displayName: 'Faculty Housing',
    building: 'Faculty Housing',
    floor: 'Ground',
    room: 'Common Area',
    x: 0.488,
    y: 0.762,
    aliases: ['Lojmanlar', 'Faculty Housing'],
  ),
  CampusLocationData(
    id: 25,
    displayName: 'Student Dormitories',
    building: 'Student Dormitories',
    floor: 'Ground',
    room: 'Common Hall',
    x: 0.492,
    y: 0.500,
    aliases: [
      'Öğrenci Yurtları',
      'Ogrenci Yurtlari',
      'Student Dormitories',
      'Dormitories',
    ],
  ),
];

final List<String> kCampusLocations = List<String>.unmodifiable(
  kCampusMapLocations.map((location) => location.label),
);

final Map<String, CampusLocationData> kCampusLocationLookup =
    Map<String, CampusLocationData>.unmodifiable({
      for (final location in kCampusMapLocations) location.label: location,
    });

final Map<String, Map<String, String>> kCampusLocationDetails =
    Map<String, Map<String, String>>.unmodifiable({
      for (final location in kCampusMapLocations)
        location.label: <String, String>{
          'building': location.building,
          'floor': location.floor,
          'room': location.room,
          'label': location.label,
        },
    });

final Map<String, String> kLegacyLocationAliases =
    Map<String, String>.unmodifiable(_buildCampusLocationAliasMap());

String normalizeCampusLocation(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  return kLegacyLocationAliases[_normalizeCampusLocationKey(trimmed)] ?? trimmed;
}

CampusLocationData? findCampusLocation(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return kCampusLocationLookup[normalizeCampusLocation(value)];
}

Map<String, String> _buildCampusLocationAliasMap() {
  final aliases = <String, String>{};
  for (final location in kCampusMapLocations) {
    aliases[_normalizeCampusLocationKey(location.label)] = location.label;
    aliases[_normalizeCampusLocationKey(location.displayName)] = location.label;
    aliases[_normalizeCampusLocationKey(location.building)] = location.label;
    for (final alias in location.aliases) {
      aliases[_normalizeCampusLocationKey(alias)] = location.label;
    }
  }
  return aliases;
}

String _normalizeCampusLocationKey(String value) {
  return value.trim().toLowerCase();
}

const List<String> kDepartments = [
  'Computer Science',
  'Industrial Engineering',
  'Electronics Engineering',
  'Mechatronics',
  'Management',
  'Economics',
  'Psychology',
  'Sociology',
  'Visual Arts & Communication',
  'Political Science',
  'Mathematics',
  'Physics',
  'Molecular Biology',
];

final Map<String, AppUser> kDemoSeeds = {
  'student@sabanciuniv.edu': AppUser(
    uid: 'seed_student',
    email: 'student@sabanciuniv.edu',
    role: 'student',
    firstName: 'Emir',
    lastName: 'Mirza',
    department: 'Computer Science',
    createdAt: DateTime(2026, 1, 1),
  ),
  'cssociety@sabanciuniv.edu': AppUser(
    uid: 'seed_cssociety',
    email: 'cssociety@sabanciuniv.edu',
    role: 'admin',
    firstName: 'CS',
    lastName: 'Society',
    department: 'Club Administrator',
    clubName: 'CS Society',
    createdAt: DateTime(2026, 1, 1),
  ),
};
