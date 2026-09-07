import 'package:flutter/material.dart';
import '../models/insurance_product.dart';

/// Static company information and product catalogue for Mayfair Insurance
/// Company Rwanda Ltd. Sourced from the company's public materials.
///
/// NOTE: This is a demonstration/educational app and is not affiliated with
/// or endorsed by Mayfair Insurance Company Rwanda Ltd.
class CompanyData {
  CompanyData._();

  static const String name = 'Mayfair Insurance Company Rwanda';
  static const String shortName = 'Mayfair Rwanda';
  static const String tagline = 'Your trusted general insurance partner';

  static const String about =
      'Mayfair Insurance Company Rwanda Limited is a general insurer '
      'registered with the Rwanda Development Board and licensed by the '
      'National Bank of Rwanda (BNR) since 5th May 2017. We are part of the '
      'Mayfair group of companies operating across East and Central Africa, '
      'offering a wide range of general insurance solutions for individuals '
      'and businesses.';

  static const List<String> regionalPresence = [
    'Kenya',
    'Uganda',
    'Tanzania',
    'Zambia',
    'DR Congo',
    'Rwanda',
  ];

  static const List<CompanyValue> whyChooseUs = [
    CompanyValue(
      icon: Icons.verified_user_outlined,
      title: 'Licensed & Trusted',
      description:
          'Regulated by the National Bank of Rwanda since 2017 with a strong '
          'record of prompt, fair claims settlement.',
    ),
    CompanyValue(
      icon: Icons.public_outlined,
      title: 'Regional Strength',
      description:
          'Backed by the Mayfair group operating in six countries across '
          'East and Central Africa.',
    ),
    CompanyValue(
      icon: Icons.handshake_outlined,
      title: 'Tailored Cover',
      description:
          'Flexible general insurance solutions designed around the needs of '
          'individuals, families and businesses.',
    ),
    CompanyValue(
      icon: Icons.support_agent_outlined,
      title: 'Dedicated Support',
      description:
          'A responsive team and nationwide network of agents ready to '
          'assist you when it matters most.',
    ),
  ];

  static const ContactInfo contact = ContactInfo(
    addressLine1: 'Kigali Heights Building, Ground Floor',
    addressLine2: 'KG 7 Ave, Kigali, Rwanda',
    email: 'info@mayfair.co.rw',
    phone: '+250 788 000 000',
    poBox: 'P.O. Box, Kigali',
    website: 'rw.mayfairinsurance.africa',
    workingHours: 'Mon – Fri: 8:00 AM – 5:00 PM',
  );

  static const List<InsuranceCategory> categories = [
    InsuranceCategory(
      id: 'motor',
      name: 'Motor Insurance',
      tagline: 'Cover for your vehicles on every road',
      description:
          'Protect your private, commercial or trade vehicles against '
          'accidents, theft, fire and third-party liability.',
      icon: Icons.directions_car_filled_outlined,
      plans: [
        InsurancePlan(
          name: 'Motor Comprehensive',
          description:
              'All-round protection covering accidental damage, fire, theft '
              'and third-party liability for your vehicle.',
        ),
        InsurancePlan(
          name: 'Third Party Fire & Theft',
          description:
              'Covers third-party liability plus loss or damage to your '
              'vehicle from fire and theft.',
        ),
        InsurancePlan(
          name: 'Third Party Only',
          description:
              'The mandatory cover for injury or damage you may cause to '
              'other people and their property.',
        ),
        InsurancePlan(
          name: 'Motor Trade',
          description:
              'Internal and external policies for motor traders and '
              'businesses handling vehicles.',
        ),
        InsurancePlan(
          name: 'Goods in Transit',
          description:
              'Protects goods being transported by road against loss or '
              'damage while in transit.',
        ),
      ],
    ),
    InsuranceCategory(
      id: 'property',
      name: 'Property Insurance',
      tagline: 'Safeguard your home and business premises',
      description:
          'Comprehensive protection for buildings, contents and business '
          'operations against fire and allied perils.',
      icon: Icons.home_work_outlined,
      plans: [
        InsurancePlan(
          name: 'Domestic Buildings',
          description:
              'Covers your residential building against fire, floods and '
              'other insured perils.',
        ),
        InsurancePlan(
          name: 'Domestic Contents',
          description:
              'Protects household goods and belongings inside your home.',
        ),
        InsurancePlan(
          name: 'Fire & Allied Perils',
          description:
              'Covers property against fire, lightning, explosion and '
              'related risks.',
        ),
        InsurancePlan(
          name: 'Business Interruption',
          description:
              'Compensates for loss of profits following an insured event '
              'that disrupts your business.',
        ),
        InsurancePlan(
          name: 'Office Comprehensive',
          description:
              'An all-in-one package covering office premises, contents and '
              'associated risks.',
        ),
      ],
    ),
    InsuranceCategory(
      id: 'marine',
      name: 'Marine Insurance',
      tagline: 'Protection for cargo and vessels',
      description:
          'Cover for goods and craft moving by sea, inland waterways and '
          'road, locally and internationally.',
      icon: Icons.sailing_outlined,
      plans: [
        InsurancePlan(
          name: 'Marine Open Cover',
          description:
              'Ongoing cover for regular shipments over an agreed period.',
        ),
        InsurancePlan(
          name: 'Marine Specific',
          description:
              'Cover arranged for a single, specified consignment or voyage.',
        ),
        InsurancePlan(
          name: 'Single Inland Transit',
          description:
              'Protects a specific consignment transported within the country.',
        ),
        InsurancePlan(
          name: 'Craft & Motorboat',
          description:
              'Insures boats and craft against loss or damage on the water.',
        ),
      ],
    ),
    InsuranceCategory(
      id: 'travel',
      name: 'Travel Insurance',
      tagline: 'Travel with peace of mind',
      description:
          'Protection against travel delays, lost baggage and medical '
          'emergencies while you are away from home.',
      icon: Icons.flight_takeoff_outlined,
      plans: [
        InsurancePlan(
          name: 'Travel Cover',
          description:
              'Covers medical emergencies, trip delays, lost baggage and '
              'other travel-related risks abroad.',
        ),
      ],
    ),
    InsuranceCategory(
      id: 'accident',
      name: 'General Accident',
      tagline: 'Liability and miscellaneous cover',
      description:
          'A broad range of covers protecting people, money and businesses '
          'against everyday risks and liabilities.',
      icon: Icons.security_outlined,
      plans: [
        InsurancePlan(
          name: 'All Risks',
          description:
              'Covers portable and valuable items against accidental loss or '
              'damage anywhere.',
        ),
        InsurancePlan(
          name: 'Burglary',
          description:
              'Protects business stock and contents against theft following '
              'forcible entry.',
        ),
        InsurancePlan(
          name: 'Group / Individual Personal Accident',
          description:
              'Pays benefits for accidental injury, disability or death for '
              'individuals or groups.',
        ),
        InsurancePlan(
          name: 'Money',
          description:
              'Covers cash in transit and on premises against loss or theft.',
        ),
        InsurancePlan(
          name: 'Professional Indemnity',
          description:
              'Protects professionals against claims arising from advice or '
              'services provided.',
        ),
        InsurancePlan(
          name: 'Public & Employers’ Liability',
          description:
              'Covers legal liability to the public and to employees for '
              'injury or damage.',
        ),
        InsurancePlan(
          name: 'Fidelity Guarantee',
          description:
              'Protects your business against losses caused by dishonest '
              'employees.',
        ),
      ],
    ),
  ];
}

class CompanyValue {
  final IconData icon;
  final String title;
  final String description;

  const CompanyValue({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class ContactInfo {
  final String addressLine1;
  final String addressLine2;
  final String email;
  final String phone;
  final String poBox;
  final String website;
  final String workingHours;

  const ContactInfo({
    required this.addressLine1,
    required this.addressLine2,
    required this.email,
    required this.phone,
    required this.poBox,
    required this.website,
    required this.workingHours,
  });
}
