% ----- Pengacakan List -----
 
acak_list([], []) :- !.
acak_list(List, [X|Rest]) :-
    length(List, Len),
    random(R),
    Idx is truncate(R * Len),
    N is Idx + 1,
    ambil_ke(N, List, X, Sisa),
    acak_list(Sisa, Rest).
 
% ----- Konstruksi Deck -----
 
buat_angka_satu_warna(_, [], []).
buat_angka_satu_warna(W, [A|As], [kartu(W,A)|Rest]) :-
    buat_angka_satu_warna(W, As, Rest).
 
buat_kartu_angka([], _, []).
buat_kartu_angka([W|Ws], Angkas, Hasil) :-
    buat_angka_satu_warna(W, Angkas, KartuW),
    buat_kartu_angka(Ws, Angkas, KartuRest),
    append(KartuW, KartuRest, Hasil).
 
buat_aksi_warna([], _, []).
buat_aksi_warna([W|Ws], Jenis, [kartu(W,Jenis)|Rest]) :-
    buat_aksi_warna(Ws, Jenis, Rest).
 
buat_wild(0, _, []) :- !.
buat_wild(N, Jenis, [kartu(hitam,Jenis)|Rest]) :-
    N > 0,
    N1 is N - 1,
    buat_wild(N1, Jenis, Rest).
 
buat_deck(Deck) :-
    semua_warna(Warnas),
    semua_angka(Angkas),
    buat_kartu_angka(Warnas, Angkas, KartuAngka),
    buat_aksi_warna(Warnas, skip,       KartuSkip),
    buat_aksi_warna(Warnas, reverse,    KartuReverse),
    buat_aksi_warna(Warnas, draw_two,   KartuDrawTwo),
    buat_wild(4, wild,           KartuWild),
    buat_wild(4, wild_draw_four, KartuWDF),
    append(KartuAngka,  KartuSkip,     D1),
    append(D1,          KartuReverse,  D2),
    append(D2,          KartuDrawTwo,  D3),
    append(D3,          KartuWild,     D4),
    append(D4,          KartuWDF,      Deck).
 
acak_deck(DeckAsli, DeckAcak) :-
    acak_list(DeckAsli, DeckAcak).
 
% ----- Pengambilan Kartu dari Deck -----
 
ambil_kartu_dari_deck(1, [Kartu|Sisa], Kartu, Sisa) :- !.
ambil_kartu_dari_deck(N, [Kartu|Sisa], KartuAmbil, [Kartu|DeckSisa]) :-
    N > 1,
    N1 is N - 1,
    ambil_kartu_dari_deck(N1, Sisa, KartuAmbil, DeckSisa).
 
ambil_kartu_acak_dari_deck(Deck, Kartu, SisaDeck) :-
    length(Deck, L),
    random(R),
    N is truncate(R * L) + 1,
    ambil_kartu_dari_deck(N, Deck, Kartu, SisaDeck).
 
% ----- Pembagian Kartu ke Pemain -----
 
bagi_kartu([], Deck, Deck).
bagi_kartu([Pemain|PemainLain], Deck, DeckSisa) :-
    ambil_sejumlah_kartu(Deck, 7, KartuPemain, DeckAfter),
    assertz(kartu_di_tangan(Pemain, KartuPemain)),
    bagi_kartu(PemainLain, DeckAfter, DeckSisa).
 
ambil_sejumlah_kartu(Deck, 0, [], Deck) :- !.
ambil_sejumlah_kartu(Deck, N, [Kartu|KartuLain], DeckSisa) :-
    N > 0,
    ambil_kartu_acak_dari_deck(Deck, Kartu, DeckAfter),
    N1 is N - 1,
    ambil_sejumlah_kartu(DeckAfter, N1, KartuLain, DeckSisa).
 
% Pastikan kartu awal discard pile adalah kartu angka
kartu_angka_valid(kartu(_, Angka)) :- angka(Angka).
 
init_discard_pile(Deck, KartuAwal, SisaDeck) :-
    ambil_kartu_acak_dari_deck(Deck, Kartu, DeckSisa),
    ( kartu_angka_valid(Kartu)
        ->  KartuAwal = Kartu,
            SisaDeck  = DeckSisa
        ;   init_discard_pile(DeckSisa, KartuAwal, SisaDeck)
    ).
 
% ----- Ambil N Kartu untuk Satu Pemain (dari Dynamic Deck) -----
 
ambil_n_kartu_untuk(_, 0) :- !.
ambil_n_kartu_untuk(Pemain, N) :-
    N > 0,
    deck_kartu(Deck),
    ambil_kartu_acak_dari_deck(Deck, Kartu, SisaDeck),
    retract(deck_kartu(Deck)),
    assertz(deck_kartu(SisaDeck)),
    kartu_di_tangan(Pemain, KartuLama),
    retract(kartu_di_tangan(Pemain, KartuLama)),
    append(KartuLama, [Kartu], KartuBaru),
    assertz(kartu_di_tangan(Pemain, KartuBaru)),
    N1 is N - 1,
    ambil_n_kartu_untuk(Pemain, N1).
