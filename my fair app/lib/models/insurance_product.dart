import 'package:flutter/material.dart';

/// A top-level category of insurance (e.g. Motor, Property).
class InsuranceCategory {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final IconData icon;
  final List<InsurancePlan> plans;

  const InsuranceCategory({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.plans,
  });
}

/// A specific product / cover within a category.
class InsurancePlan {
  final String name;
  final String description;

  const InsurancePlan({required this.name, required this.description});
}
