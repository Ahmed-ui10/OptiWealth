/// Represents the configuration and result of a data export operation.
///
/// This model encapsulates the settings chosen by the user when they 
/// request to download their financial data, such as the format and date range.
class DataExport {
  /// The file format chosen for the export (e.g., 'CSV', 'PDF').
  String exportFormat;
  
  /// The starting date of the period from which data will be exported.
  DateTime dateRangeStart;
  
  /// The ending date of the period from which data will be exported.
  DateTime dateRangeEnd;
  
  /// A flag indicating whether additional metadata or specific data points 
  /// should be included in the export.
  bool dataInclusions;
  
  /// The local file system path where the exported file has been saved.
  /// 
  /// Defaults to an empty string until the file is successfully generated.
  String generatedFilePath;

  /// Creates a new [DataExport] configuration instance.
  DataExport({
    required this.exportFormat,
    required this.dateRangeStart,
    required this.dateRangeEnd,
    required this.dataInclusions,
    this.generatedFilePath = '',
  });
}
