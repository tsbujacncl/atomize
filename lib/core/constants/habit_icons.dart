import 'package:flutter/material.dart';

/// Represents a habit icon with its Material Icons data and display name.
class HabitIcon {
  final String id;
  final IconData icon;
  final String label;

  const HabitIcon({
    required this.id,
    required this.icon,
    required this.label,
  });
}

/// Represents a category of habit icons.
class HabitIconCategory {
  final String name;
  final List<HabitIcon> icons;

  const HabitIconCategory({
    required this.name,
    required this.icons,
  });
}

/// Curated set of habit icons organized by category.
const List<HabitIconCategory> habitIconCategories = [
  HabitIconCategory(
    name: 'Health & Fitness',
    icons: [
      HabitIcon(id: 'fitness_center', icon: Icons.fitness_center, label: 'Gym'),
      HabitIcon(id: 'directions_run', icon: Icons.directions_run, label: 'Run'),
      HabitIcon(id: 'directions_walk', icon: Icons.directions_walk, label: 'Walk'),
      HabitIcon(id: 'directions_bike', icon: Icons.directions_bike, label: 'Bike'),
      HabitIcon(id: 'pool', icon: Icons.pool, label: 'Swim'),
      HabitIcon(id: 'self_improvement', icon: Icons.self_improvement, label: 'Yoga'),
      HabitIcon(id: 'sports_martial_arts', icon: Icons.sports_martial_arts, label: 'Martial Arts'),
      HabitIcon(id: 'sports_tennis', icon: Icons.sports_tennis, label: 'Sports'),
      HabitIcon(id: 'hiking', icon: Icons.hiking, label: 'Hiking'),
    ],
  ),
  HabitIconCategory(
    name: 'Mind & Learning',
    icons: [
      HabitIcon(id: 'auto_stories', icon: Icons.auto_stories, label: 'Read'),
      HabitIcon(id: 'school', icon: Icons.school, label: 'Study'),
      HabitIcon(id: 'psychology', icon: Icons.psychology, label: 'Mindfulness'),
      HabitIcon(id: 'lightbulb', icon: Icons.lightbulb_outline, label: 'Learn'),
      HabitIcon(id: 'edit_note', icon: Icons.edit_note, label: 'Write'),
      HabitIcon(id: 'translate', icon: Icons.translate, label: 'Language'),
      HabitIcon(id: 'headphones', icon: Icons.headphones, label: 'Podcast'),
      HabitIcon(id: 'music_note', icon: Icons.music_note, label: 'Music'),
    ],
  ),
  HabitIconCategory(
    name: 'Productivity',
    icons: [
      HabitIcon(id: 'work', icon: Icons.work_outline, label: 'Work'),
      HabitIcon(id: 'laptop', icon: Icons.laptop_mac, label: 'Computer'),
      HabitIcon(id: 'task_alt', icon: Icons.task_alt, label: 'Task'),
      HabitIcon(id: 'schedule', icon: Icons.schedule, label: 'Schedule'),
      HabitIcon(id: 'code', icon: Icons.code, label: 'Code'),
      HabitIcon(id: 'email', icon: Icons.email_outlined, label: 'Email'),
      HabitIcon(id: 'folder', icon: Icons.folder_outlined, label: 'Organize'),
    ],
  ),
  HabitIconCategory(
    name: 'Self-Care',
    icons: [
      HabitIcon(id: 'spa', icon: Icons.spa, label: 'Relax'),
      HabitIcon(id: 'bed', icon: Icons.bed, label: 'Sleep'),
      HabitIcon(id: 'bathtub', icon: Icons.bathtub_outlined, label: 'Bath'),
      HabitIcon(id: 'face', icon: Icons.face, label: 'Skincare'),
      HabitIcon(id: 'favorite', icon: Icons.favorite_outline, label: 'Self-Love'),
      HabitIcon(id: 'mood', icon: Icons.mood, label: 'Mood'),
    ],
  ),
  HabitIconCategory(
    name: 'Social',
    icons: [
      HabitIcon(id: 'people', icon: Icons.people_outline, label: 'Friends'),
      HabitIcon(id: 'family', icon: Icons.family_restroom, label: 'Family'),
      HabitIcon(id: 'call', icon: Icons.call, label: 'Call'),
      HabitIcon(id: 'message', icon: Icons.message_outlined, label: 'Message'),
      HabitIcon(id: 'volunteer', icon: Icons.volunteer_activism, label: 'Give'),
    ],
  ),
  HabitIconCategory(
    name: 'Finance',
    icons: [
      HabitIcon(id: 'savings', icon: Icons.savings, label: 'Save'),
      HabitIcon(id: 'account_balance', icon: Icons.account_balance, label: 'Bank'),
      HabitIcon(id: 'receipt', icon: Icons.receipt_long, label: 'Budget'),
      HabitIcon(id: 'trending_up', icon: Icons.trending_up, label: 'Invest'),
    ],
  ),
  HabitIconCategory(
    name: 'Home',
    icons: [
      HabitIcon(id: 'home', icon: Icons.home_outlined, label: 'Home'),
      HabitIcon(id: 'cleaning', icon: Icons.cleaning_services, label: 'Clean'),
      HabitIcon(id: 'laundry', icon: Icons.local_laundry_service, label: 'Laundry'),
      HabitIcon(id: 'yard', icon: Icons.yard, label: 'Garden'),
      HabitIcon(id: 'pets', icon: Icons.pets, label: 'Pet'),
      HabitIcon(id: 'kitchen', icon: Icons.kitchen, label: 'Kitchen'),
    ],
  ),
  HabitIconCategory(
    name: 'Food & Nutrition',
    icons: [
      HabitIcon(id: 'restaurant', icon: Icons.restaurant, label: 'Meal'),
      HabitIcon(id: 'local_cafe', icon: Icons.local_cafe, label: 'Coffee'),
      HabitIcon(id: 'water_drop', icon: Icons.water_drop, label: 'Water'),
      HabitIcon(id: 'medication', icon: Icons.medication, label: 'Vitamins'),
      HabitIcon(id: 'egg', icon: Icons.egg_alt, label: 'Breakfast'),
      HabitIcon(id: 'apple', icon: Icons.apple, label: 'Fruit'),
    ],
  ),
  HabitIconCategory(
    name: 'Breaking Habits',
    icons: [
      HabitIcon(id: 'smoke_free', icon: Icons.smoke_free, label: 'Smoke-Free'),
      HabitIcon(id: 'no_drinks', icon: Icons.no_drinks, label: 'Alcohol-Free'),
      HabitIcon(id: 'phonelink_erase', icon: Icons.phonelink_erase, label: 'Screen-Free'),
      HabitIcon(id: 'block', icon: Icons.block, label: 'Avoid'),
      HabitIcon(id: 'do_not_disturb', icon: Icons.do_not_disturb_on, label: 'No Distract'),
    ],
  ),
  HabitIconCategory(
    name: 'Creative',
    icons: [
      HabitIcon(id: 'palette', icon: Icons.palette, label: 'Art'),
      HabitIcon(id: 'photo_camera', icon: Icons.photo_camera, label: 'Photo'),
      HabitIcon(id: 'videocam', icon: Icons.videocam, label: 'Video'),
      HabitIcon(id: 'mic', icon: Icons.mic, label: 'Record'),
      HabitIcon(id: 'brush', icon: Icons.brush, label: 'Paint'),
      HabitIcon(id: 'piano', icon: Icons.piano, label: 'Piano'),
    ],
  ),
  HabitIconCategory(
    name: 'Spiritual',
    icons: [
      HabitIcon(id: 'nights_stay', icon: Icons.nights_stay, label: 'Reflect'),
      HabitIcon(id: 'auto_awesome', icon: Icons.auto_awesome, label: 'Gratitude'),
      HabitIcon(id: 'wb_sunny', icon: Icons.wb_sunny_outlined, label: 'Morning'),
      HabitIcon(id: 'nature', icon: Icons.nature_people, label: 'Nature'),
    ],
  ),
  HabitIconCategory(
    name: 'General',
    icons: [
      HabitIcon(id: 'star', icon: Icons.star_outline, label: 'Goal'),
      HabitIcon(id: 'check_circle', icon: Icons.check_circle_outline, label: 'Complete'),
      HabitIcon(id: 'emoji_events', icon: Icons.emoji_events, label: 'Achievement'),
      HabitIcon(id: 'rocket', icon: Icons.rocket_launch, label: 'Launch'),
      HabitIcon(id: 'flag', icon: Icons.flag_outlined, label: 'Milestone'),
      HabitIcon(id: 'timer', icon: Icons.timer, label: 'Timed'),
    ],
  ),
];

/// Get a HabitIcon by its ID. Returns null if not found.
HabitIcon? getHabitIconById(String? id) {
  if (id == null) return null;
  for (final category in habitIconCategories) {
    for (final icon in category.icons) {
      if (icon.id == id) return icon;
    }
  }
  return null;
}

/// Get the IconData for a habit icon ID. Returns a default icon if not found.
IconData getIconData(String? id) {
  return getHabitIconById(id)?.icon ?? Icons.local_fire_department;
}

/// Default icon ID for new habits.
const String defaultHabitIconId = 'star';
