class Event {
  final int id;
  final String title;
  final String club;
  final String clubId;
  final String date;
  final String time;
  final String loc;
  final String cat;
  final String desc;
  final int rsvp;
  final bool saved;
  final String building;
  final String floor;
  final String room;
  final String? posterUrl;
  final bool deleted;

  Event({
    required this.id,
    required this.title,
    required this.club,
    required this.clubId,
    required this.date,
    required this.time,
    required this.loc,
    required this.cat,
    required this.desc,
    required this.rsvp,
    required this.saved,
    required this.building,
    required this.floor,
    required this.room,
    this.posterUrl,
    this.deleted = false,
  });

  Event copyWith({
    bool? saved,
    int? rsvp,
    String? posterUrl,
    bool? deleted,
  }) => Event(
        id: id,
        title: title,
        club: club,
        clubId: clubId,
        date: date,
        time: time,
        loc: loc,
        cat: cat,
        desc: desc,
        rsvp: rsvp ?? this.rsvp,
        saved: saved ?? this.saved,
        building: building,
        floor: floor,
        room: room,
        posterUrl: posterUrl ?? this.posterUrl,
        deleted: deleted ?? this.deleted,
      );
}
