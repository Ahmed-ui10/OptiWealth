class DataExport {
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
}