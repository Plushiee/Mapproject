// place_data.dart

class PlaceData {
  String nama;
  String kategori;
  String keterangan;
  double lat;
  double lng;
  String jamBuka;
  String jamTutup;

  PlaceData({
    required this.nama,
    required this.kategori,
    required this.keterangan,
    this.lat = 0.0,
    this.lng = 0.0,
    required this.jamBuka,
    required this.jamTutup,
  });
}
