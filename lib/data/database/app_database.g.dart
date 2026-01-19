// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VideosTable extends Videos with TableInfo<$VideosTable, Video> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitlePathMeta = const VerificationMeta(
    'subtitlePath',
  );
  @override
  late final GeneratedColumn<String> subtitlePath = GeneratedColumn<String>(
    'subtitle_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<int> lastPlayedAt = GeneratedColumn<int>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta(
    'lastPositionMs',
  );
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    filePath,
    subtitlePath,
    thumbnailPath,
    durationMs,
    addedAt,
    lastPlayedAt,
    lastPositionMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Video> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('subtitle_path')) {
      context.handle(
        _subtitlePathMeta,
        subtitlePath.isAcceptableOrUnknown(
          data['subtitle_path']!,
          _subtitlePathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(
          data['last_position_ms']!,
          _lastPositionMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Video map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Video(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      subtitlePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle_path'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_at'],
      ),
      lastPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position_ms'],
      )!,
    );
  }

  @override
  $VideosTable createAlias(String alias) {
    return $VideosTable(attachedDatabase, alias);
  }
}

class Video extends DataClass implements Insertable<Video> {
  final String id;
  final String title;
  final String filePath;
  final String? subtitlePath;
  final String? thumbnailPath;
  final int durationMs;
  final int addedAt;
  final int? lastPlayedAt;
  final int lastPositionMs;
  const Video({
    required this.id,
    required this.title,
    required this.filePath,
    this.subtitlePath,
    this.thumbnailPath,
    required this.durationMs,
    required this.addedAt,
    this.lastPlayedAt,
    required this.lastPositionMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || subtitlePath != null) {
      map['subtitle_path'] = Variable<String>(subtitlePath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['added_at'] = Variable<int>(addedAt);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<int>(lastPlayedAt);
    }
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    return map;
  }

  VideosCompanion toCompanion(bool nullToAbsent) {
    return VideosCompanion(
      id: Value(id),
      title: Value(title),
      filePath: Value(filePath),
      subtitlePath: subtitlePath == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitlePath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      durationMs: Value(durationMs),
      addedAt: Value(addedAt),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      lastPositionMs: Value(lastPositionMs),
    );
  }

  factory Video.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Video(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      subtitlePath: serializer.fromJson<String?>(json['subtitlePath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
      lastPlayedAt: serializer.fromJson<int?>(json['lastPlayedAt']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'subtitlePath': serializer.toJson<String?>(subtitlePath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'durationMs': serializer.toJson<int>(durationMs),
      'addedAt': serializer.toJson<int>(addedAt),
      'lastPlayedAt': serializer.toJson<int?>(lastPlayedAt),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
    };
  }

  Video copyWith({
    String? id,
    String? title,
    String? filePath,
    Value<String?> subtitlePath = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    int? durationMs,
    int? addedAt,
    Value<int?> lastPlayedAt = const Value.absent(),
    int? lastPositionMs,
  }) => Video(
    id: id ?? this.id,
    title: title ?? this.title,
    filePath: filePath ?? this.filePath,
    subtitlePath: subtitlePath.present ? subtitlePath.value : this.subtitlePath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    durationMs: durationMs ?? this.durationMs,
    addedAt: addedAt ?? this.addedAt,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
  );
  Video copyWithCompanion(VideosCompanion data) {
    return Video(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      subtitlePath: data.subtitlePath.present
          ? data.subtitlePath.value
          : this.subtitlePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      lastPositionMs: data.lastPositionMs.present
          ? data.lastPositionMs.value
          : this.lastPositionMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Video(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('subtitlePath: $subtitlePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('durationMs: $durationMs, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('lastPositionMs: $lastPositionMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    filePath,
    subtitlePath,
    thumbnailPath,
    durationMs,
    addedAt,
    lastPlayedAt,
    lastPositionMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Video &&
          other.id == this.id &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.subtitlePath == this.subtitlePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.durationMs == this.durationMs &&
          other.addedAt == this.addedAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.lastPositionMs == this.lastPositionMs);
}

class VideosCompanion extends UpdateCompanion<Video> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> filePath;
  final Value<String?> subtitlePath;
  final Value<String?> thumbnailPath;
  final Value<int> durationMs;
  final Value<int> addedAt;
  final Value<int?> lastPlayedAt;
  final Value<int> lastPositionMs;
  final Value<int> rowid;
  const VideosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.subtitlePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideosCompanion.insert({
    required String id,
    required String title,
    required String filePath,
    this.subtitlePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int addedAt,
    this.lastPlayedAt = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       filePath = Value(filePath),
       addedAt = Value(addedAt);
  static Insertable<Video> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? subtitlePath,
    Expression<String>? thumbnailPath,
    Expression<int>? durationMs,
    Expression<int>? addedAt,
    Expression<int>? lastPlayedAt,
    Expression<int>? lastPositionMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (subtitlePath != null) 'subtitle_path': subtitlePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (addedAt != null) 'added_at': addedAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideosCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? filePath,
    Value<String?>? subtitlePath,
    Value<String?>? thumbnailPath,
    Value<int>? durationMs,
    Value<int>? addedAt,
    Value<int?>? lastPlayedAt,
    Value<int>? lastPositionMs,
    Value<int>? rowid,
  }) {
    return VideosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationMs: durationMs ?? this.durationMs,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (subtitlePath.present) {
      map['subtitle_path'] = Variable<String>(subtitlePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<int>(lastPlayedAt.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('subtitlePath: $subtitlePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('durationMs: $durationMs, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtitlesTable extends Subtitles
    with TableInfo<$SubtitlesTable, Subtitle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtitlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleIndexMeta = const VerificationMeta(
    'subtitleIndex',
  );
  @override
  late final GeneratedColumn<int> subtitleIndex = GeneratedColumn<int>(
    'subtitle_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMsMeta = const VerificationMeta(
    'startTimeMs',
  );
  @override
  late final GeneratedColumn<int> startTimeMs = GeneratedColumn<int>(
    'start_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMsMeta = const VerificationMeta(
    'endTimeMs',
  );
  @override
  late final GeneratedColumn<int> endTimeMs = GeneratedColumn<int>(
    'end_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    videoId,
    subtitleIndex,
    startTimeMs,
    endTimeMs,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtitles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtitle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('subtitle_index')) {
      context.handle(
        _subtitleIndexMeta,
        subtitleIndex.isAcceptableOrUnknown(
          data['subtitle_index']!,
          _subtitleIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtitleIndexMeta);
    }
    if (data.containsKey('start_time_ms')) {
      context.handle(
        _startTimeMsMeta,
        startTimeMs.isAcceptableOrUnknown(
          data['start_time_ms']!,
          _startTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeMsMeta);
    }
    if (data.containsKey('end_time_ms')) {
      context.handle(
        _endTimeMsMeta,
        endTimeMs.isAcceptableOrUnknown(data['end_time_ms']!, _endTimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subtitle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subtitle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      subtitleIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtitle_index'],
      )!,
      startTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_ms'],
      )!,
      endTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_ms'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $SubtitlesTable createAlias(String alias) {
    return $SubtitlesTable(attachedDatabase, alias);
  }
}

class Subtitle extends DataClass implements Insertable<Subtitle> {
  final int id;
  final String videoId;
  final int subtitleIndex;
  final int startTimeMs;
  final int endTimeMs;
  final String content;
  const Subtitle({
    required this.id,
    required this.videoId,
    required this.subtitleIndex,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['video_id'] = Variable<String>(videoId);
    map['subtitle_index'] = Variable<int>(subtitleIndex);
    map['start_time_ms'] = Variable<int>(startTimeMs);
    map['end_time_ms'] = Variable<int>(endTimeMs);
    map['content'] = Variable<String>(content);
    return map;
  }

  SubtitlesCompanion toCompanion(bool nullToAbsent) {
    return SubtitlesCompanion(
      id: Value(id),
      videoId: Value(videoId),
      subtitleIndex: Value(subtitleIndex),
      startTimeMs: Value(startTimeMs),
      endTimeMs: Value(endTimeMs),
      content: Value(content),
    );
  }

  factory Subtitle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subtitle(
      id: serializer.fromJson<int>(json['id']),
      videoId: serializer.fromJson<String>(json['videoId']),
      subtitleIndex: serializer.fromJson<int>(json['subtitleIndex']),
      startTimeMs: serializer.fromJson<int>(json['startTimeMs']),
      endTimeMs: serializer.fromJson<int>(json['endTimeMs']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'videoId': serializer.toJson<String>(videoId),
      'subtitleIndex': serializer.toJson<int>(subtitleIndex),
      'startTimeMs': serializer.toJson<int>(startTimeMs),
      'endTimeMs': serializer.toJson<int>(endTimeMs),
      'content': serializer.toJson<String>(content),
    };
  }

  Subtitle copyWith({
    int? id,
    String? videoId,
    int? subtitleIndex,
    int? startTimeMs,
    int? endTimeMs,
    String? content,
  }) => Subtitle(
    id: id ?? this.id,
    videoId: videoId ?? this.videoId,
    subtitleIndex: subtitleIndex ?? this.subtitleIndex,
    startTimeMs: startTimeMs ?? this.startTimeMs,
    endTimeMs: endTimeMs ?? this.endTimeMs,
    content: content ?? this.content,
  );
  Subtitle copyWithCompanion(SubtitlesCompanion data) {
    return Subtitle(
      id: data.id.present ? data.id.value : this.id,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      subtitleIndex: data.subtitleIndex.present
          ? data.subtitleIndex.value
          : this.subtitleIndex,
      startTimeMs: data.startTimeMs.present
          ? data.startTimeMs.value
          : this.startTimeMs,
      endTimeMs: data.endTimeMs.present ? data.endTimeMs.value : this.endTimeMs,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subtitle(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('subtitleIndex: $subtitleIndex, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, videoId, subtitleIndex, startTimeMs, endTimeMs, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtitle &&
          other.id == this.id &&
          other.videoId == this.videoId &&
          other.subtitleIndex == this.subtitleIndex &&
          other.startTimeMs == this.startTimeMs &&
          other.endTimeMs == this.endTimeMs &&
          other.content == this.content);
}

class SubtitlesCompanion extends UpdateCompanion<Subtitle> {
  final Value<int> id;
  final Value<String> videoId;
  final Value<int> subtitleIndex;
  final Value<int> startTimeMs;
  final Value<int> endTimeMs;
  final Value<String> content;
  const SubtitlesCompanion({
    this.id = const Value.absent(),
    this.videoId = const Value.absent(),
    this.subtitleIndex = const Value.absent(),
    this.startTimeMs = const Value.absent(),
    this.endTimeMs = const Value.absent(),
    this.content = const Value.absent(),
  });
  SubtitlesCompanion.insert({
    this.id = const Value.absent(),
    required String videoId,
    required int subtitleIndex,
    required int startTimeMs,
    required int endTimeMs,
    required String content,
  }) : videoId = Value(videoId),
       subtitleIndex = Value(subtitleIndex),
       startTimeMs = Value(startTimeMs),
       endTimeMs = Value(endTimeMs),
       content = Value(content);
  static Insertable<Subtitle> custom({
    Expression<int>? id,
    Expression<String>? videoId,
    Expression<int>? subtitleIndex,
    Expression<int>? startTimeMs,
    Expression<int>? endTimeMs,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoId != null) 'video_id': videoId,
      if (subtitleIndex != null) 'subtitle_index': subtitleIndex,
      if (startTimeMs != null) 'start_time_ms': startTimeMs,
      if (endTimeMs != null) 'end_time_ms': endTimeMs,
      if (content != null) 'content': content,
    });
  }

  SubtitlesCompanion copyWith({
    Value<int>? id,
    Value<String>? videoId,
    Value<int>? subtitleIndex,
    Value<int>? startTimeMs,
    Value<int>? endTimeMs,
    Value<String>? content,
  }) {
    return SubtitlesCompanion(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      subtitleIndex: subtitleIndex ?? this.subtitleIndex,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      endTimeMs: endTimeMs ?? this.endTimeMs,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (subtitleIndex.present) {
      map['subtitle_index'] = Variable<int>(subtitleIndex.value);
    }
    if (startTimeMs.present) {
      map['start_time_ms'] = Variable<int>(startTimeMs.value);
    }
    if (endTimeMs.present) {
      map['end_time_ms'] = Variable<int>(endTimeMs.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtitlesCompanion(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('subtitleIndex: $subtitleIndex, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

class $VocabularyWordsTable extends VocabularyWords
    with TableInfo<$VocabularyWordsTable, VocabularyWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoTitleMeta = const VerificationMeta(
    'videoTitle',
  );
  @override
  late final GeneratedColumn<String> videoTitle = GeneratedColumn<String>(
    'video_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextSentenceMeta = const VerificationMeta(
    'contextSentence',
  );
  @override
  late final GeneratedColumn<String> contextSentence = GeneratedColumn<String>(
    'context_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<int> savedAt = GeneratedColumn<int>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<int> lastReviewedAt = GeneratedColumn<int>(
    'last_reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<int> nextReviewAt = GeneratedColumn<int>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    partOfSpeech,
    definition,
    example,
    phonetic,
    audioUrl,
    videoId,
    videoTitle,
    timestampMs,
    contextSentence,
    savedAt,
    lastReviewedAt,
    reviewCount,
    correctCount,
    easeFactor,
    intervalDays,
    nextReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('video_title')) {
      context.handle(
        _videoTitleMeta,
        videoTitle.isAcceptableOrUnknown(data['video_title']!, _videoTitleMeta),
      );
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('context_sentence')) {
      context.handle(
        _contextSentenceMeta,
        contextSentence.isAcceptableOrUnknown(
          data['context_sentence']!,
          _contextSentenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextSentenceMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      ),
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      ),
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      videoTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_title'],
      ),
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      contextSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_sentence'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_at'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_review_at'],
      ),
    );
  }

  @override
  $VocabularyWordsTable createAlias(String alias) {
    return $VocabularyWordsTable(attachedDatabase, alias);
  }
}

class VocabularyWord extends DataClass implements Insertable<VocabularyWord> {
  final String id;
  final String word;
  final String? partOfSpeech;
  final String? definition;
  final String? example;
  final String? phonetic;
  final String? audioUrl;
  final String videoId;
  final String? videoTitle;
  final int timestampMs;
  final String contextSentence;
  final int savedAt;
  final int? lastReviewedAt;
  final int reviewCount;
  final int correctCount;
  final double easeFactor;
  final int intervalDays;
  final int? nextReviewAt;
  const VocabularyWord({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.definition,
    this.example,
    this.phonetic,
    this.audioUrl,
    required this.videoId,
    this.videoTitle,
    required this.timestampMs,
    required this.contextSentence,
    required this.savedAt,
    this.lastReviewedAt,
    required this.reviewCount,
    required this.correctCount,
    required this.easeFactor,
    required this.intervalDays,
    this.nextReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    if (!nullToAbsent || definition != null) {
      map['definition'] = Variable<String>(definition);
    }
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    map['video_id'] = Variable<String>(videoId);
    if (!nullToAbsent || videoTitle != null) {
      map['video_title'] = Variable<String>(videoTitle);
    }
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['context_sentence'] = Variable<String>(contextSentence);
    map['saved_at'] = Variable<int>(savedAt);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<int>(lastReviewedAt);
    }
    map['review_count'] = Variable<int>(reviewCount);
    map['correct_count'] = Variable<int>(correctCount);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<int>(nextReviewAt);
    }
    return map;
  }

  VocabularyWordsCompanion toCompanion(bool nullToAbsent) {
    return VocabularyWordsCompanion(
      id: Value(id),
      word: Value(word),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      definition: definition == null && nullToAbsent
          ? const Value.absent()
          : Value(definition),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      videoId: Value(videoId),
      videoTitle: videoTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(videoTitle),
      timestampMs: Value(timestampMs),
      contextSentence: Value(contextSentence),
      savedAt: Value(savedAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      reviewCount: Value(reviewCount),
      correctCount: Value(correctCount),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
    );
  }

  factory VocabularyWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyWord(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      definition: serializer.fromJson<String?>(json['definition']),
      example: serializer.fromJson<String?>(json['example']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      videoId: serializer.fromJson<String>(json['videoId']),
      videoTitle: serializer.fromJson<String?>(json['videoTitle']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      contextSentence: serializer.fromJson<String>(json['contextSentence']),
      savedAt: serializer.fromJson<int>(json['savedAt']),
      lastReviewedAt: serializer.fromJson<int?>(json['lastReviewedAt']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      nextReviewAt: serializer.fromJson<int?>(json['nextReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'definition': serializer.toJson<String?>(definition),
      'example': serializer.toJson<String?>(example),
      'phonetic': serializer.toJson<String?>(phonetic),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'videoId': serializer.toJson<String>(videoId),
      'videoTitle': serializer.toJson<String?>(videoTitle),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'contextSentence': serializer.toJson<String>(contextSentence),
      'savedAt': serializer.toJson<int>(savedAt),
      'lastReviewedAt': serializer.toJson<int?>(lastReviewedAt),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'correctCount': serializer.toJson<int>(correctCount),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'nextReviewAt': serializer.toJson<int?>(nextReviewAt),
    };
  }

  VocabularyWord copyWith({
    String? id,
    String? word,
    Value<String?> partOfSpeech = const Value.absent(),
    Value<String?> definition = const Value.absent(),
    Value<String?> example = const Value.absent(),
    Value<String?> phonetic = const Value.absent(),
    Value<String?> audioUrl = const Value.absent(),
    String? videoId,
    Value<String?> videoTitle = const Value.absent(),
    int? timestampMs,
    String? contextSentence,
    int? savedAt,
    Value<int?> lastReviewedAt = const Value.absent(),
    int? reviewCount,
    int? correctCount,
    double? easeFactor,
    int? intervalDays,
    Value<int?> nextReviewAt = const Value.absent(),
  }) => VocabularyWord(
    id: id ?? this.id,
    word: word ?? this.word,
    partOfSpeech: partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
    definition: definition.present ? definition.value : this.definition,
    example: example.present ? example.value : this.example,
    phonetic: phonetic.present ? phonetic.value : this.phonetic,
    audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
    videoId: videoId ?? this.videoId,
    videoTitle: videoTitle.present ? videoTitle.value : this.videoTitle,
    timestampMs: timestampMs ?? this.timestampMs,
    contextSentence: contextSentence ?? this.contextSentence,
    savedAt: savedAt ?? this.savedAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    reviewCount: reviewCount ?? this.reviewCount,
    correctCount: correctCount ?? this.correctCount,
    easeFactor: easeFactor ?? this.easeFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
  );
  VocabularyWord copyWithCompanion(VocabularyWordsCompanion data) {
    return VocabularyWord(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      example: data.example.present ? data.example.value : this.example,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      videoTitle: data.videoTitle.present
          ? data.videoTitle.value
          : this.videoTitle,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      contextSentence: data.contextSentence.present
          ? data.contextSentence.value
          : this.contextSentence,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyWord(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('phonetic: $phonetic, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('videoId: $videoId, ')
          ..write('videoTitle: $videoTitle, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('savedAt: $savedAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    partOfSpeech,
    definition,
    example,
    phonetic,
    audioUrl,
    videoId,
    videoTitle,
    timestampMs,
    contextSentence,
    savedAt,
    lastReviewedAt,
    reviewCount,
    correctCount,
    easeFactor,
    intervalDays,
    nextReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyWord &&
          other.id == this.id &&
          other.word == this.word &&
          other.partOfSpeech == this.partOfSpeech &&
          other.definition == this.definition &&
          other.example == this.example &&
          other.phonetic == this.phonetic &&
          other.audioUrl == this.audioUrl &&
          other.videoId == this.videoId &&
          other.videoTitle == this.videoTitle &&
          other.timestampMs == this.timestampMs &&
          other.contextSentence == this.contextSentence &&
          other.savedAt == this.savedAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.reviewCount == this.reviewCount &&
          other.correctCount == this.correctCount &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.nextReviewAt == this.nextReviewAt);
}

class VocabularyWordsCompanion extends UpdateCompanion<VocabularyWord> {
  final Value<String> id;
  final Value<String> word;
  final Value<String?> partOfSpeech;
  final Value<String?> definition;
  final Value<String?> example;
  final Value<String?> phonetic;
  final Value<String?> audioUrl;
  final Value<String> videoId;
  final Value<String?> videoTitle;
  final Value<int> timestampMs;
  final Value<String> contextSentence;
  final Value<int> savedAt;
  final Value<int?> lastReviewedAt;
  final Value<int> reviewCount;
  final Value<int> correctCount;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<int?> nextReviewAt;
  final Value<int> rowid;
  const VocabularyWordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.videoId = const Value.absent(),
    this.videoTitle = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.contextSentence = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocabularyWordsCompanion.insert({
    required String id,
    required String word,
    this.partOfSpeech = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.audioUrl = const Value.absent(),
    required String videoId,
    this.videoTitle = const Value.absent(),
    required int timestampMs,
    required String contextSentence,
    required int savedAt,
    this.lastReviewedAt = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       videoId = Value(videoId),
       timestampMs = Value(timestampMs),
       contextSentence = Value(contextSentence),
       savedAt = Value(savedAt);
  static Insertable<VocabularyWord> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? partOfSpeech,
    Expression<String>? definition,
    Expression<String>? example,
    Expression<String>? phonetic,
    Expression<String>? audioUrl,
    Expression<String>? videoId,
    Expression<String>? videoTitle,
    Expression<int>? timestampMs,
    Expression<String>? contextSentence,
    Expression<int>? savedAt,
    Expression<int>? lastReviewedAt,
    Expression<int>? reviewCount,
    Expression<int>? correctCount,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<int>? nextReviewAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (definition != null) 'definition': definition,
      if (example != null) 'example': example,
      if (phonetic != null) 'phonetic': phonetic,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (videoId != null) 'video_id': videoId,
      if (videoTitle != null) 'video_title': videoTitle,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (contextSentence != null) 'context_sentence': contextSentence,
      if (savedAt != null) 'saved_at': savedAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (reviewCount != null) 'review_count': reviewCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocabularyWordsCompanion copyWith({
    Value<String>? id,
    Value<String>? word,
    Value<String?>? partOfSpeech,
    Value<String?>? definition,
    Value<String?>? example,
    Value<String?>? phonetic,
    Value<String?>? audioUrl,
    Value<String>? videoId,
    Value<String?>? videoTitle,
    Value<int>? timestampMs,
    Value<String>? contextSentence,
    Value<int>? savedAt,
    Value<int?>? lastReviewedAt,
    Value<int>? reviewCount,
    Value<int>? correctCount,
    Value<double>? easeFactor,
    Value<int>? intervalDays,
    Value<int?>? nextReviewAt,
    Value<int>? rowid,
  }) {
    return VocabularyWordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      videoId: videoId ?? this.videoId,
      videoTitle: videoTitle ?? this.videoTitle,
      timestampMs: timestampMs ?? this.timestampMs,
      contextSentence: contextSentence ?? this.contextSentence,
      savedAt: savedAt ?? this.savedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (videoTitle.present) {
      map['video_title'] = Variable<String>(videoTitle.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (contextSentence.present) {
      map['context_sentence'] = Variable<String>(contextSentence.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<int>(savedAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<int>(lastReviewedAt.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<int>(nextReviewAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyWordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('phonetic: $phonetic, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('videoId: $videoId, ')
          ..write('videoTitle: $videoTitle, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('savedAt: $savedAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewClipsTable extends ReviewClips
    with TableInfo<$ReviewClipsTable, ReviewClip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewClipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clipStartMsMeta = const VerificationMeta(
    'clipStartMs',
  );
  @override
  late final GeneratedColumn<int> clipStartMs = GeneratedColumn<int>(
    'clip_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clipEndMsMeta = const VerificationMeta(
    'clipEndMs',
  );
  @override
  late final GeneratedColumn<int> clipEndMs = GeneratedColumn<int>(
    'clip_end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clipPathMeta = const VerificationMeta(
    'clipPath',
  );
  @override
  late final GeneratedColumn<String> clipPath = GeneratedColumn<String>(
    'clip_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabularyId,
    videoId,
    clipStartMs,
    clipEndMs,
    clipPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_clips';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewClip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('clip_start_ms')) {
      context.handle(
        _clipStartMsMeta,
        clipStartMs.isAcceptableOrUnknown(
          data['clip_start_ms']!,
          _clipStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clipStartMsMeta);
    }
    if (data.containsKey('clip_end_ms')) {
      context.handle(
        _clipEndMsMeta,
        clipEndMs.isAcceptableOrUnknown(data['clip_end_ms']!, _clipEndMsMeta),
      );
    } else if (isInserting) {
      context.missing(_clipEndMsMeta);
    }
    if (data.containsKey('clip_path')) {
      context.handle(
        _clipPathMeta,
        clipPath.isAcceptableOrUnknown(data['clip_path']!, _clipPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewClip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewClip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      clipStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clip_start_ms'],
      )!,
      clipEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clip_end_ms'],
      )!,
      clipPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clip_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReviewClipsTable createAlias(String alias) {
    return $ReviewClipsTable(attachedDatabase, alias);
  }
}

class ReviewClip extends DataClass implements Insertable<ReviewClip> {
  final String id;
  final String vocabularyId;
  final String videoId;
  final int clipStartMs;
  final int clipEndMs;
  final String? clipPath;
  final int createdAt;
  const ReviewClip({
    required this.id,
    required this.vocabularyId,
    required this.videoId,
    required this.clipStartMs,
    required this.clipEndMs,
    this.clipPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['video_id'] = Variable<String>(videoId);
    map['clip_start_ms'] = Variable<int>(clipStartMs);
    map['clip_end_ms'] = Variable<int>(clipEndMs);
    if (!nullToAbsent || clipPath != null) {
      map['clip_path'] = Variable<String>(clipPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ReviewClipsCompanion toCompanion(bool nullToAbsent) {
    return ReviewClipsCompanion(
      id: Value(id),
      vocabularyId: Value(vocabularyId),
      videoId: Value(videoId),
      clipStartMs: Value(clipStartMs),
      clipEndMs: Value(clipEndMs),
      clipPath: clipPath == null && nullToAbsent
          ? const Value.absent()
          : Value(clipPath),
      createdAt: Value(createdAt),
    );
  }

  factory ReviewClip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewClip(
      id: serializer.fromJson<String>(json['id']),
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      videoId: serializer.fromJson<String>(json['videoId']),
      clipStartMs: serializer.fromJson<int>(json['clipStartMs']),
      clipEndMs: serializer.fromJson<int>(json['clipEndMs']),
      clipPath: serializer.fromJson<String?>(json['clipPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'videoId': serializer.toJson<String>(videoId),
      'clipStartMs': serializer.toJson<int>(clipStartMs),
      'clipEndMs': serializer.toJson<int>(clipEndMs),
      'clipPath': serializer.toJson<String?>(clipPath),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ReviewClip copyWith({
    String? id,
    String? vocabularyId,
    String? videoId,
    int? clipStartMs,
    int? clipEndMs,
    Value<String?> clipPath = const Value.absent(),
    int? createdAt,
  }) => ReviewClip(
    id: id ?? this.id,
    vocabularyId: vocabularyId ?? this.vocabularyId,
    videoId: videoId ?? this.videoId,
    clipStartMs: clipStartMs ?? this.clipStartMs,
    clipEndMs: clipEndMs ?? this.clipEndMs,
    clipPath: clipPath.present ? clipPath.value : this.clipPath,
    createdAt: createdAt ?? this.createdAt,
  );
  ReviewClip copyWithCompanion(ReviewClipsCompanion data) {
    return ReviewClip(
      id: data.id.present ? data.id.value : this.id,
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      clipStartMs: data.clipStartMs.present
          ? data.clipStartMs.value
          : this.clipStartMs,
      clipEndMs: data.clipEndMs.present ? data.clipEndMs.value : this.clipEndMs,
      clipPath: data.clipPath.present ? data.clipPath.value : this.clipPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewClip(')
          ..write('id: $id, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('videoId: $videoId, ')
          ..write('clipStartMs: $clipStartMs, ')
          ..write('clipEndMs: $clipEndMs, ')
          ..write('clipPath: $clipPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabularyId,
    videoId,
    clipStartMs,
    clipEndMs,
    clipPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewClip &&
          other.id == this.id &&
          other.vocabularyId == this.vocabularyId &&
          other.videoId == this.videoId &&
          other.clipStartMs == this.clipStartMs &&
          other.clipEndMs == this.clipEndMs &&
          other.clipPath == this.clipPath &&
          other.createdAt == this.createdAt);
}

class ReviewClipsCompanion extends UpdateCompanion<ReviewClip> {
  final Value<String> id;
  final Value<String> vocabularyId;
  final Value<String> videoId;
  final Value<int> clipStartMs;
  final Value<int> clipEndMs;
  final Value<String?> clipPath;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ReviewClipsCompanion({
    this.id = const Value.absent(),
    this.vocabularyId = const Value.absent(),
    this.videoId = const Value.absent(),
    this.clipStartMs = const Value.absent(),
    this.clipEndMs = const Value.absent(),
    this.clipPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewClipsCompanion.insert({
    required String id,
    required String vocabularyId,
    required String videoId,
    required int clipStartMs,
    required int clipEndMs,
    this.clipPath = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vocabularyId = Value(vocabularyId),
       videoId = Value(videoId),
       clipStartMs = Value(clipStartMs),
       clipEndMs = Value(clipEndMs),
       createdAt = Value(createdAt);
  static Insertable<ReviewClip> custom({
    Expression<String>? id,
    Expression<String>? vocabularyId,
    Expression<String>? videoId,
    Expression<int>? clipStartMs,
    Expression<int>? clipEndMs,
    Expression<String>? clipPath,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (videoId != null) 'video_id': videoId,
      if (clipStartMs != null) 'clip_start_ms': clipStartMs,
      if (clipEndMs != null) 'clip_end_ms': clipEndMs,
      if (clipPath != null) 'clip_path': clipPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewClipsCompanion copyWith({
    Value<String>? id,
    Value<String>? vocabularyId,
    Value<String>? videoId,
    Value<int>? clipStartMs,
    Value<int>? clipEndMs,
    Value<String?>? clipPath,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ReviewClipsCompanion(
      id: id ?? this.id,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      videoId: videoId ?? this.videoId,
      clipStartMs: clipStartMs ?? this.clipStartMs,
      clipEndMs: clipEndMs ?? this.clipEndMs,
      clipPath: clipPath ?? this.clipPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (clipStartMs.present) {
      map['clip_start_ms'] = Variable<int>(clipStartMs.value);
    }
    if (clipEndMs.present) {
      map['clip_end_ms'] = Variable<int>(clipEndMs.value);
    }
    if (clipPath.present) {
      map['clip_path'] = Variable<String>(clipPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewClipsCompanion(')
          ..write('id: $id, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('videoId: $videoId, ')
          ..write('clipStartMs: $clipStartMs, ')
          ..write('clipEndMs: $clipEndMs, ')
          ..write('clipPath: $clipPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideosTable videos = $VideosTable(this);
  late final $SubtitlesTable subtitles = $SubtitlesTable(this);
  late final $VocabularyWordsTable vocabularyWords = $VocabularyWordsTable(
    this,
  );
  late final $ReviewClipsTable reviewClips = $ReviewClipsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    videos,
    subtitles,
    vocabularyWords,
    reviewClips,
    appSettings,
  ];
}

typedef $$VideosTableCreateCompanionBuilder =
    VideosCompanion Function({
      required String id,
      required String title,
      required String filePath,
      Value<String?> subtitlePath,
      Value<String?> thumbnailPath,
      Value<int> durationMs,
      required int addedAt,
      Value<int?> lastPlayedAt,
      Value<int> lastPositionMs,
      Value<int> rowid,
    });
typedef $$VideosTableUpdateCompanionBuilder =
    VideosCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> filePath,
      Value<String?> subtitlePath,
      Value<String?> thumbnailPath,
      Value<int> durationMs,
      Value<int> addedAt,
      Value<int?> lastPlayedAt,
      Value<int> lastPositionMs,
      Value<int> rowid,
    });

class $$VideosTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitlePath => $composableBuilder(
    column: $table.subtitlePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideosTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitlePath => $composableBuilder(
    column: $table.subtitlePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get subtitlePath => $composableBuilder(
    column: $table.subtitlePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => column,
  );
}

class $$VideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideosTable,
          Video,
          $$VideosTableFilterComposer,
          $$VideosTableOrderingComposer,
          $$VideosTableAnnotationComposer,
          $$VideosTableCreateCompanionBuilder,
          $$VideosTableUpdateCompanionBuilder,
          (Video, BaseReferences<_$AppDatabase, $VideosTable, Video>),
          Video,
          PrefetchHooks Function()
        > {
  $$VideosTableTableManager(_$AppDatabase db, $VideosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> subtitlePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion(
                id: id,
                title: title,
                filePath: filePath,
                subtitlePath: subtitlePath,
                thumbnailPath: thumbnailPath,
                durationMs: durationMs,
                addedAt: addedAt,
                lastPlayedAt: lastPlayedAt,
                lastPositionMs: lastPositionMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String filePath,
                Value<String?> subtitlePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required int addedAt,
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion.insert(
                id: id,
                title: title,
                filePath: filePath,
                subtitlePath: subtitlePath,
                thumbnailPath: thumbnailPath,
                durationMs: durationMs,
                addedAt: addedAt,
                lastPlayedAt: lastPlayedAt,
                lastPositionMs: lastPositionMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideosTable,
      Video,
      $$VideosTableFilterComposer,
      $$VideosTableOrderingComposer,
      $$VideosTableAnnotationComposer,
      $$VideosTableCreateCompanionBuilder,
      $$VideosTableUpdateCompanionBuilder,
      (Video, BaseReferences<_$AppDatabase, $VideosTable, Video>),
      Video,
      PrefetchHooks Function()
    >;
typedef $$SubtitlesTableCreateCompanionBuilder =
    SubtitlesCompanion Function({
      Value<int> id,
      required String videoId,
      required int subtitleIndex,
      required int startTimeMs,
      required int endTimeMs,
      required String content,
    });
typedef $$SubtitlesTableUpdateCompanionBuilder =
    SubtitlesCompanion Function({
      Value<int> id,
      Value<String> videoId,
      Value<int> subtitleIndex,
      Value<int> startTimeMs,
      Value<int> endTimeMs,
      Value<String> content,
    });

class $$SubtitlesTableFilterComposer
    extends Composer<_$AppDatabase, $SubtitlesTable> {
  $$SubtitlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtitleIndex => $composableBuilder(
    column: $table.subtitleIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubtitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtitlesTable> {
  $$SubtitlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtitleIndex => $composableBuilder(
    column: $table.subtitleIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubtitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtitlesTable> {
  $$SubtitlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<int> get subtitleIndex => $composableBuilder(
    column: $table.subtitleIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMs =>
      $composableBuilder(column: $table.endTimeMs, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$SubtitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtitlesTable,
          Subtitle,
          $$SubtitlesTableFilterComposer,
          $$SubtitlesTableOrderingComposer,
          $$SubtitlesTableAnnotationComposer,
          $$SubtitlesTableCreateCompanionBuilder,
          $$SubtitlesTableUpdateCompanionBuilder,
          (Subtitle, BaseReferences<_$AppDatabase, $SubtitlesTable, Subtitle>),
          Subtitle,
          PrefetchHooks Function()
        > {
  $$SubtitlesTableTableManager(_$AppDatabase db, $SubtitlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<int> subtitleIndex = const Value.absent(),
                Value<int> startTimeMs = const Value.absent(),
                Value<int> endTimeMs = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => SubtitlesCompanion(
                id: id,
                videoId: videoId,
                subtitleIndex: subtitleIndex,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String videoId,
                required int subtitleIndex,
                required int startTimeMs,
                required int endTimeMs,
                required String content,
              }) => SubtitlesCompanion.insert(
                id: id,
                videoId: videoId,
                subtitleIndex: subtitleIndex,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubtitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtitlesTable,
      Subtitle,
      $$SubtitlesTableFilterComposer,
      $$SubtitlesTableOrderingComposer,
      $$SubtitlesTableAnnotationComposer,
      $$SubtitlesTableCreateCompanionBuilder,
      $$SubtitlesTableUpdateCompanionBuilder,
      (Subtitle, BaseReferences<_$AppDatabase, $SubtitlesTable, Subtitle>),
      Subtitle,
      PrefetchHooks Function()
    >;
typedef $$VocabularyWordsTableCreateCompanionBuilder =
    VocabularyWordsCompanion Function({
      required String id,
      required String word,
      Value<String?> partOfSpeech,
      Value<String?> definition,
      Value<String?> example,
      Value<String?> phonetic,
      Value<String?> audioUrl,
      required String videoId,
      Value<String?> videoTitle,
      required int timestampMs,
      required String contextSentence,
      required int savedAt,
      Value<int?> lastReviewedAt,
      Value<int> reviewCount,
      Value<int> correctCount,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int?> nextReviewAt,
      Value<int> rowid,
    });
typedef $$VocabularyWordsTableUpdateCompanionBuilder =
    VocabularyWordsCompanion Function({
      Value<String> id,
      Value<String> word,
      Value<String?> partOfSpeech,
      Value<String?> definition,
      Value<String?> example,
      Value<String?> phonetic,
      Value<String?> audioUrl,
      Value<String> videoId,
      Value<String?> videoTitle,
      Value<int> timestampMs,
      Value<String> contextSentence,
      Value<int> savedAt,
      Value<int?> lastReviewedAt,
      Value<int> reviewCount,
      Value<int> correctCount,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int?> nextReviewAt,
      Value<int> rowid,
    });

class $$VocabularyWordsTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyWordsTable> {
  $$VocabularyWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoTitle => $composableBuilder(
    column: $table.videoTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabularyWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyWordsTable> {
  $$VocabularyWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoTitle => $composableBuilder(
    column: $table.videoTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyWordsTable> {
  $$VocabularyWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get videoTitle => $composableBuilder(
    column: $table.videoTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );
}

class $$VocabularyWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyWordsTable,
          VocabularyWord,
          $$VocabularyWordsTableFilterComposer,
          $$VocabularyWordsTableOrderingComposer,
          $$VocabularyWordsTableAnnotationComposer,
          $$VocabularyWordsTableCreateCompanionBuilder,
          $$VocabularyWordsTableUpdateCompanionBuilder,
          (
            VocabularyWord,
            BaseReferences<
              _$AppDatabase,
              $VocabularyWordsTable,
              VocabularyWord
            >,
          ),
          VocabularyWord,
          PrefetchHooks Function()
        > {
  $$VocabularyWordsTableTableManager(
    _$AppDatabase db,
    $VocabularyWordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<String?> videoTitle = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<String> contextSentence = const Value.absent(),
                Value<int> savedAt = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabularyWordsCompanion(
                id: id,
                word: word,
                partOfSpeech: partOfSpeech,
                definition: definition,
                example: example,
                phonetic: phonetic,
                audioUrl: audioUrl,
                videoId: videoId,
                videoTitle: videoTitle,
                timestampMs: timestampMs,
                contextSentence: contextSentence,
                savedAt: savedAt,
                lastReviewedAt: lastReviewedAt,
                reviewCount: reviewCount,
                correctCount: correctCount,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                nextReviewAt: nextReviewAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String word,
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                required String videoId,
                Value<String?> videoTitle = const Value.absent(),
                required int timestampMs,
                required String contextSentence,
                required int savedAt,
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabularyWordsCompanion.insert(
                id: id,
                word: word,
                partOfSpeech: partOfSpeech,
                definition: definition,
                example: example,
                phonetic: phonetic,
                audioUrl: audioUrl,
                videoId: videoId,
                videoTitle: videoTitle,
                timestampMs: timestampMs,
                contextSentence: contextSentence,
                savedAt: savedAt,
                lastReviewedAt: lastReviewedAt,
                reviewCount: reviewCount,
                correctCount: correctCount,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                nextReviewAt: nextReviewAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabularyWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyWordsTable,
      VocabularyWord,
      $$VocabularyWordsTableFilterComposer,
      $$VocabularyWordsTableOrderingComposer,
      $$VocabularyWordsTableAnnotationComposer,
      $$VocabularyWordsTableCreateCompanionBuilder,
      $$VocabularyWordsTableUpdateCompanionBuilder,
      (
        VocabularyWord,
        BaseReferences<_$AppDatabase, $VocabularyWordsTable, VocabularyWord>,
      ),
      VocabularyWord,
      PrefetchHooks Function()
    >;
typedef $$ReviewClipsTableCreateCompanionBuilder =
    ReviewClipsCompanion Function({
      required String id,
      required String vocabularyId,
      required String videoId,
      required int clipStartMs,
      required int clipEndMs,
      Value<String?> clipPath,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ReviewClipsTableUpdateCompanionBuilder =
    ReviewClipsCompanion Function({
      Value<String> id,
      Value<String> vocabularyId,
      Value<String> videoId,
      Value<int> clipStartMs,
      Value<int> clipEndMs,
      Value<String?> clipPath,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$ReviewClipsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewClipsTable> {
  $$ReviewClipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vocabularyId => $composableBuilder(
    column: $table.vocabularyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clipStartMs => $composableBuilder(
    column: $table.clipStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clipEndMs => $composableBuilder(
    column: $table.clipEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clipPath => $composableBuilder(
    column: $table.clipPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewClipsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewClipsTable> {
  $$ReviewClipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vocabularyId => $composableBuilder(
    column: $table.vocabularyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clipStartMs => $composableBuilder(
    column: $table.clipStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clipEndMs => $composableBuilder(
    column: $table.clipEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clipPath => $composableBuilder(
    column: $table.clipPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewClipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewClipsTable> {
  $$ReviewClipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vocabularyId => $composableBuilder(
    column: $table.vocabularyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<int> get clipStartMs => $composableBuilder(
    column: $table.clipStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clipEndMs =>
      $composableBuilder(column: $table.clipEndMs, builder: (column) => column);

  GeneratedColumn<String> get clipPath =>
      $composableBuilder(column: $table.clipPath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReviewClipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewClipsTable,
          ReviewClip,
          $$ReviewClipsTableFilterComposer,
          $$ReviewClipsTableOrderingComposer,
          $$ReviewClipsTableAnnotationComposer,
          $$ReviewClipsTableCreateCompanionBuilder,
          $$ReviewClipsTableUpdateCompanionBuilder,
          (
            ReviewClip,
            BaseReferences<_$AppDatabase, $ReviewClipsTable, ReviewClip>,
          ),
          ReviewClip,
          PrefetchHooks Function()
        > {
  $$ReviewClipsTableTableManager(_$AppDatabase db, $ReviewClipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewClipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewClipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewClipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vocabularyId = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<int> clipStartMs = const Value.absent(),
                Value<int> clipEndMs = const Value.absent(),
                Value<String?> clipPath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewClipsCompanion(
                id: id,
                vocabularyId: vocabularyId,
                videoId: videoId,
                clipStartMs: clipStartMs,
                clipEndMs: clipEndMs,
                clipPath: clipPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vocabularyId,
                required String videoId,
                required int clipStartMs,
                required int clipEndMs,
                Value<String?> clipPath = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReviewClipsCompanion.insert(
                id: id,
                vocabularyId: vocabularyId,
                videoId: videoId,
                clipStartMs: clipStartMs,
                clipEndMs: clipEndMs,
                clipPath: clipPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewClipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewClipsTable,
      ReviewClip,
      $$ReviewClipsTableFilterComposer,
      $$ReviewClipsTableOrderingComposer,
      $$ReviewClipsTableAnnotationComposer,
      $$ReviewClipsTableCreateCompanionBuilder,
      $$ReviewClipsTableUpdateCompanionBuilder,
      (
        ReviewClip,
        BaseReferences<_$AppDatabase, $ReviewClipsTable, ReviewClip>,
      ),
      ReviewClip,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db, _db.videos);
  $$SubtitlesTableTableManager get subtitles =>
      $$SubtitlesTableTableManager(_db, _db.subtitles);
  $$VocabularyWordsTableTableManager get vocabularyWords =>
      $$VocabularyWordsTableTableManager(_db, _db.vocabularyWords);
  $$ReviewClipsTableTableManager get reviewClips =>
      $$ReviewClipsTableTableManager(_db, _db.reviewClips);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
