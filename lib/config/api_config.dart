const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://juma-jordan-lume.pbp.cs.ui.ac.id',
);

String apiPath(String path) => '$baseUrl$path';
