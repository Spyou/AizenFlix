class EpisodeListModel {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  String? nextPageUrl;
  Null prevPageUrl;
  int? from;
  int? to;
  List<Data>? data;

  EpisodeListModel({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
    this.data,
  });

  EpisodeListModel.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    nextPageUrl = json['next_page_url'];
    prevPageUrl = json['prev_page_url'];
    from = json['from'];
    to = json['to'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['per_page'] = perPage;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['next_page_url'] = nextPageUrl;
    data['prev_page_url'] = prevPageUrl;
    data['from'] = from;
    data['to'] = to;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? animeId;
  int? episode;
  int? episode2;
  String? edition;
  String? title;
  String? snapshot;
  String? disc;
  String? audio;
  String? duration;
  String? session;
  int? filler;
  String? createdAt;

  Data({
    this.id,
    this.animeId,
    this.episode,
    this.episode2,
    this.edition,
    this.title,
    this.snapshot,
    this.disc,
    this.audio,
    this.duration,
    this.session,
    this.filler,
    this.createdAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    animeId = json['anime_id'];
    episode = json['episode'];
    episode2 = json['episode2'];
    edition = json['edition'];
    title = json['title'];
    snapshot = json['snapshot'];
    disc = json['disc'];
    audio = json['audio'];
    duration = json['duration'];
    session = json['session'];
    filler = json['filler'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['anime_id'] = animeId;
    data['episode'] = episode;
    data['episode2'] = episode2;
    data['edition'] = edition;
    data['title'] = title;
    data['snapshot'] = snapshot;
    data['disc'] = disc;
    data['audio'] = audio;
    data['duration'] = duration;
    data['session'] = session;
    data['filler'] = filler;
    data['created_at'] = createdAt;
    return data;
  }
}
