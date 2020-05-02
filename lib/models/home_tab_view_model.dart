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
    this.zorastrianDate,
    this.shahanshahiGeh,
    this.kadmiGeh,
    this.fasliGeh,
    this.chog,
    this.shahanshahiEvents,
    this.kadmiEvents,
    this.fasliEvents,
  });
}
