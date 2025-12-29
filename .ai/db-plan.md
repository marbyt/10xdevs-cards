10xCards Database Schema

1\. Tabele

1.1. users

This table is managed by Supabase Auth.



id: UUID PRIMARY KEY

email: VARCHAR(255) NOT NULL UNIQUE

encrypted\_password: VARCHAR NOT NULL

created\_at: TIMESTAMPTZ NOT NULL DEFAULT now()

confirmed\_at: TIMESTAMPTZ

1.2. flashcards

id: BIGSERIAL PRIMARY KEY

front: VARCHAR(200) NOT NULL

back: VARCHAR(500) NOT NULL

source: VARCHAR NOT NULL CHECK (source IN ('ai-full', 'ai-edited', 'manual'))

created\_at: TIMESTAMPTZ NOT NULL DEFAULT now()

updated\_at: TIMESTAMPTZ NOT NULL DEFAULT now()

generation\_id: BIGINT REFERENCES generations(id) ON DELETE SET NULL

user\_id: UUID NOT NULL REFERENCES users(id)

Trigger: Automatically update the updated\_at column on record updates.



1.3. generations

id: BIGSERIAL PRIMARY KEY

user\_id: UUID NOT NULL REFERENCES users(id)

model: VARCHAR NOT NULL

generated\_count: INTEGER NOT NULL

accepted\_unedited\_count: INTEGER NULLABLE

accepted\_edited\_count: INTEGER NULLABLE

source\_text\_hash: VARCHAR NOT NULL

source\_text\_length: INTEGER NOT NULL CHECK (source\_text\_length BETWEEN 1000 AND 10000)

generation\_duration: INTEGER NOT NULL

created\_at: TIMESTAMPTZ NOT NULL DEFAULT now()

updated\_at: TIMESTAMPTZ NOT NULL DEFAULT now()

1.4. generation\_error\_logs

id: BIGSERIAL PRIMARY KEY

user\_id: UUID NOT NULL REFERENCES users(id)

model: VARCHAR NOT NULL

source\_text\_hash: VARCHAR NOT NULL

source\_text\_length: INTEGER NOT NULL CHECK (source\_text\_length BETWEEN 1000 AND 10000)

error\_code: VARCHAR(100) NOT NULL

error\_message: TEXT NOT NULL

created\_at: TIMESTAMPTZ NOT NULL DEFAULT now()

2\. Relacje

Jeden użytkownik (users) ma wiele fiszek (flashcards).

Jeden użytkownik (users) ma wiele rekordów w tabeli generations.

Jeden użytkownik (users) ma wiele rekordów w tabeli generation\_error\_logs.

Każda fiszka (flashcards) może opcjonalnie odnosić się do jednej generacji (generations) poprzez generation\_id.

3\. Indeksy

Indeks na kolumnie user\_id w tabeli flashcards.

Indeks na kolumnie generation\_id w tabeli flashcards.

Indeks na kolumnie user\_id w tabeli generations.

Indeks na kolumnie user\_id w tabeli generation\_error\_logs.

4\. Zasady RLS (Row-Level Security)

W tabelach flashcards, generations oraz generation\_error\_logs wdrożyć polityki RLS, które pozwalają użytkownikowi na dostęp tylko do rekordów, gdzie user\_id odpowiada identyfikatorowi użytkownika z Supabase Auth (np. auth.uid() = user\_id).

5\. Dodatkowe uwagi

Trigger w tabeli flashcards ma automatycznie aktualizować kolumnę updated\_at przy każdej modyfikacji rekordu.

