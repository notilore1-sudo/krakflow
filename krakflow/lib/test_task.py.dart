import 'dart:convert';

void main() {
  print("--- Zadanie 1A ---");
  zadanieA();

  print("\n--- Zadanie 1B ---");
  zadanieB();

  print("\n--- Zadanie 1C ---");
  zadanieC();
}

// A
void zadanieA() {
  String jsonText = '[1, 5, 8, 3, 2]';
  final List<dynamic> lista = jsonDecode(jsonText);

  int suma = 0;
  for (var liczba in lista) {
    suma += liczba as int;
  }

  print("Liczby: $lista");
  print("Suma: $suma");
}

// B
void zadanieB() {
  String jsonText = '{"group": "Dart", "students": ["Ola", "Adam", "Kasia"]}';
  final data = jsonDecode(jsonText);

  print("Nazwa grupy: ${data["group"]}");

  List<dynamic> students = data["students"];
  print("Studenci: ${students.join(", ")}");
}

// C
void zadanieC() {
  String jsonText = '{"product": {"name": "Laptop", "price": 3500}}';
  final data = jsonDecode(jsonText);

  print("Produkt: ${data["product"]["name"]}");
  print("Cena: ${data["product"]["price"]}");
}