SQL-like Bash CLI for CSV
Lekki interfejs wiersza poleceń (CLI) napisany w Bashu, który umożliwia wykonywanie operacji typu CRUD (Create, Read, Update, Delete) bezpośrednio na plikach CSV przy użyciu składni inspirowanej językiem SQL.

Narzędzie idealnie nadaje się do szybkiej analizy danych, gdzie pełna baza danych byłaby zbyt ciężkim rozwiązaniem, a standardowe narzędzia tekstowe wymagają zbyt skomplikowanych komend.

🛠️ Podstawowe technologie
Projekt opiera się na klasycznym stosie narzędzi Unixowych do przetwarzania strumieniowego:

AWK: Wykorzystywany do zaawansowanej filtracji, operacji na kolumnach i logiki warunkowej.

Sed: Służy do transformacji tekstu i edycji plików "w miejscu".

Grep: Szybkie wyszukiwanie wzorców i filtrowanie rekordów.

csvkit: Zapewnia poprawną obsługę formatu CSV (np. nagłówki, parsowanie danych).

🚀 Funkcje i składnia
Narzędzie imituje standardowe zapytania SQL, przekładając je na wydajne potoki (pipelines) w Bashu.

Wspierane operacje (CRUD):

SELECT: Wybieranie konkretnych kolumn z pliku.

INSERT: Dodawanie nowych rekordów do pliku CSV.

UPDATE: Modyfikacja istniejących wierszy spełniających określone warunki.

DELETE: Usuwanie rekordów na podstawie filtrów.

Klauzule i modyfikatory:

Klauzula warunkowa (WHERE): Filtrowanie danych przy użyciu operatorów porównania.

SORT (ORDER BY): Sortowanie wyników według wskazanej kolumny (alfabetycznie lub numerycznie).

LIMIT: Ograniczenie liczby zwracanych rekordów.
