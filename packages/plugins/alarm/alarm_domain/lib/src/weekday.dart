/// Día de la semana, de lunes a domingo (el orden de las fichas de 03.4).
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// El día de [date] (`DateTime.weekday` va de 1, lunes, a 7, domingo).
  static Weekday of(DateTime date) => Weekday.values[date.weekday - 1];

  /// De lunes a viernes.
  static const Set<Weekday> weekdays = <Weekday>{monday, tuesday, wednesday, thursday, friday};

  /// Sábado y domingo.
  static const Set<Weekday> weekend = <Weekday>{saturday, sunday};

  /// Todos.
  static const Set<Weekday> everyDay = <Weekday>{
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  };
}
