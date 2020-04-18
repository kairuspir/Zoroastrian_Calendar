import 'calendar_event.dart';
import 'zorastrian_date.dart';

class HomeTabViewModel {
  final ZorastrianDate zorastrianDate;
  final String shahanshahiGah;
  final String kadmiGah;
  final String fasliGah;
  final String chog;
  final List<CalendarEvent> shahanshahiEvents;
  final List<CalendarEvent> kadmiEvents;
  final List<CalendarEvent> fasliEvents;

  const HomeTabViewModel({
    this.zorastrianDate,
    this.shahanshahiGah,
    this.kadmiGah,
    this.fasliGah,
    this.chog,
    this.shahanshahiEvents,
    this.kadmiEvents,
    this.fasliEvents,
  });
}
