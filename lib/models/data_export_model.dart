class DataExport
{
  String exportFormat;
  DateTime dateRangeStart;
  DateTime dateRangeEnd;
  bool dataInclusions;
  String generatedFilePath;

  DataExport({
    required this.exportFormat,
    required this.dateRangeStart,
    required this.dateRangeEnd,
    required this.dataInclusions,
    this.generatedFilePath = '',
  });

  factory DataExport.fromJson(Map<String, dynamic> json)
  {
    return DataExport(
      exportFormat: json['exportFormat'],
      dateRangeStart: DateTime.parse(json['dateRangeStart']),
      dateRangeEnd: DateTime.parse(json['dateRangeEnd']),
      dataInclusions: json['dataInclusions'],
      generatedFilePath: json['generatedFilePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'exportFormat': exportFormat,
      'dateRangeStart': dateRangeStart.toIso8601String(),
      'dateRangeEnd': dateRangeEnd.toIso8601String(),
      'dataInclusions': dataInclusions,
      'generatedFilePath': generatedFilePath,
    };
  }

  Future<void> generateAndDownload() async {}
}
