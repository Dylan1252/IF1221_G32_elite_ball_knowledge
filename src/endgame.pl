% ============================================================
%  RESET DATA
% ============================================================
 
hapus_data :-
    retractall(pemain(_)),
    retractall(urutan_pemain(_)),
    retractall(kartu_di_tangan(_, _)),
    retractall(discard_top(_)),
    retractall(giliran_sekarang(_)),
    retractall(deck_kartu(_)),
    retractall(arah_giliran(_)),
    retractall(warna_aktif(_)),
    retractall(efek_pending(_)),
    retractall(pemain_wdf(_)),
    retractall(status_uni(_)).
 
% ============================================================
%  INPUT PEMAIN
% ============================================================
 
minta_jumlah(Jumlah) :-
    write('Masukkan jumlah pemain: '),
    read(Input),
    ( (Input >= 2, Input =< 4)
        ->  Jumlah = Input
        ;   write('Mohon masukkan angka antara 2-4.'), nl,
            minta_jumlah(Jumlah)
    ).
 
input_pemain(N, Max, [NamaAsli|Rest]) :-
    N =< Max,
    format('Masukkan nama pemain ~w: ', [N]),
    read(NamaAsli),
    ( pemain(NamaAsli) ->
        write('Nama sudah digunakan. Masukkan nama lain: '), nl,
        input_pemain(N, Max, [NamaAsli|Rest])
    ;
        assertz(pemain(NamaAsli)),
        N1 is N + 1,
        input_pemain(N1, Max, Rest)
    ).
input_pemain(_, _, []).
 
acak_pemain(ListPemain, UrutanAcak) :-
    acak_list(ListPemain, UrutanAcak),
    write('Urutan pemain: '),
    tampilkan_list(UrutanAcak),
    assertz(urutan_pemain(UrutanAcak)).
 
% ============================================================
%  START GAME
% ============================================================
 
startGame :-
    hapus_data,
 
    minta_jumlah(Jumlah),
    input_pemain(1, Jumlah, ListPemain),
    acak_pemain(ListPemain, UrutanAcak), nl,
 
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,
 
    buat_deck(DeckAsli),
    acak_deck(DeckAsli, DeckAcak),
    bagi_kartu(UrutanAcak, DeckAcak, SisaDeckSetelahBagikan),
    init_discard_pile(SisaDeckSetelahBagikan, KartuAwal, SisaDeckFinal),
    assertz(discard_top(KartuAwal)),
    assertz(deck_kartu(SisaDeckFinal)),
    assertz(arah_giliran(kanan)),
    KartuAwal = kartu(WarnaAwal, _),
    assertz(warna_aktif(WarnaAwal)),
    UrutanAcak = [PemainPertama|_],
    assertz(giliran_sekarang(PemainPertama)), nl,
    write('Kartu discard top: '), tulis_kartu(KartuAwal), write('.'), nl,
    write('Giliran '), write(PemainPertama), write('.'), nl.
 
% ============================================================
%  END GAME
% ============================================================
 
nilai_kartu(kartu(_, N), N) :- angka(N), !.
nilai_kartu(kartu(_, skip),          10) :- !.
nilai_kartu(kartu(_, reverse),       10) :- !.
nilai_kartu(kartu(_, draw_two),      10) :- !.
nilai_kartu(kartu(hitam, wild),      20) :- !.
nilai_kartu(kartu(hitam, wild_draw_four), 20) :- !.
 
hitung_poin([], 0).
hitung_poin([K|T], Total) :-
    nilai_kartu(K, P),
    hitung_poin(T, Sisa),
    Total is P + Sisa.
 
tulis_detail_poin([]).
tulis_detail_poin([K]) :- tulis_kartu(K).
tulis_detail_poin([K|T]) :-
    tulis_kartu(K), write(' + '),
    tulis_detail_poin(T).
 
cetak_poin_pemain([]).
cetak_poin_pemain([P|Rest]) :-
    kartu_di_tangan(P, Kartu),
    ( Kartu = []
        ->  format('~w: kartu habis = 0 poin~n', [P])
        ;   format('~w: ', [P]),
            tulis_detail_poin(Kartu),
            hitung_poin(Kartu, Total),
            format(' = ~w poin~n', [Total])
    ),
    cetak_poin_pemain(Rest).
 
buat_poin_list([], []).
buat_poin_list([P|Rest], [Poin-P|T]) :-
    kartu_di_tangan(P, K),
    hitung_poin(K, Poin),
    buat_poin_list(Rest, T).
 
cetak_peringkat([], _).
cetak_peringkat([_Poin-P|T], No) :-
    kartu_di_tangan(P, K),
    hitung_poin(K, Poin),
    format('~w. ~w (~w poin)~n', [No, P, Poin]),
    No1 is No + 1,
    cetak_peringkat(T, No1).
 
endGame :-
    urutan_pemain(Urutan),
    nl, write('=== PERMAINAN SELESAI ==='), nl,
    ( member(Pemenang, Urutan), kartu_di_tangan(Pemenang, []) -> true ; true ),
    format('~w menghabiskan semua kartunya!~n~n', [Pemenang]),
    write('Berikut perhitungan poin sisa kartu.'), nl,
    cetak_poin_pemain(Urutan), nl,
    buat_poin_list(Urutan, PoinList),
    msort(PoinList, PoinSort),
    write('Urutan pemenang:'), nl,
    cetak_peringkat(PoinSort, 1), nl,
    PoinSort = [_-Juara|_],
    format('Selamat, ~w menjadi pemenang!~n', [Juara]).
 
