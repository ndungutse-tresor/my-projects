import 'base_model.dart';

class Expert extends BaseModel {
  @override
  final String id;
  final String name;
  final String title;
  final String sector;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final int yearsExp;
  final String responseTime;
  final int completedJobs;
  final String about;
  final int startingPrice;
  final List<ExpertService> services;
  final List<ClientReview> reviews;
  final bool isVerified;
  final bool isOnline;

  const Expert({
    required this.id,
    required this.name,
    required this.title,
    required this.sector,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.yearsExp,
    required this.responseTime,
    required this.completedJobs,
    required this.about,
    required this.startingPrice,
    this.services = const [],
    this.reviews = const [],
    this.isVerified = false,
    this.isOnline = false,
  }) : super();

  Expert.preview({
    required this.id,
    required this.name,
    required this.title,
    this.sector = 'General',
    this.avatarUrl = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.yearsExp = 0,
    this.responseTime = 'N/A',
    this.completedJobs = 0,
    this.about = '',
    this.startingPrice = 0,
    this.services = const [],
    this.reviews = const [],
    this.isVerified = false,
    this.isOnline = false,
  }) : super();

  factory Expert.fromMap(Map<String, dynamic> map) {
    final services = (map['services'] as List<dynamic>? ?? [])
        .map((s) => ExpertService.fromMap(s as Map<String, dynamic>))
        .toList();

    final reviews = (map['reviews'] as List<dynamic>? ?? [])
        .map((r) => ClientReview.fromMap(r as Map<String, dynamic>))
        .toList();

    return Expert(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      title: map['title'] as String? ?? '',
      sector: map['sector'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      rating: (map['rating'] as num? ?? 0).toDouble(),
      reviewCount: map['reviewCount'] as int? ?? 0,
      yearsExp: map['yearsExp'] as int? ?? 0,
      responseTime: map['responseTime'] as String? ?? 'N/A',
      completedJobs: map['completedJobs'] as int? ?? 0,
      about: map['about'] as String? ?? '',
      startingPrice: map['startingPrice'] as int? ?? 0,
      services: services,
      reviews: reviews,
      isVerified: map['isVerified'] as bool? ?? false,
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'title': title,
        'sector': sector,
        'avatarUrl': avatarUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'yearsExp': yearsExp,
        'responseTime': responseTime,
        'completedJobs': completedJobs,
        'about': about,
        'startingPrice': startingPrice,
        'services': services.map((s) => s.toMap()).toList(),
        'reviews': reviews.map((r) => r.toMap()).toList(),
        'isVerified': isVerified,
        'isOnline': isOnline,
      };
}

class ExpertService {
  final String icon;
  final String name;
  final String description;
  final int price;

  const ExpertService({
    required this.icon,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ExpertService.fromMap(Map<String, dynamic> map) => ExpertService(
        icon: map['icon'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        price: map['price'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'icon': icon,
        'name': name,
        'description': description,
        'price': price,
      };
}

class ClientReview {
  final String clientName;
  final String avatarUrl;
  final int stars;
  final String comment;
  final String date;

  const ClientReview({
    required this.clientName,
    required this.avatarUrl,
    required this.stars,
    required this.comment,
    required this.date,
  });

  factory ClientReview.fromMap(Map<String, dynamic> map) => ClientReview(
        clientName: map['clientName'] as String? ?? '',
        avatarUrl: map['avatarUrl'] as String? ?? '',
        stars: map['stars'] as int? ?? 0,
        comment: map['comment'] as String? ?? '',
        date: map['date'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'clientName': clientName,
        'avatarUrl': avatarUrl,
        'stars': stars,
        'comment': comment,
        'date': date,
      };
}

const List<Expert> kExperts = [
  Expert(
    id: '1',
    name: 'Marcus Williams',
    title: 'Full-Stack Developer',
    sector: 'Tech & Dev',
    avatarUrl: '',
    rating: 4.9,
    reviewCount: 126,
    yearsExp: 7,
    responseTime: '< 1 hr',
    completedJobs: 312,
    startingPrice: 150000,
    isVerified: true,
    isOnline: true,
    about:
        'I build scalable web and mobile applications. Specializing in Flutter, React, and Node.js with experience delivering enterprise-grade solutions for startups and large organizations alike.',
    services: [
      ExpertService(
        icon: '💻',
        name: 'App Development',
        description: 'Full mobile app built with Flutter or React Native.',
        price: 150000,
      ),
      ExpertService(
        icon: '🌐',
        name: 'Web Development',
        description: 'Responsive websites and web apps.',
        price: 80000,
      ),
    ],
    reviews: [
      ClientReview(
        clientName: 'Sophia Vance',
        avatarUrl: '',
        stars: 5,
        comment:
            'Delivered our app on time with exceptional quality. Highly recommended!',
        date: 'Mar 2025',
      ),
      ClientReview(
        clientName: 'Julian Diaz',
        avatarUrl: '',
        stars: 5,
        comment:
            'Technical proficiency combined with a true artistic sense. Will definitely work with again.',
        date: 'Feb 2025',
      ),
    ],
  ),
  Expert(
    id: '2',
    name: 'Sophia Vance',
    title: 'UI/UX Designer',
    sector: 'Design',
    avatarUrl: '',
    rating: 4.8,
    reviewCount: 98,
    yearsExp: 5,
    responseTime: '< 2 hr',
    completedJobs: 201,
    startingPrice: 55000,
    isVerified: true,
    isOnline: false,
    about:
        'Passionate UI/UX designer with a focus on user-centered design. I create intuitive, beautiful interfaces for mobile and web products that users love.',
    services: [
      ExpertService(
        icon: '🎨',
        name: 'UI Design',
        description: 'High-fidelity mockups and design systems.',
        price: 55000,
      ),
      ExpertService(
        icon: '🔍',
        name: 'UX Research',
        description: 'User interviews, wireframes, and usability testing.',
        price: 40000,
      ),
    ],
    reviews: [
      ClientReview(
        clientName: 'Marcus Williams',
        avatarUrl: '',
        stars: 5,
        comment:
            'Transformed our product visually. Clean, modern, and user-friendly.',
        date: 'Jan 2025',
      ),
    ],
  ),
  Expert(
    id: '3',
    name: 'Julian Vance',
    title: 'Law Consultant',
    sector: 'Legal',
    avatarUrl: '',
    rating: 4.7,
    reviewCount: 75,
    yearsExp: 10,
    responseTime: '< 3 hr',
    completedJobs: 180,
    startingPrice: 250000,
    isVerified: true,
    isOnline: true,
    about:
        'Experienced legal consultant specializing in contract law, intellectual property, and startup advisory. I help individuals and businesses navigate complex legal landscapes.',
    services: [
      ExpertService(
        icon: '📝',
        name: 'Contract Review',
        description: 'Thorough review and drafting of legal contracts.',
        price: 250000,
      ),
    ],
    reviews: [],
  ),
  Expert(
    id: '4',
    name: 'Amara Osei',
    title: 'Financial Advisor',
    sector: 'Finance',
    avatarUrl: '',
    rating: 4.6,
    reviewCount: 54,
    yearsExp: 8,
    responseTime: '< 4 hr',
    completedJobs: 140,
    startingPrice: 120000,
    isVerified: true,
    isOnline: false,
    about:
        'Certified financial advisor helping individuals and SMEs with investment planning, tax optimization, and financial modelling.',
    services: [
      ExpertService(
        icon: '📊',
        name: 'Investment Planning',
        description: 'Personalized investment portfolio strategy.',
        price: 120000,
      ),
    ],
    reviews: [],
  ),
];

const List<String> kSectors = [
  'All',
  'Tech & Dev',
  'Design',
  'Legal',
  'Finance',
  'Education',
  'Marketing',
];

final Set<String> kFeaturedSkills = {
  'Flutter',
  'React',
  'Node.js',
  'UI/UX Design',
  'Figma',
  'Contract Law',
  'Investment Planning',
  'Data Analysis',
  'Python',
  'Financial Modelling',
};
