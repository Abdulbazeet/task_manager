class FileAttachment {
  final int id;
  final int taskId;
  final String filename;
  final String originalFilename;
  final String mimeType;
  final int size;
  final String path;
  final DateTime createdAt;

  FileAttachment({
    required this.id,
    required this.taskId,
    required this.filename,
    required this.originalFilename,
    required this.mimeType,
    required this.size,
    required this.path,
    required this.createdAt,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'] as int? ?? 0,
      taskId: json['task_id'] as int? ?? 0,
      filename: json['filename'] as String? ?? '',
      originalFilename: json['original_filename'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      path: json['path'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'filename': filename,
      'original_filename': originalFilename,
      'mime_type': mimeType,
      'size': size,
      'path': path,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
