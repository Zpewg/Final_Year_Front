class Journal {
  final int? IdJournal; // ✅ ADĂUGAT: Cheia primară (opțională la creare)
  final int userId;
  final String journalName;
  final String jounralText;

  const Journal({
    this.IdJournal, // ✅ ADĂUGAT
    required this.userId,
    required this.journalName,
    required this.jounralText,
  });

 factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      // ✅ ADĂUGAT 'idJournal' (camelCase, exact cum trimite .NET implicit)
      IdJournal: json['idJournal'] ?? json['IdJournal'] ?? json['id'] ?? json['Id'] ?? 0, 
      userId: json['userId'] as int,
      journalName: json['journalName'] as String,
      jounralText: json['journalText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        "IdJournal": IdJournal ?? 0, // ✅ ADĂUGAT: Trimite ID-ul către backend
        "UserId": userId,
        "JournalName": journalName,
        "JournalText": jounralText,
      };
}