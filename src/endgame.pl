% ============================================================
%  HITUNG NILAI KARTU
% ============================================================

nilai_kartu(kartu(_, N), N) :-
    angka(N), !.

nilai_kartu(kartu(_, skip), 10) :- !.

nilai_kartu(kartu(_, reverse), 10) :- !.

nilai_kartu(kartu(_, draw_two), 10) :- !.

nilai_kartu(kartu(hitam, wild), 20) :- !.

nilai_kartu(
    kartu(hitam, wild_draw_four),
    20
) :- !.

% ============================================================
%  HITUNG POIN
% ============================================================

hitung_poin([], 0).

hitung_poin([K|T], Total) :-

    nilai_kartu(K, P),

    hitung_poin(T, Sisa),

    Total is P + Sisa.

% ============================================================
%  TULIS DETAIL POIN
% ============================================================

tulis_detail_poin([]).

tulis_detail_poin([K]) :-
    tulis_kartu(K).

tulis_detail_poin([K|T]) :-

    tulis_kartu(K),

    write(' + '),

    tulis_detail_poin(T).

% ============================================================
%  CETAK POIN
% ============================================================

cetak_poin_pemain([]).

cetak_poin_pemain([P|Rest]) :-

    kartu_di_tangan(P, Kartu),

    (
        Kartu = []

        ->

        format(
            '~w: kartu habis = 0 poin~n',
            [P]
        )

        ;

        format('~w: ', [P]),

        tulis_detail_poin(Kartu),

        hitung_poin(Kartu, Total),

        format(
            ' = ~w poin~n',
            [Total]
        )
    ),

    cetak_poin_pemain(Rest).

% ============================================================
%  RANKING
% ============================================================

buat_poin_list([], []).

buat_poin_list(
    [P|Rest],
    [Poin-P|T]
) :-

    kartu_di_tangan(P, K),

    hitung_poin(K, Poin),

    buat_poin_list(Rest, T).

cetak_peringkat([], _).

cetak_peringkat(
    [_Poin-P|T],
    No
) :-

    kartu_di_tangan(P, K),

    hitung_poin(K, Poin),

    format(
        '~w. ~w (~w poin)~n',
        [No, P, Poin]
    ),

    No1 is No + 1,

    cetak_peringkat(T, No1).

% ============================================================
%  END GAME
% ============================================================

endGame :-

    urutan_pemain(Urutan),

    nl,

    write(
        '=== PERMAINAN SELESAI ==='
    ),
    nl,

    (
        member(Pemenang, Urutan),

        kartu_di_tangan(Pemenang, [])

        -> true

        ;

        true
    ),

    format(
        '~w menghabiskan semua kartunya!~n~n',
        [Pemenang]
    ),

    write(
        'Berikut perhitungan poin sisa kartu.'
    ),
    nl,

    cetak_poin_pemain(Urutan),

    nl,

    buat_poin_list(
        Urutan,
        PoinList
    ),

    msort(PoinList, PoinSort),

    write('Urutan pemenang:'), nl,

    cetak_peringkat(
        PoinSort,
        1
    ),

    nl,

    PoinSort = [_-Juara|_],

    format(
        'Selamat, ~w menjadi pemenang!~n',
        [Juara]
    ).