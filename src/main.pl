:- consult('fakta.pl').
:- consult('util.pl').
:- consult('deck.pl').
:- consult('turn.pl').
:- consult('aksi.pl').
:- consult('support.pl').
:- consult('endgame.pl').

:- initialization(startGame).

startGame :-
    hapus_data,

    input_jumlah(Jumlah),
    input_pemain(1, Jumlah, ListPemain),
    acak_pemain(ListPemain, UrutanAcak), nl,

    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,

    buat_deck(DeckAsli),
    acak_deck(DeckAsli, DeckAcak),
    bagi_kartu(UrutanAcak, DeckAcak, SisaDeckSetelahBagikan),

    init_discard_pile(
        SisaDeckSetelahBagikan,
        KartuAwal,
        SisaDeckFinal
    ),

    assertz(discard_top(KartuAwal)),
    assertz(deck_kartu(SisaDeckFinal)),
    assertz(arah_giliran(kanan)),

    KartuAwal = kartu(WarnaAwal, _),
    assertz(warna_aktif(WarnaAwal)),

    UrutanAcak = [PemainPertama|_],
    assertz(giliran_sekarang(PemainPertama)), nl,

    write('Kartu discard top: '),
    tulis_kartu(KartuAwal),
    write('.'), nl,

    write('Giliran '),
    write(PemainPertama),
    write('.'), nl.