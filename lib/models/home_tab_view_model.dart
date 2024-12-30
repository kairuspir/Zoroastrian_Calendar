import 'calendar_event.dart';
import 'zorastrian_date.dart';

class HomeTabViewModel {
  final ZorastrianDate zorastrianDate;
  final String shahanshahiGeh;
  final String kadmiGeh;
  final String fasliGeh;
  final String chog;
  final List<CalendarEvent> shahanshahiEvents;
  final List<CalendarEvent> kadmiEvents;
  final List<CalendarEvent> fasliEvents;

  const HomeTabViewModel({
    required this.zorastrianDate,
    required this.shahanshahiGeh,
    required this.kadmiGeh,
    required this.fasliGeh,
    required this.chog,
    required this.shahanshahiEvents,
    required this.kadmiEvents,
    required this.fasliEvents,
  });
}
