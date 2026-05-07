class VisaCheckResult {
  final String applicationNumber;
  final bool found;
  final String? decision;
  final String? source;
  final NearestResult? before;
  final NearestResult? after;

  const VisaCheckResult({
    required this.applicationNumber,
    required this.found,
    this.decision,
    this.source,
    this.before,
    this.after,
  });

  bool get isApproved => decision?.toUpperCase() == 'APPROVED';
  bool get isRefused => decision?.toUpperCase() == 'REFUSED';
}

class NearestResult {
  final String number;
  final String decision;
  final int? difference;

  const NearestResult({
    required this.number,
    required this.decision,
    this.difference,
  });

  bool get isApproved => decision.toUpperCase() == 'APPROVED';

  factory NearestResult.fromJson(Map<String, dynamic> json) => NearestResult(
        number: json['number'] as String,
        decision: json['decision'] as String,
        difference: json['difference'] as int?,
      );
}

class EmbassyStats {
  final int recordCount;
  final bool available;
  final String cadence;

  const EmbassyStats({
    required this.recordCount,
    required this.available,
    required this.cadence,
  });
}
