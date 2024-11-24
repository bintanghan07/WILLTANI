class GrafikM {
  final String name;
  final List<String> labels;
  final List<double> data;

  GrafikM({
    required this.name,
    required this.labels,
    required this.data,
  });

  // Factory constructor to create a GrafikM object from a JSON map
  factory GrafikM.fromJson(Map<String, dynamic> json) {
    return GrafikM(
      name: json['name'],
      labels: List<String>.from(json['labels']), // Convert the labels from JSON
      data: List<double>.from(json['data']
          .map((item) => double.parse(item))), // Convert data to double
    );
  }

  // Method to convert a GrafikM object back to JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'labels': labels,
      'data': data
          .map((item) => item.toString())
          .toList(), // Convert double data to string
    };
  }
}
