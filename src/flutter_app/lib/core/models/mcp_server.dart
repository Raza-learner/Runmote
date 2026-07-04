class McpServer {
  final String name;
  final String command;
  final List<String> args;
  final List<Map<String, String>> env;
  final String type;
  final String? url;
  final List<Map<String, String>>? headers;

  const McpServer({
    required this.name,
    required this.command,
    this.args = const [],
    this.env = const [],
    this.type = 'stdio',
    this.url,
    this.headers,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'command': command,
    'args': args,
    'env': env.map((e) => {'name': e['name'], 'value': e['value']}).toList(),
    'type': type,
    if (url != null) 'url': url,
    if (headers != null) 'headers': headers,
  };

  factory McpServer.fromJson(Map<String, dynamic> json) => McpServer(
    name: json['name'] as String,
    command: json['command'] as String,
    args: (json['args'] as List<dynamic>?)?.cast<String>() ?? [],
    env: ((json['env'] as List<dynamic>?) ?? [])
        .map((e) => {
              'name': (e as Map<String, dynamic>)['name'] as String? ?? '',
              'value': e['value'] as String? ?? '',
            })
        .toList(),
    type: json['type'] as String? ?? 'stdio',
    url: json['url'] as String?,
    headers: json['headers'] != null
        ? ((json['headers'] as List<dynamic>)
            .map((e) => {
                  'name': (e as Map<String, dynamic>)['name'] as String? ?? '',
                  'value': e['value'] as String? ?? '',
                })
            .toList())
        : null,
  );
}
